`timescale 1ns / 1ps

module miriscv_core (
input             clk_i,//
  input             stall_i,
  input             arstn_i,//
  //inst
  input  [ 31 : 0 ] instr_rdata_i,//
  output [ 31 : 0 ] instr_addr_o,//
  //lsu
  input  [ 31 : 0 ] data_rdata_i,
  output [ 31 : 0 ] data_addr_o,//
  output [  2 : 0 ] data_be_o,//
  output            data_req_o,//
  output            data_we_o,//
  output [ 31 : 0 ] data_wdata_o//
);
  logic [ 31 : 0 ] imm_I,imm_U,imm_S,imm_B,imm_J;
  logic [ 31 : 0 ] RD1,RD2;
  logic [ 31 : 0 ] res_alu;
  logic [ 31 : 0 ] branch_o;       
  logic [ 31 : 0 ] PC_add,PC_sum; 
  logic [ 31 : 0 ] PC_imm;
  logic [ 31 : 0 ] PC,PC_per; 
  logic [ 31 : 0 ] wb_data;
  logic [ 4  : 0 ] operation;
  logic [ 31 : 0 ] alu_input_1, alu_input_2;
  logic [ 1  : 0 ] a_sel;
  logic [ 2  : 0 ] b_sel;
  logic            flag;
  logic            wb_sel;
  logic            branch;
  logic            jal,jalr;
  assign data_addr_o  = res_alu;
  assign data_wdata_o     = RD2;
  assign instr_addr_o = PC;
  assign PC_sum       = PC_add + PC;
  assign imm_I  = { {20{ instr_rdata_i[31] }}, instr_rdata_i[31:20]                                                     };
  assign imm_U  = { instr_rdata_i[31:12]     , { 12{ 1'b0 } }                                                     };
  assign imm_S  = { {20{ instr_rdata_i[31] }}, instr_rdata_i[31:25], instr_rdata_i[11: 7]                                     };  
  assign imm_B  = { {20{ instr_rdata_i[31] }}, instr_rdata_i[ 7   ], instr_rdata_i[30:25], instr_rdata_i[11:8] , 1'b0               };
  assign imm_J  = { {10{ instr_rdata_i[31] }}, instr_rdata_i[ 31  ], instr_rdata_i[19:12], instr_rdata_i[20]   , instr_rdata_i[31:21],1'b0};
  assign PC_imm = imm_I + RD1;

  rf_riscv rg(                                    // register module
    .read_addr2_i   ( instr_rdata_i[24:20] ),
    .read_addr1_i   ( instr_rdata_i[19:15] ),
    .write_addr_i   ( instr_rdata_i[11:7]  ),
    .write_data_i   ( wb_data        ),
    .write_enable_i ( gpr_we         ),
    .clk_i          ( clk_i          ),
    .read_data1_o   ( RD1            ), 
    .read_data2_o   ( RD2            )
  );

  alu_riscv alu(                                  // alu module
    .a_i      ( alu_input_1 ),
    .b_i      ( alu_input_2 ),                       
    .alu_op_i ( operation   ), 
    .result_o ( res_alu     ),
    .flag_o   ( flag        )
  );

  decoder_riscv der(                              // decoder module
    .fetched_instr_i  ( instr_rdata_i ),
    .mem_req_o        ( data_req_o ),   
    .mem_size_o       ( data_be_o  ),  
    .alu_op_o         ( operation  ),
    .mem_we_o         ( data_we_o  ),            
    .wb_src_sel_o     ( wb_sel     ), 
    .gpr_we_a_o       ( gpr_we     ),  
    .branch_o         ( branch     ),
    .a_sel_o          ( a_sel      ),
    .b_sel_o          ( b_sel      ),   
    .jalr_o           ( jalr       ),
    .jal_o            ( jal        ),
    .illegal_instr_o  (            )// without connection 
  );

  always_comb begin                               // b_sel multiplexer 
    case (b_sel)
      0: alu_input_2 <= RD2;
      1: alu_input_2 <= imm_I;
      2: alu_input_2 <= imm_U;
      3: alu_input_2 <= imm_S;  
      4: alu_input_2 <= 3'd4;
    endcase    
  end

  always_comb begin                               // a_sel multiplexer 
    case (a_sel)
      0:alu_input_1 <= RD1;
      1:alu_input_1 <= PC;
      2:alu_input_1 <= 32'b0; 
    endcase
  end

  always_comb begin                               //sel alu or data_rdata_i
    case (wb_sel)
      0: wb_data <= res_alu;
      1: wb_data <= data_rdata_i;
    endcase
  end

  always_comb begin                               // branch multiplexer
    case (branch)
      1: branch_o <= imm_B;
      0: branch_o <= imm_J;
    endcase
  end

  always_comb begin                               // PC + branch or 4 multiplexer
    case (jal || (flag && branch))                   
      1: PC_add <= branch_o;
      0: PC_add <= 3'd4;
    endcase
  end

  always_comb begin                               // PC multiplexer
    case (jalr)                   
      1: PC_per <= PC_imm;
      0: PC_per <= PC_sum;
    endcase
  end
  
  always_ff @(posedge clk_i or posedge arstn_i) begin                 // PC stall and reset unit
    if(!arstn_i)
        PC <= 0;
    else begin
      if(!stall_i)
        PC <= PC_per;
    end
  end

endmodule
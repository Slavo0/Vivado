`timescale 1ns / 1ps
`include "C:/Users/97ras/Documents/Vivado/LABA_5/Files/riscv_pkg.sv"
`include "C:/Users/97ras/Documents/Vivado/LABA_5/Files/alu_opcodes_pkg.sv"

import riscv_pkg::*;
import alu_opcodes_pkg::*;

module decoder_riscv (
  input  logic [31:0]  fetched_instr_i,
  output logic [ 1:0]  a_sel_o,
  output logic [ 2:0]  b_sel_o,
  output logic [ 4:0]  alu_op_o,
  output logic         mem_req_o,//
  output logic         mem_we_o,//
  output logic [ 2:0]  mem_size_o,//
  output logic         gpr_we_a_o,//
  output logic         illegal_instr_o,//
  output logic         branch_o,//
  output logic         jal_o,//
  output logic         jalr_o,//
  output logic         stall_i,
  output logic         mret_o,//
  output logic [ 2:0]  csr_op_o,
  output logic         csr_we_o,
  output logic [ 1:0]  wb_src_sel_o
);
  logic [ 2 : 0 ] funk3 ;
  logic [ 6 : 0 ] funk7 ;
  logic [ 6 : 0 ] opcode;
  logic [ 9 : 0 ] sum;

  assign opcode =  fetched_instr_i[  6 :  0 ];
  assign funk3  =  fetched_instr_i[ 14 : 12 ];
  assign funk7  =  fetched_instr_i[ 31 : 25 ];

  assign sum = {funk7,funk3};

  always_comb begin
    alu_op_o        = 5'd0;
    wb_src_sel_o    = 2'd0;
    mem_req_o       = 1'd0;
    mem_we_o        = 1'd0;
    branch_o        = 1'd0; 
    jal_o           = 1'd0; 
    jalr_o          = 1'd0;
    illegal_instr_o = 1'd0;      
    gpr_we_a_o      = 1'b0;
    mem_size_o      = 3'b0;
    mret_o          = 1'b0;
    csr_we_o        = 1'b0;
    csr_op_o        = 3'b0;

    if( opcode[1:0] == 2'b11) begin
      case (opcode[6:2])
        LOAD_OPCODE     : begin
                            a_sel_o      <= 2'd0;
                            b_sel_o      <= 3'd1;
                            alu_op_o     <= ALU_ADD;
                            wb_src_sel_o <= 2'b1;
                            case (funk3)
                              LDST_B: 
                                begin  
                                  mem_size_o <= LDST_B;
                                  gpr_we_a_o <= 1'b1;
                                  mem_req_o  <= 1'b1;
                                end
                              LDST_H: 
                                begin  
                                  mem_size_o <= LDST_H;
                                  gpr_we_a_o <= 1'b1;
                                  mem_req_o  <= 1'b1;
                                end
                              LDST_W: 
                                begin  
                                  mem_size_o <= LDST_W;
                                  gpr_we_a_o <= 1'b1;
                                  mem_req_o  <= 1'b1;
                                end
                              LDST_BU: 
                                begin  
                                  mem_size_o <= LDST_BU;
                                  gpr_we_a_o <= 1'b1;
                                  mem_req_o  <= 1'b1;
                                end
                              LDST_HU: 
                                begin  
                                  mem_size_o <= LDST_HU;
                                  gpr_we_a_o <= 1'b1;
                                  mem_req_o  <= 1'b1;
                                end
                              default: illegal_instr_o <= 1'd1; 
                            endcase
                          end
        OP_IMM_OPCODE   : begin
                            a_sel_o    <= 2'd0;
                            b_sel_o    <= 3'd1;
                            case (funk3)
                              3'd0:
                                  begin
                                    alu_op_o   <= ALU_ADD;
                                    gpr_we_a_o <= 1'd1;
                                  end
                              3'b001:
                                  begin
                                    case (funk7)
                                      7'd0:
                                        begin
                                          alu_op_o   <= ALU_SLL;
                                          gpr_we_a_o <= 1'd1;  
                                        end 
                                      default: illegal_instr_o <= 1'd1;
                                    endcase                 
                                  end                                
                              3'd2:
                                  begin
                                    alu_op_o   <= ALU_SLTS;
                                    gpr_we_a_o <= 1'd1;
                                  end   
                              3'd3:
                                  begin
                                    alu_op_o   <= ALU_SLTU;
                                    gpr_we_a_o <= 1'd1;
                                  end   
                              3'd4:
                                  begin
                                    alu_op_o   <= ALU_XOR; 
                                    gpr_we_a_o <= 1'd1;
                                  end   
                              3'b101: 
                                  begin
                                    case (funk7)
                                      7'b0:
                                        begin
                                          alu_op_o   <= ALU_SRL;
                                          gpr_we_a_o <= 1'd1; 
                                        end
                                      7'h20: 
                                        begin
                                          alu_op_o   <= ALU_SRA;
                                          gpr_we_a_o <= 1'd1;  
                                        end
                                      default: illegal_instr_o <= 1'd1; 
                                    endcase    
                                  end
                              3'd6:
                                  begin
                                    alu_op_o   <= ALU_OR;
                                    gpr_we_a_o <= 1'd1;  
                                  end                      
                              3'd7:
                                  begin
                                    alu_op_o   <= ALU_AND; 
                                    gpr_we_a_o <= 1'd1;
                                  end      
                              default: illegal_instr_o <= 1'd1; 
                            endcase    
                          end
        AUIPC_OPCODE    : begin
                            gpr_we_a_o <= 1'd1;
                            a_sel_o    <= 2'd1;
                            b_sel_o    <= 3'd2;
                            alu_op_o   <= ALU_ADD;

                          end 
        STORE_OPCODE    : begin 
                            gpr_we_a_o  <= 1'd0;
                            a_sel_o     <= 2'd0;
                            b_sel_o     <= 3'd3;  
                            alu_op_o    <= ALU_ADD;  
                            case (funk3)
                              LDST_B: 
                                begin
                                  mem_we_o   <= 1'd1; 
                                  mem_req_o  <= 1'd1;
                                  mem_size_o <= LDST_B;
                                end
                              LDST_H: 
                                begin
                                  mem_we_o   <= 1'd1;  
                                  mem_req_o  <= 1'd1;
                                  mem_size_o <= LDST_H;
                                end
                              LDST_W: 
                                begin
                                  mem_we_o   <= 1'd1;  
                                  mem_req_o  <= 1'd1;
                                  mem_size_o <= LDST_W;
                                end
                              default: illegal_instr_o <= 1'd1;   
                            endcase
                          end 
        OP_OPCODE       : begin       
                            a_sel_o    <= 2'd0;
                            b_sel_o    <= 3'd0;        
                            case (sum)
                              10'd0:
                                    begin
                                      alu_op_o   <= ALU_ADD;
                                      gpr_we_a_o <= 1'd1;
                                    end 
                              10'd1: 
                                    begin
                                      alu_op_o   <= ALU_SLL;
                                      gpr_we_a_o <= 1'd1;
                                    end
                              10'd2: 
                                    begin
                                      alu_op_o   <= ALU_SLTS;
                                      gpr_we_a_o <= 1'd1;
                                    end
                              10'd3: 
                                    begin
                                      alu_op_o   <= ALU_SLTU;
                                      gpr_we_a_o <= 1'd1;
                                    end
                              10'd4: 
                                    begin 
                                      alu_op_o   <= ALU_XOR;
                                      gpr_we_a_o <= 1'd1;
                                    end
                              10'd5: 
                                    begin
                                      alu_op_o   <= ALU_SRL;
                                      gpr_we_a_o <= 1'd1;
                                    end            
                              10'd6: 
                                    begin
                                      alu_op_o   <= ALU_OR;
                                      gpr_we_a_o <= 1'd1;
                                    end
                              10'd7:  
                                    begin
                                      alu_op_o   <= ALU_AND;
                                      gpr_we_a_o <= 1'd1;
                                    end
                              10'd256: 
                                    begin
                                      alu_op_o   <= ALU_SUB;
                                      gpr_we_a_o <= 1'd1;
                                    end 
                              10'd261: 
                                    begin
                                      alu_op_o   <= ALU_SRA;
                                      gpr_we_a_o <= 1'd1;        
                                    end            
                              default: illegal_instr_o <= 1'd1; 
                            endcase
                          end
        LUI_OPCODE      : begin
                            gpr_we_a_o <= 1'd1;
                            a_sel_o    <= 2'd2;
                            b_sel_o    <= 3'd2;
                            alu_op_o   <= ALU_ADD; 
                          end     
        BRANCH_OPCODE   : begin
                            gpr_we_a_o <= 1'd0;
                            a_sel_o    <= 2'd0;
                            b_sel_o    <= 3'd0;
                            case(funk3[2:0])
                              3'b000:
                                      begin
                                        alu_op_o <= ALU_EQ;
                                        branch_o <= 1'b1;
                                      end 
                              3'b001:
                                      begin 
                                        alu_op_o <= ALU_NE; 
                                        branch_o <= 1'b1;
                                      end 
                              3'b100:
                                      begin 
                                        alu_op_o <= ALU_LTS;
                                        branch_o <= 1'b1;
                                      end 
                              3'b101:
                                      begin 
                                        alu_op_o <= ALU_GES;
                                        branch_o <= 1'b1;
                                      end
                              3'b110:
                                      begin
                                        alu_op_o <= ALU_LTU;
                                        branch_o <= 1'b1;
                                      end 
                              3'b111:
                                      begin
                                        alu_op_o <= ALU_GEU;
                                        branch_o <= 1'b1;
                                      end 
                              default: illegal_instr_o <= 1'd1;   
                            endcase
                          end 
        JALR_OPCODE     : begin
                            a_sel_o    <= 2'd1;
                            b_sel_o    <= 3'd4;
                            if(funk3 == 3'b0) begin
                              jalr_o     <= 1'd1;
                              gpr_we_a_o <= 1'd1;
                            end else 
                              illegal_instr_o <= 1'd1;  
                          end 
        JAL_OPCODE      : begin
                            a_sel_o    <= 2'd1;
                            b_sel_o    <= 3'd4;
                            gpr_we_a_o <= 1'd1;
                            jal_o      <= 1'd1; 
                            alu_op_o   <= ALU_ADD; 
                          end
        SYSTEM_OPCODE  : 
                          begin
                            wb_src_sel_o <= 2'b10;
                            if( funk3 == 3'd4)
                              illegal_instr_o <= 1'b1;
                            else if( funk3 == 3'd0) begin
                                if( funk7 == 7'h18) 
                                  mret_o          <=1'b1;
                                else 
                                  begin
                                    illegal_instr_o <= 1'b1;
                                    csr_we_o        <= 1'b0;
                                  end
                              end
                            else 
                              begin 
                                  csr_we_o   <= 1'b1;
                                  gpr_we_a_o <= 1'b1;
                              end                                                            
                          end
        MISC_MEM_OPCODE: 
                          begin
                            if (funk3 != 3'b0) 
                            illegal_instr_o <= 1'b1;    
                          end      
        default:         illegal_instr_o <= 1'd1;   
      endcase 
    end   
    else
      illegal_instr_o <= 1'b1;
  end
endmodule
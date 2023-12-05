`timescale 1ns / 1ps

`include "C:/Users/97ras/Documents/Vivado/LABA_5/Files/riscv_pkg.sv"
import riscv_pkg::*;

module miriscv_lsu(
  input             clk_i,            // synchronization
  input             arstn_i,          // reset 
    //core protocol
  input             lsu_req_i,        // valid request
  input             lsu_we_i,         // write enable
  input  [  2 : 0 ] lsu_size_i,       // size of prossed data 
  input  [ 31 : 0 ] lsu_addr_i,       // required address
  input  [ 31 : 0 ] data_i,           // data
  output [ 31 : 0 ] lsu_data_o,       // output data
  output            core_stall_o,
    //memory protocol
  input  [ 31 : 0 ] data_rdata_i,     //                  
  output            data_req_o,       //
  output            data_we_o,        //
  output [  3 : 0 ] data_be_o,        //
  output [ 31 : 0 ] data_addr_o,      //
  output [ 31 : 0 ] data_wdata_o,      //
  input             mem_ready_i 
);


//logic            stall,core_stall_o;
logic            half_offset;
logic            stall;
logic [  1 : 0 ] byte_offset;
logic [  3 : 0 ] be;
logic [ 31 : 0 ] wd;
logic [ 31 : 0 ] lsu_data_output;

//straight wires
  assign data_we_o  = lsu_we_i;
  assign data_req_o = lsu_req_i;
  assign lsu_addr_i = data_addr_o;

//with multiplexers
  assign data_wdata_o = wd;
  assign data_be_o    = be; 
  assign lsu_data_o   = lsu_data_output;

// help
  assign half_offset = lsu_addr_i[ 1 ];
  assign byte_offset = lsu_addr_i[1:0];
// logic
// assign core_stall_o = ( lsu_req_i && ~( stall ) ); //( lsu_req_i && ~( mem_ready_i &&  stall ) )
  assign core_stall_o = stall;
//delete

  always_comb begin 
    case(lsu_size_i)
                      LDST_B:
                              begin
                                case (byte_offset)
                                  2'b00:
                                        begin
                                          lsu_data_output[ 31 : 8 ] <= { 24{data_rdata_i[7]} };
                                          lsu_data_output[ 7 :  0 ] <= data_rdata_i [  7 :  0 ];                                               
                                        end
                                  2'b01:
                                        begin
                                          lsu_data_output[ 31 : 8 ] <= { 24{data_rdata_i[15]} };
                                          lsu_data_output[ 7 :  0 ] <= data_rdata_i [ 15 : 8 ];                                              
                                        end
                                  2'b10:
                                        begin
                                          lsu_data_output[ 31 : 8 ] <= {  24{data_rdata_i[23]} };
                                          lsu_data_output[ 7 :  0 ] <= data_rdata_i [ 23 : 16 ];                                              
                                        end
                                  2'b11:
                                        begin
                                          lsu_data_output[ 31 : 8 ] <= {  24{data_rdata_i[31]} };
                                          lsu_data_output[ 7 :  0 ] <= data_rdata_i [ 31 : 24 ];                                                 
                                        end 
                                endcase
                              end
                      LDST_H:
                              begin
                                case (half_offset)
                                  1'b0:
                                    begin
                                      lsu_data_output[ 31 : 16 ] <= { 16{data_rdata_i[15]} };
                                      lsu_data_output[ 15 :  0 ] <= data_rdata_i [ 15 :  0 ];                                                
                                    end
                                  1'b1:
                                    begin
                                      lsu_data_output[ 31 :  16 ] <= { 16{data_rdata_i[31]} };                                     
                                      lsu_data_output[ 15 :   0 ] <= data_rdata_i [ 31 : 15 ];    
                                    end
                                endcase
                              end
                      LDST_W:
                              begin
                                lsu_data_output <= data_rdata_i;                      
                              end
                      LDST_BU:
                              begin
                                case (byte_offset)
                                  2'b00:     
                                        begin
                                          lsu_data_output[ 31 : 8 ] <= { 24{1'b0}  };
                                          lsu_data_output[ 7 :  0 ] <= data_rdata_i [  7 :  0 ];                                               
                                        end
                                  2'b01:
                                        begin
                                          lsu_data_output[ 31 : 8 ] <= { 24{1'b0}  };
                                          lsu_data_output[ 7 :  0 ] <= data_rdata_i [ 15 : 8 ];                                              
                                        end
                                  2'b10:
                                        begin
                                          lsu_data_output[ 31 : 8 ] <= {  24{1'b0}  };
                                          lsu_data_output[ 7 :  0 ] <= data_rdata_i [ 23 : 16 ];                                                 
                                        end
                                  2'b11:
                                        begin
                                          lsu_data_output[ 31 : 8 ] <= {  24{1'b0}  };
                                          lsu_data_output[ 7 :  0 ] <= data_rdata_i [ 31 : 24 ];                                                 
                                        end 
                                endcase
                              end
                      LDST_HU:
                              begin
                                case (half_offset)
                                  1'b0:
                                    begin
                                      lsu_data_output[ 31 : 16 ] <= { 16{1'b0} };
                                      lsu_data_output[ 15 :  0 ] <= data_rdata_i [ 15  :  0 ];                                                
                                    end
                                  1'b1:
                                    begin
                                      lsu_data_output[ 31 :  16 ] <= { 16{1'b0} };                                     
                                      lsu_data_output[ 15 :   0 ] <= data_rdata_i [ 31 :  15 ];    
                                    end
                                endcase
                              end
                            endcase
  end 

  always_comb begin                                   // mem_wd_o
    case(lsu_size_i)
      LDST_W: wd <=     data_i[31:0];
      LDST_H: wd <= {{2{data_i[15:0]}}};
      LDST_B: wd <= {{4{data_i[ 7:0]}}};
      //default: ;
    endcase
  end

  always_comb begin       
    be <= 4'b0;                            // mem_be_o
    if(lsu_req_i && lsu_we_i) begin
      case (lsu_size_i)
        LDST_W: be <= 4'b1111;
        LDST_H:
                begin
                  case (half_offset) // ...10 , ...00
                    1'b0: be <= 4'b0011;
                    1'b1: be <= 4'b1100; 
                  endcase
                end
        LDST_B:
                begin
                  case (byte_offset) // ...00,...01 ...10, ...11
                    2'b00: be <= 4'b0001; 
                    2'b01: be <= 4'b0010; 
                    2'b10: be <= 4'b0100; 
                    2'b11: be <= 4'b1000; 
                  endcase
                end
        //default: ;
      endcase
    end 
  end

  
  always @(posedge clk_i or posedge arstn_i) begin    // stall
    if(arstn_i)
      stall <= 0;
    else
      stall <= ( lsu_req_i && ~( mem_ready_i &&  stall ) );
  end
endmodule

















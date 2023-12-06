`timescale 1ns / 1ps

module rf_riscv#(
  parameter int DWIDTH = 32,
  parameter int DEPTH  = 32
)(
  input  logic                           clk_i,
  input  logic [ $clog2(DEPTH) - 1 : 0 ] read_addr1_i, read_addr2_i, write_addr_i,
  input  logic                           write_enable_i,
  input  logic [ DWIDTH - 1        : 0 ] write_data_i,
  output logic [ DWIDTH - 1        : 0 ] read_data1_o, read_data2_o
);
  
  logic [ DWIDTH - 1 : 0 ] rf_mem[ DEPTH ];
  
  initial rf_mem [0] = 'b0;
  
  assign read_data1_o  = rf_mem [ read_addr1_i ];
  assign read_data2_o  = rf_mem [ read_addr2_i ];
  
  always_ff @(posedge clk_i) begin
    if( write_enable_i )begin 
      if( write_addr_i != 'b0 )begin
        rf_mem [ write_addr_i ] <= write_data_i;
      end  
    end
  end
 
endmodule

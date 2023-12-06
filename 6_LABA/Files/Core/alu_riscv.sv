`timescale 1ns / 1ps
`include "C:/Users/97ras/Documents/Vivado/LABA_5/Files/alu_opcodes_pkg.sv"
package exaple_pkg;
    localparam int DATA_WIDTH = 32;
endpackage


import exaple_pkg::DATA_WIDTH;

module alu_riscv(
  input logic  [DATA_WIDTH-1:0] a_i,
  input logic  [DATA_WIDTH-1:0] b_i,
  
  input logic  [4:0]            alu_op_i,
  
  output logic                  flag_o,
  output logic [DATA_WIDTH-1:0] result_o
);
import alu_opcodes_pkg::*;  

always_comb begin
    case( alu_op_i )
      ALU_ADD:  result_o <= a_i + b_i;
      ALU_SUB:  result_o <= $signed( a_i ) - $signed( b_i );
      ALU_SLL:  result_o <= a_i << b_i[4:0];
      ALU_SLTS: result_o <= $signed( a_i ) < $signed( b_i );
      ALU_SLTU: result_o <= a_i < b_i;
      ALU_XOR:  result_o <= $signed( a_i ) ^ $signed( b_i );
      ALU_SRL:  result_o <= a_i >> b_i[4:0];
      ALU_SRA:  result_o <= $signed( a_i ) >>> b_i[4:0];
      ALU_OR:   result_o <= $signed( a_i ) | $signed( b_i );
      ALU_AND:  result_o <= $signed( a_i ) & $signed( b_i );
      default:  result_o <= '0;
    endcase
end
always_comb begin
    case( alu_op_i )
      ALU_EQ:  flag_o  <=  a_i  ==  b_i ;
      ALU_NE:  flag_o  <= a_i != b_i;
      ALU_LTS: flag_o  <= $signed( a_i ) <  $signed( b_i );
      ALU_GES: flag_o  <= $signed( a_i ) >= $signed( b_i );
      ALU_LTU: flag_o  <= a_i < b_i;
      ALU_GEU: flag_o  <= a_i >= b_i;
      default: flag_o  <= 'b0;
    endcase
end
endmodule
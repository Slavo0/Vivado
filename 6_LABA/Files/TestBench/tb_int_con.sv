`timescale 1ns/1ps

module tb_int_con (
  
);
  logic clk;
  logic rst;
  logic [31:0] mie,int_req;
  assign mie = 32'hFFFF_FFFF; 
  localparam interrupt = 1'b0;

  initial
    begin
      rst = '1;
      clk = '0;#500;
      clk = '1;
      int_req = 32'b0;
      #2000;
      rst = '0;
      int_req [9] = 1'b1;
      #15000;
      rst = '1;
      int_req [9] = 1'b0;
      int_req [13] = 1'b1;
      #1000;
      rst = '0;

    end
    initial
      forever
      # 500 clk = ~ clk;
    interrupt_controller interr(
      .clk_i(clk),//
      .mie_i(mie),
      .int_req_i(int_req),
      .interrupt_i(rst),
      .interrupt_o(),
      .int_fin(),
      .mcause_cause_o()
    );
endmodule
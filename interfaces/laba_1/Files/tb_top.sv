`timescale 1ns/1ps

module tb_top (
  
);
  logic clk;
  logic rst;
  logic b1t;

  localparam n = 24;
  localparam [0 : n - 1] studak = 24'b011111010100110001001010; // 8211530

  initial
    begin
      rst = '1;
      clk = '0;#500;
      clk = '1;
      #2000;
      rst = '0;
      forever
      # 500 clk = ~ clk;
    end
    
    top test(
    .b1t(b1t),
    .clk(clk),
    .rst(rst)
    );

    initial
      begin
        @ (negedge rst);

        for (int i = 0; i < n; i ++)
          begin
            @(posedge clk)
            b1t <= studak [i];
          end
        $finish;
      end
endmodule
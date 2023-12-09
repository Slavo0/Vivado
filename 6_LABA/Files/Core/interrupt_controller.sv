module interrupt_controller(
  input  logic        clk_i,//

  input  logic [31:0] mie_i,
  input  logic [31:0] int_req_i,
  input  logic        interrupt_i,

  output logic        interrupt_o,
  output logic [31:0] int_fin,
  output logic [31:0] mcause_cause_o
);

logic [  4 : 0 ] counter;
logic [ 31 : 0 ] deshifrator_o;
logic [ 31 : 0 ] intermediate;
logic [ 31 : 0 ] int_fin_sum;
logic            enable;   // if not enable counter ++
logic            reset_int;

assign mcause_cause_o = { 16'h4000, 11'b0, counter };
assign enable         = (| int_fin_sum) ;
assign interrupt_o    = enable ^ reset_int;

assign intermediate = mie_i          & int_req_i;    // first mul
assign int_fin_sum  = deshifrator_o  & intermediate ;
assign int_fin      = int_fin_sum   && interrupt_i;

always_ff @( posedge clk_i ) begin    // counter   module
  if(interrupt_i)
    counter <= 1'b0;
  else if(~enable)
    counter <= counter + 1'b1;
  else
    counter <= counter;
end

always_ff @( posedge clk_i ) begin    // interrupt module
  if(interrupt_i)
    reset_int <= 1'b1;
  else
    reset_int <= enable;
end

always_comb begin 
  deshifrator_o           = 32'b0; 
  deshifrator_o [counter] = 1'b1; 
end


endmodule
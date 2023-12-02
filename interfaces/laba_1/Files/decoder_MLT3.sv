module decoder_MLT3 (
  input [ 1 : 0 ] code,
  input clk,
  input rst
);

  localparam     up = 2'b11;
  localparam   down = 2'b01;
  localparam    top = 2'b00;
  localparam bottom = 2'b10;

  logic get;
  logic error;

  logic [1:0] state, previous_state, comp;

  assign comp = previous_state + 1'b1;

  always_comb begin
    error = 1'b0;
    
    if(previous_state == state)
      get <= 1'b0;
    else begin
      if ( comp == state)
        get <= 1'b1;
      else 
        error <= 1'b1;
    end
  end

  always_ff @( posedge clk ) begin 
    if(rst) begin
      previous_state  = 2'b00;
      state           = 2'b00;
    end
    else begin 
      previous_state  = state;
      state           = code;
    end
  end
  
endmodule
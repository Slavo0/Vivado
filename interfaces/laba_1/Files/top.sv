module top (
  input clk,
  input rst,
  input b1t
);
  
  enum logic [1:0] {  
        top    = 2'b00,
        down   = 2'b01,
        bottom = 2'b10,
        up     = 2'b11
  } state,new_state;

  logic        [ 5 : 0 ] stuffing;
  logic signed [ 1 : 0 ] vol ;
  logic                  flag;
  
  assign flag = &stuffing|(~(|stuffing));

  always_comb begin 
    new_state = state;
    if(b1t) begin
      case (state)
                bottom: new_state <= up;
                  down: new_state <= bottom;
                   top: new_state <= down;//top: new_state <= up;
                    up: new_state <= top ;
               default: new_state <= down;
      endcase
    end
  end

  always_comb begin 
    case (state)
                bottom: vol <= -1 ;
                  down: vol <=  0 ;
                   top: vol <=  1 ;
                    up: vol <=  0 ;
    endcase
  end

  always_ff @ (posedge clk)
    if (rst)
      state <= down;
    else  
      state <= new_state;
    
  always_ff @ (posedge clk)
    if (rst)
      stuffing <= {6{1'b0}};
    else  
      stuffing <= {stuffing [ 4 : 0 ], b1t};

  decoder_MLT3 decode(
    .clk(clk),
    .rst(rst),
    .code(state)
  );
endmodule



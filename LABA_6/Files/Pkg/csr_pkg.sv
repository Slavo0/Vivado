package csr_pkg;

  localparam CSR_RW          = 3'b001;
  localparam CSR_RS          = 3'b010;
  localparam CSR_RC          = 3'b011;
  localparam CSR_RWI         = 3'b101;
  localparam CSR_RSI         = 3'b110;
  localparam CSR_RCI         = 3'b111;
  
  localparam MIE_ADDR        = 12'h304;
  localparam MTVEC_ADDR      = 12'h305;
  localparam MSCRATCH_ADDR   = 12'h340;
  localparam MEPC_ADDR       = 12'h341;
  localparam MCAUSE_ADDR     = 12'h342;

endpackage
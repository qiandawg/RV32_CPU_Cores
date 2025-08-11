module Start_Div_mul(
  input clk,
  input reset,                    // add a reset input
  input [2:0] func3,
  input fuse,
  input rv32m,
  output reg start_sdivide,
  output reg start_udivide,
  output reg start_multiply
);

 // reg [2:0] func3_d;
  reg rv32m_d, fuse_d;

  wire new_op = (rv32m && !fuse) && !(rv32m_d && !fuse_d); // rising edge of rv32m && !fuse

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      start_sdivide   <= 0;
      start_udivide   <= 0;
      start_multiply  <= 0;
   //   func3_d         <= 0;
      rv32m_d         <= 0;
      fuse_d          <= 0;
    end else begin
      // Latch previous values
    //  func3_d <= func3;
      rv32m_d <= rv32m;
      fuse_d  <= fuse;

      // Default outputs to 0 every cycle (pulse lasts 1 cycle)
      start_sdivide   <= 0;
      start_udivide   <= 0;
      start_multiply  <= 0;

      // Trigger pulse when a new valid op appears
      if (rv32m && !fuse && new_op) begin
        case (func3)
          3'h1, 3'h2, 3'h3: start_multiply <= 1;
          3'h4, 3'h6:       start_sdivide  <= 1;
          3'h5, 3'h7:       start_udivide  <= 1;
        endcase
      end
    end
  end

endmodule

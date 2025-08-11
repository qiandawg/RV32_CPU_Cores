`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2024 10:56:33 AM
// Design Name: 
// Module Name: multiplysignedunsigned
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module multiplysignedunsigned(
  input clk,
  input clrn,
  input start,
  input [31:0] signed_data1,
  input [31:0] unsigned_data2,
  output reg [63:0] result,
  output reg ready
);
    // Sign-extend 'a' to 64 bits
    wire signed [63:0] a_ext = {{32{signed_data1[31]}}, signed_data1};

    // Zero-extend 'b' to 64 bits
    wire        [63:0] b_ext = {32'b0, unsigned_data2};
  reg multiply_active;

  always @(posedge clk,negedge clrn) begin
    // Perform the multiply
    if (!clrn) begin
       ready <= 1;
       result <= 0;
       multiply_active <= 0;
    end else if (start) begin

    // Perform signed * unsigned = signed multiplication
     result <= a_ext * b_ext;    
       
       multiply_active <= 1;

    // Manage the ready signal
    end else if (multiply_active) begin
      ready <= 1;             // Ready the next cycle
      multiply_active <= 0;   // Reset active flag
    end
  end

endmodule



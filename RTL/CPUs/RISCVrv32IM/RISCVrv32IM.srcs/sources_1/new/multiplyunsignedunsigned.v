`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2024 10:56:33 AM
// Design Name: 
// Module Name: multiplyunsignedunsigned
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

module multiplyunsignedunsigned(
  input clk,
  input clrn,
  input start,
  input [31:0] unsigned_data1,
  input [31:0] unsigned_data2,
  output reg [63:0] result,
  output reg ready
);

  reg multiply_active;

  always @(posedge clk,negedge clrn) begin
    // Perform the multiply
    if (!clrn) begin
       ready <= 1;
       result <= 0;
       multiply_active <= 0;
    end else if (start) begin
       result <= unsigned_data1 * unsigned_data2;
       ready <= 0;
       multiply_active <= 1;

    // Manage the ready signal
    end else if (multiply_active) begin
      ready <= 1;             // Ready the next cycle
      multiply_active <= 0;   // Reset active flag
    end
  end

endmodule


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2024 03:43:45 PM
// Design Name: 
// Module Name: Basic_or
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


module Basic_and(
    input clk,
    input clrn,             // active-low reset
    input multsigned,
    input multsu,
    input multuu,
    input in1,
    input in2,
    output reg out
);

  always @(posedge clk or negedge clrn) begin
    if (!clrn) begin
      out <= 1;  // reset value
    end else begin
      out <= multsigned & multsu & multuu & in1 & in2;
    end
  end

endmodule

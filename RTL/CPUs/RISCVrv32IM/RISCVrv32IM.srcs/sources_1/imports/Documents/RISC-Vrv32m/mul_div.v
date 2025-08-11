`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/11/2024 02:05:48 AM
// Design Name: 
// Module Name: mul_div
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


module mul_div(
    input [31:0] a,
    input [31:0] b,
    input [4:0] rs1,
    input [4:0] rs2,
    input [2:0] func3,
    input s_rv32m,
    input [4:0] s_rs1,
    input [4:0] s_rs2,
    input [2:0] s_func3,
    input clk,
    input clrn,
    input rv32m,
    output [31:0] c_mulh,
    output [31:0] c_mulhsu,
    output [31:0] c_mulu,
    output [31:0] c_div,
    output [31:0] c_divu,
    output [31:0] c_mul,
    output [31:0] c_rem,
    output [31:0] c_remu,
    output ready,
    output fuse,
    output mul_fuse,
    output rem_fuse);
    
//    wire [31:0] lower_product;
//    wire [31:0] upper_product;
    wire [31:0] quotient_signed,quotient_unsigned;
    wire [31:0] rem_signed,rem_unsigned;
    wire ready_signed;
    wire ready_unsigned;
    wire error_signed;
    wire error_unsigned;
    wire ready_multsigned;
    wire ready_multsu;
    wire ready_multuu;
    wire start_multiply;
    wire [63:0] product1,product2,product3;
    
    //wire ready;
    
    wire start_sdivide,start_udivide;
    
 
    rv32m_fuse rv32m_fuse(
        .clk(clk),
        .clrn(clrn),
        .rv32m(rv32m),
        .srv32m(s_rv32m),
        .rs1(rs1),
        .rs2(rs2),
        .srs1(s_rs1),
        .srs2(s_rs2),
        .func3(func3),
        .sfunc3(s_func3),
        .fuse(fuse),
        .mul_fuse(mul_fuse),
        .rem_fuse(rem_fuse));
        
    Start_Div_mul Start_Div_mul(
       .clk(clk),
       .reset(clrn),
       .func3(func3),
       .fuse(fuse),
       .rv32m(rv32m),
       .start_sdivide(start_sdivide),
       .start_udivide(start_udivide),
       .start_multiply(start_multiply));

    
    multiplysignedsigned multiplysignedsigned(
       .clk(clk),
       .clrn(clrn),
       .start(start_multiply),
       .signed_data1(a),
       .signed_data2(b),
       .result(product1),
       .ready(ready_multsigned));
       
    multiplysignedunsigned multiplysignedunsigned(
       .clk(clk),
       .clrn(clrn),
       .start(start_multiply),
       .signed_data1(a),
       .unsigned_data2(b),
       .result(product2),
       .ready(ready_multsu));
          
    multiplyunsignedunsigned multiplyunsignedunsigned(
       .clk(clk),
       .clrn(clrn),
       .start(start_multiply),
       .unsigned_data1(a),
       .unsigned_data2(b),
       .result(product3),
       .ready(ready_multuu));
       
    UDivide UDivide(
       .clk(clk),
       .reset(clrn),
       .start(start_udivide),
       .A(a),
       .B(b),
       .D(quotient_unsigned),
       .R(rem_unsigned),
       .ok(ready_unsigned),
       .err(error_unsigned));

    SDivide SDivide(
       .clk(clk),
       .reset(clrn),
       .start(start_sdivide),
       .A(a),
       .B(b),
       .D(quotient_signed),
       .R(rem_signed),
       .ok(ready_signed),
       .err(error_signed));

 // Inputs
//reg start;
// Outputs
//wire pulse;

   Basic_and andfun(clk,clrn,ready_multsigned, ready_multsu, ready_multuu, ready_unsigned,ready_signed,ready); 
   
 //  mux4x32 lowerpart(product3[31:0],product1[31:0],
 //                   product2[31:0],product3[31:0],func3,lower_product);
 //  mux4x32 upperpart(product3[63:32],product1[63:32],
 //                   product2[63:32],product3[63:32],func3,upper_product);
 
       
   //assign ready = ready_unsigned | ready_signed;
   assign c_mulhsu = product2[63:32];
   assign c_mulu = product3[63:32];
   assign c_mulh = product1[63:32];
   assign c_mul = product1[31:0];
   assign c_div = quotient_signed;
   assign c_divu = quotient_unsigned;
   assign c_rem = rem_signed;
   assign c_remu = rem_unsigned;

endmodule
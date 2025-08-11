<<<<<<< HEAD
module sc_cu (clk,clrn,opcode,func7,func3,z,aluc,alui,pcsrc,m2reg,bimm,call,wreg,wmem,rv32m,wpc,mdwait,fuse); // sc control unit
    input        clk,clrn;
    input  [6:0] opcode;
    input  [6:0] func7;
    input  [2:0] func3;
    input        z;
    input  mdwait,fuse;
    
    output [3:0] aluc;
    output [1:0] alui;
    output [1:0] pcsrc;
    output       m2reg;
    output       bimm;
    output       call;
    output       wreg;
    output       wmem;
    output       rv32m;
    output reg      wpc;

    reg mdwait_prev;
    
        // instruction decode
    wire i_lui = (opcode == 7'b0110111);
    wire i_jal   = (opcode == 7'b1101111);
    wire i_jalr = (opcode == 7'b1100111) & (func3 == 3'b000);
    wire i_beq   = (opcode == 7'b1100011) & (func3 == 3'b000);
    wire i_bne   = (opcode == 7'b1100011) & (func3 == 3'b001);
    wire i_lw    = (opcode == 7'b0000011) & (func3 == 3'b010);
    wire i_sw    = (opcode == 7'b0100011) & (func3 == 3'b010);
    wire i_addi  = (opcode == 7'b0010011) & (func3 == 3'b000);
    wire i_xori  = (opcode == 7'b0010011) & (func3 == 3'b100);
    wire i_ori   = (opcode == 7'b0010011) & (func3 == 3'b110);
    wire i_andi  = (opcode == 7'b0010011) & (func3 == 3'b111);
    wire i_slli  = (opcode == 7'b0010011) & (func3 == 3'b001) & (func7 == 7'b0000000);
    wire i_srli  = (opcode == 7'b0010011) & (func3 == 3'b101) & (func7 == 7'b0000000);
    wire i_srai  = (opcode == 7'b0010011) & (func3 == 3'b101) & (func7 == 7'b0100000);
    wire i_add   = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0000000);
    wire i_sub   = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0100000);
    wire i_slt   = (opcode == 7'b0110011) & (func3 == 3'b010) & (func7 == 7'b0000000);
    wire i_xor   = (opcode == 7'b0110011) & (func3 == 3'b100) & (func7 == 7'b0000000);
    wire i_or    = (opcode == 7'b0110011) & (func3 == 3'b110) & (func7 == 7'b0000000);
    wire i_and   = (opcode == 7'b0110011) & (func3 == 3'b111) & (func7 == 7'b0000000);

// rv32m flags
    wire i_mul = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0000001);
    wire i_mulh = (opcode == 7'b0110011) & (func3 == 3'b001) & (func7 == 7'b0000001);
    wire i_mulhsu = (opcode == 7'b0110011) & (func3 == 3'b010) & (func7 == 7'b0000001);
    wire i_mulhu = (opcode == 7'b0110011) & (func3 == 3'b011) & (func7 == 7'b0000001);
    wire i_div = (opcode == 7'b0110011) & (func3 == 3'b100) & (func7 == 7'b0000001);
    wire i_divu = (opcode == 7'b0110011) & (func3 == 3'b101) & (func7 == 7'b0000001);
    wire i_rem = (opcode == 7'b0110011) & (func3 == 3'b110) & (func7 == 7'b0000001);
    wire i_remu = (opcode == 7'b0110011) & (func3 == 3'b111) & (func7 == 7'b0000001);
    
    // control signals
  	 assign aluc[0]  = i_sub  | i_xori | i_xor  | i_andi | i_add  |
							 i_slli | i_srli |  i_srai | i_beq | i_bne;//
    assign aluc[1]  = i_xor  | i_slli  | i_srli  | i_srai  | i_xori | i_beq | // Check i_beq and i_bne
                     i_bne  | i_lui; //
    assign aluc[2]  = i_or   | i_srli  | i_srai  | i_ori  | i_lui; //
    assign aluc[3]  = i_xori | i_xor | i_srai | i_beq | i_bne;
    assign m2reg    = i_lw;
    assign wmem     = i_sw;
    assign wreg     = i_lui  | i_jal | i_jalr | i_lw | i_addi | i_xori | i_ori |
							 i_andi | i_slli | i_srli | i_srai | i_add | i_sub | i_slt | 
							 i_xor | i_or | i_and;
    assign pcsrc[0] = i_beq & z | i_bne & ~z | i_jal; //
    assign pcsrc[1] = i_jal | i_jalr; //
    assign call     = i_jal | i_jalr; //
    assign alui[0]  = i_lui | i_slli | i_srli | i_srai; //
    assign alui[1]  = i_lui | i_sw; //
    assign bimm     = i_sw | i_lw | i_addi | i_lui | i_slli | i_srli | i_srai |
							 i_xori | i_ori | i_andi; //
    assign rv32m    = i_mul | i_mulh | i_mulhsu | i_mulhu | 
                    i_div | i_divu | i_rem | i_remu;
                    
//always @(posedge mdwait) begin
//    if (rv32m == 0)
//        wpc <= 1;
//    else if (rv32m == 1 && fuse == 1)
//        wpc <= 1;
//    else if (rv32m == 1 && fuse == 0)
//        wpc <= 0;
//    else if (mdwait && !wdwait_prev)
//        wpc <= 1;
//    else
//        wpc <= 0;
//    wdwait_prev <= mdwait;
//end	
//always @(posedge clk) begin
//    if (rv32m == 0)
//        wpc <= 1;
//    else if (rv32m == 1 && fuse == 1)
//        wpc <= 0;
//    else if (mdwait && !mdwait_prev)
//        wpc <= 1;
//    else
//        wpc <= 0;
//    
//    mdwait_prev <= mdwait;
always @(negedge mdwait) begin
       if (mdwait==0) 
          wpc <=0;
//       else if (mdwait==1)
//         wpc <=1;
       end
always @(posedge mdwait) begin
       if (mdwait ==1)
          wpc <=1;
//       else if (mdwait==0)
//          wpc <=0;
       end					 
    always @ (!clrn)
    begin  
      if (!clrn) begin
        wpc <= 1;
        mdwait_prev<=0;
      end     
    end
endmodule
=======
module sc_cu (clk,clrn,opcode,func7,func3,z,aluc,alui,pcsrc,m2reg,bimm,call,wreg,wmem,rv32m,wpc,mdwait,fuse); // sc control unit
    input        clk,clrn;
    input  [6:0] opcode;
    input  [6:0] func7;
    input  [2:0] func3;
    input        z;
    input  mdwait,fuse;
    
    output [3:0] aluc;
    output [1:0] alui;
    output [1:0] pcsrc;
    output       m2reg;
    output       bimm;
    output       call;
    output       wreg;
    output       wmem;
    output       rv32m;
    output reg      wpc;

    reg mdwait_prev;
    
        // instruction decode
    wire i_lui = (opcode == 7'b0110111);
    wire i_jal   = (opcode == 7'b1101111);
    wire i_jalr = (opcode == 7'b1100111) & (func3 == 3'b000);
    wire i_beq   = (opcode == 7'b1100011) & (func3 == 3'b000);
    wire i_bne   = (opcode == 7'b1100011) & (func3 == 3'b001);
    wire i_lw    = (opcode == 7'b0000011) & (func3 == 3'b010);
    wire i_sw    = (opcode == 7'b0100011) & (func3 == 3'b010);
    wire i_addi  = (opcode == 7'b0010011) & (func3 == 3'b000);
    wire i_xori  = (opcode == 7'b0010011) & (func3 == 3'b100);
    wire i_ori   = (opcode == 7'b0010011) & (func3 == 3'b110);
    wire i_andi  = (opcode == 7'b0010011) & (func3 == 3'b111);
    wire i_slli  = (opcode == 7'b0010011) & (func3 == 3'b001) & (func7 == 7'b0000000);
    wire i_srli  = (opcode == 7'b0010011) & (func3 == 3'b101) & (func7 == 7'b0000000);
    wire i_srai  = (opcode == 7'b0010011) & (func3 == 3'b101) & (func7 == 7'b0100000);
    wire i_add   = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0000000);
    wire i_sub   = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0100000);
    wire i_slt   = (opcode == 7'b0110011) & (func3 == 3'b010) & (func7 == 7'b0000000);
    wire i_xor   = (opcode == 7'b0110011) & (func3 == 3'b100) & (func7 == 7'b0000000);
    wire i_or    = (opcode == 7'b0110011) & (func3 == 3'b110) & (func7 == 7'b0000000);
    wire i_and   = (opcode == 7'b0110011) & (func3 == 3'b111) & (func7 == 7'b0000000);

// rv32m flags
    wire i_mul = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0000001);
    wire i_mulh = (opcode == 7'b0110011) & (func3 == 3'b001) & (func7 == 7'b0000001);
    wire i_mulhsu = (opcode == 7'b0110011) & (func3 == 3'b010) & (func7 == 7'b0000001);
    wire i_mulhu = (opcode == 7'b0110011) & (func3 == 3'b011) & (func7 == 7'b0000001);
    wire i_div = (opcode == 7'b0110011) & (func3 == 3'b100) & (func7 == 7'b0000001);
    wire i_divu = (opcode == 7'b0110011) & (func3 == 3'b101) & (func7 == 7'b0000001);
    wire i_rem = (opcode == 7'b0110011) & (func3 == 3'b110) & (func7 == 7'b0000001);
    wire i_remu = (opcode == 7'b0110011) & (func3 == 3'b111) & (func7 == 7'b0000001);
    
    // control signals
  	 assign aluc[0]  = i_sub  | i_xori | i_xor  | i_andi | i_add  |
							 i_slli | i_srli |  i_srai | i_beq | i_bne;//
    assign aluc[1]  = i_xor  | i_slli  | i_srli  | i_srai  | i_xori | i_beq | // Check i_beq and i_bne
                     i_bne  | i_lui; //
    assign aluc[2]  = i_or   | i_srli  | i_srai  | i_ori  | i_lui; //
    assign aluc[3]  = i_xori | i_xor | i_srai | i_beq | i_bne;
    assign m2reg    = i_lw;
    assign wmem     = i_sw;
    assign wreg     = i_lui  | i_jal | i_jalr | i_lw | i_addi | i_xori | i_ori |
							 i_andi | i_slli | i_srli | i_srai | i_add | i_sub | i_slt | 
							 i_xor | i_or | i_and | i_mul | i_mulh | i_mulhsu | 
							 i_mulhu | 
                             i_div | i_divu | i_rem | i_remu;
    assign pcsrc[0] = i_beq & z | i_bne & ~z | i_jal; //
    assign pcsrc[1] = i_jal | i_jalr; //
    assign call     = i_jal | i_jalr; //
    assign alui[0]  = i_lui | i_slli | i_srli | i_srai; //
    assign alui[1]  = i_lui | i_sw; //
    assign bimm     = i_sw | i_lw | i_addi | i_lui | i_slli | i_srli | i_srai |
							 i_xori | i_ori | i_andi; //
    assign rv32m    = i_mul | i_mulh | i_mulhsu | i_mulhu | 
                    i_div | i_divu | i_rem | i_remu;
                    
//always @(posedge mdwait) begin
//    if (rv32m == 0)
//        wpc <= 1;
//    else if (rv32m == 1 && fuse == 1)
//        wpc <= 1;
//    else if (rv32m == 1 && fuse == 0)
//        wpc <= 0;
//    else if (mdwait && !wdwait_prev)
//        wpc <= 1;
//    else
//        wpc <= 0;
//    wdwait_prev <= mdwait;
//end	
//always @(posedge clk) begin
//    if (rv32m == 0)
//        wpc <= 1;
//    else if (rv32m == 1 && fuse == 1)
//        wpc <= 0;
//    else if (mdwait && !mdwait_prev)
//        wpc <= 1;
//    else
//        wpc <= 0;
//    
//    mdwait_prev <= mdwait;
//always @(negedge mdwait) begin
//       if (mdwait==0) 
//          wpc <=0;
//       else if (mdwait==1)
//         wpc <=1;
//       end
//always @(posedge mdwait) begin
//       if (mdwait ==1)
//          wpc <=1;
//       else if (mdwait==0)
//          wpc <=0;
//       end					 
//    always @ (!clrn)
//    begin  
//      if (!clrn) begin
//        wpc <= 1;
//        mdwait_prev<=0;
//      end     
//    end
//always @(posedge clk or negedge clrn) begin
//  if (!clrn) begin
//    wpc <= 1;
//    mdwait_prev <= 0;
//  end else begin
//    mdwait_prev <= mdwait;

    // Detect rising edge of mdwait
//    if (mdwait && !mdwait_prev) begin
//      wpc <= 1;
//    end
    // Detect falling edge of mdwait
//    else if (!mdwait && mdwait_prev) begin
//      wpc <= 0;
//    end
//  end
//end
//always @(posedge clk or negedge clrn or negedge mdwait) begin
//  if (!clrn) begin
//    wpc <= 1;
//    mdwait_prev <= 0;
//  end else if (!mdwait) begin
//    wpc <= 0;
//  end else begin
//    wpc <= 1;
//  end
//end
always @(posedge clk or negedge clrn) begin
  if (!clrn) begin
    wpc        <= 1'b1;
  end else begin
    if ((i_div || i_divu) && mdwait) begin
      wpc <= 1'b0;
    end else begin
      wpc <= 1'b1;
    end
  end
end
 
endmodule
>>>>>>> 6c103d1 (dded RISCVrv31IM 0 single cycle RISCV with multiply and divide. Also)

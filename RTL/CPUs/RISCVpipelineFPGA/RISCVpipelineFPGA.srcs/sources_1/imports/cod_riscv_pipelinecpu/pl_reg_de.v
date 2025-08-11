module pl_reg_de ( cancel, wreg, m2reg, wmem, call, aluc, rd,dpc4,da,db,dd,clk,clrn,
                      ecancel,ewreg,em2reg,ewmem,ecall,ealuc,erd,epc4,ea,eb,ed);
    input clk;
    input clrn;
    input cancel;
    input wreg;
    input m2reg;
    input wmem;
    input call;
    input [3:0] aluc;
    input [4:0] rd;
    input [31:0] dpc4;
    input [31:0] da;
    input [31:0] db;
    input [31:0] dd;
    output   ecancel;
    output   ewreg;
    output   em2reg;
    output  ewmem;
    output  ecall;
    output  [3:0] ealuc;
    output  [4:0] erd;
    output  [31:0] epc4;
    output  [31:0] ea;
    output  [31:0] eb;
    output  [31:0] ed;
    reg ecancel;
    reg ewreg;
    reg em2reg;
    reg ewmem;
    reg ecall;
    reg [3:0] ealuc;
    reg [4:0] erd;
    reg [31:0] epc4;
    reg [31:0] ea;
    reg [31:0] eb;
    reg [31:0] ed;
    
    always @(negedge clrn or posedge clk)
       if (!clrn) begin
        	ecancel <=0;
        	ewreg <=0;
        	em2reg <=0;
        	ewmem <=0;
        	ecall <=0;
        	ealuc <= 0;
        	erd <=0;
        	epc4 <=0;
        	ea <=0;
        	eb <=0;
        	ed <=0;
        	erd <=0;
       end else begin
       		ecancel <=cancel;
//       		if (cancel==1) begin
//           		ewreg <=0;
//        		em2reg <=0;
//        		ewmem <=0;
//        		ecall <=0;
//        		ealuc <= 0;
//        		erd <=0;
//        		epc4 <=0;
//        		ea <=0;
//        		eb <=0;
//        		ed <=0;
//        		erd <=0;
 //       	end else begin    			
       			ewreg <= wreg;
       			em2reg <= m2reg;
       			ewmem <= wmem;
       			ecall <= call;
       			ealuc <= aluc;
       			erd <= rd;
       			epc4 <= dpc4;
       			ea <= da;
       			eb <= db;
       			ed <= dd;
       			erd <= rd;
 //      		end
       end 
endmodule       

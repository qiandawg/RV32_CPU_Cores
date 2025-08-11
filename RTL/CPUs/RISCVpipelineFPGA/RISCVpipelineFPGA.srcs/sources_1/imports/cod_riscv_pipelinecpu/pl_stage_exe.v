module pl_stage_exe(ea,eb,epc4,ealuc,ecall, eal);
	input   [31:0] ea;
	input   [31:0] eb;
	input [31:0] epc4;
	input [3:0] ealuc;
	input ecall;
	output [31:0] eal;
	
	wire [31:0] ealu;
	wire zout;
	
	alu alunit (ea,eb,ealuc,ealu,zout);            // alu
	mux2x32 alu_eal (ealu,epc4,ecall,eal);  
endmodule

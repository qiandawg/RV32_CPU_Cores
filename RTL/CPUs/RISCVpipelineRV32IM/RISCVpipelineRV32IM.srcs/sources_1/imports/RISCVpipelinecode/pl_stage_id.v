/************************************************
  The Verilog HDL code example is from the book
  Computer Principles and Design in Verilog HDL
  by Yamin Li, published by A JOHN WILEY & SONS
************************************************/
module pl_stage_id (mrd,mm2reg,mwreg,erd,em2reg,ewreg,ecancel,mdwait,dpc,inst,
                          eal,mal,mm,wrd,wres,wwreg,clk,clrn,brad,jalrad,
                          jalad,pcsrc,wpcir,cancel,wreg,m2reg,wmem,calls,aluc,da,
                          db,dd,rs1,rs2,func3,rv32m,fuse,ers1,ers2,efunc3,
                          efuse,erv32m,start_sdivide,start_udivide,wremw,is_fpu,fc,fs,ft,ern,mrn,e1n,e2n,e3n,mwfpr,ewfpr,wf,e1w,e2w,e3w,stall_div_sqrt,st,wfpr,fwdla,fwdlb,fwdfa,fwdfb,jal);// ID stage

    input         clk, clrn;                           // clock and reset
    input  [31:0] dpc;                                // pc+4 in ID
    input  [31:0] inst;                                // inst in ID
    input  [31:0] wres;                                 // data in WB
    input  [31:0] eal;                                // alu res in EXE
    input  [31:0] mal;                                // alu res in MEM
    input  [31:0] mm;                                 // mem out in MEM
    input   [4:0] erd;                                 // dest reg # in EXE
    input   [4:0] mrd;                                 // dest reg # in MEM
    input   [4:0] wrd;                                 // dest reg # in WB
    input         ewreg;                               // wreg in EXE
    input         em2reg;                              // m2reg in EXE
    input         mwreg;                               // wreg in MEM
    input         mm2reg;                              // m2reg in MEM
    input         wwreg;                               // wreg in MEM
    input         ecancel;                              // cancel to CU
    input         mdwait;
    input   [4:0] ers1;
    input   [4:0] ers2;
    input   [2:0] efunc3;
    input         efuse;
    input         erv32m;
    output        cancel;                               // cancel to EXE
    output [31:0] brad;                                 // branch target
    output [31:0] jalad;                                 // jump target
    output [31:0] jalrad;                                 // jump target
    output [31:0] da, db, dd;                                // operands a and b
    output        calls;                                // call to EXE stage
    output        wpcir;                               // write to PC register
    output  [3:0] aluc;                                // alu control
    output  [1:0] pcsrc;                               // next pc select
    output        wreg;                                // write regfile
    output        m2reg;                               // mem to reg
    output        wmem;                                // write memory
    output [4:0] rs1;
    output [4:0] rs2;
    output [2:0] func3;
    output fuse;
    output rv32m;
    output start_sdivide,start_udivide,wremw;
    output is_fpu;
    output [2:0] fc;
    input  [4:0] fs,ft,ern,mrn,e1n,e2n,e3n;
    input mwfpr,ewfpr,wf;
    input        e1w,e2w,e3w,stall_div_sqrt,st;
    output wfpr;
    output fwdla,fwdlb,fwdfa,fwdfb;
    output jal;

    // instruction fields
    wire    [6:0] op   = inst[6:0];               // op
    wire    [4:0] rs1   = inst[19:15];            // rs1
    wire    [4:0] rs2   = inst[25:20];             // rs2
    wire    [4:0] rd   = inst[11:7];             // rd
    wire    [2:0] func3 = inst[14:12];             // func3
    wire    [6:0] func7 = inst[31:25];             // func7
    wire   [15:0] imm  = inst[15:00];             // immediate
    wire   [25:0] addr = inst[25:00];             // address
    
    
    wire    [31:0] imme;
    wire    [31:0] b;
    wire    [31:0] da;
    wire    [31:0] db;
    
    wire [31:0] qa;
    wire [31:0] qb;
    
    // control signals
    wire    [3:0] aluc;                           // alu operation control
    wire    [1:0] pcsrc;                          // select pc source
    wire          wreg;                           // write regfile
    wire          bimm;                          // control to mux for immediate value
    wire          m2reg;                          // instruction is an lw
    wire    [1:0] alui;                          // alu input b is an i32
    wire          call;                            // control to mux for pc+4 vs output wb mux
    wire          wmem;                           // write memory
    wire    [1:0] fwda, fwdb;                          // forward a and b
    wire    z;
    wire wremw;
    wire rv32m;
    wire efuse;
    
    pl_id_cu cu (
        .clk(clk),
        .clrn(clrn),
        .opcode(op),
        .func7(func7),
        .func3(func3),
        .rs1(rs1),
        .rs2(rs2),
        .mrd(mrd),
        .mm2reg(mm2reg),
        .mwreg(mwreg),
        .erd(erd),
        .em2reg(em2reg),
        .ewreg(ewreg),
        .ecancel(ecancel),
    	.z(z),
    	.mdwait(mdwait),
    	.efuse(efuse),
    	.wpcir(wpcir),
    	.wremw(wremw),
    	.cancel(cancel),
    	.aluc(aluc),
    	.alui(alui),
        .pcsrc(pcsrc),
    	.m2reg(m2reg), 
    	.bimm(bimm),
    	.calls(calls),
    	.wreg(wreg),
    	.wmem(wmem),
        .rv32m(rv32m),
        .fuse(fuse),
    	.fwda(fwda),
    	.fwdb(fwdb),
    	.ers1(ers1),
    	.ers2(ers2),
    	.efunc3(efunc3),
    	.erv32m(erv32m),
    	.start_sdivide(start_sdivide),
    	.start_udivide(start_udivide),
    	.is_fpu(is_fpu),
        .fc(fc),
        .fs(fs),
        .ft(ft),
        .ern(ern),
        .mrn(mrn),
        .e1n(e1n),
        .e2n(e2n),
        .e3n(e3n),
        .mwfpr(mwfpr),
        .ewfpr(ewfpr),
        .wf(wf),
        .e1w(e1w),
        .e2w(e2w),
        .e3w(e3w),
        .stall_div_sqrt(stall_div_sqrt),
        .st(st),
        .wfpr(wfpr),
        .fwdla(fwdla),
        .fwdlb(fwdlb),
        .fwdfa(fwdfa),
        .fwdfb(fwdfb),
        .jal(jal));    // control unit
    regfile r_f (rs1,rs2,wres,wrd,wwreg,~clk,clrn,qa,qb); // register file

    mux4x32 s_a (qa,eal,mal,mm,fwda,da);             // forward for a
    mux4x32 s_b (qb,eal,mal,mm,fwdb,b);             // forward for b
    mux2x32 s_ime_qb (b,imme,bimm,db);

     jal_addr jalai(dpc,inst,jalad);
    jalr_addr jalrai(da,inst,jalrad);
    branch_addr brai(dpc,inst,brad);
    imme immeblock(inst,alui,imme);
    assign dd = b;

endmodule

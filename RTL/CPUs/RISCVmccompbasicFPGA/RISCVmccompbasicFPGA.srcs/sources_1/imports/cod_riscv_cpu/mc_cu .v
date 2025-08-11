module mc_cu (clk,clrn,opcode,func7,func3,z,aluc,alui,pcsrc,m2reg,bimm,call,wreg,wmem,wpc,wir,iord,state);
    input            clk, clrn;                    // clock and reset
    input      [6:0] opcode;                       // opcode
    input      [6:0] func7;                        // func7
    input      [2:0] func3;                        // func3
    input            z;                            // for beq,bne
    output reg [3:0] aluc;                         // alu operation control
    output reg [1:0] alui;                         // 00: addi,...; 01: slli,srli,srai; 10: sw;   11: lui
    output reg [1:0] pcsrc;                        // 00: pc+4;     01: beq,bne;        10: jalr; 11: jal
    output reg       m2reg;                        // instruction is an lw
    output reg       bimm;                         // alu input b is an immediate
    output reg       call;                         // instruction is a jalr or jal
    output reg       wreg;                         // write regfile
    output reg       wmem;                         // memory write enable
    output reg       wpc;                          // write pc
    output reg       wir;                          // write ir
    output reg       iord;                         // select memory address
    output reg [3:0] state;                        // state
    reg        [3:0] next_state;                   // next state
    parameter  [3:0] sif  = 4'b0000,               // IF  state
                     sid  = 4'b0001,               // ID  state
                     seal = 4'b1000,               // EXE Arithmetic Logic state
                     sebr = 4'b0100,               // EXE Branch state
                     sels = 4'b0010,               // EXE Load/Store state
                     smld = 4'b0011,               // MEM Load state
                     smst = 4'b0101,               // MEM Store state
                     swal = 4'b1001,               // WB  Arithmetic Logic state
                     swld = 4'b0110;               // WB  Load state

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

    // control signals
    always @* begin                                // default outputs:
        aluc       = 4'b0000;                      // alu operation: add
        alui       = 2'h0;                         // select imm[11:0]
        pcsrc      = 2'h0;                         // select pc+4;
        m2reg      = 0;                            // select reg c
        bimm       = 0;                            // select a;
        call       = 0;                            // neither jalr nor jal
        wreg       = 0;                            // do not write regfile
        wmem       = 0;                            // do not write memory
        wpc        = 0;                            // do not write pc
        wir        = 0;                            // do not write ir
        iord       = 0;                            // select pc as address
        next_state = sif;
        case (state)
            sif: begin                             // IF state --------- IF:
                wir     = 1;                       // write IR
                next_state = sid;                  // next state: ID
            end                                    // 
            sid: begin                             // ID state --------- ID:
                case (1)
                    i_beq | i_bne | i_jalr | i_jal: begin // branch or jump instructions
                        next_state = sebr;         // next state: EBR
                    end
                    i_lw | i_sw: begin             // load/store instructions
                        next_state = sels;         // next state: ELS
                    end
                    default: next_state = seal;    // next state: EAL
                endcase
            end
            seal: begin                            // EAL state ------- EAL:
					 aluc[0]  = i_sub  | i_xori | i_xor  | i_andi | i_add  |
							 i_slli | i_srli |  i_srai;//
					 aluc[1]  = i_xor  | i_slli  | i_srli  | i_srai  | i_xori |  // Check i_beq and i_bne
                      i_lui; //
					 aluc[2]  = i_or   | i_srli  | i_srai  | i_ori  | i_lui; //
					 aluc[3]  = i_xori | i_xor | i_srai;
					 alui[0]  = i_lui | i_slli | i_srli | i_srai; //
					 alui[1]  = i_lui ; //
					 bimm     = i_sw | i_lw | i_addi | i_lui | i_slli | i_srli | i_srai |
							 i_xori | i_ori | i_andi; //
                next_state = swal;                 // next state: WAL
            end
            sebr: begin                            // EBR state ------- EBR:
                call       = i_jalr | i_jal;       // save pc+4
					 pcsrc[0] = i_beq & z | i_bne & ~z | i_jal; //
					 pcsrc[1] = i_jal | i_jalr; //
                aluc       = 4'b0001;              // sub for beq, bne; alu does nothing for jalr, jal
                wpc        = 1;                    // write PC
                wreg       = i_jalr | i_jal;       // save pc+4
                next_state = sif;                  // next state: IF
            end
            sels: begin                            // ELS state ------- ELS:
                alui[1]    = i_sw;                 // alui[1:0] = 10 for sw; 00 for lw
                bimm       = 1;                    // select imm
                if (i_lw) next_state = smld;       // next state: MLD
                else      next_state = smst;       // next state: MST
            end
            smld: begin                            // MLD state ------- MLD:
                iord       = 1;                    // memory address = C
                next_state = swld;                 // next state: WLD
            end
            smst: begin                            // MST state ------- MST:
                iord       = 1;                    // memory address = C
                wmem       = 1;                    // write memory
                wpc        = 1;                    // write PC
                next_state = sif;                  // next state: IF
            end
            swld: begin                            // WLD state ------- WLD:
                m2reg      = 1;                    // select memory data
                wreg       = 1;                    // write register file
                wpc        = 1;                    // write PC
                next_state = sif;                  // next state: IF
            end
            swal: begin                            // WAL state ------- WAL:
                wreg       = 1;                    // write register file
                wpc        = 1;                    // write PC
                next_state = sif;                  // next state: IF
            end //----------------------------------------------------- END
            default: begin
                next_state = sif;                  // default state: IF
            end
        endcase
    end
    always @ (posedge clk or negedge clrn) begin
        if (!clrn) begin
            state <= sif;                          // reset state to IF
        end else begin
            state <= next_state;                   // state transition
        end
    end
endmodule
module sc_cu (
    input clk,
    input clrn,
    input [6:0] opcode,
    input [6:0] func7,
    input [2:0] func3,
    input z,
    input mdwait,
    input fuse,
    input mul_fuse,
    input rem_fuse,
    output [3:0] aluc,
    output [1:0] alui,
    output [1:0] pcsrc,
    output       m2reg,
    output       bimm,
    output       call,
    output       wreg,
    output       wmem,
    output       rv32m,
    output       wpc
);

    // Registers
    reg wpc_reg = 1;
    reg counting = 0;
    reg [5:0] counter = 0;

    // Instruction decode
    wire i_lui    = (opcode == 7'b0110111);
    wire i_jal    = (opcode == 7'b1101111);
    wire i_jalr   = (opcode == 7'b1100111) & (func3 == 3'b000);
    wire i_beq    = (opcode == 7'b1100011) & (func3 == 3'b000);
    wire i_bne    = (opcode == 7'b1100011) & (func3 == 3'b001);
    wire i_lw     = (opcode == 7'b0000011) & (func3 == 3'b010);
    wire i_sw     = (opcode == 7'b0100011) & (func3 == 3'b010);
    wire i_addi   = (opcode == 7'b0010011) & (func3 == 3'b000);
    wire i_xori   = (opcode == 7'b0010011) & (func3 == 3'b100);
    wire i_ori    = (opcode == 7'b0010011) & (func3 == 3'b110);
    wire i_andi   = (opcode == 7'b0010011) & (func3 == 3'b111);
    wire i_slli   = (opcode == 7'b0010011) & (func3 == 3'b001) & (func7 == 7'b0000000);
    wire i_srli   = (opcode == 7'b0010011) & (func3 == 3'b101) & (func7 == 7'b0000000);
    wire i_srai   = (opcode == 7'b0010011) & (func3 == 3'b101) & (func7 == 7'b0100000);
    wire i_add    = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0000000);
    wire i_sub    = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0100000);
    wire i_slt    = (opcode == 7'b0110011) & (func3 == 3'b010);
    wire i_xor    = (opcode == 7'b0110011) & (func3 == 3'b100);
    wire i_or     = (opcode == 7'b0110011) & (func3 == 3'b110);
    wire i_and    = (opcode == 7'b0110011) & (func3 == 3'b111);

    // RV32M instructions
    wire i_mul     = (opcode == 7'b0110011) & (func3 == 3'b000) & (func7 == 7'b0000001);
    wire i_mulh    = (opcode == 7'b0110011) & (func3 == 3'b001) & (func7 == 7'b0000001);
    wire i_mulhsu  = (opcode == 7'b0110011) & (func3 == 3'b010) & (func7 == 7'b0000001);
    wire i_mulhu   = (opcode == 7'b0110011) & (func3 == 3'b011) & (func7 == 7'b0000001);
    wire i_div     = (opcode == 7'b0110011) & (func3 == 3'b100) & (func7 == 7'b0000001);
    wire i_divu    = (opcode == 7'b0110011) & (func3 == 3'b101) & (func7 == 7'b0000001);
    wire i_rem     = (opcode == 7'b0110011) & (func3 == 3'b110) & (func7 == 7'b0000001);
    wire i_remu    = (opcode == 7'b0110011) & (func3 == 3'b111) & (func7 == 7'b0000001);

    wire start_short_now = i_mulh | i_mulhsu | i_mulhu | i_mul | i_rem | i_remu ;
    wire start_long_now  = i_div | i_divu ;


    // Control signal outputs
    assign aluc[0] = i_sub | i_xori | i_xor | i_andi | i_add | i_slli | i_srli | i_srai | i_beq | i_bne;
    assign aluc[1] = i_xor | i_slli | i_srli | i_srai | i_xori | i_bne | i_beq | i_lui;
    assign aluc[2] = i_or | i_srli | i_srai | i_ori | i_lui;
    assign aluc[3] = i_xori | i_xor | i_srai | i_beq | i_bne;

    assign m2reg   = i_lw;
    assign wmem    = i_sw;
    assign wreg    = i_lui | i_jal | i_jalr | i_lw | i_addi | i_xori | i_ori |
                     i_andi | i_slli | i_srli | i_srai | i_add | i_sub | i_slt |
                     i_xor | i_or | i_and | i_mul | i_mulh | i_mulhsu | i_mulhu |
                     i_div | i_divu | i_rem | i_remu;

    assign pcsrc[0] = (i_beq & z) | (i_bne & ~z) | i_jal;
    assign pcsrc[1] = i_jal | i_jalr;
    assign call     = i_jal | i_jalr;
    assign alui[0]  = i_lui | i_slli | i_srli | i_srai;
    assign alui[1]  = i_lui | i_sw;
    assign bimm     = i_sw | i_lw | i_addi | i_lui | i_slli | i_srli | i_srai |
                      i_xori | i_ori | i_andi;

    assign rv32m    = i_mul | i_mulh | i_mulhsu | i_mulhu | i_div | i_divu | i_rem | i_remu;

    // Main control logic for wpc
// Start signal valid only when not counting and not in reset
wire start_now = (start_short_now || start_long_now) && (counter == 0) && clrn;

wire starting;

assign starting = (start_short_now || start_long_now) && (counter == 0) && clrn;
wire finishing = counting && (counter == 1);

// Control FSM
always @(posedge clk or negedge clrn) begin
    if (!clrn) begin
        counter  <= 0;
        counting <= 0;
    end else begin
        if ((start_short_now || start_long_now) && !counting) begin
            counter  <= (start_short_now ? 1 : 34);
            counting <= 1;
        end else begin
            if (counting) begin
                if (counter == 1) begin
                    counter  <= 0;
                    counting <= 0;
                end else begin
                    counter <= counter - 1;
                end
            end
        end
    end
end

// wpc goes low during operation, high otherwise
assign wpc = finishing || !(counting || starting);

endmodule

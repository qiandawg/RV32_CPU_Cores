module interrupt_ack_gen (
    input  wire clk,
    input  wire rst_n,
    input  wire intr_req,       // Interrupt request input
    output wire intr_ack        // One-clock interrupt acknowledge
);

    reg intr_req_d1;            // Delayed version of intr_req
    
    // Register the interrupt request to detect rising edge
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            intr_req_d1 <= 1'b0;
        end
        else begin
            intr_req_d1 <= intr_req;
        end
    end
    
    // Generate one-clock pulse on rising edge of intr_req
    assign intr_ack = intr_req & ~intr_req_d1;

endmodule
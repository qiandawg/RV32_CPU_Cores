module button_debounce_pulse #(
    parameter DEBOUNCE_PERIOD = 1000000,  // 10ms at 100MHz
    parameter PULSE_WIDTH = 5             // 5 clock cycles = 50ns at 100MHz
)(
    input wire clk,
    input wire clrn,        // Active low reset
    input wire btn_in,
    output reg btn_pulse
);

    // Debounce logic
    reg [31:0] debounce_counter;
    reg btn_sync_0, btn_sync_1;  // Synchronizer flip-flops
    reg btn_debounced;
    
    // Pulse generation logic
    reg btn_debounced_prev;
    reg [7:0] pulse_counter;

    // Button synchronizer and debouncer
    always @(posedge clk or negedge clrn) begin
        if (!clrn) begin
            btn_sync_0 <= 1'b0;
            btn_sync_1 <= 1'b0;
            debounce_counter <= 0;
            btn_debounced <= 1'b0;
        end else begin
            // Synchronize button input
            btn_sync_0 <= btn_in;
            btn_sync_1 <= btn_sync_0;
            
            // Debounce logic
            if (btn_sync_1 == btn_debounced) begin
                debounce_counter <= 0;
            end else begin
                debounce_counter <= debounce_counter + 1;
                if (debounce_counter >= DEBOUNCE_PERIOD) begin
                    btn_debounced <= btn_sync_1;
                    debounce_counter <= 0;
                end
            end
        end
    end

    // Pulse generator - detects rising edge and creates pulse
    always @(posedge clk or negedge clrn) begin
        if (!clrn) begin
            btn_debounced_prev <= 1'b0;
            pulse_counter <= 0;
            btn_pulse <= 1'b0;
        end else begin
            btn_debounced_prev <= btn_debounced;
            
            // Detect rising edge of debounced button
            if (btn_debounced && !btn_debounced_prev) begin
                pulse_counter <= PULSE_WIDTH - 1;
                btn_pulse <= 1'b1;
            end else if (pulse_counter > 0) begin
                pulse_counter <= pulse_counter - 1;
                btn_pulse <= 1'b1;
            end else begin
                btn_pulse <= 1'b0;
            end
        end
    end

endmodule
module S1_T10(
    input wire clk,
    input wire reset,
    input wire mono_pulse,
    input wire fall_detector,
    input wire [7:0] temperature,
    output wire bpm_state,  
    output wire temp_state,
    output wire fall_state,
    output wire medicine_reminder,
    output wire idle_state
);

wire [4:0] bpm;
wire temp_high;

// Instantiate sub-modules
BPM_Monitor bpm_monitor (
    .clk(clk),
    .reset(reset),
    .mono_pulse(mono_pulse),
    .bpm(bpm),
    .bpm_state(bpm_state)
);

Temperature_Monitor temp_monitor (
    .temperature(temperature),
    .temp_high(temp_high),
    .temp_state(temp_state)
);

Medicine_Reminder med_reminder (
    .clk(clk),
    .reset(reset),
    .medicine_reminder(medicine_reminder)
);

Fall_Detection fall_detection (
    .clk(clk),
    .reset(reset),
    .fall_detector(fall_detector),
    .fall_state(fall_state)
);

Control_System control_system (
    .clk(clk),
    .bpm_state(bpm_state),
    .temp_state(temp_state),
    .fall_state(fall_state),
    .idle_state(idle_state)
);

endmodule

module BPM_Monitor(
    input wire clk,
    input wire reset,
    input wire mono_pulse,
    output reg [4:0] bpm,
    output reg bpm_state
);

reg [3:0] pulse_counter;
reg [4:0] bpm_counter;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        pulse_counter <= 4'b0;
        bpm_counter <= 5'b0;
        bpm <= 5'b0;
        bpm_state <= 1'b0;
    end else begin
        if (mono_pulse) begin
            pulse_counter <= pulse_counter + 1'b1;
            if (pulse_counter == 4'd10) begin
                bpm <= bpm_counter;  // Set BPM after 10 pulses
                bpm_counter <= 5'b0; // Reset BPM counter
                pulse_counter <= 4'b0; // Reset pulse counter
            end
        end
        
        bpm_counter <= bpm_counter + 1'b1; // Count BPM continuously
        
        // Determine BPM state
        bpm_state <= (bpm > 5'd20) ? 1'b1 : 1'b0;
    end
end

endmodule

module Temperature_Monitor(
    input wire [7:0] temperature,
    output wire temp_high,
    output wire temp_state
);

// High temperature threshold logic
assign temp_high = (temperature > 8'd97) ? 1'b1 : 1'b0;
// Determine if the temperature is critically high
assign temp_state = (temperature > 8'd100) ? 1'b1 : 1'b0;

endmodule

module Medicine_Reminder(
    input wire clk,
    input wire reset,
    output reg medicine_reminder
);

reg [11:0] counter; // Counter for time intervals
reg [3:0] medicine_counter; // Medicine reminder count

always @(posedge clk or posedge reset) begin
    if (reset) begin
        counter <= 12'b0;
        medicine_counter <= 4'b0;
        medicine_reminder <= 1'b0;
    end else begin
        // Check if 600 clock cycles have passed
        if (counter == 12'd600) begin
            counter <= 12'b0; // Reset the counter
            if (medicine_counter < 4'd10) begin
                medicine_reminder <= 1'b1; // Trigger reminder
                medicine_counter <= medicine_counter + 1'b1; // Increment medicine counter
            end else begin
                medicine_reminder <= 1'b0; // Reset reminder after all medicine reminders
            end
        end else begin
            counter <= counter + 1'b1; // Increment main counter
        end
    end
end

endmodule

module Fall_Detection(
    input wire clk,
    input wire reset,
    input wire fall_detector,
    output reg fall_state
);

reg [4:0] fall_counter;
reg debounced_signal;
reg [1:0] sample_count;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        fall_counter <= 5'b0;
        fall_state <= 1'b0;
        debounced_signal <= 1'b0;
        sample_count <= 2'b0;
    end else begin
        // Debounce logic
        if (fall_detector) begin
            sample_count <= sample_count + 1'b1;
            if (sample_count == 2'b11) begin // Check if the signal is high for enough samples
                debounced_signal <= 1'b1;
            end
        end else begin
            sample_count <= 2'b0; // Reset if low
            debounced_signal <= 1'b0; // Reset debounced signal
        end

        // Count how many clock cycles the debounced signal is high
        if (debounced_signal) begin
            fall_counter <= fall_counter + 1'b1;
            if (fall_counter >= 5'd20) begin
                fall_state <= 1'b1; // Trigger fall state
            end
        end else begin
            fall_counter <= 5'b0; // Reset counter if no fall detected
            fall_state <= 1'b0; // Reset fall state
        end
    end
end

endmodule

module Control_System(
    input wire clk,
    input wire bpm_state,
    input wire temp_state,
    input wire fall_state,
    output reg idle_state
);

reg [1:0] state;

always @(posedge clk) begin
    case (state)
        2'b00: begin // Idle state
            if (bpm_state) 
                state <= 2'b01; // Transition to BPM state
            else if (temp_state) 
                state <= 2'b10; // Transition to Temperature state
            else if (fall_state) 
                state <= 2'b11; // Transition to Fall state
            else 
                idle_state <= 1'b1; // Remain idle
        end
        2'b01: begin // BPM active
            if (!bpm_state) 
                state <= 2'b00; // Return to idle if BPM is normal
            idle_state <= 1'b0;
        end
        2'b10: begin // Temperature alert
            if (!temp_state) 
                state <= 2'b00; // Return to idle if temperature is normal
            idle_state <= 1'b0;
        end
        2'b11: begin // Fall detected
            if (!fall_state) 
                state <= 2'b00; // Return to idle if no fall detected
            idle_state <= 1'b0;
        end
    endcase
end

endmodule

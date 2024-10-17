module Health_Monitoring_System;

    // Utility modules (structural implementations)
    
    module half_adder(input a, b, output sum, carry);
        xor(sum, a, b);
        and(carry, a, b);
    endmodule

    module full_adder(input a, b, cin, output sum, carry);
        wire s1, c1, c2;
        half_adder ha1(a, b, s1, c1);
        half_adder ha2(s1, cin, sum, c2);
        or(carry, c1, c2);
    endmodule

    module adder_8bit(input [7:0] a, b, output [7:0] sum, output carry_out);
        wire [7:0] carry;
        full_adder fa0(a[0], b[0], 1'b0, sum[0], carry[0]);
        full_adder fa1(a[1], b[1], carry[0], sum[1], carry[1]);
        full_adder fa2(a[2], b[2], carry[1], sum[2], carry[2]);
        full_adder fa3(a[3], b[3], carry[2], sum[3], carry[3]);
        full_adder fa4(a[4], b[4], carry[3], sum[4], carry[4]);
        full_adder fa5(a[5], b[5], carry[4], sum[5], carry[5]);
        full_adder fa6(a[6], b[6], carry[5], sum[6], carry[6]);
        full_adder fa7(a[7], b[7], carry[6], sum[7], carry_out);
    endmodule

    module comparator(input [7:0] a, output lt_10, gt_17);
        wire [7:0] not_a;
        genvar i;
        generate
            for (i = 0; i < 8; i = i + 1) begin : gen_not
                not(not_a[i], a[i]);
            end
        endgenerate

        and(lt_10, not_a[7], not_a[6], not_a[5], not_a[4], not_a[3], ~a[2], ~a[1], ~a[0]);
        and(gt_17, not_a[7], not_a[6], not_a[5], a[4], a[0]);
    endmodule

    module d_ff(input d, clk, reset, output reg q);
        always @(posedge clk or posedge reset) begin
            if (reset) q <= 0;
            else q <= d;
        end
    endmodule

    module counter_8bit(input clk, reset, output [7:0] count);
        wire [7:0] next_count;
        genvar i;
        generate
            for (i = 0; i < 8; i = i + 1) begin : gen_counter
                if (i == 0)
                    xor(next_count[i], count[i], 1'b1);
                else
                    and(next_count[i], count[i-1], next_count[i-1]);
                d_ff dff(next_count[i], clk, reset, count[i]);
            end
        endgenerate
    endmodule

    // Main modules

    module BPM_Monitor(
        input wire clk,
        input wire reset,
        input wire [7:0] pulse_count,
        output wire [7:0] bpm,
        output wire bpm_state
    );
        wire lt_10, gt_17;
        
        comparator comp(pulse_count, lt_10, gt_17);
        or(bpm_state, lt_10, gt_17);

        // Multiply by 6: pulse_count * 4 + pulse_count * 2
        wire [7:0] mult_by_4, mult_by_2, temp_sum;
        assign mult_by_4 = {pulse_count[5:0], 2'b00};
        assign mult_by_2 = {1'b0, pulse_count[6:0], 1'b0};
        adder_8bit add1(mult_by_4, mult_by_2, temp_sum, );
        adder_8bit add2(temp_sum, 8'b0, bpm, ); // Final sum (no carry needed)
    endmodule

    module Temperature_Monitor(
        input wire [7:0] temperature,
        output wire temp_high,
        output wire temp_state,
        output wire temp_low
    );
        wire lt_97, gt_100;
        
        and(lt_97, ~temperature[7], ~temperature[6], ~temperature[5], ~temperature[4], 
                   temperature[3], temperature[2], ~temperature[1], temperature[0]);
        and(gt_100, ~temperature[7], ~temperature[6], ~temperature[5], temperature[4], 
                    ~temperature[3], temperature[2], temperature[1], temperature[0]);

        or(temp_state, lt_97, gt_100);
        buf(temp_high , gt_100);
        buf(temp_low, lt_97);
    endmodule

    module fall_detection_system(
        input wire clk,
        input wire reset,
        input wire fall_sensor,
        input wire patient_reset,
        output wire alarm
    );
        parameter STABLE_TIME = 1;
        parameter RECOVERY_TIME = 30;
        parameter CLOCKS_PER_SECOND = 1000000;

        wire [1:0] state;
        wire [31:0] timer, clock_counter;
        wire timer_reset, timer_enable, alarm_set, alarm_reset;

        // State logic
        wire state_idle, state_fall_detected, state_recovery;
        and(state_idle, ~state[1], ~state[0]);
        and(state_fall_detected, ~state[1], state[0]);
        and(state_recovery, state[1], ~state[0]);

        // Timer and counter logic
        counter_8bit timer_counter(clk, timer_reset, timer[7:0]);
        counter_8bit clock_counter_low(clk, reset, clock_counter[7:0]);
        counter_8bit clock_counter_high(clk, reset, clock_counter[15:8]);
        counter_8bit clock_counter_higher(clk, reset, clock_counter[23:16]);
        counter_8bit clock_counter_highest(clk, reset, clock_counter[31:24]);

        // State transitions
        wire next_state_fall_detected, next_state_recovery, next_state_idle;
        and(next_state_fall_detected, state_idle, fall_sensor);
        and(next_state_recovery, state_fall_detected, timer[2], timer[0]); // STABLE_TIME - 1 = 4
        or(next_state_idle, patient_reset, 
           and(state_recovery, clock_counter[24], clock_counter[23], clock_counter[22], 
               clock_counter[21], clock_counter[20])); // RECOVERY_TIME * CLOCKS_PER_SECOND

        // Update state
        or(state_reset, reset, next_state_idle);
        d_ff state_ff0(next_state_fall_detected, clk, state_reset, state[0]);
        d_ff state_ff1(next_state_recovery, clk, state_reset, state[1]);

        // Alarm logic
        and(alarm_set, state_recovery, clock_counter[24], clock_counter[23], clock_counter[22], 
                       clock_counter[21], clock_counter[20]); // RECOVERY_TIME * CLOCKS_PER_SECOND
        or(alarm_reset, reset, patient_reset);
        d_ff alarm_ff(alarm_set, clk, alarm_reset, alarm);

        // Timer reset logic
        or(timer_reset, reset, state_idle, next_state_recovery);
    endmodule

    module Medicine_Reminder(
        input wire clk,
        input wire reset,
        output wire medicine_reminder
    );
        wire [31:0] counter;
        wire reminder_active;

        counter_8bit counter_0(clk, reset, counter[7:0]);
        counter_8bit counter_1(clk, reset, counter[15:8]);
        counter_8bit counter_2(clk, reset, counter[23:16]);
        counter_8bit counter_3(clk, reset, counter[31:24]);

        // 10 minutes = 600 seconds = 600,000,000 clock cycles at 1MHz
        wire ten_min_reached;
        and(ten_min_reached, counter[28], counter[27], counter[26], counter[25], counter[24],
                             counter[23], counter[22], counter[21], counter[20]);

        // 10 second reminder duration = 10,000,000 clock cycles
        wire reminder_period;
        nor(reminder_period, counter[23], counter[22], counter[21], counter[20]);

        and(reminder_active, ten_min_reached, reminder_period);
        d_ff reminder_ff(reminder_active, clk, reset, medicine_reminder);
    endmodule

    module Control_System(
        input clk,
        input reset,
        input temp,
        input bpm,
        input idle,
        output temp_out,
        output bpm_out,
        output idle_out
    );

    wire dff1_out, dff2_out;
    wire not1_out, not2_out;
    wire and1_out, and2_out, and3_out;

    d_ff dff1 (.d(bpm), .clk(clk), .reset(reset), .q(dff1_out));
    d_ff dff2 (.d(temp), .clk(clk), .reset(reset), .q(dff2_out));

    not (not1_out, bpm);
    not (not2_out, temp);

    and (and1_out, temp, not1_out);
    and (and2_out, idle, and1_out);
    and (and3_out, and2_out, not2_out);

    assign temp_out = and1_out;
    assign bpm_out = and2_out;
    assign idle_out = and3_out;

endmodule


endmodule

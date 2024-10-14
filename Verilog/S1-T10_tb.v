`timescale 1ns / 1ps

module S1_T10_tb;

    // Common signals
    reg clk;
    reg reset;

    // Fall Detection signals
    reg fall_detector;
    wire fall_state;

    // BPM Monitor signals
    reg mono_pulse;
    wire [4:0] bpm;
    wire bpm_state;

    // Temperature Monitor signals
    reg [7:0] temperature;
    wire temp_high;
    wire temp_state;

    // Medicine Reminder signals
    wire medicine_reminder;

    // Instantiate all modules
    Fall_Detection fall_detection_inst (
        .clk(clk),
        .reset(reset),
        .fall_detector(fall_detector),
        .fall_state(fall_state)
    );

    BPM_Monitor bpm_monitor_inst (
        .clk(clk),
        .reset(reset),
        .mono_pulse(mono_pulse),
        .bpm(bpm),
        .bpm_state(bpm_state)
    );

    Temperature_Monitor temp_monitor_inst (
        .temperature(temperature),
        .temp_high(temp_high),
        .temp_state(temp_state)
    );

    Medicine_Reminder medicine_reminder_inst (
        .clk(clk),
        .reset(reset),
        .medicine_reminder(medicine_reminder)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test procedure
    initial begin
        // Initialize
        reset = 1;
        fall_detector = 0;
        mono_pulse = 0;
        temperature = 8'd98;
        #100 reset = 0;

        // Run tests for each module
        test_fall_detection();
        test_bpm_monitor();
        test_temperature_monitor();
        test_medicine_reminder();

        $finish;
    end

    // Fall Detection test task
    task test_fall_detection;
        integer i;
        reg [31:0] fall_duration;
        begin
            $display("\nFall Detection Test Cases");
            $display("+-------+----------------+--------------+");
            $display("| Case  | Fall Duration  | Fall State   |");
            $display("+-------+----------------+--------------+");

            for (i = 1; i <= 30; i = i + 1) begin
                fall_duration = $urandom_range(5, 50);
                
                fall_detector = 1;
                #(fall_duration);
                fall_detector = 0;
                #10;

                $display("| %3d   | %14d | %12b |", i, fall_duration, fall_state);
            end

            $display("+-------+----------------+--------------+");
        end
    endtask

    // BPM Monitor test task
    task test_bpm_monitor;
        integer i, j;
        reg [31:0] num_pulses;
        begin
            $display("\nBPM Monitor Test Cases");
            $display("+-------+--------------+--------+-----------+");
            $display("| Case  | Pulse Count  | BPM    | BPM State |");
            $display("+-------+--------------+--------+-----------+");

            for (i = 1; i <= 35; i = i + 1) begin
                num_pulses = $urandom_range(5, 60);
                
                for (j = 0; j < num_pulses; j = j + 1) begin
                    mono_pulse = 1;
                    #10;
                    mono_pulse = 0;
                    #10;
                end
                
                #100; // Wait for BPM calculation

                $display("| %3d   | %12d | %6d | %9b |", i, num_pulses, bpm, bpm_state);
            end

            $display("+-------+--------------+--------+-----------+");
        end
    endtask

    // Temperature Monitor test task
    task test_temperature_monitor;
        integer i;
        reg [7:0] temp_value;
        begin
            $display("\nTemperature Monitor Test Cases");
            $display("+-------+-------------+-----------+------------+");
            $display("| Case  | Temperature | Temp High | Temp State |");
            $display("+-------+-------------+-----------+------------+");

            for (i = 1; i <= 40; i = i + 1) begin
                temp_value = $urandom_range(85, 110);
                temperature = temp_value;
                #10;

                $display("| %3d   | %11d | %9b | %10b |", i, temp_value, temp_high, temp_state);
            end

            $display("+-------+-------------+-----------+------------+");
        end
    endtask

    // Medicine Reminder test task
    task test_medicine_reminder;
        integer i;
        reg [31:0] wait_time;
        begin
            $display("\nMedicine Reminder Test Cases");
            $display("+-------+------------+-------------------+");
            $display("| Case  | Wait Time  | Medicine Reminder |");
            $display("+-------+------------+-------------------+");

            for (i = 1; i <= 25; i = i + 1) begin
                wait_time = $urandom_range(500, 700);
                #(wait_time);

                $display("| %3d   | %10d | %17b |", i, wait_time, medicine_reminder);
            end

            $display("+-------+------------+-------------------+");
        end
    endtask

endmodule
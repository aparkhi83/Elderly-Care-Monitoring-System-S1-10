# Elderly Care Monitoring System

<!-- First Section -->

## Team Details

<details>
  <summary>Detail</summary>

> Semester: 3rd Sem B. Tech. CSE

> Section: S1

> Member-1: Aayushman, 231CS105, aayushman.231cs105@nitk.edu.in

> Member-2: Atharva Parkhi, 231CS115, aparkhi.231cs115@nitk.edu.in

> Member-3: Sahil Mengji, 231CS151, sahilmengji.231cs151@nitk.edu.in

</details>

<!-- Second Section -->

## Abstract

<details>
  <summary>Detail</summary>
  
  > The motivation for developing an Elderly Care Monitoring System arises from the
pressing need to ensure the safety and well-being of the aging population, especially those
living independently. Real-time health monitoring solutions can detect critical conditions
like abnormal heart rates, high temperatures, and falls, reducing health risks. Further-
more, managing multiple medications can be challenging for seniors, so incorporating a
medicine reminder feature helps ensure timely intake and prevents missed doses. This
system provides peace of mind for caregivers, enabling timely medical intervention and
better health management.<br><br>
The growing elderly population faces significant challenges in health management and
safety. Many seniors struggle to monitor vital health parameters, leading to unnoticed
risks. The complexity of medication regimens can result in missed doses, jeopardizing
their well-being. This project aims to create a comprehensive system that integrates
health monitoring, fall detection, and medication reminders, along with a fall recovery
timer to track recovery times after falls. This enhances safety, ensures timely assistance,
and improves the quality of life for elderly individuals living independently.<br> <br>
Here are the features of the Elderly Care Monitoring System:<br>
~ Real-Time Health Monitoring: Continuously tracks vital parameters such as heart
rate and body temperature, providing immediate alerts for abnormalities.<br>
~ Error-free Fall Detection Mechanism: Quickly identifies falls and notifies caregivers
at the same time avoiding any false alarms using a robust recovery timer system and
debouncing system, ensuring prompt assistance in emergencies.<br>
~ Medicine Reminder System: Alerts seniors when to take their medications, prevent-
ing missed doses and promoting adherence to medication schedules.
</details>

<!-- Third Section -->
## Functional Box Diagram
<details>
  <summary>Detail</summary>

> ![Block Diagram](Snapshots/Block2png.png)

</details>

## Working

<details>
  <summary>Detail</summary>

> The Elderly Monitoring System is designed to assist in the continuous health and safety monitoring of elderly individuals. It integrates multiple modules, each serving a specific function to enhance the well-being and daily life of the user. The system consists of the following core components: <br>

 Control System: It is used to identify what module we are interested in looking at a particular instance between BPM monitoring and Temperature monitoring. It is made using a simple finite state machine, which contains three states: BPM monitoring, Temperature monitoring and Idle State which is accomplished using D flip flops.<br>

> ![](Snapshots/Control2.png) <br>

 
BPM Monitoring: This module tracks the user's heart rate (beats per minute). It triggers an alert if the BPM falls outside the normal range, helping detect any irregularities in real-time.<br>

It contains a simple  structure in which we measure beats per minute of a person. In our case, we measure it for 10 seconds using a counter and a mono pulse button, thus giving the pulse manually, and multiply it by 6 using a multiplier thus getting it for a minute. Then that value is compared to certain threshold values determined for a person of old age using a comparator and if the measured values doesn't lie in the particular slot then the monitor returns an abnormal state. It also shows the current BPM of the patient.<br><br>

> ![](Snapshots/bpm2.png) <br>

Temperature Monitoring: This module measures the user's body temperature and monitors for abnormal fluctuations. If the temperature deviates from a healthy range, an alert is activated to prompt immediate action. Special handling is included to ensure no false alerts when the sensor detects a reading of zero. <br>

So the temperature is detected using a sensor, and if it falls below or above certain threshold values determined for old age people which is compared in our circuits using comparators, then it is an abnormality and it shows on the LED or output generated.<br><br>

> ![](Snapshots/temp2.png) <br>
Medicine Reminder: The medicine reminder module is programmed to provide timely alerts to the user when it's time to take their medication. This helps ensure adherence to prescribed medication schedules. <br>

At certain intervals, the patient gets a reminder for taking his/her medicines, which is executed using a simple counter and timer circuits. <br><br>

Fall Detection System: The fall detection system monitors for any sudden movements or lack of movement that could indicate a fall. In the event of a detected fall, the system sends an immediate alert to caregivers or family members, ensuring a quick response.<br>

This intricate system includes a debouncing system which ensures that no noisy signals pass through in the circuit and only stable signals do. This is done using D flip flops. When a stable signal reaches the system, a recovery timer starts executed using a counter thus allowing the user to reset the timer if the fall isn't serious. The reset button is executed using S flip flop. If the patient fails to press the reset button before the recovery timer ends, then an alarm is sent.<br><br>

> ![](Snapshots/fall2.png) <br>

</details>

<!-- Fourth Section -->

## Logisim Circuit Diagram

<details>
  <summary>Detail</summary>
This is the main circuit diagram of our Elderly Care Monitoring System, which contains the following modules:
  BPM Monitor<br>
  Temperature Monitor<br>
  Fall Detection System<br>
  Medicine Reminder<br>
  Control System<br>
  
>  ![Main Circuit](Snapshots/main.png) <br> <br>
  BPM Monitor takes pulses of the patient and returns whether it is abnormal or normal.
> ![BPM monitor](Snapshots/bpm1.png) <br> <br>
  Temperature Monitor takes temperature of the patient and returns  whether it is abnormal or normal.
> ![Temperature monitor](Snapshots/temp1.png)<br> <br>
  Fall detection system detects a fall, which passes through a debouncing system and starts a recovery timer which sends an alert after 30 seconds if it is not reset.
> ![Fall Detection System](Snapshots/fall1.png)<br> <br>
  Medicine Reminder helps the patient to avoid missing any doses of their prescribed medication, thus taking care of their health.
> ![Medicine Reminder](Snapshots/medicine1.png)<br> <br>
  COntrol System helps to decide which state are we currently on.
> ![Control System](Snapshots/control1.png)<br> <br>

</details>

<!-- Fifth Section -->

## Verilog Code

<details>
  <summary>Detail</summary>

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

</details>

## References

<details>
  <summary>Detail</summary>

> http://www.csroc.org.tw/journal/JOC24-2/JOC24-2-1.pdf<br>
https://www.safewise.com/what-is-fall-detection/<br>
https://blogs.worldbank.org/en/health/health-systems-must-address-unique-needs-aging-populations<br>

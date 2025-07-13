/*
 * Simple PWM LED Breathing Effect
 * Description: This module creates a basic breathing effect on the built-in LED using PWM.
 *              The brightness increases and decreases cyclically at a faster rate (approx 6-9 Hz).
 * Author: Abhinav
 * Date: 2023-10-05
 */

module pwm_led (
    input CLK,       // System clock input (12 MHz for iCESugar Nano)
    output LED       // Output to the built-in LED on pin B6
);

    // Parameters for PWM and breathing effect
    parameter PERIOD = 21'd12_000;   // PWM period in clock cycles (1 kHz at 12 MHz)
    parameter STEP = PERIOD / 50;    // Step size for duty cycle change (smooth transition)
    parameter BREATHE_STEP = 21'd5; // Number of PWM cycles per duty cycle update (faster breathing speed, 3x original)

    // Internal registers
    reg [20:0] counter = 0;          // Counter for PWM period
    reg [20:0] duty_cycle = 0;       // Current duty cycle (ON time)
    reg direction = 0;               // 0 for increasing, 1 for decreasing brightness
    reg [15:0] breathe_counter = 0;  // Counter to slow down breathing effect to desired rate

    // PWM output logic
    assign LED = (counter < duty_cycle) ? 1'b1 : 1'b0;

    // Combined PWM and breathing logic
    always @(posedge CLK) begin
        // PWM counter
        if (counter < PERIOD) begin
            counter <= counter + 1;
        end else begin
            counter <= 0;
            // Breathing speed control - update every BREATHE_STEP PWM cycles
            breathe_counter <= breathe_counter + 1;
            if (breathe_counter >= BREATHE_STEP) begin // Approx 6-9 Hz full cycle (3x faster)
                breathe_counter <= 0;
                if (direction == 0) begin
                    if (duty_cycle < PERIOD - STEP) begin
                        duty_cycle <= duty_cycle + STEP; // Increase brightness
                    end else begin
                        direction <= 1; // Switch to decreasing
                    end
                end else begin
                    if (duty_cycle > STEP) begin
                        duty_cycle <= duty_cycle - STEP; // Decrease brightness
                    end else begin
                        direction <= 0; // Switch to increasing
                    end
                end
            end
        end
    end

endmodule 
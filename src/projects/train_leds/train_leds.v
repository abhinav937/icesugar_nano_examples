/*
 * Throbbing LED Strip Effect with Moving Pattern
 * Description: This module creates a throbbing effect with a moving pattern across all PMOD pins.
 *              LEDs light up with a forward-moving brighter head and dimmer tail, then reverse direction.
 * Author: Abhinav
 * Date: 2023-10-05
 */

module train_leds (
    input CLK,       // System clock input (12 MHz for iCESugar Nano)
    output PMOD1,    // B4 - LED in strip
    output PMOD3,    // B5 - LED in strip
    output PMOD5,    // E1 - LED in strip
    output PMOD7,    // B1 - LED in strip
    output PMOD2,    // C6 - LED in strip
    output PMOD4,    // E3 - LED in strip
    output PMOD6,    // C2 - LED in strip
    output PMOD8     // A1 - LED in strip
);

    // Parameters for PWM and throbbing timing
    parameter PWM_PERIOD = 21'd4_000;   // PWM period in clock cycles (1 kHz at 12 MHz)
    parameter STEP = PWM_PERIOD / 100;   // Smaller step size for smoother brightness transition
    parameter THROB_STEP = 21'd200;       // Increased to slow down the movement

    // Internal registers
    reg [20:0] pwm_counter = 0;          // Counter for PWM period
    reg [2:0] head_pos = 0;             // Position of the brightest LED (head)
    reg direction = 0;                   // 0 for forward, 1 for backward
    reg [15:0] throb_counter = 0;        // Counter for throbbing speed
    
    // Duty cycles for each LED with decreasing brightness for tail
    reg [20:0] duty_cycle [0:7];         // Duty cycles for each LED

    // LED output assignments - each LED has its own duty cycle
    assign PMOD1 = (pwm_counter < duty_cycle[0]) ? 1'b1 : 1'b0; // B4
    assign PMOD3 = (pwm_counter < duty_cycle[1]) ? 1'b1 : 1'b0; // B5
    assign PMOD5 = (pwm_counter < duty_cycle[2]) ? 1'b1 : 1'b0; // E1
    assign PMOD7 = (pwm_counter < duty_cycle[3]) ? 1'b1 : 1'b0; // B1
    assign PMOD2 = (pwm_counter < duty_cycle[4]) ? 1'b1 : 1'b0; // C6
    assign PMOD4 = (pwm_counter < duty_cycle[5]) ? 1'b1 : 1'b0; // E3
    assign PMOD6 = (pwm_counter < duty_cycle[6]) ? 1'b1 : 1'b0; // C2
    assign PMOD8 = (pwm_counter < duty_cycle[7]) ? 1'b1 : 1'b0; // A1

    // Initialize duty cycles
    initial begin
        duty_cycle[0] = 0;
        duty_cycle[1] = 0;
        duty_cycle[2] = 0;
        duty_cycle[3] = 0;
        duty_cycle[4] = 0;
        duty_cycle[5] = 0;
        duty_cycle[6] = 0;
        duty_cycle[7] = 0;
    end

    // Combined PWM and moving throbbing logic
    always @(posedge CLK) begin
        // PWM counter
        if (pwm_counter < PWM_PERIOD) begin
            pwm_counter <= pwm_counter + 1;
        end else begin
            pwm_counter <= 0;
            // Throbbing speed control - update duty cycle every THROB_STEP PWM cycles
            throb_counter <= throb_counter + 1;
            if (throb_counter >= THROB_STEP) begin // Slower movement
                throb_counter <= 0;
                // Update head position based on direction
                if (direction == 0) begin // Forward
                    if (head_pos < 7) begin
                        head_pos <= head_pos + 1;
                    end else begin
                        direction <= 1; // Switch to backward
                    end
                end else begin // Backward
                    if (head_pos > 0) begin
                        head_pos <= head_pos - 1;
                    end else begin
                        direction <= 0; // Switch to forward
                    end
                end
                
                // Set duty cycles based on head position with decreasing brightness for tail
                case (head_pos)
                    0: begin
                        duty_cycle[0] = PWM_PERIOD;
                        duty_cycle[1] = PWM_PERIOD * 85 / 100;
                        duty_cycle[2] = PWM_PERIOD * 70 / 100;
                        duty_cycle[3] = PWM_PERIOD * 55 / 100;
                        duty_cycle[4] = PWM_PERIOD * 40 / 100;
                        duty_cycle[5] = PWM_PERIOD * 25 / 100;
                        duty_cycle[6] = PWM_PERIOD * 25 / 100;
                        duty_cycle[7] = PWM_PERIOD * 25 / 100;
                    end
                    1: begin
                        duty_cycle[0] = PWM_PERIOD * 85 / 100;
                        duty_cycle[1] = PWM_PERIOD;
                        duty_cycle[2] = PWM_PERIOD * 85 / 100;
                        duty_cycle[3] = PWM_PERIOD * 70 / 100;
                        duty_cycle[4] = PWM_PERIOD * 55 / 100;
                        duty_cycle[5] = PWM_PERIOD * 40 / 100;
                        duty_cycle[6] = PWM_PERIOD * 25 / 100;
                        duty_cycle[7] = PWM_PERIOD * 25 / 100;
                    end
                    2: begin
                        duty_cycle[0] = PWM_PERIOD * 70 / 100;
                        duty_cycle[1] = PWM_PERIOD * 85 / 100;
                        duty_cycle[2] = PWM_PERIOD;
                        duty_cycle[3] = PWM_PERIOD * 85 / 100;
                        duty_cycle[4] = PWM_PERIOD * 70 / 100;
                        duty_cycle[5] = PWM_PERIOD * 55 / 100;
                        duty_cycle[6] = PWM_PERIOD * 40 / 100;
                        duty_cycle[7] = PWM_PERIOD * 25 / 100;
                    end
                    3: begin
                        duty_cycle[0] = PWM_PERIOD * 55 / 100;
                        duty_cycle[1] = PWM_PERIOD * 70 / 100;
                        duty_cycle[2] = PWM_PERIOD * 85 / 100;
                        duty_cycle[3] = PWM_PERIOD;
                        duty_cycle[4] = PWM_PERIOD * 85 / 100;
                        duty_cycle[5] = PWM_PERIOD * 70 / 100;
                        duty_cycle[6] = PWM_PERIOD * 55 / 100;
                        duty_cycle[7] = PWM_PERIOD * 40 / 100;
                    end
                    4: begin
                        duty_cycle[0] = PWM_PERIOD * 40 / 100;
                        duty_cycle[1] = PWM_PERIOD * 55 / 100;
                        duty_cycle[2] = PWM_PERIOD * 70 / 100;
                        duty_cycle[3] = PWM_PERIOD * 85 / 100;
                        duty_cycle[4] = PWM_PERIOD;
                        duty_cycle[5] = PWM_PERIOD * 85 / 100;
                        duty_cycle[6] = PWM_PERIOD * 70 / 100;
                        duty_cycle[7] = PWM_PERIOD * 55 / 100;
                    end
                    5: begin
                        duty_cycle[0] = PWM_PERIOD * 25 / 100;
                        duty_cycle[1] = PWM_PERIOD * 40 / 100;
                        duty_cycle[2] = PWM_PERIOD * 55 / 100;
                        duty_cycle[3] = PWM_PERIOD * 70 / 100;
                        duty_cycle[4] = PWM_PERIOD * 85 / 100;
                        duty_cycle[5] = PWM_PERIOD;
                        duty_cycle[6] = PWM_PERIOD * 85 / 100;
                        duty_cycle[7] = PWM_PERIOD * 70 / 100;
                    end
                    6: begin
                        duty_cycle[0] = PWM_PERIOD * 25 / 100;
                        duty_cycle[1] = PWM_PERIOD * 25 / 100;
                        duty_cycle[2] = PWM_PERIOD * 40 / 100;
                        duty_cycle[3] = PWM_PERIOD * 55 / 100;
                        duty_cycle[4] = PWM_PERIOD * 70 / 100;
                        duty_cycle[5] = PWM_PERIOD * 85 / 100;
                        duty_cycle[6] = PWM_PERIOD;
                        duty_cycle[7] = PWM_PERIOD * 85 / 100;
                    end
                    7: begin
                        duty_cycle[0] = PWM_PERIOD * 25 / 100;
                        duty_cycle[1] = PWM_PERIOD * 25 / 100;
                        duty_cycle[2] = PWM_PERIOD * 25 / 100;
                        duty_cycle[3] = PWM_PERIOD * 40 / 100;
                        duty_cycle[4] = PWM_PERIOD * 55 / 100;
                        duty_cycle[5] = PWM_PERIOD * 70 / 100;
                        duty_cycle[6] = PWM_PERIOD * 85 / 100;
                        duty_cycle[7] = PWM_PERIOD;
                    end
                endcase
            end
        end
    end

endmodule 
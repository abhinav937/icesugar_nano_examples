/*
 * Simple LED Blink
 * Description: This module creates a basic blinking effect on the built-in LED.
 *              The LED turns on and off at a fixed interval.
 * Author: Abhinav
 * Date: 2023-10-05
 */

module blinky (
    input CLK,       // System clock input (12 MHz for iCESugar Nano)
    output LED       // Output to the built-in LED on pin B6
);

    // Parameters for blink timing
    parameter CLK_FREQ = 12_000_000; // 12 MHz clock frequency
    parameter BLINK_FREQ = 1;        // Blink frequency in Hz (1 blink per second)
    parameter COUNT_MAX = CLK_FREQ / (2 * BLINK_FREQ); // Half period count for toggle

    // Internal register for counting
    reg [23:0] counter = 0;          // Counter for timing
    reg led_state = 0;               // LED state (0 for off, 1 for on)

    // LED output logic
    assign LED = led_state;

    // Blink logic
    always @(posedge CLK) begin
        if (counter < COUNT_MAX) begin
            counter <= counter + 1;
        end else begin
            counter <= 0;
            led_state <= ~led_state; // Toggle LED state
        end
    end

endmodule 
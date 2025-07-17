/*
 * Low-Pass Filtered PWM to LED Demo for iCESugar-nano
 * - Generates a PWM signal with a sweeping duty cycle
 * - Passes PWM through a digital low-pass filter (exponential moving average)
 * - Outputs the filtered value as PWM duty cycle on B6 LED
 * - Uses PMOD LEDs as a cumulative bar graph for the filtered value, updated once per PWM period
 * - All connections are internal (no external wiring needed)
 * Author: Abhinav
 * Date: 2025-07-17
 */


module lowpass_pwm_uart (
    input CLK,      // 12 MHz system clock
    output B6,      // PWM output for filtered value on B6
    output PMOD1,   // B4 - LED level indicator
    output PMOD3,   // B5 - LED level indicator
    output PMOD5,   // E1 - LED level indicator
    output PMOD7,   // B1 - LED level indicator
    output PMOD2,   // C6 - LED level indicator
    output PMOD4,   // E3 - LED level indicator
    output PMOD6,   // C2 - LED level indicator
    output PMOD8    // A1 - LED level indicator
);
    // Parameters
    parameter CLK_FREQ = 12_000_000;
    parameter PWM_FREQ = 1000;
    parameter PWM_PERIOD = CLK_FREQ / PWM_FREQ; // 12000
    parameter FILTER_ALPHA_SHIFT = 16; // Alpha ≈ 1/65536 for EMA (slower response, cutoff ~29 Hz)

    // PWM Generator for sweeping input
    reg [31:0] pwm_counter = 0; // Increased size for safety
    reg [7:0] duty_cycle = 0;
    reg pwm_out = 0;
    reg direction = 0;

    always @(posedge CLK) begin
        if (pwm_counter < PWM_PERIOD - 1)
            pwm_counter <= pwm_counter + 1;
        else
            pwm_counter <= 0;
        pwm_out <= (pwm_counter < ((duty_cycle * PWM_PERIOD) >> 8));
        // Sweep duty cycle up and down every PWM period (~1ms)
        if (pwm_counter == 0) begin
            if (!direction) begin
                if (duty_cycle < 255) duty_cycle <= duty_cycle + 1;
                else direction <= 1;
            end else begin
                if (duty_cycle > 0) duty_cycle <= duty_cycle - 1;
                else direction <= 0;
            end
        end
    end

    // Digital Low-Pass Filter (Exponential Moving Average, scaled to 0-255)
    reg [23:0] filter_accum = 0;
    always @(posedge CLK) begin
        filter_accum <= filter_accum - (filter_accum >> FILTER_ALPHA_SHIFT) + (pwm_out ? 8'd255 : 8'd0);
    end
    wire [7:0] filter_out = filter_accum >> FILTER_ALPHA_SHIFT;

    // PWM output for filtered value on B6 LED
    reg [31:0] led_pwm_counter = 0;
    reg led_pwm_out = 0;
    
    always @(posedge CLK) begin
        if (led_pwm_counter < PWM_PERIOD - 1)
            led_pwm_counter <= led_pwm_counter + 1;
        else
            led_pwm_counter <= 0;
        
        // Use filtered value as duty cycle for B6 LED
        led_pwm_out <= (led_pwm_counter < ((filter_out * PWM_PERIOD) >> 8));
    end
    
    assign B6 = led_pwm_out;

    // Sample filter_out once per PWM period for stable PMOD LED bar graph
    reg [7:0] filter_sample = 0;
    always @(posedge CLK) begin
        if (pwm_counter == 0) // Sample at the start of each PWM period
            filter_sample <= filter_out;
    end

    // Cumulative bar graph for PMOD LEDs: each LED lights up when filter_sample exceeds a threshold
    assign PMOD2 = (filter_sample >= 8'd32);   // B4: Lights up at 32 and above
    assign PMOD4 = (filter_sample >= 8'd64);   // B5: Lights up at 64 and above
    assign PMOD6 = (filter_sample >= 8'd96);   // E1: Lights up at 96 and above
    assign PMOD8 = (filter_sample >= 8'd128);  // B1: Lights up at 128 and above
    assign PMOD1 = (filter_sample >= 8'd160);  // C6: Lights up at 160 and above
    assign PMOD3 = (filter_sample >= 8'd192);  // E3: Lights up at 192 and above
    assign PMOD5 = (filter_sample >= 8'd224);  // C2: Lights up at 224 and above
    assign PMOD7 = (filter_sample >= 8'd255);  // A1: Lights up at 255 (full)

endmodule
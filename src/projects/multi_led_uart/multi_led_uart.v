/* 
 * UART PWM LED Controller for iCESugar-nano 
 * Description: Receives two-byte commands via UART (LED ID + brightness, 0-255) and controls 
 * multiple LED brightnesses using PWM. LED IDs: 0=B6, 1=B4, 2=C6.
 * Note: Outputs non-inverted for active-high LEDs (common wiring: FPGA pin high turns LED on).
 * Author: Abhinav (modified for multiple LEDs and polarity adjustment)
 * Date: 2024, Updated 2025 
 */ 

module uart_pwm_led (
input CLK,      // 12 MHz system clock from iCELink
input RX,       // UART RX pin (A3 on iCESugar-nano)
output LED_B6,  // PWM output to LED (B6 on iCESugar-nano)
output LED_B4,  // PWM output to LED (B4 on iCESugar-nano)
output LED_C6   // PWM output to LED (C6 on iCESugar-nano)
);

// Parameters
parameter CLK_FREQ = 12_000_000;    // 12 MHz clock frequency
parameter BAUD_RATE = 115200;       // UART baud rate (matched to Python script)
parameter PWM_FREQ = 1000;          // PWM frequency in Hz

// Calculated parameters
parameter BAUD_COUNT = CLK_FREQ / BAUD_RATE;  // Clock cycles per baud (~104)
parameter PWM_PERIOD = CLK_FREQ / PWM_FREQ;   // PWM period in clock cycles (~12000)

// UART receiver signals
reg [7:0] rx_data = 8'h00;          // Received byte
reg rx_valid = 1'b0;                // Valid data received flag
reg [2:0] rx_state = 3'b000;        // UART receiver state
reg [15:0] baud_counter = 16'h0000; // Baud rate counter
reg [2:0] bit_counter = 3'b000;     // Bit position counter
reg rx_sync1 = 1'b1, rx_sync2 = 1'b1; // Double-synchronized RX input

// PWM signals (shared counter, per-LED brightness/threshold)
reg [15:0] pwm_counter = 16'h0000;  // PWM counter
reg [7:0] brightness0 = 8'h40;      // Brightness for LED_B6 (initial 25%)
reg [7:0] brightness1 = 8'h40;      // Brightness for LED_B4 (initial 25%)
reg [7:0] brightness2 = 8'h40;      // Brightness for LED_C6 (initial 25%)
reg [31:0] pwm_threshold0;          // PWM threshold for LED_B6 (wide for safety)
reg [31:0] pwm_threshold1;          // PWM threshold for LED_B4
reg [31:0] pwm_threshold2;          // PWM threshold for LED_C6

// Protocol signals for multi-byte receive
reg waiting_for_brightness = 1'b0; // Flag: next byte is brightness
reg [7:0] current_id = 8'h00;      // Temp storage for received LED ID

    // Output assignments (PWM comparison)
    assign LED_B6 = (pwm_counter < pwm_threshold0) ? 1'b1 : 1'b0; 
    assign LED_B4 = (pwm_counter < pwm_threshold1) ? 1'b0 : 1'b1; 
    assign LED_C6 = (pwm_counter < pwm_threshold2) ? 1'b0 : 1'b1;

// Double-synchronize RX input
always @(posedge CLK) begin
rx_sync1 <= RX;
rx_sync2 <= rx_sync1;
end

// UART Receiver State Machine
always @(posedge CLK) begin
rx_valid <= 1'b0;

case (rx_state)
3'b000: begin // IDLE
if (rx_sync2 == 1'b0) begin
rx_state <= 3'b001;
baud_counter <= 16'h0000;
bit_counter <= 3'b000;
end
end

3'b001: begin // START
if (baud_counter >= (BAUD_COUNT >> 1)) begin
if (rx_sync2 == 1'b0) begin
rx_state <= 3'b010;
baud_counter <= 16'h0000;
end else begin
rx_state <= 3'b000;
end
end else begin
baud_counter <= baud_counter + 16'h0001;
end
end

3'b010: begin // DATA
if (baud_counter >= BAUD_COUNT) begin
rx_data[bit_counter] <= rx_sync2;
baud_counter <= 16'h0000;
bit_counter <= bit_counter + 3'b001;
if (bit_counter == 3'b111) begin
rx_state <= 3'b100;
end
end else begin
baud_counter <= baud_counter + 16'h0001;
end
end

3'b100: begin // STOP
if (baud_counter >= BAUD_COUNT) begin
if (rx_sync2 == 1'b1) begin
rx_valid <= 1'b1;
end
rx_state <= 3'b000;
baud_counter <= 16'h0000;
end else begin
baud_counter <= baud_counter + 16'h0001;
end
end

default: begin
rx_state <= 3'b000;
baud_counter <= 16'h0000;
end
endcase
end

// Update brightness based on two-byte protocol (ID then brightness)
always @(posedge CLK) begin
if (rx_valid) begin
if (!waiting_for_brightness) begin
current_id <= rx_data;
waiting_for_brightness <= 1'b1;
end else begin
case (current_id)
8'd0: brightness0 <= rx_data;
8'd1: brightness1 <= rx_data;
8'd2: brightness2 <= rx_data;
default: ; // Ignore invalid IDs
endcase
waiting_for_brightness <= 1'b0;
end
end
end

// PWM counter and thresholds
always @(posedge CLK) begin
if (pwm_counter >= PWM_PERIOD - 1) begin
pwm_counter <= 16'h0000;
end else begin
pwm_counter <= pwm_counter + 16'h0001;
end

pwm_threshold0 <= (brightness0 * PWM_PERIOD) / 256;
pwm_threshold1 <= (brightness1 * PWM_PERIOD) / 256;
pwm_threshold2 <= (brightness2 * PWM_PERIOD) / 256;
end

endmodule
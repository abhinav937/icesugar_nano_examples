/* * UART PWM LED Controller for iCESugar-nano 
 * Description: Receives single-byte brightness values (0-255) via UART and controls 
 * LED brightness using PWM. 
 * Author: Abhinav 
 * Date: 2024, Updated 2025 
 */ 

module uart_pwm_led ( 
	 input CLK, 	 // 12 MHz system clock from iCELink 
	 input RX, 		 // UART RX pin (A3 on iCESugar-nano) 
	 output LED 	 // PWM output to LED (B6 on iCESugar-nano) 
); 

	 // Parameters 
	 parameter CLK_FREQ = 12_000_000; 	 // 12 MHz clock frequency 
	 parameter BAUD_RATE = 115200; 		 // UART baud rate 
	 parameter PWM_FREQ = 1000; 		 // PWM frequency in Hz 
	  
	 // Calculated parameters 
	 parameter BAUD_COUNT = CLK_FREQ / BAUD_RATE; 	// Clock cycles per baud 
	 parameter PWM_PERIOD = CLK_FREQ / PWM_FREQ; 	 // PWM period in clock cycles 
	  
	 // UART receiver signals 
	 reg [7:0] rx_data = 8'h00; 		 // Received byte 
	 reg rx_valid = 1'b0; 				 // Valid data received flag 
	 reg [2:0] rx_state = 3'b000; 		 // UART receiver state 
	 reg [15:0] baud_counter = 16'h0000; // Baud rate counter 
	 reg [2:0] bit_counter = 3'b000; 	// Bit position counter 
	 reg rx_sync1 = 1'b1, rx_sync2 = 1'b1; // Double-synchronized RX input 
	  
	 // PWM signals 
	 reg [15:0] pwm_counter = 16'h0000; // PWM counter 
	 reg [7:0] brightness = 8'h40; 		// Current brightness (initial 25%) 
	 reg [15:0] pwm_threshold; 			// PWM threshold 
	  
	 // Initialize PWM threshold 
	 initial begin 
	 	 pwm_threshold = (16'h40 * PWM_PERIOD) / 16'h100; // 64 * period / 256 
	 end 
	  
	 // Output assignments 
	 assign LED = (pwm_counter < pwm_threshold) ? 1'b1 : 1'b0; 
	  
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
	  
	 // Update brightness when valid UART data received 
	 always @(posedge CLK) begin 
	 	 if (rx_valid) begin 
	 	 	 brightness <= rx_data; 
	 	 end 
	 end 
	  
	 // PWM counter and threshold 
	 always @(posedge CLK) begin 
	 	 if (pwm_counter >= PWM_PERIOD - 1) begin 
	 	 	 pwm_counter <= 16'h0000; 
	 	 end else begin 
	 	 	 pwm_counter <= pwm_counter + 16'h0001; 
	 	 end 
	 	  
	 	 pwm_threshold <= (brightness * PWM_PERIOD) / 16'h100; 
	 end 

endmodule
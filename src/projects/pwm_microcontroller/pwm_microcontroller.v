/*
 * PWM Microcontroller Example for iCESugar Nano
 * Implements a simple programmable microcontroller with two PWM outputs.
 * Program via UART RX pin; sends ACK via UART TX pin.
 */

module pwm_microcontroller(
    input clk,           // System clock (D1)
    input RX,            // UART RX pin (A3)
    output TX,           // UART TX pin (B3)
    output pwm0,         // PWM channel 0 output (B4)
    output pwm1          // PWM channel 1 output (C6)
);
    // Parameters
    parameter PWM_BITS = 8;
    parameter PWM_FREQ = 1000;          // PWM frequency in Hz
    parameter PWM_PERIOD = CLK_FREQ / PWM_FREQ; // 12,000,000 / 1,000 = 12,000
    parameter BAUD_RATE = 115200;
    parameter CLK_FREQ = 12000000;
    parameter BAUD_COUNT = CLK_FREQ / BAUD_RATE;

    // Registers for PWM duty cycles
    reg [PWM_BITS-1:0] pwm0_duty = 0;
    reg [PWM_BITS-1:0] pwm1_duty = 0;
    reg [15:0] pwm_counter = 0;  // Increased bit width for larger period

    // UART RX signals
    reg [7:0] rx_data = 8'h00;
    reg rx_valid = 1'b0;
    reg [2:0] rx_state = 3'b000;
    reg [15:0] baud_counter = 16'h0000;
    reg [2:0] bit_counter = 3'b000;
    reg rx_sync1 = 1'b1, rx_sync2 = 1'b1;

    // UART TX signals
    reg tx_busy = 0;
    reg tx_start = 0;
    reg [7:0] tx_data = 8'h00;
    reg [3:0] tx_bit_counter = 0;
    reg [15:0] tx_baud_counter = 0;
    reg tx_reg = 1'b1;
    assign TX = tx_reg;

    // Microcontroller state
    reg [7:0] instr = 0;
    reg [7:0] data = 0;
    reg waiting_for_data = 0;

    // Double-synchronize RX input
    always @(posedge clk) begin
        rx_sync1 <= RX;
        rx_sync2 <= rx_sync1;
    end

    // UART RX State Machine
    always @(posedge clk) begin
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

    // Microcontroller instruction handling
    always @(posedge clk) begin
        if (rx_valid) begin
            if (!waiting_for_data) begin
                instr <= rx_data;
                if (rx_data == 8'h01 || rx_data == 8'h02) begin
                    waiting_for_data <= 1;
                end else if (rx_data == 8'hFF) begin
                    pwm0_duty <= 0;
                    pwm1_duty <= 0;
                    // Send ACK for reset
                    tx_data <= 8'hAA; // ACK byte
                    tx_start <= 1;
                end
            end else begin
                data <= rx_data;
                if (instr == 8'h01) pwm0_duty <= rx_data;
                else if (instr == 8'h02) pwm1_duty <= rx_data;
                // Send ACK for PWM set
                tx_data <= 8'h55; // ACK byte
                tx_start <= 1;
                waiting_for_data <= 0;
            end
        end else begin
            tx_start <= 0;
        end
    end

    // UART TX State Machine
    always @(posedge clk) begin
        if (tx_start && !tx_busy) begin
            tx_busy <= 1;
            tx_bit_counter <= 0;
            tx_baud_counter <= 0;
        end
        if (tx_busy) begin
            if (tx_baud_counter == 0) begin
                case (tx_bit_counter)
                    0: tx_reg <= 1'b0; // Start bit
                    1: tx_reg <= tx_data[0];
                    2: tx_reg <= tx_data[1];
                    3: tx_reg <= tx_data[2];
                    4: tx_reg <= tx_data[3];
                    5: tx_reg <= tx_data[4];
                    6: tx_reg <= tx_data[5];
                    7: tx_reg <= tx_data[6];
                    8: tx_reg <= tx_data[7];
                    9: tx_reg <= 1'b1; // Stop bit
                    default: begin
                        tx_reg <= 1'b1;
                        tx_busy <= 0;
                        tx_bit_counter <= 0;
                    end
                endcase
                tx_bit_counter <= tx_bit_counter + 1;
            end
            tx_baud_counter <= (tx_baud_counter == BAUD_COUNT-1) ? 0 : tx_baud_counter + 1;
        end
    end

    // PWM counter
    always @(posedge clk) begin
        if (pwm_counter == PWM_PERIOD-1) pwm_counter <= 0;
        else pwm_counter <= pwm_counter + 1;
    end

    // PWM outputs (inverted for active-low LEDs)
    assign pwm0 = (pwm_counter < ((pwm0_duty * PWM_PERIOD) >> 8)) ? 1'b0 : 1'b1;
    assign pwm1 = (pwm_counter < ((pwm1_duty * PWM_PERIOD) >> 8)) ? 1'b0 : 1'b1;

endmodule

# Low-Pass Filtered PWM to LED Demo (lowpass_pwm_uart)

This project demonstrates a digital low-pass filter (exponential moving average) applied to a PWM signal on the iCESugar Nano FPGA board. The filtered value is visualized both as a smooth LED brightness (on B6) and as a cumulative bar graph on the PMOD LEDs.

## Features
- **PWM Generator:** Sweeps the duty cycle from 0% to 100% and back, creating a triangle wave.
- **Digital Low-Pass Filter:** Smooths the PWM signal using an exponential moving average (EMA) for a slow, analog-like response.
- **Filtered Output:** Drives the on-board B6 LED with the filtered value as a PWM duty cycle, resulting in a smooth brightness change.
- **Bar Graph Display:** PMOD LEDs act as a cumulative bar graph, lighting up progressively as the filtered value increases.
- **No external wiring required:** All connections are internal to the FPGA board.

## How It Works
1. **PWM Generation:**
   - The module generates a PWM signal with a duty cycle that sweeps up and down automatically.
2. **Low-Pass Filtering:**
   - The PWM output is passed through a digital low-pass filter (EMA) to smooth out rapid changes.
   - The filter's output is an 8-bit value (0-255) representing the smoothed signal.
3. **LED Output:**
   - The filtered value is used as the duty cycle for a second PWM, driving the on-board B6 LED for a smooth brightness effect.
4. **Bar Graph:**
   - The filtered value is sampled once per PWM period and displayed on the PMOD LEDs as a cumulative bar graph, with each LED lighting up at increasing thresholds.

## Pin Mapping
| Signal   | FPGA Pin | Function                  |
|----------|----------|---------------------------|
| CLK      | D1       | 12 MHz system clock       |
| B6       | B6       | On-board LED (filtered PWM)|
| PMOD1    | B4       | Bar graph LED             |
| PMOD2    | C6       | Bar graph LED             |
| PMOD3    | B5       | Bar graph LED             |
| PMOD4    | E3       | Bar graph LED             |
| PMOD5    | E1       | Bar graph LED             |
| PMOD6    | C2       | Bar graph LED             |
| PMOD7    | B1       | Bar graph LED             |
| PMOD8    | A1       | Bar graph LED             |

Refer to [`lowpass_pwm_uart.pcf`](lowpass_pwm_uart.pcf) for exact pin assignments.

## Files
- `lowpass_pwm_uart.v` — Main Verilog source for the demo
- `lowpass_pwm_uart.pcf` — Pin constraint file for iCESugar Nano

## Usage
1. Synthesize and upload the design to your iCESugar Nano FPGA using your preferred toolchain (e.g., Yosys, NextPNR, IcePack).
2. Observe the on-board B6 LED smoothly changing brightness.
3. Watch the PMOD LEDs light up in a cumulative bar graph pattern as the filtered value increases.

No external input or UART is required for this demo.

## Author
Abhinav

---
For more FPGA examples, see the [main project README](../../../README.md). 
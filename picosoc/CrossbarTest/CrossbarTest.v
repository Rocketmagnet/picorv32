/*
 * This project implements a simple 8 channel crossbar.
 * It's driven by the 32-bit GPIO register.
 *
 * Bits [ 7: 0] are the inputs to the crossbar
 * Bits [10: 8] control which input goes to output 0
 * Bits [11: 9] control which input goes to output 1 ...
 *
 * Bits [31:29] control which input goes to output 7.
 *
 */

module CrossBar( clkIn,
                 inputs,
                 switch0,
                 switch1,
                 switch2,
                 switch3,
                 switch4,
                 switch5,
                 switch6,
                 switch7,
                 outputs);
  
  parameter  NUM_IO          = 8;
  parameter  NUM_SWITCH_BITS = 3;
  
  input                clkIn;
  input      [7:0]     inputs;
  input      [2:0]     switch0;
  input      [2:0]     switch1;
  input      [2:0]     switch2;
  input      [2:0]     switch3;
  input      [2:0]     switch4;
  input      [2:0]     switch5;
  input      [2:0]     switch6;
  input      [2:0]     switch7;
  output reg [7:0]     outputs;  
  
  //integer i;
  
  always @(posedge clkIn)
    begin

      //for (i=0; i<NUM_IO; i=i+1) begin
      //  outputs[i] <= |(inputs & (4'b0001<<switches[i]));
      //end
      outputs[0] <= |(inputs & (8'b00000001<<switch0));
      outputs[1] <= |(inputs & (8'b00000001<<switch1));
      outputs[2] <= |(inputs & (8'b00000001<<switch2));
      outputs[3] <= |(inputs & (8'b00000001<<switch3));
      outputs[4] <= |(inputs & (8'b00000001<<switch4));
      outputs[5] <= |(inputs & (8'b00000001<<switch5));
      outputs[6] <= |(inputs & (8'b00000001<<switch6));
      outputs[7] <= |(inputs & (8'b00000001<<switch7));
      
    end  
  
endmodule

module CrossbarTest (
	input clk,

	output ser_tx,
	input ser_rx,

	input  [3:0] buttons,
	output [7:0] leds,
	output [3:0] drv,

	output flash_csb,
	output flash_clk,
	inout  flash_io0,
	inout  flash_io1,
	inout  flash_io2,
	inout  flash_io3,

	output debug_ser_tx,
	output debug_ser_rx,

	output debug_flash_0,
	output debug_flash_1,
	output debug_flash_2,
	output debug_flash_3,
	output debug_flash_4,
	output debug_flash_5,

	output [1:0] piezo
);

	reg [5:0] reset_cnt = 0;
	wire resetn = &reset_cnt;

	always @(posedge clk) begin
		reset_cnt <= reset_cnt + !resetn;
	end

	wire flash_io0_oe, flash_io0_do, flash_io0_di;
	wire flash_io1_oe, flash_io1_do, flash_io1_di;
	wire flash_io2_oe, flash_io2_do, flash_io2_di;
	wire flash_io3_oe, flash_io3_do, flash_io3_di;


        CrossBar crossBar( clk,
                           crossbar_inputs,
                           crossbar_switch0,
                           crossbar_switch1,
                           crossbar_switch2,
                           crossbar_switch3,
                           crossbar_switch4,
                           crossbar_switch5,
                           crossbar_switch6,
                           crossbar_switch7,
                           crossbar_outputs);

        wire      [7:0]    crossbar_inputs;
        wire      [2:0]    crossbar_switch0;
        wire      [2:0]    crossbar_switch1;
        wire      [2:0]    crossbar_switch2;
        wire      [2:0]    crossbar_switch3;
        wire      [2:0]    crossbar_switch4;
        wire      [2:0]    crossbar_switch5;
        wire      [2:0]    crossbar_switch6;
        wire      [2:0]    crossbar_switch7;
        wire      [7:0]    crossbar_outputs;

	SB_IO #(
		.PIN_TYPE(6'b 1010_01),
		.PULLUP(1'b 0)
	) flash_io_buf [3:0] (
		.PACKAGE_PIN({   flash_io3,    flash_io2,    flash_io1,    flash_io0    }),
		.OUTPUT_ENABLE({ flash_io3_oe, flash_io2_oe, flash_io1_oe, flash_io0_oe }),
		.D_OUT_0({       flash_io3_do, flash_io2_do, flash_io1_do, flash_io0_do }),
		.D_IN_0({        flash_io3_di, flash_io2_di, flash_io1_di, flash_io0_di })
	);

	wire        iomem_valid;
	reg         iomem_ready;
	wire [ 3:0] iomem_wstrb;
	wire [31:0] iomem_addr;
	wire [31:0] iomem_wdata;
	reg  [31:0] iomem_rdata;

        reg [15:0] piezoCounter;
	reg [31:0] gpio;

	assign leds[7:0] = crossbar_outputs[7:0];
	assign  drv[3:0] = 4'b1110;

        assign  crossbar_inputs[7:0] = gpio[7:0];
        assign  crossbar_switch0 = gpio[10:8];
        assign  crossbar_switch1 = gpio[13:11];
        assign  crossbar_switch2 = gpio[16:14];
        assign  crossbar_switch3 = gpio[19:17];
        assign  crossbar_switch4 = gpio[22:20];
        assign  crossbar_switch5 = gpio[25:23];
        assign  crossbar_switch6 = gpio[28:26];
        assign  crossbar_switch7 = gpio[31:29];

 	assign piezo[0]  = ~piezo[1];
 	assign piezo[1]  = piezoCounter[14] | buttons[0];

	always @(posedge clk) begin
		if (!resetn) begin
			gpio <= 0;
			piezoCounter <= 0;
		end else begin
			piezoCounter <= piezoCounter+1;
			iomem_ready <= 0;
			if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h 03) begin
				iomem_ready <= 1;
				iomem_rdata <= gpio;
				if (iomem_wstrb[0]) gpio[ 7: 0] <= iomem_wdata[ 7: 0];
				if (iomem_wstrb[1]) gpio[15: 8] <= iomem_wdata[15: 8];
				if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
				if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
			end
		end
	end

	picosoc soc (
		.clk          (clk         ),
		.resetn       (resetn      ),

		.ser_tx       (ser_tx      ),
		.ser_rx       (ser_rx      ),

		.flash_csb    (flash_csb   ),
		.flash_clk    (flash_clk   ),

		.flash_io0_oe (flash_io0_oe),
		.flash_io1_oe (flash_io1_oe),
		.flash_io2_oe (flash_io2_oe),
		.flash_io3_oe (flash_io3_oe),

		.flash_io0_do (flash_io0_do),
		.flash_io1_do (flash_io1_do),
		.flash_io2_do (flash_io2_do),
		.flash_io3_do (flash_io3_do),

		.flash_io0_di (flash_io0_di),
		.flash_io1_di (flash_io1_di),
		.flash_io2_di (flash_io2_di),
		.flash_io3_di (flash_io3_di),

		.irq_5        (1'b0        ),
		.irq_6        (1'b0        ),
		.irq_7        (1'b0        ),

		.iomem_valid  (iomem_valid ),
		.iomem_ready  (iomem_ready ),
		.iomem_wstrb  (iomem_wstrb ),
		.iomem_addr   (iomem_addr  ),
		.iomem_wdata  (iomem_wdata ),
		.iomem_rdata  (iomem_rdata )
	);

	assign debug_ser_tx = ser_tx;
	assign debug_ser_rx = ser_rx;

	assign debug_flash_0 = clk;
	assign debug_flash_1 = iomem_valid;
	assign debug_flash_2 = iomem_ready;
	assign debug_flash_3 = iomem_addr[0];
	assign debug_flash_4 = iomem_addr[1];
	assign debug_flash_5 = iomem_addr[2];
endmodule

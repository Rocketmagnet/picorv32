
CROSS=riscv32-unknown-elf-
CFLAGS=

# ---- IceFun board ----

CrossbarTestsim: CrossbarTest_tb.vvp CrossbarTest_fw.hex
	vvp -N $< +firmware=CrossbarTest_fw.hex

CrossbarTestsynsim: CrossbarTest_syn_tb.vvp CrossbarTest_fw.hex
	vvp -N $< +firmware=CrossbarTest_fw.hex

CrossbarTest.json: CrossbarTest.v spimemio.v simpleuart.v picosoc.v ../../picorv32.v
	yosys -ql CrossbarTest.log -p 'synth_ice40 -top CrossbarTest -json CrossbarTest.json' $^

CrossbarTest_tb.vvp: CrossbarTest_tb.v CrossbarTest.v spimemio.v simpleuart.v picosoc.v ../../picorv32.v spiflash.v
	iverilog -s testbench -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

CrossbarTest_syn_tb.vvp: CrossbarTest_tb.v CrossbarTest_syn.v spiflash.v
	iverilog -s testbench -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

CrossbarTest_syn.v: CrossbarTest.blif
	yosys -p 'read_blif -wideports CrossbarTest.blif; write_verilog CrossbarTest_syn.v'

CrossbarTest.asc: CrossbarTest.pcf CrossbarTest.json
	#arachne-pnr -d 8k -o CrossbarTest.asc -p CrossbarTest.pcf CrossbarTest.blif
	nextpnr-ice40 -r --hx8k --json CrossbarTest.json --package cb132 --asc CrossbarTest.asc --opt-timing --pcf CrossbarTest.pcf

CrossbarTest.bin: CrossbarTest.asc
	icetime -d hx8k -c 12 -mtr CrossbarTest.rpt CrossbarTest.asc
	icepack CrossbarTest.asc CrossbarTest.bin

CrossbarTest_sections.lds: sections.lds
	$(CROSS)cpp -P -DICEFUN -o $@ $^




#Firmware
#--------

CrossbarTest_leds.elf: CrossbarTest_sections.lds start.s firmware_leds.c
	$(CROSS)gcc $(CFLAGS) -DICEFUN -march=rv32imc -Wl,-Bstatic,-T,CrossbarTest_sections.lds,--strip-debug -ffreestanding -nostdlib -o CrossbarTest_leds.elf start.s firmware_leds.c

CrossbarTest_leds.hex: CrossbarTest_leds.elf
	$(CROSS)objcopy -O verilog CrossbarTest_leds.elf CrossbarTest_leds.hex

CrossbarTest_leds.bin: CrossbarTest_leds.elf
	$(CROSS)objcopy -O binary CrossbarTest_leds.elf CrossbarTest_leds.bin

CrossbarTestprog_leds: CrossbarTest.bin CrossbarTest_leds.bin
	iceFUNprog -P /dev/ttyACM0 CrossbarTest.bin
	iceFUNprog -P /dev/ttyACM0 -o 256k CrossbarTest_leds.bin




# ---- Clean ----

clean:
	rm -f icebreaker_fw.elf icebreaker_fw.hex icebreaker_fw.bin
	rm -f hx8kdemo.blif hx8kdemo.log hx8kdemo.asc hx8kdemo.rpt hx8kdemo.bin
	rm -f hx8kdemo_syn.v hx8kdemo_syn_tb.vvp hx8kdemo_tb.vvp
	rm -f icebreaker.json icebreaker.log icebreaker.asc icebreaker.rpt icebreaker.bin
	rm -f icebreaker_syn.v icebreaker_syn_tb.vvp icebreaker_tb.vvp

.PHONY: spiflash_tb clean
.PHONY: hx8kprog hx8kprog_fw hx8ksim hx8ksynsim
.PHONY: icebprog icebprog_fw icebsim icebsynsim

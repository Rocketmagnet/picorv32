
CROSS=riscv32-unknown-elf-
CFLAGS=

# ---- IceFun board ----

icefunsim: icefun_tb.vvp icefun_fw.hex
	vvp -N $< +firmware=icefun_fw.hex

icefunsynsim: icefun_syn_tb.vvp icefun_fw.hex
	vvp -N $< +firmware=icefun_fw.hex

icefun.json: icefun.v spimemio.v simpleuart.v picosoc.v ../../picorv32.v
	yosys -ql icefun.log -p 'synth_ice40 -top icefun -json icefun.json' $^

icefun_tb.vvp: icefun_tb.v icefun.v spimemio.v simpleuart.v picosoc.v ../../picorv32.v spiflash.v
	iverilog -s testbench -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

icefun_syn_tb.vvp: icefun_tb.v icefun_syn.v spiflash.v
	iverilog -s testbench -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

icefun_syn.v: icefun.blif
	yosys -p 'read_blif -wideports icefun.blif; write_verilog icefun_syn.v'

icefun.asc: icefun.pcf icefun.json
	#arachne-pnr -d 8k -o icefun.asc -p icefun.pcf icefun.blif
	nextpnr-ice40 -r --hx8k --json icefun.json --package cb132 --asc icefun.asc --opt-timing --pcf icefun.pcf

icefun.bin: icefun.asc
	icetime -d hx8k -c 12 -mtr icefun.rpt icefun.asc
	icepack icefun.asc icefun.bin

icefun_sections.lds: sections.lds
	$(CROSS)cpp -P -DICEFUN -o $@ $^




#Firmware
#--------

icefun_leds.elf: icefun_sections.lds start.s firmware_leds.c
	$(CROSS)gcc $(CFLAGS) -DICEFUN -march=rv32imc -Wl,-Bstatic,-T,icefun_sections.lds,--strip-debug -ffreestanding -nostdlib -o icefun_leds.elf start.s firmware_leds.c

icefun_leds.hex: icefun_leds.elf
	$(CROSS)objcopy -O verilog icefun_leds.elf icefun_leds.hex

icefun_leds.bin: icefun_leds.elf
	$(CROSS)objcopy -O binary icefun_leds.elf icefun_leds.bin

icefunprog_leds: icefun.bin icefun_leds.bin
	iceFUNprog -P /dev/ttyACM0 icefun.bin
	iceFUNprog -P /dev/ttyACM0 -o 256k icefun_leds.bin




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

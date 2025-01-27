
CROSS=riscv32-unknown-elf-
CFLAGS=

# ---- IceFun board ----

icefunsim: icefun_tb.vvp icefun_fw.hex
	vvp -N $< +firmware=icefun_fw.hex

icefunsynsim: icefun_syn_tb.vvp icefun_fw.hex
	vvp -N $< +firmware=icefun_fw.hex

#icefun.blif: icefun.v spimemio.v simpleuart.v picosoc.v ../picorv32.v
#	yosys -ql icefun.log -p 'synth_ice40 -top icefun -blif icefun.blif' $^

icefun.json: icefun.v spimemio.v simpleuart.v picosoc.v ../picorv32.v
	yosys -ql icefun.log -p 'synth_ice40 -top icefun -json icefun.json' $^

icefun_tb.vvp: icefun_tb.v icefun.v spimemio.v simpleuart.v picosoc.v ../picorv32.v spiflash.v
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

#icefunprog: icefun.bin icefun_fw.bin
#	iceFUNprog icefun.bin
#	iceFUNprog -o 1M icefun_fw.bin

#icefunprog_fw: icefun_fw.bin
#	iceFUNprog -o 1M icefun_fw.bin


# Firmware: Original
#-------------------

icefun_fw.elf: icefun_sections.lds start.s firmware.c
	$(CROSS)gcc $(CFLAGS) -DICEFUN -march=rv32imc -Wl,-Bstatic,-T,icefun_sections.lds,--strip-debug -ffreestanding -nostdlib -o icefun_fw.elf start.s firmware.c

icefun_fw.bin: icefun_fw.elf
	$(CROSS)objcopy -O binary icefun_fw.elf icefun_fw.bin

icefun_fw.asm: icefun_sections.lds start.s firmware.c
	$(CROSS)gcc $(CFLAGS) -DICEFUN -S -march=rv32imc -Wl,-Bstatic,-T,icefun_sections.lds,--strip-debug -ffreestanding -nostdlib -o icefun_fw.asm firmware.c

icefunprog: icefun.bin icefun_fw.bin
	iceFUNprog -P /dev/ttyACM0 icefun.bin
	iceFUNprog -P /dev/ttyACM0 -o 256k icefun_fw.bin


#Firmware: LEDs
#--------------

icefun_leds.elf: icefun_sections.lds start.s firmware_leds.c
	$(CROSS)gcc $(CFLAGS) -DICEFUN -march=rv32imc -Wl,-Bstatic,-T,icefun_sections.lds,--strip-debug -ffreestanding -nostdlib -o icefun_leds.elf start.s firmware_leds.c

icefun_leds.hex: icefun_leds.elf
	$(CROSS)objcopy -O verilog icefun_leds.elf icefun_leds.hex

icefun_leds.bin: icefun_leds.elf
	$(CROSS)objcopy -O binary icefun_leds.elf icefun_leds.bin

icefunprog_leds: icefun.bin icefun_leds.bin
	iceFUNprog -P /dev/ttyACM0 icefun.bin
	iceFUNprog -P /dev/ttyACM0 -o 256k icefun_leds.bin


# ---- iCE40 HX8K Breakout Board ----

hx8ksim: hx8kdemo_tb.vvp hx8kdemo_fw.hex
	vvp -N $< +firmware=hx8kdemo_fw.hex

hx8ksynsim: hx8kdemo_syn_tb.vvp hx8kdemo_fw.hex
	vvp -N $< +firmware=hx8kdemo_fw.hex

hx8kdemo.blif: hx8kdemo.v spimemio.v simpleuart.v picosoc.v ../picorv32.v
	yosys -ql hx8kdemo.log -p 'synth_ice40 -top hx8kdemo -blif hx8kdemo.blif' $^

hx8kdemo_tb.vvp: hx8kdemo_tb.v hx8kdemo.v spimemio.v simpleuart.v picosoc.v ../picorv32.v spiflash.v
	iverilog -s testbench -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

hx8kdemo_syn_tb.vvp: hx8kdemo_tb.v hx8kdemo_syn.v spiflash.v
	iverilog -s testbench -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

hx8kdemo_syn.v: hx8kdemo.blif
	yosys -p 'read_blif -wideports hx8kdemo.blif; write_verilog hx8kdemo_syn.v'

hx8kdemo.asc: hx8kdemo.pcf hx8kdemo.blif
	arachne-pnr -d 8k -o hx8kdemo.asc -p hx8kdemo.pcf hx8kdemo.blif

hx8kdemo.bin: hx8kdemo.asc
	icetime -d hx8k -c 12 -mtr hx8kdemo.rpt hx8kdemo.asc
	icepack hx8kdemo.asc hx8kdemo.bin

hx8kprog: hx8kdemo.bin hx8kdemo_fw.bin
	iceprog hx8kdemo.bin
	iceprog -o 1M hx8kdemo_fw.bin

hx8kprog_fw: hx8kdemo_fw.bin
	iceprog -o 1M hx8kdemo_fw.bin

hx8kdemo_sections.lds: sections.lds
	$(CROSS)cpp -P -DHX8KDEMO -o $@ $^

hx8kdemo_fw.elf: hx8kdemo_sections.lds start.s firmware.c
	$(CROSS)gcc $(CFLAGS) -DHX8KDEMO -S -march=rv32imc -Wl,-Bstatic,-T,hx8kdemo_sections.lds,--strip-debug -ffreestanding -nostdlib -o hx8kdemo_fw.elf start.s firmware.c

hx8kdemo_fw.hex: hx8kdemo_fw.elf
	$(CROSS)objcopy -O verilog hx8kdemo_fw.elf hx8kdemo_fw.hex

hx8kdemo_fw.bin: hx8kdemo_fw.elf
	$(CROSS)objcopy -O binary hx8kdemo_fw.elf hx8kdemo_fw.bin

# ---- iCE40 IceBreaker Board ----

icebsim: icebreaker_tb.vvp icebreaker_fw.hex
	vvp -N $< +firmware=icebreaker_fw.hex

icebsynsim: icebreaker_syn_tb.vvp icebreaker_fw.hex
	vvp -N $< +firmware=icebreaker_fw.hex

icebreaker.json: icebreaker.v ice40up5k_spram.v spimemio.v simpleuart.v picosoc.v ../picorv32.v
	yosys -ql icebreaker.log -p 'synth_ice40 -top icebreaker -json icebreaker.json' $^

icebreaker_tb.vvp: icebreaker_tb.v icebreaker.v ice40up5k_spram.v spimemio.v simpleuart.v picosoc.v ../picorv32.v spiflash.v
	iverilog -s testbench -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

icebreaker_syn_tb.vvp: icebreaker_tb.v icebreaker_syn.v spiflash.v
	iverilog -s testbench -o $@ $^ `yosys-config --datdir/ice40/cells_sim.v`

icebreaker_syn.v: icebreaker.json
	yosys -p 'read_json icebreaker.json; write_verilog icebreaker_syn.v'

icebreaker.asc: icebreaker.pcf icebreaker.json
	nextpnr-ice40 --freq 13 --up5k --asc icebreaker.asc --pcf icebreaker.pcf --json icebreaker.json

icebreaker.bin: icebreaker.asc
	icetime -d up5k -c 12 -mtr icebreaker.rpt icebreaker.asc
	icepack icebreaker.asc icebreaker.bin

icebprog: icebreaker.bin icebreaker_fw.bin
	iceprog icebreaker.bin
	iceprog -o 1M icebreaker_fw.bin

icebprog_fw: icebreaker_fw.bin
	iceprog -o 1M icebreaker_fw.bin

icebreaker_sections.lds: sections.lds
	$(CROSS)cpp -P -DICEBREAKER -o $@ $^

icebreaker_fw.elf: icebreaker_sections.lds start.s firmware.c
	$(CROSS)gcc $(CFLAGS) -DICEBREAKER -march=rv32ic -Wl,-Bstatic,-T,icebreaker_sections.lds,--strip-debug -ffreestanding -nostdlib -o icebreaker_fw.elf start.s firmware.c

icebreaker_fw.hex: icebreaker_fw.elf
	$(CROSS)objcopy -O verilog icebreaker_fw.elf icebreaker_fw.hex

icebreaker_fw.bin: icebreaker_fw.elf
	$(CROSS)objcopy -O binary icebreaker_fw.elf icebreaker_fw.bin

# ---- Testbench for SPI Flash Model ----

spiflash_tb: spiflash_tb.vvp firmware.hex
	vvp -N $<

spiflash_tb.vvp: spiflash.v spiflash_tb.v
	iverilog -s testbench -o $@ $^

# ---- ASIC Synthesis Tests ----

cmos.log: spimemio.v simpleuart.v picosoc.v ../picorv32.v
	yosys -l cmos.log -p 'synth -top picosoc; abc -g cmos2; opt -fast; stat' $^

# ---- Clean ----

clean:
	rm -f testbench.vvp testbench.vcd spiflash_tb.vvp spiflash_tb.vcd
	rm -f hx8kdemo_fw.elf hx8kdemo_fw.hex hx8kdemo_fw.bin cmos.log
	rm -f icebreaker_fw.elf icebreaker_fw.hex icebreaker_fw.bin
	rm -f hx8kdemo.blif hx8kdemo.log hx8kdemo.asc hx8kdemo.rpt hx8kdemo.bin
	rm -f hx8kdemo_syn.v hx8kdemo_syn_tb.vvp hx8kdemo_tb.vvp
	rm -f icebreaker.json icebreaker.log icebreaker.asc icebreaker.rpt icebreaker.bin
	rm -f icebreaker_syn.v icebreaker_syn_tb.vvp icebreaker_tb.vvp

.PHONY: spiflash_tb clean
.PHONY: hx8kprog hx8kprog_fw hx8ksim hx8ksynsim
.PHONY: icebprog icebprog_fw icebsim icebsynsim

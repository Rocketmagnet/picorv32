/*
 *  PicoSoC - A simple example SoC using PicoRV32
 *
 *  Copyright (C) 2017  Clifford Wolf <clifford@clifford.at>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

#include <stdint.h>
#include <stdbool.h>

#ifdef ICEBREAKER
#  define MEM_TOTAL 0x20000 /* 128 KB */
#elif HX8KDEMO
#  define MEM_TOTAL 0x200 /* 2 KB */
#elif ICEFUN
#  define MEM_TOTAL 0x200 /* 2 KB */
#else
#  error "Set -DICEBREAKER or -DHX8KDEMO when compiling firmware.c"
#endif

// a pointer to this is a null pointer, but the compiler does not
// know that because "sram" is a linker symbol from sections.lds.
extern uint32_t sram;

#define reg_spictrl (*(volatile uint32_t*)0x02000000)
#define reg_uart_clkdiv (*(volatile uint32_t*)0x02000004)
#define reg_uart_data (*(volatile uint32_t*)0x02000008)
#define reg_leds (*(volatile uint32_t*)0x03000000)


int Delay(int d)
{
	int x = 5;
	int i;

	for (i=0; i<d; i++)
	{
		x *= i;
	}
	return x;
}



void Test_Crossbar()
{
	int inputs = 0;
	int switches[8] = {0,1,2,3,4,5,6,7};
	int startSwitch = 0;
	int i;
	int gpio;

	for (i=0; i<8; i++)
	{
		switches[i] = (startSwitch+i) & 7;
	}

	while(1)
	{
		inputs = (inputs+1) & 0xFF;


		
		if ((inputs & 0xFF) == 0)
		{
			for (i=0; i<8; i++)
			{
				switches[i] = (startSwitch+i) & 7;
			}
			startSwitch = (startSwitch+1) & 7;
		}
		

		gpio = 0;
		for (i=0; i<8; i++)
		{
			gpio <<= 3;
			gpio |= switches[i] ^ 7;
		}
		gpio <<= 8;
		gpio |= 0xFF ^ (inputs & 0x000000FF);
		reg_leds = gpio;
		Delay(400);
	}
}

void main()
{
	Test_Crossbar();
}

ask2.hex: ask2.elf
	avr-objcopy -j .text -j .data -O ihex ask2.elf ask2.hex

ask2.elf: ask2.c
	avr-gcc -Wall -Os -mmcu=atmega328p  -o ask2.elf ask2.c


clean:
	rm -f *.hex *.obj *.cof *.lst *.eep.hex *.elf

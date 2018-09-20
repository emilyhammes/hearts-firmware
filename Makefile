PROG= blink

CC= avr-gcc
CXX= avr-g++
CPPFLAGS+= -g -mmcu=attiny13a -Wall -Wextra -O2 -flto -fwhole-program
CXXFLAGS+= -std=gnu++1y
PROGRAMMER= buspirate -P /dev/ttyS3

seed:= $(shell hexdump -n 2 -e '2/1 "%\#x "' /dev/urandom)

all: ${PROG} ${PROG}.hex

flash: ${PROG}
	avrdude -c ${PROGRAMMER} -p t13 -v -U hfuse:w:$^:e -U lfuse:w:$^:e -U flash:w:$^:e -U eeprom:w:'${seed}':m

flash-bulk: ${PROG}
	@while read; do \
		if ${MAKE} flash; then \
			beep -f 400; \
		else \
			beep -f 800; \
			printf "\n\n\nFAIL!\n" >&2; \
		fi; \
	done

clean:
	-rm -f ${PROG} ${PROG}.hex

${PROG}.hex: ${PROG}
	avr-objcopy -I elf32-avr -O ihex $^ $@

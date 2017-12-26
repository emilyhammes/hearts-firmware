PROG= snowflake

CC= avr-gcc
CXX= avr-g++
CPPFLAGS+= -g -mmcu=attiny13a -Wall -Wextra -O2 -flto -fwhole-program
CXXFLAGS+= -std=gnu++1y
PROGRAMMER= avrispmkII

seed:= $(shell hexdump -n 2 -e '2/1 "%\#x "' /dev/urandom)

all: ${PROG}

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
	-rm -f ${PROG}

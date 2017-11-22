PROG= snowflake

CC= avr-gcc
CXX= avr-g++
CPPFLAGS+= -g -mmcu=attiny13a -Wall -Wextra -O2 -flto -fwhole-program
CXXFLAGS+= -std=gnu++1z
PROGRAMMER= avrispmkII

all: ${PROG}

flash: ${PROG}
	avrdude -c ${PROGRAMMER} -p t13 -v -U hfuse:w:$^:e -U lfuse:w:$^:e -U flash:w:$^:e

clean:
	-rm -f ${PROG}

CC= avr-gcc
CFLAGS+= -g -mmcu=attiny13 -Wall -Wextra -std=gnu99
PORT= /dev/serial/by-id/usb-FTDI_FT232R_USB_UART_A5005CUN-if00-port0

all: tinytest

flash: tinytest
	printf "m\n1\n" > ${PORT}
	avrdude -c buspirate -P ${PORT} -p t13 -U flash:w:$^:e
	printf "m\n9\nW\n" > ${PORT}

clean:
	-rm -f tinytest

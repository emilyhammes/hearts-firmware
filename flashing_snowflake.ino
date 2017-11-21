const byte pins[] = {2, 3, 4, 5, 6, 7, 8, 9};  // in AVR PORTD terms, not arduino
const byte nled = sizeof(pins) * (sizeof(pins) - 1);
const byte plex_screen_max = 63; // max supported brightness value 

byte screen[nled];

byte plex_row, plex_col;
byte plex_pos;
byte plex_screen, plex_screen_reverse;

const long update_time = 100;
unsigned long update_last;

const long flash_time = 100;
const long flash_time_min = 0;
unsigned long flash_next;

void plex_cycle(void)
{
  plex_pos++;
  plex_col++; // pick next led
  if (plex_col == plex_row) // never pair with ourselves
    plex_col++;
  if (plex_col > sizeof(pins) - 1) { // serviced all leds in this row?
    plex_col = 0; // start ...
    plex_row++;   // ... on next row
    if (plex_row > sizeof(pins) - 1) {  // serviced all rows?
      plex_row = 0; // start on first row...
      plex_col = 1; // ... and first possible paired pin
      plex_pos = 0;
      plex_screen++;
      if (plex_screen == plex_screen_max)
        plex_screen = 0;
      plex_screen_reverse = __builtin_avr_insert_bits (0xff012345, plex_screen, 0);
    }
  }

  byte mode = (1 << pins[plex_row]) | (1 << pins[plex_col]);
  byte val = (screen[plex_pos] > plex_screen_reverse) << pins[plex_row];
  //DDRD = 0; // remove ghosting
  PORTD = val;
  DDRD = mode;
}

void update_screen(void)
{
  if (millis() - update_last < update_time)
    return;

  update_last = millis();

  // decay
  for (byte i = 0; i < nled; i++) {
    if (screen[i] > 0)
      screen[i] /= 2;
  }

  // flash
  if (millis() >= flash_next) {
    byte target = random(0, nled);
    screen[target] = plex_screen_max;
    flash_next = millis() + flash_time_min + random(0, flash_time);
  }
}

void setup() {
  for (byte i = 0; i < nled; i++) {
    screen[i] = i;
  }
}

void loop() {
  plex_cycle();
  update_screen();
  //delayMicroseconds(10);
}

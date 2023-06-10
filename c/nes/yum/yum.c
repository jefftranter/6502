
/*
A simple "hello world" example.
Set the screen background color and palette colors.
Then write a message to the nametable.
Finally, turn on the PPU to display video.
*/

#include <string.h>
#include "neslib.h"

// link the pattern table into CHR ROM
//#link "chr_generic.s"

void writeRow(byte row, char *s)
{
  vram_adr(NTADR_A(2,row));
  vram_write(s, strlen(s));
}

// main function, run after console reset
void main(void) {

  // set palette colors
  pal_col(0,0x02);	// set screen to dark blue
  pal_col(1,0x14);	// fuchsia
  pal_col(2,0x20);	// grey
  pal_col(3,0x30);	// white

  // write text to name table
  writeRow(2, "      Round 11 of 12");
  writeRow(3, "      Player: Player2");
  writeRow(5, "1's: XX   2's: XX   3's: XX");
  writeRow(6, "4's: XX   5's: XX   6's: XX");
  writeRow(7, "Lo Strht: XX   Hi Strht: XX");
  writeRow(8, "Lo Score: XX   Hi Score: XX");
  writeRow(9, "Full Hse: --      YUM: --");
  
  writeRow(11, "\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0\xa0");
  
  writeRow(13, "Dice (roll 2 of 3):");
  
  writeRow(15, "         \xe0\xe1\xe2\xe3\xe4\xe5\xe6\xe7\xe8\xe9\xea\xeb");
  writeRow(16, "         \xf0\xf1\xf2\xf3\xf4\xf5\xf6\xf7\xf8\xf9\xfa\xfb");

  writeRow(18, "Select dice to reroll,");
  writeRow(19, "Press A to roll");
  
  writeRow(22, "          SCORES");
  writeRow(24, "Player1: XXX Player2: XXX");
  writeRow(25, "Comptr1: XXX Comptr2: XXX");
  
  
  // enable PPU rendering (turn on screen)
  ppu_on_all();

  // infinite loop
  while (1) ;
}

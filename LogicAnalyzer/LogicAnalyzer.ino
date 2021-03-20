/*

   Logic Analyzer for 6502 microprocessor based on a Teensy 4.1
   microcontroller.

   See https://github.com/jefftranter/6502/tree/master/LogicAnalyzer

   Copyright (c) 2021 by Jeff Tranter <tranter@pobox.com>


  Possible enhancements:
  - Qualify trigger to be on address read or write.
  - Trigger on data or control line state.
  - Trigger on state of SPARE1 or SPARE2 pin
  - Disassemble 65C02 instructions.


  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

#include <SD.h>

// Maximum buffer size (in samples). Increase if needed; should be
// able to go up to at least 30,000 before running out of memory.
#define BUFFSIZE 5000

// Some pin numbers
#define PHI2 2
#define RESET 5
#define IRQ 29
#define NMI 33
#define BUTTON 31

const char *versionString = "6502 Logic Analyzer version 0.2 by Jeff Tranter <tranter@pobox.com>";

// Global variables
uint32_t control[BUFFSIZE];           // Recorded control line data
uint32_t address[BUFFSIZE];           // Recorded address data
uint32_t data[BUFFSIZE];              // Recorded data lines
uint32_t triggerAddress;              // Address to trigger on
uint32_t triggerBits;                 // GPIO bit pattern to trigger on
uint32_t triggerMask;                 // bitmask of GPIO bits
uint32_t addressBits;                 // Current address read
int samples = 20;                     // Number of samples to record (up to BUFFSIZE)
bool freerun = false;                 // Indicates trigger or free-run mode (no trigger)
volatile bool triggerPressed = false; // Set by hardware trigger button


// Instructions for 6502 disassembler.
const char *opcodes[] = {
  "BRK", "ORA (nn,X)", "?", "?", "?", "ORA nn", "ASL nn", "?",
  "PHP", "ORA #nn", "ASLA", "?", "?", "ORA nnnn", "ASL nnnn", "?",
  "BPL nn", "ORA (nn),Y", "?", "?", "?", "ORA nn,X", "ASL nn,X", "?",
  "CLC", "ORA nnnn,Y", "?", "?", "?", "ORA nnnn,X", "ASL nnnn,X", "?",
  "JSR nnnn", "AND (nn,X)", "?", "?", "BIT nn", "AND nn", "ROL nn", "?",
  "PLP", "AND #nn", "ROLA", "?", "BIT nnnn", "AND nnnn", "ROL nnnn", "?",
  "BMI nn", "AND (nn),Y", "?", "?", "?", "AND nn,X", "ROL nn,X", "?",
  "SEC", "AND nnnn,Y", "?", "?", "?", "AND nnnn,X", "ROL nnnn,X", "?",
  "RTI", "EOR (nn,X)", "?", "?", "?", "EOR nn", "LSR nn", "?",
  "PHA", "EOR #nn", "LSRA", "?", "JMP nnnn", "EOR nnnn", "LSR nnnn", "?",
  "BVC nn", "EOR (nn),Y", "?", "?", "?", "EOR nn,X", "LSR nn,X", "?",
  "CLI", "EOR nnnn,Y", "?", "?", "?", "EOR nnnn,X", "LSR nnnn,X", "?",
  "RTS", "ADC (nn,X)", "?", "?", "?", "ADC nn", "ROR nn", "?",
  "PLA", "ADC #nn", "RORA", "?", "JMP (nnnn)", "ADC nnnn", "ROR nnnn", "?",
  "BVS nn", "ADC (nn),Y", "?", "?", "?", "ADC nn,X", "ROR nn,X", "?",
  "SEI", "ADC nnnn,Y", "?", "?", "?", "ADC nnnn,X", "ROR nnnn,X", "?",
  "?", "STA (nn,X)", "?", "?", "STY nn", "STA nn", "STX nn", "?",
  "DEY", "?", "TXA", "?", "STY nnnn", "STA nnnn", "STX nnnn", "?",
  "BCC nn", "STA (nn),Y", "?", "?", "STY nn,X", "STA nn,X", "STX nn,Y", "?",
  "TYA", "STA nnnn,Y", "TXS", "?", "?", "STA nnnn,X", "?", "?",
  "LDY #nn", "LDA (nn,X)", "LDX #nn", "?", "LDY nn", "LDA nn", "LDX nn", "?",
  "TAY", "LDA #nn", "TAX", "?", "LDY nnnn", "LDA nnnn", "LDX nnnn", "?",
  "BCS nn", "LDA (nn),Y", "?", "?", "LDY nn,X", "LDA nn,X", "LDX nn,Y", "?",
  "CLV", "LDA nnnn,Y", "TSX", "?", "LDY nnnn,X", "LDA nnnn,X", "LDX nnnn,Y", "?",
  "CPY #nn", "CMP (nn,X)", "?", "?", "CPY nn", "CMP nn", "DEC nn", "?",
  "INY", "CMP #nn", "DEX", "?", "CPY nnnn", "CMP nnnn", "DEC nnnn", "?",
  "BNE nn", "CMP (nn),Y", "?", "?", "?", "CMP nn,X", "DEC nn,X", "?",
  "CLD", "CMP nnnn,Y", "?", "?", "?", "CMP nnnn,X", "DEC nnnn,X", "?",
  "CPX #nn", "SBC (nn,X)", "?", "?", "CPX nn", "SBC nn", "INC nn", "?",
  "INX", "SBC #nn", "NOP", "?", "CPX nnnn", "SBC nnnn", "INC nnnn", "?",
  "BEQ nn", "SBC (nn),Y", "?", "?", "?", "SBC nn,X", "INC nn,X", "?",
  "SED", "SBC nnnn,Y", "?", "?", "?", "SBC nnnn,X", "INC nnnn,X", "?"
};


// Startup function
void setup() {

  // Enable pullups so unused pins go to a known (high) level.
  for (int i = 0; i <= 41; i++) {
    pinMode(i, INPUT_PULLUP);
  }

  // Will use on-board LED to indicate triggering.
  pinMode(CORE_LED0_PIN, OUTPUT);

  // Default trigger address to reset vector
  triggerAddress = 0xfffc;

  // Manual trigger button - low on this pin forces a trigger.
  attachInterrupt(digitalPinToInterrupt(BUTTON), triggerButton, FALLING);

  Serial.begin(115200);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB.
  }

  Serial.setTimeout(60000);
  Serial.println(versionString);
  Serial.println("Type help or ? for help.");
}


// Interrupt handler for trigger button.
void triggerButton()
{
  triggerPressed = true;
}


// Display settings and help info.
void help()
{
  Serial.println(versionString);
  Serial.print("Trigger address: ");
  if (freerun) {
    Serial.println("none (freerun)");
  } else {
    Serial.println(triggerAddress, HEX);
  }
  Serial.print("Sample buffer size: ");
  Serial.println(samples);
  Serial.println("Commands:");
  Serial.println("  s[amples] <number>        - Set number of samples");
  Serial.println("  t[rigger] <address>|none  - Set trigger address");
  Serial.println("  g[o]                      - Start analyzer");
  Serial.println("  l[ist]                    - List samples");
  Serial.println("  e[xport]                  - Export samples as CSV");
  Serial.println("  w[write]                  - Write data to SD card");
  Serial.println("  h[elp] or ?               - Show command usage");
}


// List recorded data.
void list(Stream &stream)
{
  char output[50]; // Holds output string

  // Display data
  for (int i = 0; i < samples; i++) {
    char cycle;
    const char *opcode;
    const char *comment;

    // SYNC high indicates opcode/instruction fetch, otherwise show as read or
    // write.
    if  (control[i] & 0x10) {
      cycle = 'I';
      opcode = opcodes[data[i]];
      String s = opcode;
      // Fill in operands
      if (s.indexOf("nnnn") != -1) {
        char op[5];
        sprintf(op, "%04lX", data[i + 1] + 256 * data[i + 2]);
        s.replace("nnnn", op);
      }
      if (s.indexOf("nn") != -1) {
        char op[3];
        sprintf(op, "%02lX", data[i + 1]);
        s.replace("nn", op);
      }
      opcode = s.c_str();

    } else if (control[i] & 0x08) {
      cycle = 'R';
      opcode = "";
    } else {
      cycle = 'W';
      opcode = "";
    }

    // Check for /RESET, /IRQ, or /NMI active, vector address, or stack access
    if (!(control[i] & 0x04)) {
      comment = "RESET ACTIVE";
    } else if (!(control[i] & 0x02)) {
      comment = "IRQ ACTIVE";
    } else if (!(control[i] & 0x01)) {
      comment = "NMI ACTIVE";
    } else if ((address[i] == 0xfffa) || (address[i] == 0xfffb)) {
      comment = "NMI VECTOR";
    } else if ((address[i] == 0xfffc) || (address[i] == 0xfffd)) {
      comment = "RESET VECTOR";
    } else if ((address[i] == 0xfffe) || (address[i] == 0xffff)) {
      comment = "IRQ/BRK VECTOR";
    } else if ((address[i] >= 0x0100) && (address[i] <= 0x01ff)) {
      comment = "STACK ACCESS";
    } else {
      comment = "";
    }

    sprintf(output, "%04lX  %c  %02lX  %-12s  %s",
            address[i], cycle, data[i], opcode, comment
           );

    stream.println(output);
  }
}


// Show the recorded data in CSV format (e.g. to export to spreadsheet or other program).
void exportCSV(Stream &stream)
{
  // Output header
  stream.println("Index,SYNC,R/W,/RESET,/IRQ,/NMI,Address,Data");

  // Display data
  for (int i = 0; i < samples; i++) {
    char output[50]; // Holds output string
    bool sync = control[i] & 0x10;
    bool rw = control[i] & 0x08;
    bool reset = control[i] & 0x04;
    bool irq = control[i] & 0x02;
    bool nmi = control[i] & 0x01;

    sprintf(output, "%d,%c,%c,%c,%c,%c,%04lX,%02lX",
            i,
            sync ? '1' : '0',
            rw ? '1' : '0',
            reset ? '1' : '0',
            irq ? '1' : '0',
            nmi ? '1' : '0',
            address[i],
            data[i]
           );

    stream.println(output);
  }
}


// Write the recorded data to files on the internal SD card slot.
void writeSD()
{
  const char *CSV_FILE = "analyzer.csv";
  const char *TXT_FILE = "analyzer.txt";

  if (!SD.begin(BUILTIN_SDCARD)) {
    Serial.println("Unable to initialize internal SD card.");
    return;
  }

  // Remove any existing file
  if (SD.exists(CSV_FILE)) {
    SD.remove(CSV_FILE);
  }

  File file = SD.open(CSV_FILE, FILE_WRITE);
  if (file) {
    Serial.print("Writing ");
    Serial.println(CSV_FILE);
    exportCSV(file);
    file.close();
  } else {
    Serial.print("Unable to write ");
    Serial.println(CSV_FILE);
  }

  // Remove any existing file
  if (SD.exists(TXT_FILE)) {
    SD.remove(TXT_FILE);
  }

  file = SD.open(TXT_FILE, FILE_WRITE);
  if (file) {
    Serial.print("Writing ");
    Serial.println(TXT_FILE);
    list(file);
    file.close();
  } else {
    Serial.print("Unable to write ");
    Serial.println(TXT_FILE);
  }
}


// Start recording.
void go()
{
  triggerPressed = false;

  // Scramble the trigger address to match what we will read on the
  // GPIO pins:
  // GPIO:  31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
  // 6502:  15 14 XX XX 09 08 11 10 04 05 XX XX 03 02 06 07 XX XX 13 12 XX XX XX XX XX XX XX XX 00 01 XX XX

  triggerBits = ((triggerAddress & 0x0001) << (3 - 0)) // A0
                + ((triggerAddress & 0x0002) << (2 - 1)) // A1
                + ((triggerAddress & 0x0004) << (18 - 2)) // A2
                + ((triggerAddress & 0x0008) << (19 - 3)) // A3
                + ((triggerAddress & 0x0010) << (23 - 4)) // A4
                + ((triggerAddress & 0x0020) << (22 - 5)) // A5
                + ((triggerAddress & 0x0040) << (17 - 6)) // A6
                + ((triggerAddress & 0x0080) << (16 - 7)) // A7
                + ((triggerAddress & 0x0100) << (26 - 8)) // A8
                + ((triggerAddress & 0x0200) << (27 - 9)) // A9
                + ((triggerAddress & 0x0400) << (24 - 10)) // A10
                + ((triggerAddress & 0x0800) << (25 - 11)) // A11
                + ((triggerAddress & 0x1000) << (12 - 12)) // A12
                + ((triggerAddress & 0x2000) << (13 - 13)) // A13
                + ((triggerAddress & 0x4000) << (30 - 14)) // A14
                + ((triggerAddress & 0x8000) << (31 - 15)); // A15

  triggerMask = 0b11001111110011110011000000001100;

  if (!freerun) { // Wait for trigger mode

    // Wait for trigger condition (trigger address).
    Serial.print("Waiting for trigger address ");
    Serial.print(triggerAddress, HEX);
    Serial.println("...");
    Serial.flush();

    digitalWriteFast(CORE_LED0_PIN, HIGH); // Indicates waiting for trigger

    while (true) {

      // Wait for PHI2 to go from low to high
      while (digitalReadFast(PHI2) == HIGH)
        ;
      while (digitalReadFast(PHI2) == LOW)
        ;

      // Read address lines
      addressBits = GPIO6_PSR;

      // Break out of loop if trigger address seen or trigger button pressed
      if (((addressBits & triggerMask) == (triggerBits & triggerMask)) || triggerPressed) {
        // Read control and data lines to get our first sample
        address[0] = addressBits;
        control[0] = GPIO9_PSR;
        // Wait for PHI2 to go from high to low
        while (digitalReadFast(PHI2) == HIGH)
          ;
        // Read data lines
        data[0] = GPIO7_PSR;
        // Exit loop
        break;
      }
    }

    digitalWriteFast(CORE_LED0_PIN, LOW); // Indicates received trigger

  } else { // Freerun mode, immediately read first sample

    // Wait for PHI2 to go from low to high
    while (digitalReadFast(PHI2) == HIGH)
      ;
    while (digitalReadFast(PHI2) == LOW)
      ;

    // Read address and control lines
    control[0] = GPIO9_PSR;
    address[0] = GPIO6_PSR;

    // Wait for PHI2 to go from high to low
    while (digitalReadFast(PHI2) == HIGH)
      ;

    // Read data lines
    data[0] = GPIO7_PSR;
  }

  // Trigger received, now fill buffer with samples.
  for (int i = 1; i < samples; i++) {

    // Wait for PHI2 to go from low to high
    while (digitalReadFast(PHI2) == HIGH)
      ;
    while (digitalReadFast(PHI2) == LOW)
      ;

    // Read address and control lines
    control[i] = GPIO9_PSR;
    address[i] = GPIO6_PSR;

    // Wait for PHI2 to go from high to low
    while (digitalReadFast(PHI2) == HIGH)
      ;

    // Read data lines
    data[i] = GPIO7_PSR;
  }

  Serial.print("Data recorded (");
  Serial.print(samples);
  Serial.println(" samples).");
  unscramble();
}


// Rearrange sampled bits of data in buffer back into address, data,
// and control lines.
void unscramble()
{
  // Control lines
  for (int i = 0; i < samples; i++) {
    control[i] =
      ((control[i] & CORE_PIN33_BITMASK)   ? 0x01 : 0) // /NMI
      + ((control[i] & CORE_PIN29_BITMASK) ? 0x02 : 0) // /IRQ
      + ((control[i] & CORE_PIN5_BITMASK)  ? 0x04 : 0) // /RESET
      + ((control[i] & CORE_PIN4_BITMASK)  ? 0x08 : 0) // R/W
      + ((control[i] & CORE_PIN3_BITMASK)  ? 0x10 : 0); // SYNC

    // A15...A0
    address[i] =
      ((address[i] & CORE_PIN0_BITMASK)    ? 0x0001 : 0) // A0
      + ((address[i] & CORE_PIN1_BITMASK)  ? 0x0002 : 0) // A1
      + ((address[i] & CORE_PIN14_BITMASK) ? 0x0004 : 0) // A2
      + ((address[i] & CORE_PIN15_BITMASK) ? 0x0008 : 0) // A3
      + ((address[i] & CORE_PIN16_BITMASK) ? 0x0010 : 0) // A4
      + ((address[i] & CORE_PIN17_BITMASK) ? 0x0020 : 0) // A5
      + ((address[i] & CORE_PIN18_BITMASK) ? 0x0040 : 0) // A6
      + ((address[i] & CORE_PIN19_BITMASK) ? 0x0080 : 0) // A7
      + ((address[i] & CORE_PIN20_BITMASK) ? 0x0100 : 0) // A8
      + ((address[i] & CORE_PIN21_BITMASK) ? 0x0200 : 0) // A9
      + ((address[i] & CORE_PIN22_BITMASK) ? 0x0400 : 0) // A10
      + ((address[i] & CORE_PIN23_BITMASK) ? 0x0800 : 0) // A11
      + ((address[i] & CORE_PIN24_BITMASK) ? 0x1000 : 0) // A12
      + ((address[i] & CORE_PIN25_BITMASK) ? 0x2000 : 0) // A13
      + ((address[i] & CORE_PIN26_BITMASK) ? 0x4000 : 0) // A14
      + ((address[i] & CORE_PIN27_BITMASK) ? 0x8000 : 0); // A15

    // D7...D0
    data[i] =
      ((data[i] & CORE_PIN6_BITMASK)    ? 0x01 : 0) // D0
      + ((data[i] & CORE_PIN7_BITMASK)  ? 0x02 : 0) // D1
      + ((data[i] & CORE_PIN8_BITMASK)  ? 0x04 : 0) // D2
      + ((data[i] & CORE_PIN9_BITMASK)  ? 0x08 : 0) // D3
      + ((data[i] & CORE_PIN10_BITMASK) ? 0x10 : 0) // D4
      + ((data[i] & CORE_PIN11_BITMASK) ? 0x20 : 0) // D5
      + ((data[i] & CORE_PIN12_BITMASK) ? 0x40 : 0) // D6
      + ((data[i] & CORE_PIN32_BITMASK) ? 0x80 : 0); // D7
  }
}


void loop() {
  String cmd;

  while (true) {
    Serial.print("% "); // Command prompt
    Serial.flush();

    cmd = "";
    while (true) {
      int c = Serial.read();
      if ((c == '\r') || (c == '\n')) {
        // End of command line.
        break;
      }

      if ((c == '\b') || (c == 0x7f)) { // Handle backspace or delete
        if (cmd.length() > 0) {
          cmd = cmd.remove(cmd.length() - 1); // Remove last character
          Serial.print("\b \b"); // Backspace over last character entered.
          continue;
        }
      }
      if (c != -1) {
        Serial.write((char)c); // Echo character
        cmd += (char)c; // Append to command string
      }
    }

    Serial.println("");

    if ((cmd == "help") || (cmd == "?") || (cmd == "h")) {
      help();

    } else if (cmd.startsWith("samples ") || cmd.startsWith("s ")) {
      int n = 0;
      if (cmd.startsWith("samples ")) {
        n = cmd.substring(8).toInt();
      }  else if (cmd.startsWith("s ")) {
        n = cmd.substring(2).toInt();
      }

      if ((n >= 0) && (n <= BUFFSIZE)) {
        samples = n;
      } else {
        Serial.print("Invalid samples, must be between 1 and ");
        Serial.print(BUFFSIZE);
        Serial.println(".");
      }

    } else if ((cmd == "t none") || (cmd == "trigger none")) {
      freerun = true;
    } else if (cmd.startsWith("trigger ") || cmd.startsWith("t ")) {
      int n = 0;
      if (cmd.startsWith("trigger ")) {
        n = strtol(cmd.substring(8).c_str(), NULL, 16);
      } else if (cmd.startsWith("t ")) {
        n = strtol(cmd.substring(2).c_str(), NULL, 16);
      }

      if ((n >= 0) && (n <= 0xffff)) {
        triggerAddress = n;
        freerun = false;
      } else {
        Serial.println("Invalid address, must be between 0 and FFFF.");
      }

    } else if ((cmd == "go") || (cmd == "g")) {
      go();

    } else if ((cmd == "list") || (cmd == "l")) {
      list(Serial);

    } else if ((cmd == "export") || (cmd == "e")) {
      exportCSV(Serial);

    } else if ((cmd == "write") || (cmd == "w")) {
      writeSD();

    } else {
      if (cmd != "") {
        Serial.print("Invalid command: '");
        Serial.print(cmd);
        Serial.println("'!");
      }
    }
  }
}

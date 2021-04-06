/*

   Logic Analyzer for 6502 or 6809 microprocessors based on a Teensy
   4.1 microcontroller.

   See https://github.com/jefftranter/6502/tree/master/LogicAnalyzer

   Copyright (c) 2021 by Jeff Tranter <tranter@pobox.com>

   To Do:
  - Monitor /FIRQ pin (6809)
  - Monitor BA and BS pins (6809)
  - Support disassembly of 6809 instructions


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

// Uncomment one of the following three lines to determine what
// processor to support. 65C02 is identical to 6502 except it supports
// disassembly of the additional 65C02 instructions.
//#define D6502
#define D65C02
//#define D6809

// Some pin numbers
#if defined(D6502) || defined(D65C02)
#define PHI2 2
#endif
#if defined(D6809)
#define E 2
#define Q 3
#endif
#define RESET 5
#define IRQ 29
#define NMI 33
#define BUTTON 31

#if defined(D6502)
const char *versionString = "6502 Logic Analyzer version 0.24 by Jeff Tranter <tranter@pobox.com>";
#elif defined(D65C02)
const char *versionString = "65C02 Logic Analyzer version 0.24 by Jeff Tranter <tranter@pobox.com>";
#elif defined(D6809)
const char *versionString = "6809 Logic Analyzer version 0.24 by Jeff Tranter <tranter@pobox.com>";
#else
#error "No processor defined!"
#endif

// Macros
#if defined(D6502) || defined(D65C02)
#define WAIT_PHI2_LOW while (digitalReadFast(PHI2) == HIGH) ;
#define WAIT_PHI2_HIGH while (digitalReadFast(PHI2) == LOW) ;
#endif
#if defined(D6809)
#define WAIT_Q_LOW while (digitalReadFast(Q) == HIGH) ;
#define WAIT_Q_HIGH while (digitalReadFast(Q) == LOW) ;
#define WAIT_E_LOW while (digitalReadFast(E) == HIGH) ;
#define WAIT_E_HIGH while (digitalReadFast(E) == LOW) ;
#endif

// Type definitions
typedef enum trigger_t { tr_address, tr_data, tr_reset, tr_irq, tr_nmi, tr_spare1, tr_spare2, tr_none } trigger_t;
typedef enum cycle_t { tr_read, tr_write, tr_either } access_t;

// Global variables
uint32_t control[BUFFSIZE];           // Recorded control line data
uint32_t address[BUFFSIZE];           // Recorded address data
uint32_t data[BUFFSIZE];              // Recorded data lines
uint32_t triggerAddress;              // Address or data to trigger on
uint32_t aTriggerBits;                // GPIO bit pattern to trigger address on
uint32_t aTriggerMask;                // bitmask of GPIO address bits
uint32_t cTriggerBits;                // GPIO bit pattern to trigger control on
uint32_t cTriggerMask;                // bitmask of GPIO control bits
uint32_t dTriggerBits;                // GPIO bit pattern to trigger data on
uint32_t dTriggerMask;                // bitmask of GPIO data bits
int samples = 20;                     // Total number of samples to record (up to BUFFSIZE)
int pretrigger = 3;                   // Number of samples to record before trigger (up to samples)
int triggerPoint = 0;                 // Sample in buffer corresponding to trigger point
trigger_t triggerMode = tr_address;   // Type of trigger
cycle_t triggerCycle = tr_either;     // Trigger on read, write, or either
bool triggerLevel = false;            // Trigger level (false=low, true=high);
volatile bool triggerPressed = false; // Set by hardware trigger button

#ifdef D65C02
// Instructions for 6502 disassembler.
const char *opcodes[256] = {
  "BRK", "ORA (nn,X)", "?", "?", "TSB nn", "ORA nn", "ASL nn", "RMB0 nn",
  "PHP", "ORA #nn", "ASLA", "?", "TSB XXXX", "ORA nn", "ASL nn", "BBR0 nn",
  "BPL nn", "ORA (nn),Y", "ORA (nn)", "?", "TRB nn", "ORA nn,X", "ASL nn,X", "RMB1 nn",
  "CLC", "ORA nn,Y", "INCA", "?", "TRB nn", "ORA nn,X", "ASL nn,X", "BBR1 nn",
  "JSR nn", "AND (nn,X)", "?", "?", "BIT nn", "AND nn", "ROL nn", "RMB2 nn",
  "PLP", "AND #nn", "ROLA", "?", "BIT nn", "AND nn", "ROL nn", "BBR2 nn",
  "BMI nn", "AND (nn),Y", "AND (nn)", "?", "BIT nn,X", "AND nn,X", "ROL nn,X", "RMB3 nn",
  "SEC", "AND nn,Y", "DECA", "?", "BIT nn,X", "AND nn,X", "ROL nn,X", "BBR3 nn",
  "RTI", "EOR (nn,X)", "?", "?", "?", "EOR nn", "LSR nn", "RMB4 nn",
  "PHA", "EOR #nn", "LSRA", "?", "JMP nn", "EOR nn", "LSR nn", "BBR4 nn",
  "BVC nn", "EOR (nn),Y", "EOR (nn)", "?", "?", "EOR nn,X", "LSR nn,X", "RMB5 nn",
  "CLI", "EOR nn,Y", "PHY", "?", "?", "EOR nn,X", "LSR nn,X", "BBR5 nn",
  "RTS", "ADC (nn,X)", "?", "?", "STZ nn", "ADC nn", "ROR nn", "RMB6 nn",
  "PLA", "ADC #nn", "RORA", "?", "JMP (nn)", "ADC nn", "ROR nn", "BBR6 nn",
  "BVS nn", "ADC (nn),Y", "ADC (nn)", "?", "STZ nn,X", "ADC nn,X", "ROR nn,X", "RMB7 nn",
  "SEI", "ADC nn,Y", "PLY", "?", "JMP (nn,X)", "ADC nn,X", "ROR nn,X", "BBR7 nn",
  "BRA nn", "STA (nn,X)", "?", "?", "STY nn", "STA nn", "STX nn", "SMB0 nn",
  "DEY", "BIT #nn", "TXA", "?", "STY nn", "STA nn", "STX nn", "BBS0 nn",
  "BCC nn", "STA (nn),Y", "STA (nn)", "?", "STY nn,X", "STA nn,X", "STX (nn),Y", "SMB1 nn",
  "TYA", "STA nn,Y", "TXS", "?", "STZ nn", "STA nn,X", "STZ nn,X", "BBS1 nn",
  "LDY #nn", "LDA (nn,X)", "LDX #nn", "?", "LDY nn", "LDA nn", "LDX nn", "SMB2 nn",
  "TAY", "LDA #nn", "TAX", "?", "LDY nn", "LDA nn", "LDX nn", "BBS2 nn",
  "BCS nn", "LDA (nn),Y", "LDA (nn)", "?", "LDY nn,X", "LDA nn,X", "LDX (nn),Y", "SMB3 nn",
  "CLV", "LDA nn,Y", "TSX", "?", "LDY nn,X", "LDA nn,X", "LDX nn,Y", "BBS3 nn",
  "CPY #nn", "CMP (nn,X)", "?", "?", "CPY nn", "CMP nn", "DEC nn", "SMB4 nn",
  "INY", "CMP #nn", "DEX", "WAI", "CPY nn", "CMP nn", "DEC nn", "BBS4 nn",
  "BNE nn", "CMP (nn),Y", "CMP (nn)", "?", "?", "CMP nn,X", "DEC nn,X", "SMB5 nn",
  "CLD", "CMP nn,Y", "PHX", "STP", "?", "CMP nn,X", "DEC nn,X", "BBS5 nn",
  "CPX #nn", "SBC (nn,X)", "?", "?", "CPX nn", "SBC nn", "INC nn", "SMB6 nn",
  "INX", "SBC #nn", "NOP", "?", "CPX nn", "SBC nn", "INC nn", "BBS6 nn",
  "BEQ nn", "SBC (nn),Y", "SBC (nn)", "?", "?", "SBC nn,X", "INC nn,X", "SMB7 nn",
  "SED", "SBC nn,Y", "PLX", "?", "?", "SBC nn,X", "INC nn,X", "BBS7 nnnn"
};
#endif

#ifdef D6502
// Instructions for 6502 disassembler.
const char *opcodes[256] = {
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
#endif

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
  Serial.println("Type h or ? for help.");
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
  Serial.print("Trigger: ");
  switch (triggerMode) {
    case tr_address:
      Serial.print("on address ");
      Serial.print(triggerAddress, HEX);
      switch (triggerCycle) {
        case tr_read:
          Serial.println(" read");
          break;
        case tr_write:
          Serial.println(" write");
          break;
        case tr_either:
          Serial.println(" read or write");
          break;
      }
      break;
    case tr_data:
      Serial.print("on data ");
      Serial.print(triggerAddress, HEX);
      switch (triggerCycle) {
        case tr_read:
          Serial.println(" read");
          break;
        case tr_write:
          Serial.println(" write");
          break;
        case tr_either:
          Serial.println(" read or write");
          break;
      }
      break;
    case tr_reset:
      Serial.print("on /RESET ");
      Serial.println(triggerLevel ? "high" : "low");
      break;
    case tr_irq:
      Serial.print("on /IRQ ");
      Serial.println(triggerLevel ? "high" : "low");
      break;
    case tr_nmi:
      Serial.print("on /NMI ");
      Serial.println(triggerLevel ? "high" : "low");
      break;
    case tr_spare1:
      Serial.print("on SPARE1 ");
      Serial.println(triggerLevel ? "high" : "low");
      break;
    case tr_spare2:
      Serial.print("on SPARE2 ");
      Serial.println(triggerLevel ? "high" : "low");
      break;
    case tr_none:
      Serial.println("none (freerun)");
      break;
  }

  Serial.print("Sample buffer size: ");
  Serial.println(samples);
  Serial.print("Pretrigger samples: ");
  Serial.println(pretrigger);
  Serial.println("Commands:");
  Serial.println("s <number>           - Set number of samples");
  Serial.println("p <samples>          - Set pre-trigger samples");
  Serial.println("t a <address> [r|w]  - Trigger on address");
  Serial.println("t d <data> [r|w]     - Trigger on data");
  Serial.println("t reset 0|1          - Trigger on /RESET level");
  Serial.println("t irq 0|1            - Trigger on /IRQ level");
  Serial.println("t nmi 0|1            - Trigger on /NMI level");
  Serial.println("t spare1 0|1         - Trigger on SPARE1 level");
  Serial.println("t spare2 0|1         - Trigger on SPARE2 level");
  Serial.println("t none               - Trigger freerun");
  Serial.println("g                    - Go/start analyzer");
  Serial.println("l [start] [end]      - List samples");
  Serial.println("e                    - Export samples as CSV");
  Serial.println("w                    - Write data to SD card");
  Serial.println("h or ?               - Show command usage");
}


// List recorded data from start to end.
void list(Stream &stream, int start, int end)
{
  char output[50]; // Holds output string

  int first = (triggerPoint - pretrigger + samples) % samples;
  int last = (triggerPoint - pretrigger + samples - 1) % samples;

  // Display data
  int i = first;
  int j = 0;
  while (true) {
    char cycle;
#if defined(D6502) || defined(D65C02)
    const char *opcode;
#endif
    const char *comment;

    if ((j >= start) && (j <= end)) {

      // 6502 SYNC high indicates opcode/instruction fetch, otherwise
      // show as read or write.
#if defined(D6502) || defined(D65C02)
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
#endif

#if defined(D6809)
      if (control[i] & 0x08) {
        cycle = 'R';
      } else {
        cycle = 'W';
      }
#endif

      // Check for 6502 /RESET, /IRQ, or /NMI active, vector address, or
      // stack access
#if defined(D6502) || defined(D65C02)
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
#endif

      // Check for 6502 /RESET, /IRQ, or /NMI active, vector address.
#if defined(D6809)
      if (!(control[i] & 0x04)) {
        comment = "RESET ACTIVE";
      } else if (!(control[i] & 0x02)) {
        comment = "IRQ ACTIVE";
      } else if (!(control[i] & 0x01)) {
        comment = "NMI ACTIVE";
      } else if ((address[i] == 0xfff2) || (address[i] == 0xfff3)) {
        comment = "SWI3 VECTOR";
      } else if ((address[i] == 0xfff4) || (address[i] == 0xfff5)) {
        comment = "SWI2 VECTOR";
      } else if ((address[i] == 0xfff6) || (address[i] == 0xfff7)) {
        comment = "FIRQ VECTOR";
      } else if ((address[i] == 0xfff8) || (address[i] == 0xfff8)) {
        comment = "IRQ VECTOR";
      } else if ((address[i] == 0xfffa) || (address[i] == 0xfffb)) {
        comment = "SWI VECTOR";
      } else if ((address[i] == 0xfffc) || (address[i] == 0xfffd)) {
        comment = "NMI VECTOR";
      } else if (address[i] == 0xfffe) { // Not 0xffff since it commonly occurs when bus is tri-state
        comment = "RESET VECTOR";
      } else {
        comment = "";
      }
#endif

      // Indicate when trigger happened
      if (i == triggerPoint) {
        comment = "<--- TRIGGER ----";
      }

#if defined(D6502) || defined(D65C02)
      sprintf(output, "%04lX  %c  %02lX  %-12s  %s",
              address[i], cycle, data[i], opcode, comment
             );
#endif

#if defined(D6809)
      sprintf(output, "%04lX  %c  %02lX  %s",
              address[i], cycle, data[i], comment
             );
#endif
      stream.println(output);
    }

    if (i == last) {
      break;
    }

    i = (i + 1) % samples;
    j++;
  }
}


// Show the recorded data in CSV format (e.g. to export to spreadsheet or other program).
void exportCSV(Stream &stream)
{
  // Output header
#if defined(D6502) || defined(D65C02)
  stream.println("Index,SYNC,R/W,/RESET,/IRQ,/NMI,Address,Data");
#endif
#if defined(D6809)
  stream.println("Index,R/W,/RESET,/IRQ,/NMI,Address,Data");
#endif

  int first = (triggerPoint - pretrigger + samples) % samples;
  int last = (triggerPoint - pretrigger + samples - 1) % samples;

  // Display data
  int i = first;
  int j = 0;
  while (true) {
    char output[50]; // Holds output string
#if defined(D6502) || defined(D65C02)
    bool sync = control[i] & 0x10;
#endif
    bool rw = control[i] & 0x08;
    bool reset = control[i] & 0x04;
    bool irq = control[i] & 0x02;
    bool nmi = control[i] & 0x01;

#if defined(D6502) || defined(D65C02)
    sprintf(output, "%d,%c,%c,%c,%c,%c,%04lX,%02lX",
            j,
            sync ? '1' : '0',
            rw ? '1' : '0',
            reset ? '1' : '0',
            irq ? '1' : '0',
            nmi ? '1' : '0',
            address[i],
            data[i]
           );
#endif
#if defined(D6809)
    sprintf(output, "%d,%c,%c,%c,%c,%04lX,%02lX",
            j,
            rw ? '1' : '0',
            reset ? '1' : '0',
            irq ? '1' : '0',
            nmi ? '1' : '0',
            address[i],
            data[i]
           );
#endif

    stream.println(output);

    if (i == last) {
      break;
    }

    i = (i + 1) % samples;
    j++;
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
    list(file, 0, samples - 1);
    file.close();
  } else {
    Serial.print("Unable to write ");
    Serial.println(TXT_FILE);
  }
}


// Start recording.
void go()
{
  // Scramble the trigger address, control, and data lines to match what we will read on the ports.
  if (triggerMode == tr_address) {
    // GPIO port 6 pins:
    // GPIO:   31  30  29  28  27  26  25  24  23  22  21  20  19  18  17  16  15  14  13  12  11  10  09  08  07  06  05  04  03  02  01  00
    // 6502:  A15 A14  XXX SP1 A09 A08 A11 A10 A04 A05 XXX XXX A03 A02 A06 A07 XXX XXX A13 A12 XXX XXX XXX XXX XXX XXX XXX XXX A00 A01 XXX XXX
    aTriggerBits = ((triggerAddress & 0x0001) << (3 - 0)) // A0
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
    aTriggerMask = 0b11001111110011110011000000001100;
    dTriggerBits = 0;
    dTriggerMask = 0;

    // Check for r/w qualifer
    if (triggerCycle == tr_read) {
      cTriggerBits = 0b00000000000000000000000001000000;
      cTriggerMask = 0b00000000000000000000000001000000;
    } else if (triggerCycle == tr_write) {
      cTriggerBits = 0b00000000000000000000000000000000;
      cTriggerMask = 0b00000000000000000000000001000000;
    } else {
      cTriggerBits = 0;
      cTriggerMask = 0;
    }

  } else if (triggerMode == tr_data) {
    // GPIO port 7 pins:
    // GPIO:   31  30  29  28  27  26  25  24  23  22  21  20  19  18  17  16  15  14  13  12  11  10  09  08  07  06  05  04  03  02  01  00
    // 6502:  XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX D01 D02 XXX XXX XXX D07 D03 D00 SP2 XXX XXX XXX XXX XXX LED D05 D06 D04
    dTriggerBits = ((triggerAddress & 0x0001) << (10 - 0)) // D0
                   + ((triggerAddress & 0x0002) << (17 - 1)) // D1
                   + ((triggerAddress & 0x0004) << (16 - 2)) // D2
                   + ((triggerAddress & 0x0008) << (11 - 3)) // D3
                   + ((triggerAddress & 0x0010) >> (4 - 0)) // D4
                   + ((triggerAddress & 0x0020) >> (5 - 2)) // D5
                   + ((triggerAddress & 0x0040) >> (6 - 1)) // D6
                   + ((triggerAddress & 0x0080) << (12 - 7)); // D7
    dTriggerMask = 0b00000000000000110001110000000111;
    aTriggerBits = 0;
    aTriggerMask = 0;

    // Check for r/w qualifer
    if (triggerCycle == tr_read) {
      cTriggerBits = 0b00000000000000000000000001000000;
      cTriggerMask = 0b00000000000000000000000001000000;
    } else if (triggerCycle == tr_write) {
      cTriggerBits = 0b00000000000000000000000000000000;
      cTriggerMask = 0b00000000000000000000000001000000;
    } else {
      cTriggerBits = 0;
      cTriggerMask = 0;
    }

  } else if (triggerMode == tr_reset) {
    // GPIO port 9 pins:
    // GPIO:   31  30  29  28  27  26  25  24  23  22  21  20  19  18  17  16  15  14  13  12  11  10  09  08  07  06  05  04  03  02  01  00
    // 6502:  IRQ XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX XXX RST NMI R/W SYN PH2 XXX XXX XXX XXX
    cTriggerBits = triggerLevel ? 0b00000000000000000000000100000000 : 0;
    cTriggerMask = 0b00000000000000000000000100000000;
    aTriggerBits = 0;
    aTriggerMask = 0;
    dTriggerBits = 0;
    dTriggerMask = 0;
  } else if (triggerMode == tr_irq) {
    cTriggerBits = triggerLevel ? 0b10000000000000000000000000000000 : 0;
    cTriggerMask = 0b10000000000000000000000000000000;
    aTriggerBits = 0;
    aTriggerMask = 0;
    dTriggerBits = 0;
    dTriggerMask = 0;
  } else if (triggerMode == tr_nmi) {
    cTriggerBits = triggerLevel ? 0b00000000000000000000000010000000 : 0;
    cTriggerMask = 0b00000000000000000000000010000000;
    aTriggerBits = 0;
    aTriggerMask = 0;
    dTriggerBits = 0;
    dTriggerMask = 0;
  } else if (triggerMode == tr_spare1) {
    aTriggerBits = triggerLevel ? 0b00010000000000000000000000000000 : 0;
    aTriggerMask = 0b00010000000000000000000000000000;
    cTriggerBits = 0;
    cTriggerMask = 0;
    dTriggerBits = 0;
    dTriggerMask = 0;
  } else if (triggerMode == tr_spare2) {
    dTriggerBits = triggerLevel ? 0b00000000000000000000001000000000 : 0;
    dTriggerMask = 0b00000000000000000000001000000000;
    aTriggerBits = 0;
    aTriggerMask = 0;
    dTriggerBits = 0;
    dTriggerMask = 0;
  } else if (triggerMode == tr_none) {
    aTriggerBits = 0;
    aTriggerMask = 0;
    dTriggerBits = 0;
    dTriggerMask = 0;
    cTriggerBits = 0;
    cTriggerMask = 0;
  }

  Serial.println("Waiting for trigger...");

  triggerPressed = false; // Status of trigger button

  digitalWriteFast(CORE_LED0_PIN, HIGH); // Indicates waiting for trigger

  int i = 0; // Index into data buffers
  int samplesTaken = 0; // Number of samples taken
  bool triggered = false; // Set when triggered

  while (true) {

#if defined(D6502) || defined(D65C02)
    // Wait for PHI2 to go from low to high
    WAIT_PHI2_LOW;
    WAIT_PHI2_HIGH;
#endif
#if defined(D6809)
    // Wait for Q to go from low to high
    WAIT_Q_LOW;
    WAIT_Q_HIGH;
#endif

    // Read address and control lines
    control[i] = GPIO9_PSR;
    address[i] = GPIO6_PSR;

#if defined(D6502) || defined(D65C02)
    // Wait for PHI2 to go from high to low
    WAIT_PHI2_HIGH;
    WAIT_PHI2_LOW;
#endif
#if defined(D6809)
    // Wait for E to go from high to low
    WAIT_E_HIGH;
    WAIT_E_LOW;
#endif

    // Read data lines
    data[i] = GPIO7_PSR;

    // Set triggered flag if trigger button pressed or trigger seen
    // If triggered, increment buffer index
    if (!triggered) {
      if (triggerPressed ||
          (((address[i] & aTriggerMask) == (aTriggerBits & aTriggerMask)) &&
           ((data[i] & dTriggerMask) == (dTriggerBits & dTriggerMask)) &&
           ((control[i] & cTriggerMask) == (cTriggerBits & cTriggerMask)))) {
        triggered = true;
        triggerPoint = i;
        digitalWriteFast(CORE_LED0_PIN, LOW); // Indicates received trigger
      }
    }

    // Count number of samples taken after trigger
    if (triggered) {
      samplesTaken++;
    }

    // Exit when buffer is full of samples
    if (samplesTaken >= (samples - pretrigger)) {
      break;
    }

    i = (i + 1) % samples; // Increment index, wrapping around at end for circular buffer
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
      + ((control[i] & CORE_PIN3_BITMASK)  ? 0x10 : 0); // SYNC (6502)

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

    // Help
    if ((cmd == "h") || (cmd == "?")) {
      help();

      // Samples
    } else if (cmd.startsWith("s ")) {
      int n = 0;
      n = cmd.substring(2).toInt();

      if ((n > 0) && (n <= BUFFSIZE)) {
        samples = n;
        memset(control, 0, sizeof(control)); // Clear existing data
        memset(address, 0, sizeof(address));
        memset(data, 0, sizeof(data));
      } else {
        Serial.print("Invalid samples, must be between 1 and ");
        Serial.print(BUFFSIZE);
        Serial.println(".");
      }

      // Pretrigger
    } else if (cmd.startsWith("p ")) {
      int n = 0;
      n = cmd.substring(2).toInt();

      if ((n >= 0) && (n <= samples)) {
        pretrigger = n;
      } else {
        Serial.print("Invalid samples, must be between 0 and ");
        Serial.print(samples);
        Serial.println(".");
      }

      // Trigger
    } else if (cmd == "t none") {
      triggerMode = tr_none;
    } else if (cmd == "t reset 0") {
      triggerMode = tr_reset;
      triggerLevel = false;
    } else if (cmd == "t reset 1") {
      triggerMode = tr_reset;
      triggerLevel = true;
    } else if (cmd == "t irq 0") {
      triggerMode = tr_irq;
      triggerLevel = false;
    } else if (cmd == "t irq 1") {
      triggerMode = tr_irq;
      triggerLevel = true;
    } else if (cmd == "t nmi 0") {
      triggerMode = tr_nmi;
      triggerLevel = false;
    } else if (cmd == "t nmi 1") {
      triggerMode = tr_nmi;
      triggerLevel = true;
    } else if (cmd == "t spare1 0") {
      triggerMode = tr_spare1;
      triggerLevel = false;
    } else if (cmd == "t spare1 1") {
      triggerMode = tr_spare1;
      triggerLevel = true;
    } else if (cmd == "t spare2 0") {
      triggerMode = tr_spare2;
      triggerLevel = false;
    } else if (cmd == "t spare2 1") {
      triggerMode = tr_spare2;
      triggerLevel = true;
    } else if (cmd.startsWith("t a ")) {
      int n = strtol(cmd.substring(4, 8).c_str(), NULL, 16);
      if ((n >= 0) && (n <= 0xffff)) {
        triggerAddress = n;
        triggerMode = tr_address;
        if ((cmd.length() == 10) && cmd.endsWith('r')) {
          triggerCycle = tr_read;
        } else if ((cmd.length() == 10) && cmd.endsWith('w')) {
          triggerCycle = tr_write;
        } else {
          triggerCycle = tr_either;
        }
      } else {
        Serial.println("Invalid address, must be between 0 and FFFF.");
      }
    } else if (cmd.startsWith("t d ")) {
      int n = strtol(cmd.substring(4, 6).c_str(), NULL, 16);
      if ((n >= 0) && (n <= 0xff)) {
        triggerAddress = n;
        triggerMode = tr_data;
        if ((cmd.length() == 8) && cmd.endsWith('r')) {
          triggerCycle = tr_read;
        } else if ((cmd.length() == 8) && cmd.endsWith('w')) {
          triggerCycle = tr_write;
        } else {
          triggerCycle = tr_either;
        }
      } else {
        Serial.println("Invalid address, must be between 0 and FFFF.");
      }

      // Go
    } else if (cmd == "g") {
      go();

      // List
    } else if (cmd == "l") {
      list(Serial, 0, samples - 1);
    } else if (cmd.startsWith("l ")) {
      if (cmd.indexOf(" ") == cmd.lastIndexOf(" ")) {
        // l <start>
        int start = cmd.substring(2).toInt();
        if ((start < 0) || (start >= samples)) {
          Serial.print("Invalid start, must be between 0 and ");
          Serial.print(samples - 1);
          Serial.println(".");
        } else {
          list(Serial, start, samples - 1);
        }

      } else {
        // l start end
        int start = cmd.substring(2).toInt();
        int end = cmd.substring(cmd.lastIndexOf(" ")).toInt();
        if ((start < 0) || (start >= samples)) {
          Serial.print("Invalid start, must be between 0 and ");
          Serial.print(samples - 1);
          Serial.println(".");
        } else if ((end < start) || (end >= samples)) {
          Serial.print("Invalid end, must be between ");
          Serial.print(start);
          Serial.print(" and ");
          Serial.print(samples - 1);
          Serial.println(".");
        } else {
          list(Serial, start, end);
        }
      }

      // Export
    } else if (cmd == "e") {
      exportCSV(Serial);

      // Write
    } else if (cmd == "w") {
      writeSD();

      // Invalid command
    } else {
      if (cmd != "") {
        Serial.print("Invalid command: '");
        Serial.print(cmd);
        Serial.println("'!");
      }
    }
  }
}

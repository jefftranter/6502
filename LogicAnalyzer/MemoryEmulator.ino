/*

  RAM/ROM emulator:

  Can emulate RAM when clipped on to a 6502 CPU. The memory must be
  otherwise undecoded, i.e. nothing else can be active on the bus at
  the same time.

  Uses the hardware for my Logic Analyzer for 6502 or 6809
  microprocessors based on a Teensy 4.1 microcontroller.

  See https://github.com/jefftranter/6502/tree/master/LogicAnalyzer

  Copyright (c) 2021 by Jeff Tranter <tranter@pobox.com>

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


// Defines - pin numbers
#define PHI2 2

// Macros
#define WAIT_PHI2_LOW while (digitalReadFast(PHI2) == HIGH) ;
#define WAIT_PHI2_HIGH while (digitalReadFast(PHI2) == LOW) ;

// Global variables

// Simulated RAM
uint32_t ramStartAddress = 0x9000;    // Start address of simulated memory
uint32_t ramEndAddress = 0x9fff;      // End address of simulated memory
uint8_t ramData[0x1000];              // Buffer for simulated memory
bool readWrite;                       // Status of R/W line
uint32_t control;                     // Recorded control line data
uint32_t address;                     // Recorded address data
uint32_t data;                        // Recorded data lines


// Startup function

void setup() {

  // Clear simulated RAM
  for (unsigned int i = 0; i <= ramEndAddress - ramStartAddress; i++) {
    ramData[i] = 0;
  }

  // Enable pullups so unused pins go to a known (high) level.
  for (int i = 0; i <= 41; i++) {
    pinMode(i, INPUT_PULLUP);
  }

  // Data bus direction - output low to default to reading data bus.
  pinMode(30, OUTPUT);
  digitalWriteFast(30, LOW);

  Serial.begin(115200);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB.
  }

  Serial.setTimeout(60000);
  Serial.println("Starting...");
}


void loop() {

  // Wait for PHI2 to go from low to high (address and controls lines valid).
  WAIT_PHI2_LOW;
  WAIT_PHI2_HIGH;

  // Read address and control lines.
  control = GPIO9_PSR;
  address = GPIO6_PSR;

  // Unscramble address lines.
  address =
    ((address & CORE_PIN0_BITMASK)    ? 0x0001 : 0) // A0
    + ((address & CORE_PIN1_BITMASK)  ? 0x0002 : 0) // A1
    + ((address & CORE_PIN14_BITMASK) ? 0x0004 : 0) // A2
    + ((address & CORE_PIN15_BITMASK) ? 0x0008 : 0) // A3
    + ((address & CORE_PIN16_BITMASK) ? 0x0010 : 0) // A4
    + ((address & CORE_PIN17_BITMASK) ? 0x0020 : 0) // A5
    + ((address & CORE_PIN18_BITMASK) ? 0x0040 : 0) // A6
    + ((address & CORE_PIN19_BITMASK) ? 0x0080 : 0) // A7
    + ((address & CORE_PIN20_BITMASK) ? 0x0100 : 0) // A8
    + ((address & CORE_PIN21_BITMASK) ? 0x0200 : 0) // A9
    + ((address & CORE_PIN22_BITMASK) ? 0x0400 : 0) // A10
    + ((address & CORE_PIN23_BITMASK) ? 0x0800 : 0) // A11
    + ((address & CORE_PIN24_BITMASK) ? 0x1000 : 0) // A12
    + ((address & CORE_PIN25_BITMASK) ? 0x2000 : 0) // A13
    + ((address & CORE_PIN26_BITMASK) ? 0x4000 : 0) // A14
    + ((address & CORE_PIN27_BITMASK) ? 0x8000 : 0); // A15

  // Unscramble R/W line
  readWrite = ((control & CORE_PIN4_BITMASK) ? 0x08 : 0); // R/W

  if (address >= ramStartAddress && address <= ramEndAddress) {

    if (readWrite) { // Read cycle

      // Get data at address in simulated RAM.
      data = ramData[address - ramStartAddress];

      // Scramble data for GPIO lines.
      data =
        ((data & 0x0001) << (10 - 0)) // D0
        + ((data & 0x0002) << (17 - 1)) // D1
        + ((data & 0x0004) << (16 - 2)) // D2
        + ((data & 0x0008) << (11 - 3)) // D3
        + ((data & 0x0010) >> (4 - 0)) // D4
        + ((data & 0x0020) >> (5 - 2)) // D5
        + ((data & 0x0040) >> (6 - 1)) // D6
        + ((data & 0x0080) << (12 - 7)); // D7

      // Set data bus to write mode (D30 high).
      digitalWriteFast(30, HIGH);

      // Set GPIO data bus pins to be outputs.
      GPIO7_GDIR = 0xffff; // THIS IS NOT CORRECT!

      // Wait for PHI2 to go from high to low (data lines valid).
      WAIT_PHI2_LOW;

      // Write data to data lines.
      GPIO7_PSR = data; // THIS IS NOT CORRECT!

      // Wait for PHI2 to go from low to high.
      WAIT_PHI2_HIGH;

      // Set data bus pins back to be inputs.
      GPIO7_GDIR = 0x0000; // THIS IS NOT CORRECT!

      // Set data bus to read mode (D30 low)
      digitalWriteFast(30, LOW);

      Serial.print("Read ");
      Serial.print(address, HEX);
      Serial.print("=");
      Serial.println(ramData[address - ramStartAddress], HEX);

    } else { // Write cycle
      // Wait for PHI2 to go from high to low (data lines valid).
      WAIT_PHI2_HIGH;
      WAIT_PHI2_LOW;

      // Read data lines.
      data = GPIO7_PSR;

      // Unscramble data lines.
      data =
        ((data & CORE_PIN6_BITMASK)    ? 0x01 : 0) // D0
        + ((data & CORE_PIN7_BITMASK)  ? 0x02 : 0) // D1
        + ((data & CORE_PIN8_BITMASK)  ? 0x04 : 0) // D2
        + ((data & CORE_PIN9_BITMASK)  ? 0x08 : 0) // D3
        + ((data & CORE_PIN10_BITMASK) ? 0x10 : 0) // D4
        + ((data & CORE_PIN11_BITMASK) ? 0x20 : 0) // D5
        + ((data & CORE_PIN12_BITMASK) ? 0x40 : 0) // D6
        + ((data & CORE_PIN32_BITMASK) ? 0x80 : 0); // D7

      // Save data at address in simulated RAM.
      ramData[address - ramStartAddress] = data;
    }

    //Serial.print("Write ");
    //Serial.print(address, HEX);
    //Serial.print("=");
    //Serial.println(data, HEX);
  }
}

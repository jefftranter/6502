#include <iostream>
#include "sim6502.h"

int main()
{

    Sim6502 sim;

    sim.setRamRange(0x0000, 0x7fff);
    sim.setRomRange(0x8000, 0xffff);
    sim.loadMemory("rom.bin", 0x8000);
    sim.reset();

    sim.dumpMemory(0x8000, 0x81ff);
    sim.setPC(0x8000);
    
    cout << "Running..." << endl;

    for (int i = 0; i < 10; i++) {
        sim.dumpRegisters();
        sim.step();
    }

    return 0;
}

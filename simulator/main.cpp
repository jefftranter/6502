#include <iostream>
#include "sim6502.h"


// TODO: Configure memory to match SuperBoard II image.

// TODO: Generate more extensive test ROM image.

// TODO: Generate real SuperBoard II ROM image.

int main()
{

    Sim6502 sim;

    sim.setRamRange(0x0000, 0x7fff);
    sim.setRomRange(0x8000, 0xffff);

    if (!sim.loadMemory("rom.bin", 0x8000)) {
        return 1;
    }

    sim.dumpMemory(0x8000, 0x802f);
    sim.setPC(0x8000);
    
    cout << "Running..." << endl;

    for (int i = 0; i < 30; i++) {
        sim.dumpRegisters();
        sim.step();
    }

    return 0;
}

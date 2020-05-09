#include <iostream>
#include "sim6502.h"


// TODO: Configure memory to match SuperBoard II image.

// TODO: Generate more extensive test ROM image.

// TODO: Generate real SuperBoard II ROM image.

int main()
{

    Sim6502 sim;

    sim.setRamRange(0x0000, 0x1fff);
    sim.setRomRange(0xf800, 0xffff);

    //if (!sim.loadMemory("rom.bin", 0x8000)) {
    if (!sim.loadMemory("syn600.bin", 0xf800)) {
        return 1;
    }

    //sim.dumpMemory(0x8000, 0x802f);
    sim.dumpMemory(0xf800, 0xffff);
    //sim.setPC(0x8000);
    sim.reset();
    
    cout << "Running..." << endl;

    while (true) {
        sim.dumpRegisters();
        sim.step();
    }

    return 0;
}

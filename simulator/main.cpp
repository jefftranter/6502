#include <iostream>
#include "sim6502.h"

int main()
{
    Sim6502 sim;

    sim.setRamRange(0x0000, 0x1fff);
    sim.setRomRange(0xa000, 0xbfff);
    sim.setRomRange(0xf800, 0xffff);

    if (!sim.loadMemory("syn600.rom", 0xf800)) {
        return 1;
    }
    if (!sim.loadMemory("basic1.rom", 0xa000)) {
        return 1;
    }
    if (!sim.loadMemory("basic2.rom", 0xa800)) {
        return 1;
    }
    if (!sim.loadMemory("basic3.rom", 0xb000)) {
        return 1;
    }
    if (!sim.loadMemory("basic4.rom", 0xb800)) {
        return 1;
    }

    sim.dumpMemory(0xa000, 0xbfff);
    sim.dumpMemory(0xf800, 0xffff);
    sim.reset();
    cout << "Running..." << endl;

    while (true) {
        sim.dumpRegisters();
        sim.step();
    }

    return 0;
}

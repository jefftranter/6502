#include <iostream>
#include "sim6502.h"

/*

This is a 6502 simulator to simulate an Ohio Scientific Superboard II
computer.

It is written in standard C++ and should be portable, but has only
been tested on Linux with the gcc compiler.

*/

int main()
{
    Sim6502 sim;

    // Settings for Ohio Scientific Superboard II
    sim.setRamRange(0x0000, 0x1fff); // 8K
    sim.setRomRange1(0xa000, 0xbfff); // Basic
    sim.setRomRange2(0xf800, 0xffff); // Monitor
    sim.setVideoRange(0xd000, 0xd3ff);
    sim.setPeripheral(Sim6502::MC6850, 0xf000);
    sim.setKeyboard(0xdf00);

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

    //sim.dumpMemory(0xa000, 0xbfff);
    //sim.dumpMemory(0xf800, 0xffff);
    sim.reset();
    cout << "Running..." << endl;

    int i = 0;
    while (true) {
        sim.dumpRegisters();
        sim.step();
        if (i % 100 == 0) {
            sim.dumpVideo();
        }
        i++;
    }

    return 0;
}

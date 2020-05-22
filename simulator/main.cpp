#include <algorithm>
#include <iomanip>
#include <iostream>
#include <sstream>
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
    sim.setRamRange(0x0000, 0x7fff); // 32K
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

    sim.reset();
    cout << "Running..." << endl;

    while (true) {
        string line;

        cout << "> " << flush;
        getline(cin, line);

        if (cin.eof()) {
            cout << endl;
            exit(0);
        }

        // Vector of string to save tokens
        vector <string> tokens;

        // stringstream class check1
        stringstream check1(line);

        string intermediate;

        // Tokenizing on space
        while (getline(check1, intermediate, ' ')) {
            tokens.push_back(intermediate);
        }

        if (tokens.size() > 0) {

            if (tokens[0] == "?") {
                cout << "Commands:" << endl;
                cout << "Breakpoint   B <n or ?> <address>" << endl;
                cout << "Dump         D <start> [<end>]" << endl;
                cout << "Go           G [<address>]" << endl;
                cout << "Help         ?" << endl;
                cout << "Quit         Q" << endl;
                cout << "Registers    R" << endl;
                cout << "Dump Video   V" << endl;
                cout << "Reset        X" << endl;
                cout << "Trace        . [<instructions>]" << endl;

            } else if (tokens[0] == "q" || tokens[0] == "Q") {
                exit(0);

            } else if (tokens[0] == ".") {
                int instructions = 1;
                // Get optional number of instructions to trace
                if (tokens.size() == 2) {
                    instructions = stoi(tokens[1], nullptr, 16);
                }
                for (int i = 0; i < instructions; i++) {
                    sim.step();
                    sim.dumpRegisters();
                }

            } else if (tokens[0] == "r" || tokens[0] == "R") {
                sim.dumpRegisters();

            } else if ((tokens[0] == "d" || tokens[0] == "D") && tokens.size() >= 2) {

                int start = stoi(tokens[1], nullptr, 16);
                int end;
                if (tokens.size() > 2) {
                end = stoi(tokens[2], 0, 16);
                } else {
                    end = start + 15;
                }
                sim.dumpMemory(start, end);

            } else if ((tokens[0] == "b" || tokens[0] == "B")) {

                if (tokens.size() == 1) {
                    // List breakpoints
                    for (auto b: sim.getBreakpoints()) {
                        cout << "Breakpoint at $" << hex << setw(4) <<  b << endl;
                    }
                } else if (tokens.size() == 2) {
                    // Clear breakpoint
                    int address = stoi(tokens[1], nullptr, 16);
                    if (address > 0) {
                        cout << "Adding breakpoint at $" << hex << setw(4) << address << endl;
                        sim.setBreakpoint(address);
                    } else {
                        cout << "Removing breakpoint at $" << hex << setw(4) << -address << endl;
                        sim.clearBreakpoint(-address);
                    }
                }

            } else if ((tokens[0] == "g" || tokens[0] == "G")) {

                // Get optional go address
                if (tokens.size() == 2) {
                    int address = stoi(tokens[1], nullptr, 16);
                    sim.setPC(address);
                }

                // Run until breakpoint hit.
                std::list<uint16_t> breakpoints = sim.getBreakpoints();

                while (true) {
                    sim.step();
                    //sim.dumpRegisters();
                    if (std::find(breakpoints.begin(), breakpoints.end(), sim.pc()) != breakpoints.end()) {
                        cout << "Breakpoint hit at $" << hex << setw(4) << sim.pc() << endl;
                        sim.dumpRegisters();
                        break;
                    }
                }

            } else if ((tokens[0] == "x" || tokens[0] == "X")) {
                sim.reset();

            } else if ((tokens[0] == "v" || tokens[0] == "V")) {
            sim.dumpVideo();

            } else {
                cout << "Invalid command. Type '?' for help." << endl;
            }
        }
    }


    /*
    int i = 0;
    while (true) {
        sim.dumpRegisters();
        sim.step();
        if (i % 100 == 0) {
            sim.dumpVideo();
        }
        i++;
    }

    */

    return 0;
}

/*
 * Class to emulate a 6502 CPU and system with RAM, ROM, and peripherals.
 */

#include <algorithm>
#include <cassert>
#include <iostream>
#include <iomanip>
#include "sim6502.h"

using namespace std;

Sim6502::Sim6502()
{
    // Open files for simulating serial i/o.
    m_serialIn.open(m_serialInFilename, ios::binary);
    if (m_logErrors) {
        if (!m_serialIn.is_open()) {
            cout << "Error: Unable to open serial port file 'serial.in'" << endl;
        }
    }

    m_serialOut.open(m_serialOutFilename, ios::binary);
    if (m_logErrors) {
        if (!m_serialOut.is_open()) {
            cout << "Error: Unable to open serial port file 'serial.out'" << endl;
        }
    }

    // Keyboard lookup tables
    m_row['1'] = m_row['2'] = m_row['3'] = m_row['4'] = m_row['5'] = m_row['6'] = m_row['7'] = 127;
    m_row['8'] = m_row['9'] = m_row['0'] = m_row[':'] = m_row['-'] = m_row[0x7f]             = 191;
    m_row['.'] = m_row['L'] = m_row['O'] = m_row['\n']= m_row['\r']                          = 223;
    m_row['W'] = m_row['E'] = m_row['R'] = m_row['T'] = m_row['Y'] = m_row['U'] = m_row['I'] = 239;
    m_row['S'] = m_row['D'] = m_row['F'] = m_row['G'] = m_row['H'] = m_row['J'] = m_row['K'] = 247;
    m_row['X'] = m_row['C'] = m_row['V'] = m_row['B'] = m_row['N'] = m_row['M'] = m_row[','] = 251;
    m_row['Q'] = m_row['A'] = m_row['Z'] = m_row[' '] = m_row['/'] = m_row[';'] = m_row['P'] = 253;
    m_row[0x1b] = 254;

    // Lowercase versions of above
                 m_row['l'] = m_row['o'] = 223;
    m_row['w'] = m_row['e'] = m_row['r'] = m_row['t'] = m_row['y'] = m_row['u'] = m_row['i'] = 239;
    m_row['s'] = m_row['d'] = m_row['f'] = m_row['g'] = m_row['h'] = m_row['j'] = m_row['k'] = 247;
    m_row['x'] = m_row['c'] = m_row['v'] = m_row['b'] = m_row['n'] = m_row['m']              = 251;
    m_row['q'] = m_row['a'] = m_row['z']                                        = m_row['p'] = 253;


    m_col['Q'] = m_col['X'] = m_col['S'] = m_col['W'] = m_col['.'] = m_col['8'] = m_col['1'] = 127;
    m_col['A'] = m_col['C'] = m_col['D'] = m_col['E'] = m_col['L'] = m_col['9'] = m_col['2'] = 191;
    m_col[0x1b]= m_col['Z'] = m_col['V'] = m_col['F'] = m_col['R'] = m_col['O'] = m_col['0'] = m_col['3'] = 223;
    m_col[' '] = m_col['B'] = m_col['G'] = m_col['T'] = m_col['\n']= m_col[':'] = m_col['4'] = 239;
    m_col['/'] = m_col['N'] = m_col['H'] = m_col['Y'] = m_col['\r']= m_col['-'] = m_col['5'] = 247;
    m_col[';'] = m_col['M'] = m_col['J'] = m_col['U'] = m_col[0x7F]= m_col['6']              = 251;
    m_col['P'] = m_col[','] = m_col['K'] = m_col['I'] = m_col['7']                           = 253;

    // Lowercase versions of above
    m_col['q'] = m_col['x'] = m_col['s'] = m_col['w']                                        = 127;
    m_col['a'] = m_col['c'] = m_col['d'] = m_col['e'] = m_col['l']                           = 191;
                 m_col['z'] = m_col['v'] = m_col['f'] = m_col['r'] = m_col['o']              = 223;
                 m_col['b'] = m_col['g'] = m_col['t']                                        = 239;
                 m_col['n'] = m_col['h'] = m_col['y']                                        = 247;
                 m_col['m'] = m_col['j'] = m_col['u']                                        = 251;
    m_col['p']              = m_col['k'] = m_col['i']                                        = 253;

    // Shifted versions of keys
    m_row['!'] = m_row['"'] = m_row['#'] = m_row['$'] = m_row['%'] = m_row['&'] = m_row['\''] = 127;
    m_row['('] = m_row[')'] = m_row['*'] = m_row['='] = 191;
    m_row['>'] = 223;
    m_row['<'] = m_row['^'] = 251;
    m_row['?'] = m_row['+'] = 253;

    m_col['>'] = m_col['('] = m_col['!'] = 127;
    m_col[')'] = m_col['"'] = 191;
    m_col['#'] = 223;
    m_col['*'] = m_col['$'] = 239;
    m_col['?'] = m_col['='] = m_col['%'] = m_col['^'] = 247;
    m_col['+'] = m_col['&'] = 251;
    m_col['<'] = m_col['\''] = 253;

    m_shifted['!'] = m_shifted['"'] = m_shifted['#'] = m_shifted['$'] = m_shifted['%']
        = m_shifted['&'] = m_shifted['\''] = m_shifted['('] = m_shifted[')'] = m_shifted['*']
        = m_shifted['='] = m_shifted['>'] = m_shifted['<'] = m_shifted['?'] = m_shifted['+']
        = m_shifted['^']
        = true;
}


Sim6502::~Sim6502()
{
    m_serialIn.close();
    m_serialOut.close();
}


void Sim6502::setRamRange(uint16_t start, uint16_t end)
{
    assert(start <= end);
    m_ramStart = start;
    m_ramEnd = end;
}


void Sim6502::setRomRange1(uint16_t start, uint16_t end)
{
    assert(start <= end);
    m_romStart1 = start;
    m_romEnd1 = end;
}


void Sim6502::setRomRange2(uint16_t start, uint16_t end)
{
    assert(start <= end);
    m_romStart2 = start;
    m_romEnd2 = end;
}


void Sim6502::videoRange(uint16_t &start, uint16_t &end) const
{
    start = m_videoStart;
    end = m_videoEnd;
}


void Sim6502::setVideoRange(uint16_t start, uint16_t end)
{
    assert(start <= end);
    m_videoStart = start;
    m_videoEnd = end;
}


void Sim6502::setPeripheral(PeripheralType type, uint16_t start)
{
    assert(type == MC6850);
    m_peripheralStart = start;
}


void Sim6502::setKeyboard(uint16_t start)
{
    m_keyboardStart = start;
}


void Sim6502::reset()
{
    m_regPC = m_memory[0xfffc] + m_memory[0xfffd] * 256;
}


Sim6502::CpuType Sim6502::cpuType()
{
    return m_cpuType;
}


void Sim6502::setCpuType(const CpuType &type)
{
    // TODO: Add support for other CPU variants.
    assert(m_cpuType == MOS6502);
    m_cpuType = type;
}


void Sim6502::irq()
{
    // Ignore if I bit is set.
    if (m_regP & I_BIT) {
        return;
    }

    write(STACK + m_regSP, (m_regPC + 2) >> 8); // Push PC high byte
    m_regSP--;
    write(STACK + m_regSP, (m_regPC + 2) & 0xff); // Push PC low byte
    m_regSP--;
    write(STACK + m_regSP, m_regP); // Push P
    m_regSP--;
    m_regP |= I_BIT; // Set I flag
    m_regPC = m_memory[0xfffe] + m_memory[0xffff] * 256; // Set PC from IRQ vector
    cout << "irq interrupt" << endl;
}


void Sim6502::nmi()
{
    write(STACK + m_regSP, (m_regPC + 2) >> 8); // Push PC high byte
    m_regSP--;
    write(STACK + m_regSP, (m_regPC + 2) & 0xff); // Push PC low byte
    m_regSP--;
    write(STACK + m_regSP, m_regP); // Push P
    m_regSP--;
    m_regPC = m_memory[0xfffa] + m_memory[0xfffb] * 256; // Set PC from NMI vector
    cout << "nmi interrupt" << endl;
}


uint8_t Sim6502::aReg() const
{
    return m_regA;
}


void Sim6502::setAReg(uint8_t val)
{
    m_regA = val;
}


uint8_t Sim6502::xReg() const
{
    return m_regX;
}


void Sim6502::setXReg(uint8_t val)
{
    m_regX = val;
}


uint8_t Sim6502::yReg() const
{
    return m_regY;
}


void Sim6502::setYReg(uint8_t val)
{
    m_regY = val;
}


uint8_t Sim6502::pReg() const
{
    return m_regP;
}


void Sim6502::setPReg(uint8_t val)
{
    m_regP = val;
}


uint8_t Sim6502::sp() const
{
    return m_regSP;
}


void Sim6502::setSP(uint8_t val)
{
    m_regSP = val;
}


uint16_t Sim6502::pc() const
{
    return m_regPC;
}


void Sim6502::setPC(uint16_t val)
{
    m_regPC = val;
}


void Sim6502::write(uint16_t address, uint8_t byte)
{
    assert(address >= 0);
    assert(address <= 0xffff);

    if (!m_writeWatchpoints.empty()) {
        if (std::find(m_writeWatchpoints.begin(), m_writeWatchpoints.end(), address) != m_writeWatchpoints.end()) {
            m_stop = true;
            m_stopReason = "write watchpoint hit";
        }
    }

    if (isRam(address)) {
        m_memory[address] = byte;
    } else if (isRom(address)) {
        if (m_logMemory) {
            cout << "Memory: attempt to write to ROM address $" << setw(4) << address << endl;
        }
    } else if (isVideo(address)) {
        writeVideo(address, byte);
    } else if (isPeripheral(address)) {
        writePeripheral(address, byte);
    } else if (isKeyboard(address)) {
        writeKeyboard(address, byte);
    } else {
        if (m_logMemory) {
            cout << "Memory: Write to unused memory at $" << setw(4) << address << endl;
        }
    }
}


void Sim6502::writeVideo(uint16_t address, uint8_t byte)
{
    if (m_logVideo) {
        cout << "Video: Wrote $" << setw(2) << hex << (int)byte << " to video RAM at $" << hex << setw(4) << address << endl;
    }
    m_memory[address] = byte;
}


void Sim6502::writePeripheral(uint16_t address, uint8_t byte)
{
    if (address == m_peripheralStart) {
        m_6850_control_reg = byte;

        if (m_logSerial) {
            cout << "Serial: Wrote $" << hex << setfill('0') << setw(2) << (int)byte << " to MC6850 Control Register" << endl;

            switch (byte & 0x03) {
            case 0x00:
                cout << "Serial: Clock: divide by 1" << endl;
                break;
            case 0x01:
                cout << "Serial: Clock: divide by 16" << endl;
                break;
            case 0x02:
                cout << "Serial: Clock: divide by 64" << endl;
                break;
            case 0x03:
                cout << "Serial: Clock: master reset" << endl;
                break;
            }

            switch ((byte >> 2) & 0x07) {
            case 0x00:
                cout << "Serial: Protocol 7E2" << endl;
                break;
            case 0x01:
                cout << "Serial: Protocol 7O2" << endl;
                break;
            case 0x02:
                cout << "Serial: Protocol 7E1" << endl;
                break;
            case 0x03:
                cout << "Serial: Protocol 7O1" << endl;
                break;
            case 0x04:
                cout << "Serial: Protocol 8N2" << endl;
                break;
            case 0x05:
                cout << "Serial: Protocol 8N1" << endl;
                break;
            case 0x06:
                cout << "Serial: Protocol 78E1" << endl;
                break;
            case 0x07:
                cout << "Serial: Protocol 8O1" << endl;
                break;
            }

            switch ((byte >> 5) & 0x03) {
            case 0x00:
                cout << "Serial: /RTS low, TX int. disabled" << endl;
                break;
            case 0x01:
                cout << "Serial: /RTS low, TX int. enabled" << endl;
                break;
            case 0x02:
                cout << "Serial: /RTS high, TX int. disabled" << endl;
                break;
            case 0x03:
                cout << "Serial: /RTS low, transmit break" << endl;
                break;
            }

            if (byte & 0x80) {
                cout << "Serial: Enable interrupts" << endl;
            } else {
                cout << "Serial: Disable interrupts" << endl;
            }
        }

    } else if (address == m_peripheralStart + 1) {
        m_6850_data_reg = byte;
        if (m_logSerial) {
            if (isprint(byte)) {
                cout << "Serial: Wrote '" << (char)byte << "' to MC6850 Data Register" << endl;
            } else {
                cout << "Serial: Wrote $" << hex << setfill('0') << setw(2) << (int)byte << " to MC6850 Data Register" << endl;
            }
        }
        if (byte != 0x00) { // Filter out NULLs
            m_serialOut << (char)byte << flush;
        }
    } else {
        assert(false); // Should never be reached
    }
}


void Sim6502::writeKeyboard(uint16_t address, uint8_t byte)
{
    assert(isKeyboard(address));
    m_keyboardRowRegister = byte;
    if (m_logKeyboard) {
        cout << "Keyboard: wrote $" << hex << setw(2) << (int)byte << " to row register" << endl;
    }
}


uint8_t Sim6502::read(uint16_t address)
{
    assert(address >= 0);
    assert(address <= 0xffff);

    if (!m_readWatchpoints.empty()) {
        if (std::find(m_readWatchpoints.begin(), m_readWatchpoints.end(), address) != m_readWatchpoints.end()) {
            m_stop = true;
            m_stopReason = "read watchpoint hit";
        }
    }

    if (isRam(address) || isRom(address)) {
        return m_memory[address];
    }
    if (isVideo(address)) {
        return readVideo(address);
    }
    if (isPeripheral(address)) {
        return readPeripheral(address);
    }
    if (isKeyboard(address)) {
        return readKeyboard(address);
    } else {
        if (m_logMemory) {
            cout << "Memory: Read from unused memory at $" << setw(4) << address << endl;
        }
        return 0; // Unused, read as zero
    }
}


uint8_t Sim6502::readPeripheral(uint16_t address)
{
    if (address == m_peripheralStart) {
        // Send ready if still characters to read from serial inout file.
        // Send not ready if end of file reached.
        if (!m_serialIn.eof()) {
            if (m_logSerial) {
                cout << "Serial: Read $03 from MC6850 Status Register" << endl; // Return RDRF and TDRE true.
            }
            return 0x03;
        } else {
            if (m_logSerial) {
                cout << "Serial: EOF reached for serial.in. Reopening file." << endl;
                cout << "Serial: Sending space to exit LOAD mode." << endl;
                cout << "Serial: Read $02 from MC6850 Status Register" << endl;
            }
            // Close input file and open it again in case users runs LOAD command again.
            m_serialIn.close();
            m_serialIn.open("serial.in", ios::binary);
            // Hack: Send space on keyboard to exit from LOAD mode.
            pressKey(' ');
            return 0x02; // Return RDRF false and TDRE true.
        }
    }
    if (address == m_peripheralStart + 1) {
        char byte;
        m_serialIn.read(&byte, 1);
        if (isprint(byte)) {
            cout << "Serial: Read '" << (char)byte << "' from MC6850 Data Register" << endl;
        } else {
            cout << "Serial: Read $" << hex << setfill('0') << setw(2) << (int)byte << " from MC6850 Data Register" << endl;
        }
        return byte;
    }
    assert(false); // Should never be reached
}


void Sim6502::pressKey(char key)
{
    if (m_logKeyboard) {
        if (isprint(key)) {
            cout << "Keyboard: pressKey '" << key << "'" << endl;
        } else {
            cout << "Keyboard: pressKey " << hex << (int)key << endl;
        }
    }
    if ((m_row[(int)key] == 0) || (m_col[(int)key] == 0)) {
        if (m_logKeyboard) {
            if (isprint(key)) {
                cout << "Keyboard: Error: Unrecognized key '" << key << "'" << endl;
            } else {
                cout << "Keyboard: Error: Unrecognized key " << hex << (int)key << endl;
            }
        }
        return;
    }

    m_keyboardCharacter = key; // Save keyboard key character
    m_desiredRow = m_row[(int)key];
    m_columnData = m_col[(int)key];
    m_shift = m_shifted[(int)key];

    // <Esc> or 0x1b is special case where we want Shift Lock pressed as well.
    if (key == 0x1b) {
        m_columnData &= 0xfe;
    }
    m_sendingCharacter = true;
    m_tries = 0;
}


uint8_t Sim6502::readKeyboard(uint16_t address)
{
    assert(isKeyboard(address));

    if (m_logKeyboard) {
        cout << "Keyboard: scanning row $" << (int)m_keyboardRowRegister << endl;
    }

    if (!m_sendingCharacter) {
        dumpVideo(); // Show screen

        if (!m_keyboardFifo.empty()) { // If fifo not empty
            pressKey(m_keyboardFifo.front()); // Get next key from fifo
            m_keyboardFifo.pop(); // And remove it from fifo
        } else {
            // Prompt for (keys) to press
            cout << "Keyboard: input (or \"none\"): " << flush;
            string s;
            getline(cin, s);

            if (cin.eof()) {
                cout << endl;
                exit(0);
                return 0xff;
            }

            if (s == "none") {
                return 0xff;
            }

            if (s.length() > 0) {
                for (auto i : s) {
                    m_keyboardFifo.push(i); // Push character(s) into fifo
                }
                if (s.length() > 1) {
                    m_keyboardFifo.push('\r'); // If more than than one char, append Return for convenience
                }
                pressKey(m_keyboardFifo.front()); // Send first character
                m_keyboardFifo.pop(); // And remove it from fifo
            } else {
                pressKey('\r'); // Send Return
            }
        }
    }

    // We already have a character to send.

    if (m_keyboardRowRegister == m_desiredRow) {
        m_tries++; // Need to send key pressed 4 times for software debouncing, then send no key pressed 4 times.
        if (m_tries < 4) {
            if (m_logKeyboard) {
                if (isprint(m_keyboardCharacter)) {
                    cout << "Keyboard: sent key '" << m_keyboardCharacter << "'" << endl;
                } else {
                    cout << "Keyboard: sent key " << hex << (int)m_keyboardCharacter << endl;
                }
            }
        } else if (m_tries < 8) {
            if (m_logKeyboard) {
                cout << "Keyboard: sent no key pressed" << endl;
            }
            m_columnData = 0xff;
        } else {
            if (m_logKeyboard) {
                cout << "Keyboard: finished key press cycle" << endl;
            }
            m_sendingCharacter = false;
            m_shift = false;
        }
        if (m_logKeyboard) {
            cout << "Keyboard: returning column data $" << (int)m_columnData << endl;
        }
        return m_columnData;
    }

    if (m_keyboardRowRegister == 254) { // Modifier row
        if (m_shift) {
            if (m_logKeyboard) {
                cout << "Keyboard: returning column data $" << (251&254) << " for left shift and shift lock pressed" << endl;
            }
            return (251&254); // Return both left shift and shift lock pressed
        } else {
            if (m_logKeyboard) {
                cout << "Keyboard: returning column data $" << 254 << " for shift lock pressed" << endl;
            }
            return 254; // Return shift lock pressed
        }
    }

    if (m_logKeyboard) {
        cout << "Keyboard: returning no key pressed" << endl;
    }
    return 0xff; // No key pressed.
}


uint8_t Sim6502::readVideo(uint16_t address)
{
    if (m_logVideo) {
        cout << "Video: read $" << setw(2) << hex << (int)m_memory[address] << " from video RAM at $" << hex << setw(4) << address << endl;
    }
    return m_memory[address];
}


bool Sim6502::isRam(uint16_t address) const
{
    // TODO: May want to optimize using array lookup
    return (address >= m_ramStart && address <= m_ramEnd);
}


bool Sim6502::isRom(uint16_t address) const
{
    // TODO: May want to optimize using array lookup
    return (address >= m_romStart1 && address <= m_romEnd1) || (address >= m_romStart2 && address <= m_romEnd2);
}


bool Sim6502::isPeripheral(uint16_t address) const
{
    // 6550 UART is two addresses.
    return address >= m_peripheralStart && address <= m_peripheralStart + 1;
}


bool Sim6502::isVideo(uint16_t address) const
{
    return (address >= m_videoStart && address <= m_videoEnd);
}


bool Sim6502::isKeyboard(uint16_t address) const
{
    // Keyboard is only one address
    return address == m_keyboardStart;
}


bool Sim6502::isUnused(uint16_t address) const
{
    // TODO: May want to optimize using array lookup
    return (!isRam(address) && !isRom(address) &&!isPeripheral(address));
}


bool Sim6502::loadMemory(string filename, uint16_t startAddress)
{
    // TODO: Add support for file formats other than binary

    ifstream inFile;

    inFile.open(filename, ios::binary);
    if (inFile.is_open()) {
        for (int i = startAddress; i <= 0xffff; i++) {
            inFile.read((char*) &m_memory[i], 1);
        }
        inFile.close();
        return true;
    } else {
        if (m_logErrors) {
            cerr << "Error: Unable to open file '" << filename << "' for reading." << endl;
        }
        return false;
    }
}


bool Sim6502::saveMemory(string filename, uint16_t startAddress, uint16_t endAddress)
{
    // TODO: Add support for file formats other than binary

    ofstream outFile;

    outFile.open(filename, ios::binary);
    if (outFile.is_open()) {
        for (int i = startAddress; i <= endAddress; i++) {
            outFile.write((const char*) &m_memory[i], 1);
        }
        outFile.close();
        return true;
    } else {
        if (m_logErrors) {
            cerr << "Error: Unable to open file '" << filename << "' for writing." << endl;
        }
        return false;
    }
}


void Sim6502::setMemory(uint16_t startAddress, uint16_t endAddress, uint8_t byte)
{
    assert(startAddress <= endAddress);

    for (int i = startAddress; i <= endAddress; i++) {
        m_memory[i] = byte;
    }
}


void Sim6502::dumpMemory(uint16_t startAddress, uint16_t endAddress, bool showAscii)
{
    assert(startAddress <= endAddress);

    cout << endl << hex << uppercase << setfill('0') << setw(4) << startAddress << ":";
    int printed = 0;
    for (int i = startAddress; i <= endAddress; i++) {

        if ((i != startAddress) && (i % 16 == 0)) {
            cout << endl << hex << setfill('0') << setw(4) << i << ":";
            printed = 0;
        }    
        cout << " " << setfill('0') << setw(2) << (int)m_memory[i];

        if (showAscii) {
            printed++;
            if (printed == 16) {
                cout << "  ";
                for (int j = i - 16 ; j < i; j++) {
                    if (isprint(m_memory[j])) {
                        cout << (char)m_memory[j];
                    } else {
                        cout << ".";
                    }
                    printed = 0;
                }
            }
        }
    }
    cout << endl;
}


uint16_t Sim6502::disassembleMemory(uint16_t startAddress, uint16_t endAddress, bool showAscii)
{
    assert(startAddress <= endAddress);
    int address = startAddress;

    while (address < endAddress) {

        int instruction = m_memory[address];
        const char *opcode = Sim6502::opCodeTable[instruction];
        Sim6502::AddressMode mode = Sim6502::addressModeTable[instruction];
        int length = Sim6502::lengthTable[mode];

        // Disassembly format:
        // 1000  01        nop
        // 1001  02 03     lda    #$AA
        // 1003  04 05 06  jsr    $1234
        // 0000  A0 00     ldy    #$00

        cout << hex << uppercase << setfill('0') << setw(4) << address << "  ";

        for (int i = 0; i < length; i++) {
            cout << hex << setw(2) << (int)m_memory[address + i] << " ";
        }

        if (length == 1) {
            cout << "       ";
        } else if (length == 2) {
            cout << "    ";
        } else if (length == 3) {
            cout << " ";
        }

        switch (mode) {
        case implicit: // e.g. rts
            cout << opcode << endl;
            break;
        case absolute: //  e.g. lda $1234
            cout << opcode << "    $" << setw(4) << m_memory[address + 1] + 256 * m_memory[address + 2] << endl;
            break;
        case absoluteX: // e.g. lda $1234,x
            cout << opcode << "    $" << setw(4) << m_memory[address + 1] + 256 * m_memory[address + 2] << ",x" << endl;
            break;
        case absoluteY: // e.g. lda $1234,y
            cout << opcode << "    $" << setw(4) << m_memory[address + 1] + 256 * m_memory[address + 2] << ",y" << endl;
            break;
        case accumulator: // e.g. asla
            cout << opcode << endl;
            break;
        case immediate: // e.g. lda #$12
            if (isprint(m_memory[address+ 1])) {
                cout << opcode << "    #'" << m_memory[address + 1] << "'" << endl;
            } else {
                cout << opcode << "    #$" << setw(2) << (int)m_memory[address + 1] << endl;
            }
            break;
        case indirectX: // e.g. lda ($12,x)
            cout << opcode << "    ($" << setw(2) << (int)m_memory[address + 1] << ",x)" << endl;
            break;
        case indirectY: // e.g. lda ($12),y
            cout << opcode << "    ($" << setw(2) << (int)m_memory[address + 1] << "),y" << endl;
            break;
        case indirect: // e.g. jmp ($1234)
            cout << opcode << "    ($" << setw(4) << m_memory[address + 1] + 256 * m_memory[address + 2] << ")" << endl;
            break;
        case relative: // # e.g. bne $1234
            {
                int offset = m_memory[address + 1];
                int dest;
                if (offset < 128) {
                    dest = address + offset + 2;
                } else {
                    dest = address - (256 - offset) + 2;
                }
                if (dest < 0) {
                    dest = 65536 + dest;
                }
                cout << opcode << "    $" << setw(4) << (int)dest << endl;
                break;
            }
        case zeroPage: // # e.g. lda $12
            cout << opcode << "    $" << setw(2) << (int)m_memory[address + 1] << endl;
            break;
        case zeroPageX: // # e.g. lda $12,x
            cout << opcode << "    $" << setw(2) << (int)m_memory[address + 1] << ",x" << endl;
            break;
        case zeroPageY: // # e.g. lda $12,y
            cout << opcode << "    $" << setw(2) << (int)m_memory[address + 1] << ",y" << endl;
            break;
        }

        address += length;
    }

    return address;
}


void Sim6502::dumpRegisters()
{
    string s;

    (m_regP & S_BIT) ? s += "S" : s += "s";
    (m_regP & V_BIT) ? s += "V" : s += "v";
    (m_regP & X_BIT) ? s += "1" : s += "0";
    (m_regP & B_BIT) ? s += "B" : s += "b";
    (m_regP & D_BIT) ? s += "D" : s += "d";
    (m_regP & I_BIT) ? s += "I" : s += "i";
    (m_regP & Z_BIT) ? s += "Z" : s += "z";
    (m_regP & C_BIT) ? s += "C" : s += "c";

    cout << hex << setfill('0') << "PC=$" << setw(4) << m_regPC
         << " ($" << setw(2) << (int)m_memory[m_regPC] << ") "
         <<  opCodeTable[m_memory[m_regPC]]
         << " A=$" << setw(2) << (int)m_regA
         << " X=$" << setw(2) << (int)m_regX
         << " Y=$" << setw(2) << (int)m_regY
         << " SP=$01" << setw(2) << (int)m_regSP
         << " P=" << s << endl;
}


void Sim6502::dumpVideo()
{
    cout << "+------------------------+" << endl;

    for (int row = 4; row < 28; row++) {
        cout << "|";
        for (int col = 5; col < 29; col++) {
            char c = m_memory[0xd000 + (row * 32) + col];
            if ((c >= 0x20) && (c <= 0x7c)) {
                cout << c;
            } else {
                cout << ".";
            }
        }
        cout << "|" << endl;
    }
    cout << "+------------------------+" << endl;
}


void Sim6502::setBreakpoint(uint16_t address)
{
    // Don't add breakpoint if it already exists.
    auto it = std::find(m_breakpoints.begin(), m_breakpoints.end(), address);
    if (it == m_breakpoints.end()) {
        m_breakpoints.push_back(address);
    }
}


void Sim6502::clearBreakpoint(uint16_t address)
{
    auto it = std::find(m_breakpoints.begin(), m_breakpoints.end(), address);
    if (it == m_breakpoints.end()) {
        cout << "No breakpoint at $" << setw(4) << hex << address << endl;
    } else {
        m_breakpoints.remove(address);
    }
}


std::list<uint16_t> Sim6502::getBreakpoints() const
{
    return m_breakpoints;
}


void Sim6502::setReadWatchpoint(uint16_t address)
{
    // Don't add watchpoint if it already exists.
    auto it = std::find(m_readWatchpoints.begin(), m_readWatchpoints.end(), address);
    if (it == m_readWatchpoints.end()) {
        m_readWatchpoints.push_back(address);
    }
}


void Sim6502::clearReadWatchpoint(uint16_t address)
{
    auto it = std::find(m_readWatchpoints.begin(), m_readWatchpoints.end(), address);
    if (it == m_readWatchpoints.end()) {
        cout << "No read watchpoint at $" << setw(4) << hex << address << endl;
    } else {
        m_readWatchpoints.remove(address);
    }
}


std::list<uint16_t> Sim6502::getReadWatchpoints() const
{
    return m_readWatchpoints;
}


void Sim6502::setWriteWatchpoint(uint16_t address)
{
    // Don't add watchpoint if it already exists.
    auto it = std::find(m_writeWatchpoints.begin(), m_writeWatchpoints.end(), address);
    if (it == m_writeWatchpoints.end()) {
        m_writeWatchpoints.push_back(address);
    }
}


void Sim6502::clearWriteWatchpoint(uint16_t address)
{
    auto it = std::find(m_writeWatchpoints.begin(), m_writeWatchpoints.end(), address);
    if (it == m_writeWatchpoints.end()) {
        cout << "No write watchpoint at $" << setw(4) << hex << address << endl;
    } else {
        m_writeWatchpoints.remove(address);
    }
}


std::list<uint16_t> Sim6502::getWriteWatchpoints() const
{
    return m_writeWatchpoints;
}


void Sim6502::step(bool over)
{
    // This is written for speed and efficiency and not elegance and readability.

    int len = 1; // Instruction length
    uint8_t opcode = m_memory[m_regPC];
    uint8_t operand1 = m_memory[m_regPC + 1];
    uint8_t operand2 = m_memory[m_regPC + 2];
    uint8_t tmp1 =0;
    uint8_t tmp2 = 0;
    int16_t tmp3 = 0;

    // If stepping over, just move PC to the next instruction.
    if (over) {
        Sim6502::AddressMode mode = Sim6502::addressModeTable[opcode]; // Get addressing mode
        len = Sim6502::lengthTable[mode]; // Get instruction length
        m_regPC += len; // Point to next instruction

        if (m_logRegisters) {
            dumpRegisters();
        }

        return;
    }

    switch (opcode) {

    case 0x00: // brk
        m_regPC +=2; // Increment PC by 2
        m_regP |= B_BIT; // Set B flag
        write(STACK + m_regSP, (m_regPC + 2) >> 8); // Push PC high byte
        m_regSP--;
        write(STACK + m_regSP, (m_regPC + 2) & 0xff); // Push PC low byte
        m_regSP--;
        write(STACK + m_regSP, m_regP); // Push P
        m_regSP--;
        m_regPC = m_memory[0xfffe] + m_memory[0xffff] * 256; // Set PC from IRQ vector
        if (m_logInstructions) {
            cout << "brk" << endl;
        }
        len = 0;
        if (m_stopBRK) {
            m_stop = true;
            m_stopReason = "brk instruction";
        }
        break;

    case 0x01: // ora (xx,x)
        tmp1 = (operand1 + m_regX) & 0xff;
        m_regA |= read(read(tmp1) + 256 * read(tmp1 + 1));
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "ora ($" << setw(2) << (int)operand1 << ",x)" << endl;
        }
        len = 2;
        break;

    case 0x05: // ora xx
        m_regA |= read(operand1);
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "ora $" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0x06: // asl xx
        tmp1 = read(operand1);
        (tmp1 & 0x80) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        tmp1 = (tmp1 << 1) & 0xff; // Shift left
        write(operand1, tmp1);
        (tmp1 == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (tmp1 & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        if (m_logInstructions) {
            cout << "asl $" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0x08: // php
        write(STACK + m_regSP, m_regP);
        m_regSP--;
        if (m_logInstructions) {
            cout << "php" << endl;
        }
        break;

    case 0x09: // ora #
        m_regA |= operand1;
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "ora #$" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0x0a: // asla
        (m_regA & 0x80) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        m_regA = (m_regA << 1) & 0xff; // Shift left
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        if (m_logInstructions) {
            cout << "asla" << endl;
        }
        break;

    case 0x0d: // ora xxxx
        m_regA |= read(operand1 + 256 * operand2);
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "ora $" << setw(4) << operand1 + 256 * operand2 << endl;
        }
        len = 3;
        break;

    case 0x0e: // asl xxxx
        tmp1 = read(operand1 + 256 * operand2);
        (tmp1 & 0x80) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        tmp1 = (tmp1 << 1) & 0xff; // Shift left
        write(operand1 + 256 * operand2, tmp1);
        (tmp1 == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (tmp1 & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        if (m_logInstructions) {
            cout << "asl $" << setw(4) << operand1 + 256 * operand2 << endl;
        }
        len = 2;
        break;

    case 0x10: // bpl
        if (!(m_regP & S_BIT)) {
            if (operand1 > 0x7f) { // Branch taken
                m_regPC = m_regPC + 1 - (uint8_t)~operand1; // Branch back
            } else {
                m_regPC = m_regPC + 2 + operand1; // Branch forward
            }
            len = 0;
        } else { // Branch not taken
            len = 2;
        }
        if (m_logInstructions) {
            cout << "bpl $" << setw(2) << (int)operand1 << endl;
        }
        break;

    case 0x11: // ora (xx),y
        m_regA |= read(read(operand1) + 256 * read(operand1 + 1) + m_regY);
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "ora ($" << setw(2) << (int)operand1 << "),y" << endl;
        }
        len = 2;
        break;

    case 0x15: // ora xx,x
        m_regA |= read((operand1 + m_regX) & 0xff);
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "ora $" << setw(2) << (int)operand1 << ",x" << endl;
        }
        len = 2;
        break;

    case 0x16: // asl xx,x
        tmp1 = read((operand1 + m_regX) & 0xff);
        (tmp1 & 0x80) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        tmp1 = (tmp1 << 1) & 0xff; // Shift left
        write((operand1 + m_regX) & 0xff, tmp1);
        (tmp1 == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (tmp1 & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        if (m_logInstructions) {
            cout << "asl $" << setw(2) << (int)operand1 << ",x" << endl;
        }
        len = 2;
        break;

    case 0x18: // clc
        m_regP &= ~C_BIT;
        if (m_logInstructions) {
            cout << "clc" << endl;
        }
        break;

    case 0x19: // ora xxxx,y
        assert(operand1 + 256 * operand2 + m_regY <= 0xffff);
        m_regA |= read(operand1 + 256 * operand2 + m_regY);
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "ora $" << setw(4) << operand1 + 256 * operand2 << ",y" << endl;
        }
        len = 3;
        break;

    case 0x1d: // ora xxxx,x
        assert(operand1 + 256 * operand2 + m_regX <= 0xffff);
        m_regA |= read(operand1 + 256 * operand2 + m_regX);
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "ora $" << setw(4) << operand1 + 256 * operand2 << ",x" << endl;
        }
        len = 3;
        break;

    case 0x1e: // asl xxxx,x
        assert(operand1 + 256 * operand2 + m_regX <= 0xffff);
        tmp1 = read(operand1 + 256 * operand2 + m_regX);
        (tmp1 & 0x80) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        tmp1 = (tmp1 << 1) & 0xff; // Shift left
        write(operand1 + 256 * operand2 + m_regX, tmp1);
        (tmp1 == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (tmp1 & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        if (m_logInstructions) {
            cout << "asl $" << setw(4) << operand1 + 256 * operand2 << ",x" << endl;
        }
        len = 2;
        break;

    case 0x20: // jsr xxxx
        write(STACK + m_regSP, (m_regPC + 2) >> 8); // Push PC high byte
        m_regSP--;
        write(STACK + m_regSP, (m_regPC + 2) & 0xff); // Push PC low byte
        m_regSP--;
        m_regPC = operand1 + 256 * operand2; // New PC
        if (m_logInstructions) {
            cout << "jsr $" << setw(4) << operand1 + 256 * operand2 << endl;
        }
        len = 0;
        break;

    case 0x21: // and (xx,x)
        tmp1 = (operand1 + m_regX) & 0xff;
        m_regA &= read(read(tmp1) + 256 * read(tmp1 + 1));
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "and ($" << setw(2) << (int)operand1 << ",x)" << endl;
        }
        len = 2;
        break;

    case 0x24: // bit xx
        tmp1 = read(operand1);
        ((m_regA & tmp1) == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        ((tmp1 & 0x80) != 0) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        ((tmp1 & 0x40) != 0) ? m_regP |= V_BIT : m_regP &= ~V_BIT; // Set V flag
        if (m_logInstructions) {
            cout << "bit $" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0x25: // and xx
        m_regA &= read(operand1);
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "and $" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0x26: // rol xx
        tmp1 = (m_regP & 0x01) ? 0x01 : 0x00; // Save original C flag
        tmp2 = read(operand1); // Read value
        (tmp2 & 0x80) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set new C flag
        tmp2 = (tmp2 << 1) & 0xff; // Shift left
        tmp2 |= tmp1; // Set LSB of result to original C bit
        write(operand1, tmp2); // Write back
        (tmp2 == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (tmp2 & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        if (m_logInstructions) {
            cout << "rol $" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0x28: // plp
        m_regSP++;
        m_regP = read(STACK + m_regSP);
        if (m_logInstructions) {
            cout << "plp" << endl;
        }
        break;

    case 0x29: // and #
        m_regA &= operand1;
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "and #$" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0x2a: // rola
        tmp1 = (m_regP & 0x01) ? 0x01 : 0x00; // Save original C flag
        (m_regA & 0x80) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set new C flag
        m_regA = (m_regA << 1) & 0xff; // Shift left
        m_regA |= tmp1; // Set LSB of A to original C bit
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        if (m_logInstructions) {
            cout << "rola" << endl;
        }
        break;

    case 0x2c: // bit xxxx
        tmp1 = read(operand1 + 256 * operand2);
        ((m_regA & tmp1) == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        ((tmp1 & 0x80) != 0) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        ((tmp1 & 0x40) != 0) ? m_regP |= V_BIT : m_regP &= ~V_BIT; // Set V flag
        if (m_logInstructions) {
            cout << "bit $" << setw(4) << (int)(operand1 + 256 * operand2) << endl;
        }
        len = 3;
        break;

    case 0x2d: // and xxxx
        m_regA &= read(operand1 + 256 * operand2);
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "and $" << setw(4) << operand1 + 256 * operand2 << endl;
        }
        len = 3;
        break;

    case 0x2e: // rol xxxx
        tmp1 = (m_regP & 0x01) ? 0x01 : 0x00; // Save original C flag
        tmp2 = read(operand1 + 256 * operand2); // Read value
        (tmp2 & 0x80) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set new C flag
        tmp2 = (tmp2 << 1) & 0xff; // Shift left
        tmp2 |= tmp1; // Set LSB of result to original C bit
        write(operand1 + 256 * operand2, tmp2); // Write back
        (tmp2 == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (tmp2 & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        if (m_logInstructions) {
            cout << "rol $" << setw(2) << (int)operand1 << endl;
        }
        len = 3;
        break;

    case 0x30: // bmi
        if (m_regP & S_BIT) {
            if (operand1 > 0x7f) { // Branch taken
                m_regPC = m_regPC + 1 - (uint8_t)~operand1; // Branch back
            } else {
                m_regPC = m_regPC + 2 + operand1; // Branch forward
            }
            len = 0;
        } else { // Branch not taken
            len = 2;
        }
        if (m_logInstructions) {
            cout << "bmi $" << setw(2) << (int)operand1 << endl;
        }
        break;

    case 0x31: // and (xx),y
        tmp1 = read(read(operand1) + 256 * read(operand1 + 1) + m_regY);
        assert(tmp1 <= 0xffff);
        m_regA &= tmp1;
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "and ($" << setw(2) << (int)operand1 << "),y" << endl;
        }
        len = 2;
        break;

    case 0x35: // and xx,x
        m_regA &= read((operand1 + m_regX) & 0xff);
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "and $" << setw(2) << (int)operand1 << ",x" << endl;
        }
        len = 2;
        break;

    case 0x36: // rol xx,x
        tmp1 = (m_regP & 0x01) ? 0x01 : 0x00; // Save original C flag
        tmp2 = read((operand1 + m_regX) & 0xff); // Read value
        (tmp2 & 0x80) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set new C flag
        tmp2 = (tmp2 << 1) & 0xff; // Shift left
        tmp2 |= tmp1; // Set LSB of result to original C bit
        write((operand1 + m_regX) & 0xff, tmp2); // Write back
        (tmp2 == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (tmp2 & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        if (m_logInstructions) {
            cout << "rol $" << setw(2) << (int)operand1 << ",x" << endl;
        }
        len = 2;
        break;

    case 0x38: // sec
        m_regP |= C_BIT;
        if (m_logInstructions) {
            cout << "sec" << endl;
        }
        break;

    case 0x39: // and xxxx,y
        assert(operand1 + 256 * operand2 + m_regY <= 0xffff);
        m_regA &= read(operand1 + 256 * operand2 + m_regY);
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "and $" << setw(4) << operand1 + 256 * operand2 << ",y" << endl;
        }
        len = 3;
        break;

    case 0x3d: // and xxxx,x
        assert(operand1 + 256 * operand2 + m_regX <= 0xffff);
        m_regA &= read(operand1 + 256 * operand2 + m_regX);
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "and $" << setw(4) << operand1 + 256 * operand2 << ",x" << endl;
        }
        len = 3;
        break;

    case 0x3e: // rol xxxx,x
        assert(operand1 + 256 * operand2 + m_regX <= 0xffff);
        tmp1 = (m_regP & 0x01) ? 0x01 : 0x00; // Save original C flag
        tmp2 = read(operand1 + 256 * operand2 + m_regX); // Read value
        (tmp2 & 0x80) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set new C flag
        tmp2 = (tmp2 << 1) & 0xff; // Shift left
        tmp2 |= tmp1; // Set LSB of result to original C bit
        write(operand1 + 256 * operand2 + m_regX, tmp2); // Write back
        (tmp2 == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (tmp2 & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        if (m_logInstructions) {
            cout << "rol $" << setw(4) << operand1 + 256 * operand2 << ",x" << endl;
        }
        len = 3;
        break;

    case 0x40: // rti
        m_regSP++;
        m_regP = read(STACK + m_regSP); // Pull procesor status reg
        m_regSP++;
        m_regPC = read(STACK + m_regSP); // Pull PC low byte
        m_regSP++;
        m_regPC += read(STACK + m_regSP) << 8; // Pull PC high byte
        if (m_logInstructions) {
            cout << "rti" << endl;
        }
        len = 0;
        break;

    case 0x41: // eor (xx,x)
        tmp1 = (operand1 + m_regX) & 0xff;
        m_regA ^= read(read(tmp1) + 256 * read(tmp1 + 1));
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "eor ($" << setw(2) << (int)operand1 << ",x)" << endl;
        }
        len = 2;
        break;

    case 0x45: // eor xx
        m_regA ^= read(operand1);
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "eor $" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0x46: // lsr xx
        tmp1 = read(operand1); // Read value
        (tmp1 & 0x01) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        tmp1 = (tmp1 >> 1) & 0xff; // Shift right
        write(operand1, tmp1); // Write back
        (tmp1 == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        m_regP &= ~S_BIT; // Clear S flag
        if (m_logInstructions) {
            cout << "lsr $" << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0x48: // pha
        write(STACK + m_regSP, m_regA);
        m_regSP--;
        if (m_logInstructions) {
            cout << "pha" << endl;
        }
        break;

    case 0x49: // eor #
        m_regA ^= operand1;
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "eor #$" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0x4a: // lsra
        (m_regA & 0x01) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        m_regA = (m_regA >> 1) & 0xff; // Shift right
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        m_regP &= ~S_BIT; // Clear S flag
        if (m_logInstructions) {
            cout << "lsra" << endl;
        }
        break;

    case 0x4c: // jmp xxxx
        m_regPC = operand1 + 256 * operand2;
        if (m_logInstructions) {
            cout << "jmp $" << setw(4) << operand1 + 256 * operand2 << endl;
        }
        len = 0;
        break;

    case 0x4d: // eor xxxx
        m_regA ^= read(operand1 + 256 * operand2);
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "eor $" << setw(4) << operand1 + 256 * operand2 << endl;
        }
        len = 3;
        break;

    case 0x4e: // lsr xxxx
        tmp1 = read(operand1 + 256 * operand2); // Read value
        (tmp1 & 0x01) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        tmp1 = (tmp1 >> 1) & 0xff; // Shift right
        write(operand1 + 256 * operand2, tmp1); // Write back
        (tmp1 == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        m_regP &= ~S_BIT; // Clear S flag
        if (m_logInstructions) {
            cout << "lsr $" << setw(4) << operand1 + 256 * operand2 << endl;
        }
        len = 2;
        break;

    case 0x50: // bvc xx
        if (!(m_regP & V_BIT)) {
            if (operand1 > 0x7f) { // Branch taken
                m_regPC = m_regPC + 1 - (uint8_t)~operand1; // Branch back
            } else {
                m_regPC = m_regPC + 2 + operand1; // Branch forward
            }
            len = 0;
        } else { // Branch not taken
            len = 2;
        }
        if (m_logInstructions) {
            cout << "bvc $" << setw(2) << (int)operand1 << endl;
        }
        break;

    case 0x51: // eor (xx),y
        tmp1 = read(read(operand1) + 256 * read(operand1 + 1) + m_regY);
        assert(tmp1 <= 0xffff);
        m_regA ^= tmp1;
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "eor ($" << setw(2) << (int)operand1 << "),y" << endl;
        }
        len = 2;
        break;

    case 0x55: // eor xx,x
        m_regA ^= read((operand1 + m_regX) & 0xff);
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "eor $" << setw(2) << (int)operand1 << ",x" << endl;
        }
        len = 2;
        break;

    case 0x56: // lsr xx,x
        tmp1 = read((operand1 + m_regX) & 0xff); // Read value
        (tmp1 & 0x01) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        tmp1 = (tmp1 >> 1) & 0xff; // Shift right
        write((operand1 + m_regX) & 0xff, tmp1); // Write back
        (tmp1 == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        m_regP &= ~S_BIT; // Clear S flag
        if (m_logInstructions) {
            cout << "lsr $" << (int)operand1 << ",x" << endl;
        }
        len = 2;
        break;

    case 0x58: // cli
        m_regP &= ~I_BIT; // Clear I flag
        break;

    case 0x59: // eor xxxx,y
        assert(operand1 + 256 * operand2 + m_regY <= 0xffff);
        m_regA ^= read(operand1 + 256 * operand2 + m_regY);
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "eor $" << setw(4) << operand1 + 256 * operand2 << ",y" << endl;
        }
        len = 3;
        break;

    case 0x5d: // eor xxxx,x
        assert(operand1 + 256 * operand2 + m_regX <= 0xffff);
        m_regA ^= read(operand1 + 256 * operand2 + m_regX);
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "eor $" << setw(4) << operand1 + 256 * operand2 << ",x" << endl;
        }
        len = 3;
        break;

    case 0x5e: // lsr xxxx,x
        assert(operand1 + 256 * operand2 + m_regX <= 0xffff);
        tmp1 = read(operand1 + 256 * operand2 + m_regX); // Read value
        (tmp1 & 0x01) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        tmp1 = (tmp1 >> 1) & 0xff; // Shift right
        write(operand1 + 256 * operand2 + m_regX, tmp1); // Write back
        (tmp1 == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        m_regP &= ~S_BIT; // Clear S flag
        if (m_logInstructions) {
            cout << "lsr $" << setw(4) << operand1 + 256 * operand2 << ",x" << endl;
        }
        len = 2;
        break;

    case 0x60: // rts
        m_regSP++;
        m_regPC = read(STACK + m_regSP); // Pull PC low byte
        m_regSP++;
        m_regPC += read(STACK + m_regSP) << 8; // Pull PC high byte
        m_regPC++; // Increment PC by 1
        if (m_logInstructions) {
            cout << "rts" << endl;
        }
        len = 0;
        break;

    case 0x61: // adc (xx,x)
        if (m_regP & D_BIT) {
            if (m_logWarnings) {
                cout << "Warning: Decimal mode not implemented." << endl;
            }
        }
        tmp1 = (operand1 + m_regX) & 0xff;
        tmp3 = read(read(tmp1) + 256 * read(tmp1 + 1));
        if (m_regP & C_BIT) tmp3++; // Add 1 if carry set
        ((tmp3 & 0x80) != 0) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        ((tmp3 < 0x00) || (tmp3 > 0xff)) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        ((tmp3 & 0xff) == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        ((tmp3 & 0x80) != (read(read(tmp1) + 256 * read(tmp1 + 1)) & 0x80)) ? m_regP |= V_BIT : m_regP &= ~V_BIT; // Set V flag
        m_regA = tmp3 & 0xff; // Mask result to 8 bits
        if (m_logInstructions) {
            cout << "adc ($" << setw(2) << (int)operand1 << ",x)" << endl;
        }
        len = 2;
        break;

    case 0x65: // adc xx
        if (m_regP & D_BIT) {
            if (m_logWarnings) {
                cout << "Warning: Decimal mode not implemented." << endl;
            }
        }
        tmp1 = read(operand1);
        tmp3 = m_regA + tmp1; // Add operand
        if (m_regP & C_BIT) tmp3++; // Add 1 if carry set
        ((tmp3 & 0x80) != 0) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        ((tmp3 < 0x00) || (tmp3 > 0xff)) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        ((tmp3 & 0xff) == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        ((tmp3 & 0x80) != (tmp1 & 0x80)) ? m_regP |= V_BIT : m_regP &= ~V_BIT; // Set V flag
        m_regA = tmp3 & 0xff; // Mask result to 8 bits
        if (m_logInstructions) {
            cout << "adc $" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0x66: // ror xx
        tmp1 = (m_regP & 0x01) ? 0x80 : 0x00; // Save original C flag in MSB
        tmp2 = read(operand1); // Read value
        (tmp2 & 0x01) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set new C flag
        tmp2 = (tmp2 >> 1) & 0xff; // Shift right
        tmp2 |= tmp1; // Set MSB of result to original C bit
        write(operand1, tmp2); // Write back
        (tmp2 == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (tmp2 & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        if (m_logInstructions) {
            cout << "ror $" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0x68: // pla
        m_regSP++;
        m_regA = read(STACK + m_regSP);
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "pla" << endl;
        }
        break;

    case 0x69: // adc #xx
        if (m_regP & D_BIT) {
            if (m_logWarnings) {
                cout << "Warning: Decimal mode not implemented." << endl;
            }
        }
        tmp3 = m_regA + operand1; // Add immediate operand
        if (m_regP & C_BIT) tmp3++; // Add 1 if carry set
        ((tmp3 & 0x80) != 0) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        ((tmp3 < 0x00) || (tmp3 > 0xff)) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        ((tmp3 & 0xff) == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        ((tmp3 & 0x80) != (m_regA & 0x80)) ? m_regP |= V_BIT : m_regP &= ~V_BIT; // Set V flag
        m_regA = tmp3 & 0xff; // Mask result to 8 bits
        if (m_logInstructions) {
            cout << "adc #$" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0x6a: // rora
        tmp1 = (m_regP & 0x01) ? 0x80 : 0x00; // Save original C flag in MSB
        (m_regA & 0x01) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set new C flag
        m_regA = (m_regA >> 1) & 0xff; // Shift right
        m_regA |= tmp1; // Set MSB of result to original C bit
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        if (m_logInstructions) {
            cout << "rora" << endl;
        }
        break;

    case 0x6c: // jmp (xxxx)
        m_regPC = read(operand1 + 256 * operand2) + 256 * read(operand1 + 256 * operand2 + 1);
        if (m_logInstructions) {
            cout << "jmp ($" << setw(4) << operand1 + 256 * operand2 << ")" << endl;
        }
        len = 0;
        break;

    case 0x6d: // adc xxxx
        if (m_regP & D_BIT) {
            if (m_logWarnings) {
                cout << "Warning: Decimal mode not implemented." << endl;
            }
        }
        tmp1 = read(operand1 + 256 * operand2);
        tmp3 = m_regA + tmp1; // Add operand
        if (m_regP & C_BIT) tmp3++; // Add 1 if carry set
        ((tmp3 & 0x80) != 0) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        ((tmp3 < 0x00) || (tmp3 > 0xff)) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        ((tmp3 & 0xff) == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        ((tmp3 & 0x80) != (tmp1 & 0x80)) ? m_regP |= V_BIT : m_regP &= ~V_BIT; // Set V flag
        m_regA = tmp3 & 0xff; // Mask result to 8 bits
        if (m_logInstructions) {
            cout << "adc $" << setw(4) << (int)operand1 + 256 * operand2 << endl;
        }
        len = 3;
        break;

    case 0x6e: // ror xxxx
        tmp1 = (m_regP & 0x01) ? 0x80 : 0x00; // Save original C flag in MSB
        tmp2 = read(operand1 + 256 * operand2); // Read value
        (tmp2 & 0x01) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set new C flag
        tmp2 = (tmp2 >> 1) & 0xff; // Shift right
        tmp2 |= tmp1; // Set MSB of result to original C bit
        write(operand1 + 256 * operand2, tmp2); // Write back
        (tmp2 == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (tmp2 & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        if (m_logInstructions) {
            cout << "ror $" << setw(4) << operand1 + 256 * operand2 << endl;
        }
        len = 3;
        break;

    case 0x70: // bvs xx
        if (m_regP & V_BIT) {
            if (operand1 > 0x7f) { // Branch taken
                m_regPC = m_regPC + 1 - (uint8_t)~operand1; // Branch back
            } else {
                m_regPC = m_regPC + 2 + operand1; // Branch forward
            }
            len = 0;
        } else { // Branch not taken
            len = 2;
        }
        if (m_logInstructions) {
            cout << "bvs $" << setw(2) << (int)operand1 << endl;
        }
        break;

    case 0x71: // adc (xx),y
        tmp1 = read(read(operand1) + 256 * read(operand1 + 1) + m_regY);
        assert(tmp1 <= 0xffff);
        if (m_regP & D_BIT) {
            if (m_logWarnings) {
                cout << "Warning: Decimal mode not implemented." << endl;
            }
        }
        tmp3 = tmp1;
        if (m_regP & C_BIT) tmp3++; // Add 1 if carry set
        ((tmp3 & 0x80) != 0) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        ((tmp3 < 0x00) || (tmp3 > 0xff)) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        ((tmp3 & 0xff) == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (tmp3 & 0x80) != (tmp1 & 0x80) ? m_regP |= V_BIT : m_regP &= ~V_BIT; // Set V flag
        m_regA = tmp3 & 0xff; // Mask result to 8 bits
        if (m_logInstructions) {
            cout << "adc ($" << setw(2) << (int)operand1 << "),y" << endl;
        }
        len = 2;
        break;

    case 0x75: // adc xx,x
        if (m_regP & D_BIT) {
            if (m_logWarnings) {
                cout << "Warning: Decimal mode not implemented." << endl;
            }
        }
        tmp1 = read((operand1 + m_regX) & 0xff);
        tmp3 = (m_regA + tmp1) & 0xff; // Add operand
        if (m_regP & C_BIT) tmp3++; // Add 1 if carry set
        ((tmp3 & 0x80) != 0) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        ((tmp3 < 0x00) || (tmp3 > 0xff)) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        ((tmp3 & 0xff) == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (tmp3 & 0x80) != ((tmp1 & 0xff) & 0x80) ? m_regP |= V_BIT : m_regP &= ~V_BIT; // Set V flag
        m_regA = tmp3 & 0xff; // Mask result to 8 bits
        if (m_logInstructions) {
            cout << "adc $" << setw(2) << (int)operand1 << ",x" << endl;
        }
        len = 2;
        break;

    case 0x76: // ror xx,x
        tmp1 = (m_regP & 0x01) ? 0x80 : 0x00; // Save original C flag in MSB
        tmp2 = read((operand1 + m_regX) & 0xff); // Read value
        (tmp2 & 0x01) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set new C flag
        tmp2 = (tmp2 >> 1) & 0xff; // Shift right
        tmp2 |= tmp1; // Set MSB of result to original C bit
        write((operand1 + m_regX) & 0xff, tmp2); // Write back
        (tmp2 == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (tmp2 & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        if (m_logInstructions) {
            cout << "ror $" << setw(2) << (int)operand1 << ",x" << endl;
        }
        len = 2;
        break;

    case 0x78: // sei
        m_regP |= I_BIT;
        break;

    case 0x79: // adc xxxx,y
        assert(operand1 + 256 * operand2 + m_regY <= 0xffff);
        if (m_regP & D_BIT) {
            if (m_logWarnings) {
                cout << "Warning: Decimal mode not implemented." << endl;
            }
        }
        tmp1 = read(operand1 + 256 * operand2 + m_regY);
        tmp3 = m_regA + tmp1; // Add operand
        if (m_regP & C_BIT) tmp3++; // Add 1 if carry set
        ((tmp3 & 0x80) != 0) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        ((tmp3 < 0x00) || (tmp3 > 0xff)) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        ((tmp3 & 0xff) == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        ((tmp3 & 0x80) != (tmp1 & 0x80)) ? m_regP |= V_BIT : m_regP &= ~V_BIT; // Set V flag
        m_regA = tmp3 & 0xff; // Mask result to 8 bits
        if (m_logInstructions) {
            cout << "adc $" << setw(4) << (int)operand1 + 256 * operand2 << ",y" << endl;
        }
        len = 3;
        break;

    case 0x7d: // adc xxxx,x
        assert(operand1 + 256 * operand2 + m_regX <= 0xffff);
        if (m_regP & D_BIT) {
            if (m_logWarnings) {
                cout << "Warning: Decimal mode not implemented." << endl;
            }
        }
        tmp1 = read(operand1 + 256 * operand2 + m_regX);
        tmp3 = m_regA + tmp1; // Add operand
        if (m_regP & C_BIT) tmp3++; // Add 1 if carry set
        ((tmp3 & 0x80) != 0) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        ((tmp3 < 0x00) || (tmp3 > 0xff)) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        ((tmp3 & 0xff) == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        ((tmp3 & 0x80) != (tmp1 & 0x80)) ? m_regP |= V_BIT : m_regP &= ~V_BIT; // Set V flag
        m_regA = tmp3 & 0xff; // Mask result to 8 bits
        if (m_logInstructions) {
            cout << "adc $" << setw(4) << (int)operand1 + 256 * operand2 << ",x" << endl;
        }
        len = 3;
        break;

    case 0x7e: // ror xxxx,x
        assert(operand1 + 256 * operand2 + m_regX <= 0xffff);
        tmp1 = (m_regP & 0x01) ? 0x80 : 0x00; // Save original C flag in MSB
        tmp2 = read(operand1 + 256 * operand2 + m_regX); // Read value
        (tmp2 & 0x01) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set new C flag
        tmp2 = (tmp2 >> 1) & 0xff; // Shift right
        tmp2 |= tmp1; // Set MSB of result to original C bit
        write(operand1 + 256 * operand2 + m_regX, tmp2); // Write back
        (tmp2 == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (tmp2 & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        if (m_logInstructions) {
            cout << "ror $" << setw(4) << operand1 + 256 * operand2 << ",x" << endl;
        }
        len = 3;
        break;

    case 0x81: // sta (xx,x)
        tmp1 = (operand1 + m_regX) & 0xff;
        write(read(tmp1) + 256 * read(tmp1 + 1), m_regA);
        if (m_logInstructions) {
            cout << "sta ($" << setw(2) << (int)operand1 << ",x)" << endl;
        }
        len = 2;
        break;

    case 0x84: // sty xx
        write(operand1, m_regY);
        if (m_logInstructions) {
            cout << "sty $" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0x85: // sta xx
        write(operand1, m_regA);
        if (m_logInstructions) {
            cout << "sta $" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0x86: // stx xx
        write(operand1, m_regX);
        if (m_logInstructions) {
            cout << "stx $" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0x88: // dey
        m_regY--;
        (m_regY & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regY == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "dey" << endl;
        }
        break;

    case 0x8a: // txa
        m_regA = m_regX;
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "txa" << endl;
        }
        break;

    case 0x8c: // sty xxxx
        write(operand1 + 256 * operand2, m_regY);
        if (m_logInstructions) {
            cout << "sty $" << setw(4) << operand1 + 256 * operand2 << endl;
        }
        len = 3;
        break;

    case 0x8d: // sta xxxx
        write(operand1 + 256 * operand2, m_regA);
        if (m_logInstructions) {
            cout << "sta $" << setw(4) << operand1 + 256 * operand2 << endl;
        }
        len = 3;
        break;

    case 0x8e: // stx xxxx
        write(operand1 + 256 * operand2, m_regX);
        if (m_logInstructions) {
            cout << "stx $" << setw(4) << operand1 + 256 * operand2 << endl;
        }
        len = 3;
        break;

    case 0x90: // bcc
        if (!(m_regP & C_BIT)) {
            if (operand1 > 0x7f) { // Branch taken
                m_regPC = m_regPC + 1 - (uint8_t)~operand1; // Branch back
            } else {
                m_regPC = m_regPC + 2 + operand1; // Branch forward
            }
            len = 0;
        } else { // Branch not taken
            len = 2;
        }
        if (m_logInstructions) {
            cout << "bcc $" << setw(2) << (int)operand1 << endl;
        }
        break;

    case 0x91: // sta (xx),y
        tmp1 = read(read(operand1) + 256 * read(operand1 + 1) + m_regY);
        assert(tmp1 <= 0xffff);
        write(read(operand1) + 256 * read(operand1 + 1) + m_regY, m_regA);
        if (m_logInstructions) {
            cout << "sta ($" << setw(2) << (int)operand1 << "),y" << endl;
        }
        len = 2;
        break;

    case 0x94: // sty xx,x
        write((operand1 + m_regX) & 0xff, m_regY);
        if (m_logInstructions) {
            cout << "sty $" << setw(2) << (int)operand1 << ",x" << endl;
        }
        len = 2;
        break;

    case 0x95: // sta xx,x
        write((operand1 + m_regX) & 0xff, m_regA);
        if (m_logInstructions) {
            cout << "sta $" << setw(2) << (int)operand1 << ",x" << endl;
        }
        len = 2;
        break;

    case 0x96: // stx xx,y
        write((operand1 + m_regY) & 0xff, m_regX);
        if (m_logInstructions) {
            cout << "stx $" << setw(2) << (int)operand1 << ",y" << endl;
        }
        len = 2;
        break;

    case 0x98: // tya
        m_regA = m_regY;
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "tya" << endl;
        }
        break;

    case 0x99: // sta xxxx,y
        assert(operand1 + 256 * operand2 + m_regY <= 0xffff);
        write(operand1 + 256 * operand2 + m_regY, m_regA);
        if (m_logInstructions) {
            cout << "sta $" << setw(4) << operand1 + 256 * operand2 << ",y" << endl;
        }
        len = 3;
        break;

    case 0x9a: // txs
        m_regSP = m_regX;
        if (m_logInstructions) {
            cout << "txs" << endl;
        }
        break;

    case 0x9d: // sta xxxx,x
        assert(operand1 + 256 * operand2 + m_regX <= 0xffff);
        write(operand1 + 256 * operand2 + m_regX, m_regA);
        if (m_logInstructions) {
            cout << "sta $" << setw(4) << operand1 + 256 * operand2 << ",x" << endl;
        }
        len = 3;
        break;

    case 0xa0: // ldy #
        m_regY = operand1;
        (m_regY & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regY == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "ldy #$" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0xa1: // lda (xx,x)
        tmp1 = (operand1 + m_regX) & 0xff;
        m_regA = read(read(tmp1) + 256 * read(tmp1 + 1));
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "lda ($" << setw(2) << (int)operand1 << ",x)" << endl;
        }
        len = 2;
        break;

    case 0xa2: // ldx #
        m_regX = operand1;
        (m_regX & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regX == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "ldx #$" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0xa4: // ldy xx
        m_regY = read(operand1);
        (m_regY & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regY == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "ldy $" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0xa5: // lda xx
        m_regA = read(operand1);
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "lda $" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0xa6: // ldx xx
        m_regX = read(operand1);
        (m_regX & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regX == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "ldx $" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0xa8: // tay
        m_regY = m_regA;
        (m_regY & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regY == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "tay" << endl;
        }
        break;

    case 0xa9: // lda #
        m_regA = operand1;
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "lda #$" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0xaa: // tax
        m_regX = m_regA;
        (m_regX & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regX == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "tax" << endl;
        }
        break;

    case 0xac: // ldy xxxx
        m_regY = read(operand1 + 256 * operand2);
        (m_regY & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regY == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "ldy $" << setw(4) << operand1 + 256 * operand2 << endl;
        }
        len = 3;
        break;

    case 0xad: // lda xxxx
        m_regA = read(operand1 + 256 * operand2);
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "lda $" << setw(4) << operand1 + 256 * operand2 << endl;
        }
        len = 3;
        break;

    case 0xae: // ldx xxxx
        m_regX = read(operand1 + 256 * operand2);
        (m_regX & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regX == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "ldx $" << setw(4) << operand1 + 256 * operand2 << endl;
        }
        len = 3;
        break;

    case 0xb0: // bcs
        if (m_regP & C_BIT) {
            if (operand1 > 0x7f) { // Branch taken
                m_regPC = m_regPC + 1 - (uint8_t)~operand1; // Branch back
            } else {
                m_regPC = m_regPC + 2 + operand1; // Branch forward
            }
            len = 0;
        } else { // Branch not taken
            len = 2;
        }
        if (m_logInstructions) {
            cout << "bcs $" << setw(2) << (int)operand1 << endl;
        }
        break;

    case 0xb1: // lda (xx),y
        tmp1 = read(read(operand1) + 256 * read(operand1 + 1) + m_regY);
        assert(tmp1 <= 0xffff);
        m_regA = tmp1;
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "lda ($" << setw(2) << (int)operand1 << "),y" << endl;
        }
        len = 2;
        break;

    case 0xb4: // ldy xx,x
        m_regY = read((operand1 + m_regX) & 0xff);
        (m_regY & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regY == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "ldy $" << setw(2) << (int)operand1 << ",x" << endl;
        }
        len = 2;
        break;

    case 0xb5: // lda xx,x
        m_regA = read((operand1 + m_regX) & 0xff);
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "lda $" << setw(2) << (int)operand1 << ",x" << endl;
        }
        len = 2;
        break;

    case 0xb6: // ldx xx,y
        m_regX = read((operand1 + m_regY) & 0xff);
        (m_regX & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regX == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "ldx $" << setw(2) << (int)operand1 << ",y" << endl;
        }
        len = 2;
        break;

    case 0xb8: // clv
        m_regP &= ~V_BIT; // Clear V flag
        if (m_logInstructions) {
            cout << "clv" << endl;
        }
        break;

    case 0xb9: // lda xxxx,y
        assert(operand1 + 256 * operand2 + m_regY <= 0xffff);
        m_regA = read(operand1 + 256 * operand2 + m_regY);
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "lda $" << setw(4) << operand1 + 256 * operand2 << ",y" << endl;
        }
        len = 3;
        break;

    case 0xba: // tsx
        m_regX = m_regSP;
        (m_regX & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regX == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "tsx" << endl;
        }
        break;

    case 0xbc: // ldy xxxx,x
        assert(operand1 + 256 * operand2 + m_regX <= 0xffff);
        m_regY = read(operand1 + 256 * operand2 + m_regX);
        (m_regY & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regY == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "ldy $" << setw(4) << operand1 + 256 * operand2 << ",x" << endl;
        }
        len = 3;
        break;

    case 0xbd: // lda xxxx,x
        assert(operand1 + 256 * operand2 + m_regX <= 0xffff);
        m_regA = read(operand1 + 256 * operand2 + m_regX);
        (m_regA & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "lda $" << setw(4) << operand1 + 256 * operand2 << ",x" << endl;
        }
        len = 3;
        break;

    case 0xbe: // ldx xxxx,y
        assert(operand1 + 256 * operand2 + m_regY <= 0xffff);
        m_regX = read(operand1 + 256 * operand2 + m_regY);
        (m_regX & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regX == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "ldx $" << setw(4) << operand1 + 256 * operand2 << ",y" << endl;
        }
        len = 3;
        break;

    case 0xc0: // cpy #xx
        (m_regY == operand1) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (m_regY < operand1) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regY >= operand1) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        if (m_logInstructions) {
            cout << "cpy #$" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0xc1: // cmp (xx,x)
        tmp1 = (operand1 + m_regX) & 0xff;
        tmp2 = read(read(tmp1) + 256 * read(tmp1 + 1));
        (m_regA == tmp2) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        ((m_regA < tmp2) & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA >= tmp2) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        if (m_logInstructions) {
            cout << "cmp ($" << setw(2) << (int)operand1 << ",x)" << endl;
        }
        len = 2;
        break;

    case 0xc4: // cpy xx
        tmp1 = read(operand1);
        (m_regY == tmp1) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (m_regY < tmp1) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regY >= tmp1) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        if (m_logInstructions) {
            cout << "cpy $" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0xc5: // cmp xx
        tmp1 = read(operand1);
        (m_regA == tmp1) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (m_regA < tmp1) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA >= tmp1) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        if (m_logInstructions) {
            cout << "cmp $" << setw(2) << (int)(operand1) << endl;
        }
        len = 2;
        break;

    case 0xc6: // dec xx
        tmp1 = read(operand1) - 1;
        write(operand1, tmp1);
        (tmp1 & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (tmp1 == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "dec $" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0xc8: // iny
        m_regY++;
        (m_regY & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regY == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "iny" << endl;
        }
        break;

    case 0xc9: // cmp #
        (m_regA == operand1) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (m_regA < operand1) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA >= operand1) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        if (m_logInstructions) {
            cout << "cmp #$" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0xca: // dex
        m_regX--;
        (m_regX & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regX == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "dex" << endl;
        }
        break;

    case 0xcc: // cpy xxxx
        tmp1 = read(operand1 + 256 * operand2);
        (m_regY == tmp1) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (m_regY < tmp1) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regY >= tmp1) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        if (m_logInstructions) {
            cout << "cpy $" << setw(4) << operand1 + 256 * operand2 << endl;
        }
        len = 3;
        break;

    case 0xcd: // cmp xxxx
        tmp1 = read(operand1 + 256 * operand2);
        (m_regA == tmp1) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (m_regA < tmp1) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA >= tmp1) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        if (m_logInstructions) {
            cout << "cmp $" << setw(4) << (int)(operand1 + 256 * operand2) << endl;
        }
        len = 3;
        break;

    case 0xce: // dec xxxx
        tmp1 = read(operand1 + 256 * operand2) - 1;
        write(operand1 + 256 * operand2, tmp1);
        (tmp1 & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (tmp1 == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "dec $" << setw(4) << operand1 + 256 * operand2 << endl;
        }
        len = 3;
        break;

    case 0xd0: // bne
        if (!(m_regP & Z_BIT)) {
            if (operand1 > 0x7f) { // Branch taken
                m_regPC = m_regPC + 1 - (uint8_t)~operand1; // Branch back
            } else {
                m_regPC = m_regPC + 2 + operand1; // Branch forward
            }
            len = 0;
        } else { // Branch not taken
            len = 2;
        }
        if (m_logInstructions) {
            cout << "bne $" << setw(2) << (int)operand1 << endl;
        }
        break;

    case 0xd1: // cmp (xx),y
        tmp1 = read(read(operand1) + 256 * read(operand1 + 1) + m_regY);
        assert(tmp1 <= 0xffff);
        (m_regA == tmp1) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        ((m_regA < tmp1) & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA >= tmp1) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        if (m_logInstructions) {
            cout << "cmp ($" << setw(2) << (int)operand1 << "),y" << endl;
        }
        len = 2;
        break;

    case 0xd5: // cmp xx,x
        tmp1 = read((operand1 + m_regX) & 0xff);
        (m_regA == tmp1) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (m_regA < tmp1) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA >= tmp1) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        if (m_logInstructions) {
            cout << "cmp $" << setw(2) << (int)operand1 << ",x" << endl;
        }
        len = 2;
        break;

    case 0xd6: // dec xx,x
        tmp1 = read((operand1 + m_regX) & 0xff) - 1;
        write((operand1 + m_regX) & 0xff, tmp1);
        (tmp1 & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (tmp1 == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "dec $" << setw(2) << (int)operand1 << ",x" << endl;
        }
        len = 2;
        break;

    case 0xd8: // cld
        m_regP &= ~D_BIT;
        if (m_logInstructions) {
            cout << "cld" << endl;
        }
        break;

    case 0xd9: // cmp xxxx,y
        assert(operand1 + 256 * operand2 + m_regY <= 0xffff);
        tmp1 = read(operand1 + 256 * operand2 + m_regY);
        (m_regA == tmp1) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (m_regA < tmp1) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA >= tmp1) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        if (m_logInstructions) {
            cout << "cmp $" << setw(4) << (int)(operand1 + 256 * operand2) << ",y" << endl;
        }
        len = 3;
        break;

    case 0xdd: // cmp xxxx,x
        assert(operand1 + 256 * operand2 + m_regX <= 0xffff);
        tmp1 = read(operand1 + 256 * operand2 + m_regX);
        (m_regA == tmp1) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (m_regA < tmp1) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regA >= tmp1) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        if (m_logInstructions) {
            cout << "cmp $" << setw(4) << (int)(operand1 + 256 * operand2) << ",x" << endl;
        }
        len = 3;
        break;

    case 0xde: // dec xxxx,x
        assert(operand1 + 256 * operand2 + m_regX <= 0xffff);
        tmp1 = read(operand1 + 256 * operand2 + m_regX) - 1;
        write(operand1 + 256 * operand2 + m_regX, tmp1);
        (tmp1 & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (tmp1 == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "dec $" << setw(4) << operand1 + 256 * operand2 << ",x" << endl;
        }
        len = 3;
        break;

    case 0xe0: // cpx #
        (m_regX == operand1) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (m_regX < operand1) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regX >= operand1) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        if (m_logInstructions) {
            cout << "cpx #$" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0xe1: // sbc (xx,x)
        if (m_regP & D_BIT) {
            if (m_logWarnings) {
                cout << "Warning: Decimal mode not implemented." << endl;
            }
        }
        tmp1 = (operand1 + m_regX) & 0xff;
        tmp3 = m_regA - (read(tmp1) + 256 * read(tmp1 + 1)); // Subtract operand
        if (!(m_regP & C_BIT)) tmp3--; // Subtract 1 if carry not set
        ((tmp3 & 0x80) != 0) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        ((tmp3 >= 0) && (tmp3 <= 0xff)) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        ((tmp3 & 0xff) == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        ((tmp3 & 0x80) != ((read(tmp1) + 256 * read(tmp1 + 1)) & 0x80)) ? m_regP |= V_BIT : m_regP &= ~V_BIT; // Set V flag
        m_regA = tmp3 & 0xff; // Mask result to 8 bits
        if (m_logInstructions) {
            cout << "sbc $" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0xe4: // cpx xx
        tmp1 = read(operand1);
        (m_regX == tmp1) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (m_regX < tmp1) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regX >= tmp1) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        if (m_logInstructions) {
            cout << "cpx $" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0xe5: // sbc xx
        if (m_regP & D_BIT) {
            if (m_logWarnings) {
                cout << "Warning: Decimal mode not implemented." << endl;
            }
        }
        tmp3 = m_regA - read(operand1); // Subtract operand
        if (!(m_regP & C_BIT)) tmp3--; // Subtract 1 if carry not set
        ((tmp3 & 0x80) != 0) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        ((tmp3 >= 0) && (tmp3 <= 0xff)) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        ((tmp3 & 0xff) == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        ((tmp3 & 0x80) != (read(operand1) & 0x80)) ? m_regP |= V_BIT : m_regP &= ~V_BIT; // Set V flag
        m_regA = tmp3 & 0xff; // Mask result to 8 bits
        if (m_logInstructions) {
            cout << "sbc $" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0xe6: // inc xx
        tmp1 = read(operand1) + 1;
        write(operand1, tmp1);
        (tmp1 & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (tmp1 == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "inc $" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0xe8: // inx
        m_regX++;
        (m_regX & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regX == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "inx" << endl;
        }
        break;

    case 0xe9: // sbc #
        if (m_regP & D_BIT) {
            if (m_logWarnings) {
                cout << "Warning: Decimal mode not implemented." << endl;
            }
        }
        tmp3 = m_regA - operand1; // Subtract immediate operand
        if (!(m_regP & C_BIT)) tmp3--; // Subtract 1 if carry not set
        ((tmp3 & 0x80) != 0) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        ((tmp3 >= 0) && (tmp3 <= 0xff)) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        ((tmp3 & 0xff) == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        ((tmp3 & 0x80) != (m_regA & 0x80)) ? m_regP |= V_BIT : m_regP &= ~V_BIT; // Set V flag
        m_regA = tmp3 & 0xff; // Mask result to 8 bits
        if (m_logInstructions) {
            cout << "sbc #$" << setw(2) << (int)operand1 << endl;
        }
        len = 2;
        break;

    case 0xea: // nop
        if (m_logInstructions) {
            cout << "nop" << endl;
        }
        break;

    case 0xec: // cpx xxxx
        tmp1 = read(operand1 + 256 * operand2);
        (m_regX == tmp1) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        (m_regX < tmp1) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (m_regX >= tmp1) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        if (m_logInstructions) {
            cout << "cpx $" << setw(4) << operand1 + 256 * operand2 << endl;
        }
        len = 3;
        break;

    case 0xed: // sbc xxxx
        if (m_regP & D_BIT) {
            if (m_logWarnings) {
                cout << "Warning: Decimal mode not implemented." << endl;
            }
        }
        tmp1 = read(operand1 + 256 * operand2);
        tmp3 = m_regA - tmp1; // Subtract operand
        if (!(m_regP & C_BIT)) tmp3--; // Subtract 1 if carry not set
        ((tmp3 & 0x80) != 0) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        ((tmp3 >= 0) && (tmp3 <= 0xff)) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        ((tmp3 & 0xff) == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        ((tmp3 & 0x80) != (tmp1 & 0x80)) ? m_regP |= V_BIT : m_regP &= ~V_BIT; // Set V flag
        m_regA = tmp3 & 0xff; // Mask result to 8 bits
        if (m_logInstructions) {
            cout << "sbc $" << setw(4) << operand1 + 256 * operand2 << endl;
        }
        len = 3;
        break;

    case 0xee: // inc xxxx
        tmp1 = read(operand1 + 256 * operand2) + 1;
        write(operand1 + 256 * operand2, tmp1);
        (tmp1 & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (tmp1 == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "inc $" << setw(4) << operand1 + 256 * operand2 << endl;
        }
        len = 3;
        break;

    case 0xf0: // beq
        if (m_regP & Z_BIT) {
            if (operand1 > 0x7f) { // Branch taken
                m_regPC = m_regPC + 1 - (uint8_t)~operand1; // Branch back
            } else {
                m_regPC = m_regPC + 2 + operand1; // Branch forward
            }
            len = 0;
        } else { // Branch not taken
            len = 2;
        }
        if (m_logInstructions) {
            cout << "beq $" << setw(2) << (int)operand1 << endl;
        }
        break;

    case 0xf1: // sbc (xx),y
        tmp1 = read(read(operand1) + 256 * read(operand1 + 1) + m_regY);
        assert(tmp1 <= 0xffff);
        if (m_regP & D_BIT) {
                if (m_logWarnings) {
                    cout << "Warning: Decimal mode not implemented." << endl;
                }
        }
        tmp3 = m_regA - tmp1; // Subtract operand
        if (!(m_regP & C_BIT)) tmp3--; // Subtract 1 if carry not set
        ((tmp3 & 0x80) != 0) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        ((tmp3 >= 0) && (tmp3 <= 0xff)) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        ((tmp3 & 0xff) == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        ((tmp3 & 0x80) != ((tmp1) & 0x80)) ? m_regP |= V_BIT : m_regP &= ~V_BIT; // Set V flag
        m_regA = tmp3 & 0xff; // Mask result to 8 bits
        if (m_logInstructions) {
            cout << "sbc ($" << setw(2) << (int)operand1 << "),y" << endl;
        }
        len = 2;
        break;

    case 0xf5: // sbc xx,x
        if (m_regP & D_BIT) {
            if (m_logWarnings) {
                cout << "Warning: Decimal mode not implemented." << endl;
            }
        }
        tmp1 = read((operand1 + m_regX) & 0xff);
        tmp3 = m_regA - tmp1; // Subtract operand
        if (!(m_regP & C_BIT)) tmp3--; // Subtract 1 if carry not set
        ((tmp3 & 0x80) != 0) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        ((tmp3 >= 0) && (tmp3 <= 0xff)) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        ((tmp3 & 0xff) == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        ((tmp3 & 0x80) != (tmp1 & 0x80)) ? m_regP |= V_BIT : m_regP &= ~V_BIT; // Set V flag
        m_regA = tmp3 & 0xff; // Mask result to 8 bits
        if (m_logInstructions) {
            cout << "sbc $" << setw(4) << (int)operand1 << ",x" << endl;
        }
        len = 2;
        break;

    case 0xf6: // inc xx,x
        tmp1 = read((operand1 + m_regX) & 0xff) + 1;
        write((operand1 + m_regX) & 0xff, tmp1);
        (tmp1 & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (tmp1 == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "inc $" << setw(2) << (int)operand1 << ",x" << endl;
        }
        len = 2;
        break;

    case 0xf8: // sed
        m_regP |= D_BIT;
        if (m_logWarnings) {
            cout << "Warning: Decimal mode not implemented." << endl;
        }
        if (m_logInstructions) {
            cout << "sed" << endl;
        }
        break;

    case 0xf9: // sbc xxxx,y
        assert(operand1 + 256 * operand2 + m_regY <= 0xffff);
        if (m_regP & D_BIT) {
            if (m_logWarnings) {
            cout << "Warning: Decimal mode not implemented." << endl;
            }
        }
        tmp1 = read(operand1 + 256 * operand2 + m_regY);
        tmp3 = m_regA - tmp1; // Subtract operand
        if (!(m_regP & C_BIT)) tmp3--; // Subtract 1 if carry not set
        ((tmp3 & 0x80) != 0) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        ((tmp3 >= 0) && (tmp3 <= 0xff)) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        ((tmp3 & 0xff) == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        ((tmp3 & 0x80) != (tmp1 & 0x80)) ? m_regP |= V_BIT : m_regP &= ~V_BIT; // Set V flag
        m_regA = tmp3 & 0xff; // Mask result to 8 bits
        if (m_logInstructions) {
            cout << "sbc $" << setw(4) << operand1 + 256 * operand2 << ",y" << endl;
        }
        len = 3;
        break;

    case 0xfd: // sbc xxxx,x
        assert(operand1 + 256 * operand2 + m_regX <= 0xffff);
        if (m_regP & D_BIT) {
            if (m_logWarnings) {
                cout << "Warning: Decimal mode not implemented." << endl;
            }
        }
        tmp1 = read(operand1 + 256 * operand2 + m_regX);
        tmp3 = m_regA - tmp1; // Subtract operand
        if (!(m_regP & C_BIT)) tmp3--; // Subtract 1 if carry not set
        ((tmp3 & 0x80) != 0) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        ((tmp3 >= 0) && (tmp3 <= 0xff)) ? m_regP |= C_BIT : m_regP &= ~C_BIT; // Set C flag
        ((tmp3 & 0xff) == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        ((tmp3 & 0x80) != (tmp1 & 0x80)) ? m_regP |= V_BIT : m_regP &= ~V_BIT; // Set V flag
        m_regA = tmp3 & 0xff; // Mask result to 8 bits
        if (m_logInstructions) {
            cout << "sbc $" << setw(4) << operand1 + 256 * operand2 << ",x" << endl;
        }
        len = 3;
        break;

    case 0xfe: // inc xxxx,x
        assert(operand1 + 256 * operand2 + m_regX <= 0xffff);
        tmp1 = read(operand1 + 256 * operand2 + m_regX) + 1;
        write(operand1 + 256 * operand2 + m_regX, tmp1);
        (tmp1 & 0x80) ? m_regP |= S_BIT : m_regP &= ~S_BIT; // Set S flag
        (tmp1 == 0) ? m_regP |= Z_BIT : m_regP &= ~Z_BIT; // Set Z flag
        if (m_logInstructions) {
            cout << "inc $" << setw(4) << operand1 + 256 * operand2 << ",x" << endl;
        }
        len = 3;
        break;

    default: // Invalid instruction
        if (m_logInstructions) {
            cout << "??? (invalid instruction $" << setw(2) << (int)opcode << ")" << endl;
        }
        if (m_stopInvalid) {
            m_stop = true;
            m_stopReason = "invalid instruction";
        }
        break;
    }

    assert(tmp1 >= 0);
    assert(tmp1 <= 0xff);
    assert(tmp2 >= 0);
    assert(tmp2 <= 0xff);

    m_regPC += len;

    if (m_logRegisters) {
        dumpRegisters();
    }
}


bool Sim6502::stop()
{
    return m_stop;
}


string Sim6502::stopReason()
{
    m_stop = false;
    return m_stopReason;
}


void Sim6502::loggingStatus()
{
    cout << "Logging status:" << endl;
    cout << "errors:       " << (m_logErrors       ? "on" : "off" ) << endl;
    cout << "warnings:     " << (m_logWarnings     ? "on" : "off" ) << endl;
    cout << "serial:       " << (m_logSerial       ? "on" : "off" ) << endl;
    cout << "keyboard:     " << (m_logKeyboard     ? "on" : "off" ) << endl;
    cout << "memory:       " << (m_logMemory       ? "on" : "off" ) << endl;
    cout << "video:        " << (m_logVideo        ? "on" : "off" )<< endl;
    cout << "instructions: " << (m_logInstructions ? "on" : "off" ) << endl;
    cout << "registers:    " << (m_logRegisters    ? "on" : "off" ) << endl;
}


void Sim6502::enableLogging(string category, bool enable)
{
    if (category == "errors") {
        m_logErrors = enable;
    } else if (category == "warnings") {
        m_logWarnings = enable;
    } else if (category == "serial") {
        m_logSerial = enable;
    } else if (category == "keyboard") {
        m_logKeyboard = enable;
    } else if (category == "memory") {
        m_logMemory = enable;
    } else if (category == "video") {
        m_logVideo = enable;
    } else if (category == "instructions") {
        m_logInstructions = enable;
    } else if (category == "registers") {
        m_logRegisters = enable;
    } else if (category == "all") {
        m_logErrors = enable;
        m_logWarnings = enable;
        m_logSerial = enable;
        m_logKeyboard = enable;
        m_logMemory = enable;
        m_logVideo = enable;
        m_logInstructions = enable;
        m_logRegisters = enable;
    } else {
        cout << "Invalid logging category " << category << "." << endl;
        cout << "Valid categories are: errors, warnings, serial, keyboard, memory, video, instructions, registers, and all." << endl;
    }
}


bool Sim6502::stopInvalid()
{
    return m_stopInvalid;
}


void Sim6502::setStopInvalid(bool value)
{
    m_stopInvalid = value;
}


bool Sim6502::stopBrk()
{
    return m_stopBRK;
}


void Sim6502::setStopBrk(bool value)
{
    m_stopBRK = value;
}


string Sim6502::serialInputFile()
{
    return m_serialInFilename;
}


void Sim6502::setSerialInputFile(string filename)
{
    m_serialInFilename = filename;

    m_serialIn.close();

    m_serialIn.open(m_serialInFilename, ios::binary);
    if (m_logErrors) {
        if (!m_serialIn.is_open()) {
            cout << "Error: Unable to open serial port file 'serial.in'" << endl;
        }
    }


}


string Sim6502::serialOutputFile()
{
    return m_serialOutFilename;
}


void Sim6502::setSerialOutputFile(string filename)
{
    m_serialOutFilename = filename;

    m_serialOut.close();

    m_serialOut.open(m_serialOutFilename, ios::binary);
    if (m_logErrors) {
        if (!m_serialOut.is_open()) {
            cout << "Error: Unable to open serial port file 'serial.out'" << endl;
        }
    }
}

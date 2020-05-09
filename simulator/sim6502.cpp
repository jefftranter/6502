/*
 * Class to emulate a 6502 CPU and system with RAM, ROM, and peripherals.
 */

// TODO: Profile and optimize performance bottlenecks.

#include <cassert>
#include <iostream>
#include <iomanip>
#include <fstream>
#include "sim6502.h"

using namespace std;

Sim6502::Sim6502()
{
}

Sim6502::~Sim6502()
{
}

void Sim6502::setRamRange(uint16_t start, uint16_t end)
{
    assert(start <= end);
    m_ramStart = start;
    m_ramEnd = end;
}

void Sim6502::setRomRange(uint16_t start, uint16_t end)
{
    assert(start <= end);
    m_romStart = start;
    m_romEnd = end;
}

void Sim6502::reset()
{
    m_regPC = m_memory[0xfffc] + m_memory[0xfffd] * 256;
}

void Sim6502::step()
{
    // This is written for speed and efficiency and not elegance and redability.

    // TODO: Fully implement

    int len = 1; // Instruction length
    uint8_t opcode = m_memory[m_regPC];
    uint8_t operand1 = m_memory[m_regPC + 1];
    uint8_t operand2 = m_memory[m_regPC + 2];
    
    switch (opcode) {

    case 0x18: // clc     
        m_regSR &= ~C_BIT;
        cout << "clc" << endl;
        break;

    case 0x38: // sec
        m_regSR |= C_BIT;
        cout << "sec" << endl;
        break;

    case 0x4c: // jmp
        m_regPC = operand1 + 256 * operand2;
        cout << "jmp $" << operand1 + 256 * operand2 << endl;
        len = 0;
        break;
        
    case 0x69: // adc #xx
        m_regA += operand1; // Add immediate operand
        if (m_regSR & C_BIT) m_regA++; // Add 1 if carry set
        // TODO: Update S, V, Z, C flags
        (m_regA >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regA >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT; // Set V flag
        (m_regA == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        (m_regA >= 0x80) ? m_regSR |= C_BIT : m_regSR &= ~C_BIT; // Set C flag
        cout << "adc #$" << (int)operand1 << endl;
        len = 2;
        break;

    case 0x8c: // sty xxxx
        write(operand1 + 256 * operand2, m_regY);
        cout << "sty $" << operand1 + 256 * operand2 << endl;
        len = 3;
        break;

    case 0x8d: // sta xxxx
        write(operand1 + 256 * operand2, m_regA);
        cout << "sta $" << operand1 + 256 * operand2 << endl;
        len = 3;
        break;

    case 0x8e: // stx xxxx
        write(operand1 + 256 * operand2, m_regX);
        cout << "stx $" << operand1 + 256 * operand2 << endl;
        len = 3;
        break;

    case 0xa0: // ldy #
        m_regY = operand1;
        (m_regY >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regY == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "ldy #$" << (int)operand1 << endl;
        len = 2;
        break;

    case 0xa2: // ldx #
        m_regX = operand1;
        (m_regX >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regX == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "ldx #$" << (int)operand1 << endl;
        len = 2;
        break;

    case 0xa9: // lda #
        m_regA = operand1;
        (m_regA >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regA == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "lda #$" << (int)operand1 << endl;
        len = 2;
        break;

    case 0xac: // ldy xxxx
        m_regY = read(operand1 + 256 * operand2);
        (m_regY >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regY == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "ldy $" << operand1 + 256 * operand2 << endl;
        len = 3;
        break;

    case 0xad: // lda xxxx
        m_regA = read(operand1 + 256 * operand2);
        (m_regA >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regA == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "lda $" << operand1 + 256 * operand2 << endl;
        len = 3;
        break;

    case 0xae: // ldx xxxx
        m_regX = read(operand1 + 256 * operand2);
        (m_regX >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regX == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        cout << "ldx $" << operand1 + 256 * operand2 << endl;
        len = 3;
        break;

    case 0xc8: // iny
        cout << "iny" << endl;
        m_regY++;
        (m_regY >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regY == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        break;

    case 0xca: // dex
        cout << "dex" << endl;
        m_regX--;
        (m_regX >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
        (m_regX == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
        break;

    case 0xd0: // bne
        if (!(m_regSR & Z_BIT)) {
            if (operand1 > 0x7f) { // Branch taken
                m_regPC = m_regPC + 1 - (uint8_t)~operand1; // Branch back
            } else {
                m_regPC = m_regPC + 1 + operand1; // Branch forward
            }
            len = 0;
        } else { // Branch not taken
            len = 2;
        }
        cout << "bne " << (int)operand1 << endl;
        break;
        
    case 0xd8: // cld
        m_regSR &= ~D_BIT;
        cout << "cld" << endl;
        break;

    case 0xea: // nop
        cout << "nop" << endl;
        break;

    case 0xee: // inc xxxx
        {
            uint8_t val = read(operand1 + 256 * operand2) + 1;
            write(operand1 + 256 * operand2, val);
            (val >= 0x80) ? m_regSR |= S_BIT : m_regSR &= ~S_BIT;; // Set S flag
            (val == 0) ? m_regSR |= Z_BIT : m_regSR &= ~Z_BIT; // Set Z flag
            cout << "inc $" << operand1 + 256 * operand2 << endl;
            len = 3;
            break;
        }

    case 0xf8: // sed
        // TODO: Handle decimal mode for relevant instructions
        m_regSR |= D_BIT;
        cout << "sed" << endl;
        break;
        
    default: // Invalid instruction, handle as NOP
        cout << "???" << endl;
        break;
    }

    m_regPC += len;
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
    // TODO: Implement full IRQ handling
    m_regPC = m_memory[0xfffe] + m_memory[0xffff] * 256;
}

void Sim6502::nmi()
{
    // TODO: Implement full NMI handling
    m_regPC = m_memory[0xfffa] + m_memory[0xfffb] * 256;
}

uint8_t Sim6502::aReg()
{
    return m_regA;
}

void Sim6502::setAReg(uint8_t val)
{
    m_regA = val;
}

uint8_t Sim6502::xReg()
{
    return m_regX;
}

void Sim6502::setXReg(uint8_t val)
{
    m_regX = val;
}

uint8_t Sim6502::yReg()
{
    return m_regY;
}

void Sim6502::setYReg(uint8_t val)
{
    m_regY = val;
}

uint8_t Sim6502::sr()
{
    return m_regSR;
}

void Sim6502::setSR(uint8_t val)
{
    m_regSR = val;
}

uint8_t Sim6502::sp()
{
    return m_regSP;
}

void Sim6502::setSP(uint8_t val)
{
    m_regSP = val;
}

uint16_t Sim6502::pc()
{
    return m_regPC;
}

void Sim6502::setPC(uint16_t val)
{
    m_regPC = val;
}

void Sim6502::write(uint16_t address, uint8_t byte)
{
    // Ignore writes to ROM or unused memory.
    if (isRam(address) || isPeripheral(address)) {
        m_memory[address] = byte;
    }
}

uint8_t Sim6502::read(uint16_t address)
{
    return m_memory[address];
}

bool Sim6502::isRam(uint16_t address)
{
    // TODO: May want to optimize using array lookup
    return (address >= m_ramStart && address <= m_ramEnd);
}


bool Sim6502::isRom(uint16_t address)
{
    // TODO: May want to optimize using array lookup
    return (address >= m_romStart && address <= m_romEnd);
}

bool Sim6502::isPeripheral(uint16_t address)
{
    // TODO: Implement
    return false;
}

bool Sim6502::isUnused(uint16_t address)
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
        cerr << "Error: Unable to open file '" << filename << "' for reading." << endl;
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
        cerr << "Error: Unable to open file '" << filename << "' for writing." << endl;
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

void Sim6502::dumpMemory(uint16_t startAddress, uint16_t endAddress)
{
    assert(startAddress <= endAddress);

    for (int i = startAddress; i <= endAddress; i++) {

        if ((i == startAddress) || (i % 16 == 0)) {
            cout << endl << hex << setfill('0') << setw(4) << i << ":";
        }    
        cout << " " << setfill('0') << setw(2) << (int)m_memory[i];
    }
    cout << endl;
}

void Sim6502::dumpRegisters()
{
    string s;

    (m_regSR & S_BIT) ? s += "S" : s += "s";
    (m_regSR & V_BIT) ? s += "V" : s += "v";
    (m_regSR & X_BIT) ? s += "1" : s += "0";
    (m_regSR & B_BIT) ? s += "B" : s += "b";
    (m_regSR & D_BIT) ? s += "D" : s += "d";
    (m_regSR & I_BIT) ? s += "I" : s += "i";
    (m_regSR & Z_BIT) ? s += "Z" : s += "z";
    (m_regSR & C_BIT) ? s += "C" : s += "c";

    cout << hex << setfill('0') << "PC=" << setw(4) << m_regPC
         << " A=" << setw(2) << (int)m_regA
         << " X=" << setw(2) << (int)m_regX
         << " Y=" << setw(2) << (int)m_regY
         << " SP=01" << setw(2) << (int)m_regSP
         << " SR=" << s << endl;
}

void Sim6502::disassemble(uint16_t startAddress, uint16_t endAddress)
{
    // TODO: Implement
}

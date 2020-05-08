/*
 * Class to emulate a 6502 CPU and system with RAM, ROM, and peripherals.
 */

#include <cassert>
#include <iostream>
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
    // TODO: Implement
    m_regPC += 1;
}

Sim6502::CpuType Sim6502::cpuType()
{
    return m_cpuType;
}

void Sim6502::setCpuType(const CpuType &type)
{
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

void Sim6502::poke(uint16_t address, uint8_t byte)
{
    m_memory[address] = byte;
}

uint8_t Sim6502::peek(uint16_t address)
{
    return m_memory[address];
}

bool Sim6502::isRam(uint16_t address)
{
    return (address >= m_ramStart && address <= m_ramEnd);
}


bool Sim6502::isRom(uint16_t address)
{
    return (address >= m_romStart && address <= m_romEnd);
}

bool Sim6502::isPeripheral(uint16_t address)
{
    return false;
}

bool Sim6502::isUnused(uint16_t address)
{
    return (!isRam(address) && !isRom(address));
}

bool Sim6502::loadMemory(string filename, uint16_t startAddress)
{
    ifstream inFile;

    inFile.open(filename, ios::binary);
    if (inFile.is_open()) {
        for (int i = startAddress; i <= 0xffff; i++) {
            inFile.read((char*) &m_memory[i], 1);
        }
        inFile.close();
        return true;
    } else {
        return false;
    }
}

bool Sim6502::saveMemory(string filename, uint16_t startAddress, uint16_t endAddress)
{
    ofstream outFile;

    outFile.open(filename, ios::binary);
    if (outFile.is_open()) {
        for (int i = startAddress; i <= endAddress; i++) {
            outFile.write((const char*) &m_memory[i], 1);
        }
        outFile.close();
        return true;
    } else {
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

    // TODO: Make hex output correct number of digits with leading zeroes.
    
    for (int i = startAddress; i <= endAddress; i++) {

        if ((i == startAddress) || (i % 16 == 0)) {
            cout << endl << hex << i << ":";
        }    
        cout << " " << (int) m_memory[i] << flush;
    }
    cout << endl;
}

void Sim6502::dumpRegisters()
{
    // TODO: Make hex output correct number of digits with leading zeroes.
    // TODO: Show SR symbolically eg. SV-BDIZC

    cout << hex << "PC=" << m_regPC << " A=" << (int) m_regA << " X=" << (int) m_regX << " Y=" << (int) m_regY << " SP=01" << (int) m_regSP << " SR=" << (int) m_regSP << endl;
}

void Sim6502::disassemble(uint16_t startAddress, uint16_t endAddress)
{
    // TODO: Implement
}

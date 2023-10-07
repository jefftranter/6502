These are configuration files for the Romulator for various
6502-based computers.

References:

1. https://bitfixer.com/product/romulat
2. https://github.com/bitfixer/bf-romulator

Configurations (selected using DIP switch)
------------------------------------------

```
Config Description
------ -----------
  0    NOP generator
  1    Pass through
  2    My 6502 Single Board Computer
  3    Apple 1 / Briel Replica 1
  4    Briel SuperBoard III /  OSI 600/Superboard II with 610 board
  5    Apple IIc
```

Notes and Details of Memory Maps
--------------------------------

My 6502 SBC:

ROM includes Microsoft Basic and JMON monitor.

```
$0000 - $7FFF  RAM (32K)
$8000 - $9FFF  6522 VIA
$A000 - $BFFF  6850 ACIA
$C000 - $FFFF  ROM (16K)
```

Briel Replica 1:

Should also work with an Apple 1 and other Apple 1 replicas.
ROM includes Apple 1 Basic and Krusader assembler.

```
$0000-$7FFF  RAM (32K)
$8000-$CFFF  Peripherals (optional/off-board)
$D000-$DFFF  6821 PIA
$E000-$FFFF  ROM (8K)
```

OSI Superboard II / Challenger 1P / Model 600 / Briel SuperBoard III:

ROM includes Microsoft Basic (with bug fixes) and monitor.
Emulates 32K RAM and supports 610 expander board.

```
$0000-$7FFF  RAM (32K)
$A000-$BFFF  ROM (BASIC)
$C000-$CFFF  Peripherals (PIA and ACIA on 610 expander board)
$D000-$D3FF  Video memory
$D400-$F7FF  Peripherals (keyboard, ACIA)
$F800-$FFFF  ROM
```

Apple IIc:

Currently not working, likely due to lack of support for emulating RAM
and ROM bank switching. Does work in pass through mode.

```
$0000-$03FF  RAM
$0400-$0BFF  Text Video RAM
$0C00-$1FFF  RAM
$2000-$5FFF  High Resolution Video RAM
$6000-$BFFF  RAM
$C000-$C0FF  Peripherals
$C100-$FFFF  ROM
```

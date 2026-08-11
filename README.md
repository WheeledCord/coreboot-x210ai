# Coreboot for the X210AI

A coreboot port for the X210AI: a Meteor Lake (Core Ultra 7 165H / 9 185H) mainboard for the ThinkPad X200/X201 chassis, with DDR5 SODIMM, two M.2 NVMe, a 2.5" SATA bay, and two USB C (one Thunderbolt 4).

## Building

```sh
git clone https://github.com/WheeledCord/coreboot-x210ai
cd coreboot-x210ai
git submodule update --init --checkout
make crossgcc-i386 CPUS=$(nproc)   # first time only; builds coreboot's toolchain
make menuconfig                    # Mainboard -> 51NB -> X210AI
make
```

Output is `build/coreboot.rom`. Only the BIOS region is built — the factory descriptor and ME stay on the chip.

## Disabling Boot Guard (do this first)

The X210AI ships with Intel Boot Guard enabled, so the CPU won't run coreboot until it's disabled.

Because the board is in manufacturing mode, Boot Guard's config isn't fused and lives in editable SPI flash. You can disable it via MFIT, but this isn't accessible to most people, so I provide an image [here](https://github.com/WheeledCord/coreboot-x210ai/releases). Back up your chip, then flash it internally:

```sh
flashrom -p internal -r factory_backup.bin
flashrom -p internal -w x210ai-bootguard-disabled.bin
```

## Flashing

MAKE SURE TO DISABLE INTEL BOOT GUARD FIRST!!!

Internal, from Linux on the running board (easiest):

```sh
flashrom -p internal --ifd -i bios -N -w build/coreboot.rom
```

Flashing externally with an SPI programmer can also be done. The SPI chip is a WSON-8 on the mainboard, circled here:

![SPI chip location](Documentation/mainboard/51nb/x210ai.png)

## Status

Boots Linux with NVMe/SATA, WiFi, Bluetooth, Ethernet, ALC1220 audio, internal eDP + external HDMI/DP, USB, and S3 resume all working.

Untested: TPM (Intel PTT isn't enabled in this ME), Thunderbolt/USB4, WWAN.

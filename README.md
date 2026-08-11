# Coreboot for the X210AI

A [coreboot](https://coreboot.org) port for the X210AI: a Meteor Lake
(Core Ultra 7 165H / 9 185H) mainboard that drops into the ThinkPad X200/X201
chassis, with DDR5 SODIMMs, two M.2 NVMe, a 2.5" SATA bay, and two USB C (one
Thunderbolt 4).

This is a fork of upstream coreboot with the board added under
`src/mainboard/51nb/x210ai`. It's also in review upstream:
https://review.coreboot.org/c/coreboot/+/94886

## Building

```sh
git clone https://github.com/WheeledCord/coreboot-x210ai
cd coreboot-x210ai
git submodule update --init --checkout
make crossgcc-i386 CPUS=$(nproc)   # first time only; builds coreboot's toolchain
make menuconfig                    # Mainboard -> 51NB -> X210AI
make
```

Output is `build/coreboot.rom`. Only the BIOS region is built — the factory
descriptor and ME stay on the chip.

## Flashing

MAKE SURE TO DISABLE INTEL BOOT GUARD FIRST!!!

Internal, from Linux on the running board (easiest):

```sh
flashrom -p internal --ifd -i bios -N -w build/coreboot.rom
```

Flashing externally with an SPI programmer can also be done. The SPI chip is a WSON-8
on the mainboard, circled here:

![SPI chip location](Documentation/mainboard/51nb/x210ai.png)

## Status

Boots Linux with NVMe/SATA, WiFi, Bluetooth, Ethernet, ALC1220 audio, internal
eDP + external HDMI/DP, USB, and S3 resume all working.

Untested: TPM (Intel PTT isn't enabled in this ME), Thunderbolt/USB4, WWAN.

## Payload

Payload is your choice in `make menuconfig`. I run edk2 (UefiPayloadPkg) to boot
a UEFI OS off NVMe.

/* SPDX-License-Identifier: GPL-2.0-only */

Device (\_SB.PCI0.LPCB.EC0)
{
	Name (_HID, EisaId ("PNP0C09"))
	Name (_UID, 1)
	Name (_CRS, ResourceTemplate () {
		IO (Decode16, 0x62, 0x62, 0, 1)
		IO (Decode16, 0x66, 0x66, 0, 1)
	})
	Name (_GPE, GPE0_ESPI)
	Name (_PRW, Package () { GPE0_ESPI, 4 })

	OperationRegion (ERAM, EmbeddedControl, 0, 0x100)
	Field (ERAM, ByteAcc, Lock, Preserve)
	{
		Offset (0x7f),
		LSTE, 1,
		Offset (0x80),
		ACIN, 1,
		Offset (0x81),
		B1ST, 8,
		Offset (0x84),
		B1DC, 16,	/* Design capacity, mAh */
		B1DV, 16,	/* Design voltage, mV */
		B1FC, 16,	/* Last full charge capacity, mAh */
		BICC, 16,	/* Cycle count */
		B1CR, 16,	/* Present rate, mA */
		B1RC, 16,	/* Remaining capacity, mAh */
		B1FV, 16	/* Present voltage, mV */
	}

	Name (ECAV, 0)

	Method (_REG, 2, Serialized)
	{
		If (Arg0 == 3) {
			ECAV = Arg1
			^ADP1._PSR ()
			^LID0._LID ()
		}
	}

	Method (WAK, 1)
	{
		^ADP1._PSR ()
		Notify (ADP1, 0x80)
		Notify (BAT0, 0x81)
		Notify (BAT0, 0x80)
	}

	Method (_Q06)
	{
		\_SB.PCI0.GFX0.DECB ()
	}

	Method (_Q07)
	{
		\_SB.PCI0.GFX0.INCB ()
	}

	Method (_Q0A)
	{
		Notify (ADP1, 0x80)
	}

	Method (_Q0B)
	{
		Notify (BAT0, 0x81)
		Notify (BAT0, 0x80)
	}

	Method (_Q0C)
	{
		Notify (LID0, 0x80)
	}

	Method (_Q54)
	{
		Notify (\_SB.PWRB, 0x80)
	}

	#include "battery.asl"

	Device (ADP1)
	{
		Name (_HID, "ACPI0003")
		Name (_PCL, Package () { \_SB })
		Method (_PSR)
		{
			If (ECAV) {
				If (B1ST & 8) {
					\PWRS = ACIN
				} Else {
					\PWRS = 1
				}
			}
			Return (\PWRS)
		}
	}

	Device (LID0)
	{
		Name (_HID, EisaId ("PNP0C0D"))
		Method (_LID)
		{
			If (ECAV) {
				\LIDS = LSTE
			}
			Return (\LIDS)
		}
	}
}

Device (\_SB.PWRB)
{
	Name (_HID, EisaId ("PNP0C0C"))
}

/* SPDX-License-Identifier: GPL-2.0-only */

/*
 * host-side ec acpi for the ite it5571e, from the vendor dsdt (H_EC, PNP0C09).
 * needs \PWRS and \ECON at root (see mainboard.asl).
 */

Scope (\_SB.PCI0.LPCB)
{
	Device (H_EC)
	{
		Name (_HID, EisaId ("PNP0C09") /* Embedded Controller Device */)
		Name (_UID, 1)
		Name (ECAV, 1)
		Name (BNUM, 0)
		Name (ECTK, 1)
		Mutex (EHLD, 0x00)
		Mutex (ECMT, 0x00)
		Name (VPWR, 1)

		Method (_STA, 0, NotSerialized)
		{
			If ((ECON == 1))
			{
				Return (0x0F)
			}

			Return (0)
		}

		Method (_CRS, 0, Serialized)
		{
			Name (BFFR, ResourceTemplate ()
			{
				IO (Decode16, 0x0062, 0x0062, 0x00, 0x01)
				IO (Decode16, 0x0066, 0x0066, 0x00, 0x01)
			})
			Return (BFFR)
		}

		/* EC SCI general purpose event (vendor: 0x6E). */
		Method (_GPE, 0, NotSerialized)
		{
			Return (0x6E)
		}

		/* arm the ec sci (gpe 0x6E) as a wake source (lid, power button) */
		Name (_PRW, Package () { 0x6E, 4 })

		/* authoritative ec-ram layout, accessed via the acpi ec at 0x62/0x66. */
		OperationRegion (ECF2, EmbeddedControl, 0, 0xFF)
		Field (ECF2, ByteAcc, Lock, Preserve)
		{
			ECFM,   8,
			ECFS,   8,
			ECFT,   8,
			Offset (0x10),
			APTS,   8,
			Offset (0x7F),
			LSTE,   1,
			Offset (0x80),
			ACIN,   1,
			Offset (0x81),
			B1ST,   8,
			Offset (0x84),
			B1DC,   16,
			B1DV,   16,
			B1FC,   16,
			BICC,   16,
			B1CR,   16,
			B1RC,   16,
			B1FV,   16,
			B1RS,   8,
			BTP1,   8
		}

		Method (ECRD, 1, Serialized)
		{
			If (ECTK)
			{
				If ((_REV >= 0x02))
				{
					ECAV = 1
				}

				ECTK = 0
			}

			Local0 = Acquire (ECMT, 0xA000)
			If ((Local0 == 0))
			{
				If (ECAV)
				{
					Local1 = DerefOf (Arg0)
					Release (ECMT)
					Return (Local1)
				}
				Else
				{
					Release (ECMT)
				}
			}

			Return (0xFFFFFFFF)
		}

		/* on embeddedcontrol availability, init ec-present + power/battery state. */
		Method (_REG, 2, NotSerialized)
		{
			If (((Arg0 == 0x03) && (Arg1 == 1)))
			{
				ECAV = 1
				BNUM = 0
				BNUM |= ((ECRD (RefOf (B1ST)) & 0x08) >> 0x03)
				If ((BNUM == 0))
				{
					PWRS = ECRD (RefOf (VPWR))
				}
				Else
				{
					PWRS = ECRD (RefOf (ACIN))
				}
			}
		}

		/* ac status change. */
		Method (_Q0A, 0, NotSerialized)
		{
			PWRS = ECRD (RefOf (ACIN))
			Notify (ADP1, 0x80)
		}

		/* battery status change. */
		Method (_Q0B, 0, NotSerialized)
		{
			BNUM = 0
			BNUM |= ((ECRD (RefOf (B1ST)) & 0x08) >> 0x03)
			Notify (BAT0, 0x81)
			Notify (BAT0, 0x80)
		}

		/* lid status change. */
		Method (_Q0C, 0, NotSerialized)
		{
			LIDS = ECRD (RefOf (LSTE))
			Notify (LID0, 0x80)
		}

		/* power button. */
		Method (_Q54, 0, NotSerialized)
		{
			Notify (PWRB, 0x80)
		}

		#include "battery.asl"

		Device (LID0)
		{
			Name (_HID, EisaId ("PNP0C0D") /* Lid Device */)
			Method (_STA, 0, NotSerialized)
			{
				If ((ECON == 1))
				{
					Return (0x0F)
				}

				Return (0)
			}

			Method (_LID, 0, NotSerialized)
			{
				Return (ECRD (RefOf (LSTE)))
			}
		}
	}
}

Scope (\_SB)
{
	Device (ADP1)
	{
		Name (_HID, "ACPI0003" /* Power Source Device */)
		Method (_STA, 0, NotSerialized)
		{
			If ((ECON == 1))
			{
				Return (0x0F)
			}

			Return (0)
		}

		Method (_PSR, 0, NotSerialized)
		{
			Return (PWRS)
		}

		Method (_PCL, 0, NotSerialized)
		{
			Return (Package (0x01)
			{
				_SB
			})
		}
	}

	Device (PWRB)
	{
		Name (_HID, EisaId ("PNP0C0C") /* Power Button Device */)
		Name (PBST, 1)
		Method (_STA, 0, NotSerialized)
		{
			Return (0x0F)
		}
	}
}

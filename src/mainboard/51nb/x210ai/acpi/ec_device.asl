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
		Name (_UID, One)
		Name (ECAV, One)
		Name (BNUM, Zero)
		Name (ECTK, One)
		Mutex (EHLD, 0x00)
		Mutex (ECMT, 0x00)
		Name (VPWR, One)

		Method (_STA, 0, NotSerialized)
		{
			If ((ECON == One))
			{
				Return (0x0F)
			}

			Return (Zero)
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
		OperationRegion (ECF2, EmbeddedControl, Zero, 0xFF)
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
					ECAV = One
				}

				ECTK = Zero
			}

			Local0 = Acquire (ECMT, 0xA000)
			If ((Local0 == Zero))
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
			If (((Arg0 == 0x03) && (Arg1 == One)))
			{
				ECAV = One
				BNUM = Zero
				BNUM |= ((ECRD (RefOf (B1ST)) & 0x08) >> 0x03)
				If ((BNUM == Zero))
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
			BNUM = Zero
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

		Device (BAT0)
		{
			Name (_HID, EisaId ("PNP0C0A") /* Control Method Battery */)
			Name (_UID, Zero)
			Method (_STA, 0, NotSerialized)
			{
				If ((BNUM & One))
				{
					Return (0x1F)
				}
				Else
				{
					Return (0x0B)
				}
			}

			Method (_BIF, 0, Serialized)
			{
				Name (BPK1, Package (0x0D)
				{
					Zero,
					0xFFFFFFFF,
					0xFFFFFFFF,
					One,
					0xFFFFFFFF,
					Zero,
					Zero,
					0x0100,
					0x40,
					"BASE-BAT",
					"123456789",
					"LiP",
					"Simplo"
				})
				If (ECAV)
				{
					Local0 = ECRD (RefOf (B1DV))
					Local1 = ECRD (RefOf (B1FC))
					If ((Local0 && Local1))
					{
						BPK1 [One] = ((ECRD (RefOf (B1DC)) * Local0) / 0x03E8)
						Local2 = (Local0 * Local1)
						BPK1 [0x02] = (Local2 / 0x03E8)
						BPK1 [0x04] = Local0
						BPK1 [0x05] = (Local2 / 0x2710)
						BPK1 [0x06] = (Local2 / 0x61A8)
						BPK1 [0x07] = 0x0100
						BPK1 [0x08] = 0x40
					}
				}

				Return (BPK1)
			}

			Method (_BIX, 0, Serialized)
			{
				Name (BPK1, Package (0x15)
				{
					One,
					Zero,
					0xFFFFFFFF,
					0xFFFFFFFF,
					One,
					0xFFFFFFFF,
					Zero,
					Zero,
					0x64,
					0x00017318,
					Zero,
					Zero,
					Zero,
					Zero,
					0x0100,
					0x40,
					"BASE-BAT",
					"123456789",
					"LiP",
					"Simplo",
					One
				})
				If (ECAV)
				{
					Local0 = ECRD (RefOf (B1DV))
					Local1 = ECRD (RefOf (B1FC))
					If ((Local0 && Local1))
					{
						BPK1 [0x02] = ((ECRD (RefOf (B1DC)) * Local0) / 0x03E8)
						Local2 = (Local0 * Local1)
						BPK1 [0x03] = (Local2 / 0x03E8)
						BPK1 [0x05] = Local0
						BPK1 [0x06] = (Local2 / 0x2710)
						BPK1 [0x07] = (Local2 / 0x61A8)
						BPK1 [0x08] = ECRD (RefOf (BICC))
					}
				}

				Return (BPK1)
			}

			Method (_BST, 0, Serialized)
			{
				Name (PKG1, Package (0x04)
				{
					0xFFFFFFFF,
					0xFFFFFFFF,
					0xFFFFFFFF,
					0xFFFFFFFF
				})
				If (ECAV)
				{
					PKG1 [Zero] = (ECRD (RefOf (B1ST)) & 0x07)
					Local1 = ECRD (RefOf (B1FV))
					Local0 = (ECRD (RefOf (B1CR)) * Local1)
					Local0 = (Local0 / 0x03E8)
					PKG1 [One] = Local0
					PKG1 [0x02] = ((ECRD (RefOf (B1RC)) * ECRD (RefOf (B1DV))) / 0x03E8)
					PKG1 [0x03] = Local1
				}

				Return (PKG1)
			}

			Method (_PCL, 0, NotSerialized)
			{
				Return (_SB)
			}
		}

		Device (LID0)
		{
			Name (_HID, EisaId ("PNP0C0D") /* Lid Device */)
			Method (_STA, 0, NotSerialized)
			{
				If ((ECON == One))
				{
					Return (0x0F)
				}

				Return (Zero)
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
			If ((ECON == One))
			{
				Return (0x0F)
			}

			Return (Zero)
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
		Name (PBST, One)
		Method (_STA, 0, NotSerialized)
		{
			Return (0x0F)
		}
	}
}

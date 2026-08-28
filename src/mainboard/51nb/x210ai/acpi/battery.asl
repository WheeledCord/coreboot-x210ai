/* SPDX-License-Identifier: GPL-2.0-only */

		Device (BAT0)
		{
			Name (_HID, EisaId ("PNP0C0A") /* Control Method Battery */)
			Name (_UID, 0)
			Method (_STA, 0, NotSerialized)
			{
				If ((BNUM & 1))
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
					0,
					0xFFFFFFFF,
					0xFFFFFFFF,
					1,
					0xFFFFFFFF,
					0,
					0,
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
						BPK1 [1] = ((ECRD (RefOf (B1DC)) * Local0) / 0x03E8)
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
					1,
					0,
					0xFFFFFFFF,
					0xFFFFFFFF,
					1,
					0xFFFFFFFF,
					0,
					0,
					0x64,
					0x00017318,
					0,
					0,
					0,
					0,
					0x0100,
					0x40,
					"BASE-BAT",
					"123456789",
					"LiP",
					"Simplo",
					1
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
					PKG1 [0] = (ECRD (RefOf (B1ST)) & 0x07)
					Local1 = ECRD (RefOf (B1FV))
					Local0 = (ECRD (RefOf (B1CR)) * Local1)
					Local0 = (Local0 / 0x03E8)
					PKG1 [1] = Local0
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

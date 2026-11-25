/* SPDX-License-Identifier: GPL-2.0-only */

Device (BAT0)
{
	Name (_HID, EisaId ("PNP0C0A"))
	Name (_UID, 0)
	Name (_PCL, Package () { \_SB })

	Method (_STA)
	{
		If (ECAV) {
			If (B1ST & 8) {
				Return (0x1f)
			}
		}
		Return (0x0b)
	}

	Method (_BIX, 0, Serialized)
	{
		Local0 = Package () {
			1, 0, 0xffffffff, 0xffffffff, 1, 0xffffffff,
			0, 0, 0xffffffff, 95000, 0, 0, 0, 0,
			256, 64, "BASE-BAT", "", "LiP", "", 1
		}
		If (ECAV) {
			Local1 = B1DV
			Local2 = B1FC * Local1
			If (Local2) {
				Local0[2] = B1DC * Local1 / 1000
				Local0[3] = Local2 / 1000
				Local0[5] = Local1
				Local0[6] = Local2 / 10000
				Local0[7] = Local2 / 25000
			}
			Local0[8] = BICC
		}
		Return (Local0)
	}

	Method (_BST, 0, Serialized)
	{
		Local0 = Package () { 0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff }
		If (ECAV) {
			Local1 = B1FV
			Local0[0] = B1ST & 7
			Local0[1] = B1CR * Local1 / 1000
			Local0[2] = B1RC * B1DV / 1000
			Local0[3] = Local1
		}
		Return (Local0)
	}
}

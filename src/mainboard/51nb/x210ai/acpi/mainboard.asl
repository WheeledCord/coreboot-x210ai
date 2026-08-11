/* SPDX-License-Identifier: GPL-2.0-only */

/* \ECON = ec present; \PWRS and \LIDS come from coreboot (globalnvs) */
Name (ECON, One)

#include "ec_device.asl"

Scope (\_SB) {
	#include "sleep.asl"
	Scope (PCI0) {
		#include "backlight.asl"
	}
}

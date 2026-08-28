/* SPDX-License-Identifier: GPL-2.0-only */

/* \ECON = ec present; \PWRS and \LIDS come from coreboot (globalnvs) */
Name (ECON, 1)

#include "ec.asl"

Scope (\_SB) {
	#include "sleep.asl"
	Scope (PCI0) {
		#include <drivers/intel/gma/acpi/default_brightness_levels.asl>
	}
}

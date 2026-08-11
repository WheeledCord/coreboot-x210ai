## SPDX-License-Identifier: GPL-2.0-only

CPPFLAGS_common += -I$(src)/mainboard/$(MAINBOARDDIR)/include

bootblock-y += bootblock.c

romstage-y += romstage.c

ramstage-y += ramstage.c
ramstage-y += gpio.c
ramstage-y += hda_verb.c

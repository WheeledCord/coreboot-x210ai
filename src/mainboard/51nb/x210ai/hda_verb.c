/* SPDX-License-Identifier: GPL-2.0-only */

/* alc1220 analog codec, pin config from this board's hda dump */

#include <device/azalia_device.h>

static const u32 realtek_alc1220_verbs[] = {
	AZALIA_SUBVENDOR(0, 0x10ec129e),
	AZALIA_PIN_CFG(0, 0x12, 0x90a60140), /* internal mic */
	AZALIA_PIN_CFG(0, 0x14, 0x04214010), /* headphone out */
	AZALIA_PIN_CFG(0, 0x15, 0x40000000), /* line out - n/a */
	AZALIA_PIN_CFG(0, 0x16, 0x411111f0), /* not connected */
	AZALIA_PIN_CFG(0, 0x17, 0x411111f0), /* not connected */
	AZALIA_PIN_CFG(0, 0x18, 0x04a19030), /* headset mic */
	AZALIA_PIN_CFG(0, 0x19, 0x04a1903f), /* mic - disabled */
	AZALIA_PIN_CFG(0, 0x1a, 0x90170120), /* internal speaker */
	AZALIA_PIN_CFG(0, 0x1b, 0x411111f0), /* not connected */
	AZALIA_PIN_CFG(0, 0x1d, 0x40a5b105), /* pc-beep */
	AZALIA_PIN_CFG(0, 0x1e, 0x01441120), /* spdif out */
};

struct azalia_codec mainboard_azalia_codecs[] = {
	{
		.name         = "Realtek ALC1220",
		.vendor_id    = 0x10ec1168,
		.subsystem_id = 0x10ec129e,
		.address      = 0,
		.verbs        = realtek_alc1220_verbs,
		.verb_count   = ARRAY_SIZE(realtek_alc1220_verbs),
	},
};

const u32 pc_beep_verbs[] = {};

AZALIA_ARRAY_SIZES;

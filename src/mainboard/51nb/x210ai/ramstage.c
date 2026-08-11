/* SPDX-License-Identifier: GPL-2.0-only */

#include <mainboard/gpio.h>
#include <soc/ramstage.h>

static void mainboard_init(void *chip_info)
{
	mainboard_configure_gpios();
}

struct chip_operations mainboard_ops = {
	.init = mainboard_init,
};

void mainboard_silicon_init_params(FSP_S_CONFIG *params)
{
	params->PchEspiHostC10ReportEnable = 0;

	/* SATA bay requires hot-plug for link training */
	params->SataPortsHotPlug[0] = 1;
}

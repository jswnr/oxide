/*
 * © 2026 Jakub Świniarski
 *
 * SPDX-License-Identifier: MIT
 */

#include <bsp/board_api.h>
#include <hardware/clocks.h>
#include <hardware/pll.h>
#include <hardware/vreg.h>
#include <pico/time.h>

#include "kbd.h"

static const uint32_t interval_ms = 10;

static uint8_t keycodes[N_KEYCODES] = { 0 };

int main(void) {
    board_init();

    tusb_rhport_init_t dev_init = {
        .role = TUSB_ROLE_DEVICE,
        .speed = TUSB_SPEED_FULL
    };
    tusb_init(BOARD_TUD_RHPORT, &dev_init);

    board_init_after_tusb();

    clock_stop(clk_adc);
    clock_stop(clk_rtc);
    clock_stop(clk_peri);

    clock_configure(
        clk_sys,
        CLOCKS_CLK_SYS_CTRL_SRC_VALUE_CLKSRC_CLK_SYS_AUX,
        CLOCKS_CLK_SYS_CTRL_AUXSRC_VALUE_CLKSRC_PLL_USB,
        48 * MHZ,
        48 * MHZ
    );
    pll_deinit(pll_sys);

    vreg_set_voltage(VREG_VOLTAGE_0_90);

    kbd_init();

    absolute_time_t next_scan = get_absolute_time();
    bool report_pending = false;
    while (true) {
        tud_task();

        if (time_reached(next_scan)) {
            next_scan = make_timeout_time_ms(interval_ms);

            if (kbd_scan(keycodes))
                report_pending = true;
        }

        if (report_pending && tud_hid_ready()) {
            tud_hid_keyboard_report(0, 0, keycodes);
            report_pending = false;
        }
    }
}

void tud_suspend_cb(bool remote_wakeup_en) {}

void tud_resume_cb(void) {}

uint16_t tud_hid_get_report_cb(uint8_t instance, uint8_t report_id, hid_report_type_t report_type, uint8_t *buffer, uint16_t reqlen) {}
void tud_hid_set_report_cb(uint8_t instance, uint8_t report_id, hid_report_type_t report_type, uint8_t const *buffer, uint16_t bufsize) {}

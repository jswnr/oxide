/*
 * © 2026 Jakub Świniarski
 *
 * SPDX-License-Identifier: MIT
 */

#include <hardware/gpio.h>
#include <pico/time.h>

#include "kbd.h"
#include "layout.h"

static const uint8_t col_to_gpio[N_COLS] = { 1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12, 15, 18 };
static const uint8_t row_to_gpio[N_ROWS] = { 16, 17, 13, 7, 0 };

static uint64_t row_settle_us = 5;

static bool send_empty = true;

void kbd_init(void) {
    for (size_t i = 0; i < N_COLS; i++) {
        gpio_init(col_to_gpio[i]);
        gpio_set_dir(col_to_gpio[i], GPIO_IN);
        gpio_pull_up(col_to_gpio[i]);
    }
    
    for (size_t i = 0; i < N_ROWS; i++) {
        gpio_init(row_to_gpio[i]);
        gpio_set_dir(row_to_gpio[i], GPIO_OUT);
        gpio_put(row_to_gpio[i], 1);
    }
}

bool kbd_scan(uint8_t *keycodes) {
    for (size_t i = 0; i < N_KEYCODES; i++)
        keycodes[i] = 0;

    const uint8_t (*cur_layout)[N_ROWS][N_COLS] = &layout;

    gpio_put(row_to_gpio[fn_row], 0);
    sleep_us(row_settle_us);

    if (gpio_get(col_to_gpio[fn_col]) == 0)
        cur_layout = &layout_fn;

    gpio_put(row_to_gpio[fn_row], 1);

    uint8_t index = 0;
    bool key_pressed = false;
    for (size_t i = 0; i < N_ROWS; i++) {
        if (index >= N_KEYCODES)
            break;

        gpio_put(row_to_gpio[i], 0);
        sleep_us(row_settle_us);

        for (size_t j = 0; j < N_COLS; j++) {
            if (gpio_get(col_to_gpio[j]) != 0)
                continue;

            keycodes[index] = (*cur_layout)[i][j];
            key_pressed = true;
            index++;
            if (index >= N_KEYCODES) {
                gpio_put(row_to_gpio[i], 1);
                break;
            }
        } 

        gpio_put(row_to_gpio[i], 1);
    }

    bool send = key_pressed || send_empty;
    send_empty = key_pressed;

    return send;
}

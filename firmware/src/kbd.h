/*
 * © 2026 Jakub Świniarski
 *
 * SPDX-License-Identifier: MIT
 */

#ifndef KBD_H
#define KBD_H

#include <stdbool.h>
#include <stdint.h>

#define N_KEYCODES 6

void kbd_init(void);
bool kbd_scan(uint8_t *keycodes);

#endif // KBD_H

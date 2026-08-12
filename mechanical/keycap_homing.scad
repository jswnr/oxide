/*
 * © 2026 Jakub Świniarski
 *
 * SPDX-License-Identifier: CERN-OHL-P-2.0
 */

include <keycap.scad>

bar_r = 0.3;
bar_l = 4;
bar_y = 2;

translate([0, -((cap_lt / 2) - bar_y), cap_h - curve_h])
    translate([0, 0, bar_r])
        rotate([0, 90, 0])
            cylinder(r = bar_r, h = bar_l, center = true);

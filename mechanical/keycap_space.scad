/*
 * © 2026 Jakub Świniarski
 *
 * SPDX-License-Identifier: CERN-OHL-P-2.0
 */

include <keycap_common.scad>

union() {
    difference() {
        intersection() {
            minkowski() {
                frustum(cavity_lb, cavity_lt, cap_h);
                hemisphere(cap_t);
            }
            translate([0, 0, cap_h - curve_r])
                sphere(r = curve_r);
        }
        translate([0, 0, -eps])
            frustum(cavity_lb, cavity_lt, rod_h);
    }
    interior();
}

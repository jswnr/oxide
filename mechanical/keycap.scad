/*
 * © 2026 Jakub Świniarski
 *
 * SPDX-License-Identifier: CERN-OHL-P-2.0
 */

include <keycap_common.scad>

union() {
    difference() {
        difference() {
            minkowski() {
                frustum(cavity_lb, cavity_lt, cap_h);
                hemisphere(cap_t);
            }
            translate([0, 0, curve_r + cap_h - curve_h])
                sphere(r = curve_r);
        }
        translate([0, 0, -0.01])
            frustum(cavity_lb, cavity_lt, rod_h);
    }
    interior();
}

/*
 * © 2026 Jakub Świniarski
 *
 * SPDX-License-Identifier: CERN-OHL-P-2.0
 */

$fn = 100;

stem_th = 1.1;
stem_tv = 1.3;
stem_l = 4;
stem_h = 3.6;
margin = 0.05;

cap_lb = 18;
cap_lt = 11.5;
cap_t = 1.2;

cavity_lb = cap_lb - (2 * cap_t);
cavity_lt = cap_lt - (2 * cap_t);

rib_h = 2;

rod_hole_h = stem_h + 0.5;
rod_h = rod_hole_h + rib_h;
rod_r = (stem_l / 2) + margin + 0.5;

rib_t = 0.8;
rib_lb = cavity_lt + ((rib_h / rod_h) * (cavity_lb - cavity_lt));

curve_h = 1;
curve_r = (curve_h + ((cap_lt)^2 / (curve_h * 2))) / 2;

cap_h = rod_h + curve_h + 1;

module frustum(lb, lt, h) {
    linear_extrude(height = h, scale = lt / lb) {
        square([lb, lb], center = true);
    }
}

module rib() {
    translate([0, (rib_t / 2), 0.05 + rod_h - rib_h])
        rotate([90, 0, 0])
            linear_extrude(height = rib_t)
                polygon(points = [
                    [-(rib_lb / 2), 0],
                    [(rib_lb / 2), 0],
                    [(cavity_lt / 2), rib_h],
                    [-(cavity_lt / 2), rib_h]
                ]);
}

module rod_hole(stem_t) {
    translate([0, 0, (rod_hole_h / 2) - 0.01])
        cube([stem_l + (2 * margin),
              stem_t + (2 * margin),
              rod_hole_h],
              center = true
        );
}

module interior() {
    difference() {
        union() {
            translate([0, 0, (rod_h / 2)])
                cylinder(r = rod_r, h = rod_h, center = true);
            
            rib();
            difference() {
                rotate([0, 0, 90])
                    rib();
                translate([-(cavity_lb / 2), 0, 0])
                    cube([cavity_lb, cavity_lb, cavity_lb]);
            }
        }

        rod_hole(stem_tv);
        rotate([0, 0, 90])
            rod_hole(stem_th);
    }
}

module hemisphere(r) {
    difference() {
        sphere(r = cap_t);
        translate([0, 0, -cap_t])
            cube([2 * cap_t, 2 * cap_t, 2 * cap_t], center = true);
    }
}

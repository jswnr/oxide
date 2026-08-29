/*
 * © 2026 Jakub Świniarski
 *
 * SPDX-License-Identifier: CERN-OHL-P-2.0
 */

$fn = 100;
eps = 0.01;

stem_th = 1.1;
stem_tv = 1.3;
stem_l = 4;
stem_h = 3.6;
stem_m = 0.05;

cap_lb = 18;
cap_lt = 11.5;
cap_t = 1.2;

rib_h = 2;
rib_t = 0.8;

rod_hole_m = 0.5;
rod_t = 0.5;

curve_h = 1;
extra_h = 1;

cavity_lb = cap_lb - (2 * cap_t);
cavity_lt = cap_lt - (2 * cap_t);

rod_hole_h = stem_h + rod_hole_m;
rod_h = rod_hole_h + rib_h;
rod_r = (stem_l / 2) + stem_m + rod_t;

rib_lb = cavity_lt + ((rib_h / rod_h) * (cavity_lb - cavity_lt));

curve_r = (curve_h + ((cap_lt)^2 / (curve_h * 2))) / 2;

cap_h = rod_h + curve_h + extra_h;

module frustum(lb, lt, h) {
    linear_extrude(height = h, scale = lt / lb) {
        square([lb, lb], center = true);
    }
}

module rib() {
    translate([0, (rib_t / 2), eps + rod_h - rib_h])
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
    translate([0, 0, (rod_hole_h / 2) - eps])
        cube([stem_l + (2 * stem_m),
              stem_t + (2 * stem_m),
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

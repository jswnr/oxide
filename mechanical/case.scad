/*
 * © 2026 Jakub Świniarski
 *
 * SPDX-License-Identifier: CERN-OHL-P-2.0
 */

$fn = 100;
eps = 0.01;

pcb_l = 224.7;
pcb_w = 91.7;
pcb_t = 1.2;
pcb_m = 0.5;

extra_h = 6;
case_t = 2.5;

insulator_h = 2.54;
pico_h = 3.9;
pico_m = 2;
pico_bootsel_r = 1.5;
pico_tht_h = pico_h + insulator_h;

insert_d = 3.5;
boss_hole_undersize_d = 0.2;
boss_t = 2;

rod_r = 1.5;

gusset_l = 2;
gusset_t = 0.8;

usb_lt = 5.2;
usb_lb = 8;
usb_h = 3;
usb_wall_h = 1.7;
usb_m = 0.2;
usb_overhang = 1.3;
usb_recess_m = 3;

boss_hole_r = (insert_d - boss_hole_undersize_d) / 2;
boss_r = boss_hole_r + boss_t;
boss_h = pico_tht_h + pico_m;

rod_h = boss_h;

usb_slope_l = (usb_lb - usb_lt) / 2;

usb_poly = [
    [-usb_m, -usb_m],
    [usb_lb + usb_m, -usb_m],
    [usb_lb + usb_m, usb_wall_h + usb_m],
    [usb_lb - usb_slope_l + usb_m, usb_h + usb_m],
    [usb_slope_l - usb_m, usb_h + usb_m],
    [-usb_m, usb_wall_h + usb_m]
];

usb_recess_w = case_t - (usb_overhang - pcb_m);
usb_recess_r = (usb_h + (2 * usb_recess_m)) / 2;

// For (x, y) positions, the point (0, 0) is the bottom-left corner of the PCB.

pico_bootsel_x = 49.3;
pico_bootsel_y = 79.7;

usb_x = 42;
usb_z = case_t + boss_h - pico_tht_h;

boss_pos = [
    [17.35, 17.35],
    [74.35, 17.35],
    [150.35, 17.35],
    [207.35, 17.35],

    [17.35, 74.35],
    [74.35, 74.35],
    [150.35, 74.35],
    [207.35, 74.35]
];

rod_pos = [
    [45.85, 40],
    [112.35, 54],
    [112.35, 17.35],
    [178.85, 40]
];

module box() {
    minkowski() {
        cube([
            pcb_l + (2 * pcb_m),
            pcb_w + (2 * pcb_m),
            case_t + rod_h + pcb_t + extra_h - 1
        ]);
        cylinder(r = case_t, h = 1);
    }
}

module cavity() {
    translate([0, 0, case_t])
        cube([
            pcb_l + (2 * pcb_m),
            pcb_w + (2 * pcb_m),
            rod_h + pcb_t + extra_h + eps
        ]);

    translate([usb_x + pcb_m, pcb_w + (2 * pcb_m) - eps, usb_z])
        translate([0, case_t + (2 * eps), 0])
            rotate([90, 0, 0])
                linear_extrude(height = case_t + (2 * eps))
                    polygon(points = usb_poly);

    translate([usb_x + pcb_m, pcb_w + (2 * pcb_m) + case_t - usb_recess_w + eps, usb_z - usb_recess_m])
        union() {
            cube([usb_lb, usb_recess_w, usb_h + (2 * usb_recess_m)]);
            translate([0, usb_recess_w, usb_recess_r])
                rotate([90, 0, 0])
                    cylinder(r = usb_recess_r, usb_recess_w);
            translate([usb_lb, usb_recess_w, usb_recess_r])
                rotate([90, 0, 0])
                    cylinder(r = usb_recess_r, usb_recess_w);
        }


    translate([pico_bootsel_x + pcb_m, pico_bootsel_y + pcb_m, -eps])
        cylinder(r = pico_bootsel_r, h = (2 * eps) + case_t);
}

module gusset(rod_r, n) {
    rotate([0, 0, 45 + (n * 90)])
        union() {
            translate([(gusset_t / 2), rod_r, 0])
                rotate([0, -90, 0])
                    linear_extrude(height = gusset_t)
                        polygon(points = [
                            [0, 0],
                            [rod_h, 0],
                            [0, gusset_l]
                        ]);
            translate([-(gusset_t / 2), 0, 0])
                cube([gusset_t, rod_r, rod_h]);
        }
}

module boss(x, y) {
    translate([x, y, case_t])
        difference() {
            cylinder(r = boss_r, h = boss_h);
            translate([0, 0, eps])
                cylinder(r = boss_hole_r, h = boss_h);
        }
}

module rod(x, y) {
    translate([x, y, case_t])
        union() {
            cylinder(r = rod_r, h = rod_h);
            for (n = [0:3]) {
                gusset(rod_r, n);
            }
        }
}

translate([-(pcb_l / 2), -(pcb_w / 2), 0])
    union() {
        difference() {
            box();
            cavity();
        }
        for (r = boss_pos) {
            boss(r[0] + pcb_m, r[1] + pcb_m);
        }
        for (r = rod_pos) {
            rod(r[0] + pcb_m, r[1] + pcb_m);
        }
    }

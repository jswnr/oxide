/*
 * © 2026 Jakub Świniarski
 *
 * SPDX-License-Identifier: CERN-OHL-P-2.0
 */

$fn = 100;

pcb_l = 224.7;
pcb_w = 91.7;
pcb_t = 1.2;

extra_h = 6;
case_t = 2.5;
margin = 0.5;

insert_d = 3.5;
thread_l = 6;

boss_hole_r = (insert_d - 0.2) / 2;
boss_r = boss_hole_r + 2;
boss_h = thread_l + 2;

rod_r = 1.5;
rod_h = boss_h;

gusset_l = 2;
gusset_t = 0.8;

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
            pcb_l + (2 * margin),
            pcb_w + (2 * margin),
            case_t + rod_h + pcb_t + extra_h - 1
        ]);
        cylinder(r = case_t, h = 1);
    }
}

module cavity() {
    translate([0, 0, case_t])
        cube([
            pcb_l + (2 * margin),
            pcb_w + (2 * margin),
            rod_h + extra_h + 10
        ]);
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
            translate([0, 0, 0.01])
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
            boss(r[0] + margin, r[1] + margin);
        }
        for (r = rod_pos) {
            rod(r[0] + margin, r[1] + margin);
        }
    }

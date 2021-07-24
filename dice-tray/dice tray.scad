PHI = (1 + sqrt(5)) / 2;
PHI_2 = PHI ^ 2;

// Fast preview, pretty render
/* $fa = $preview ? 12 : 0.1; */
/* $fs = $preview ? 2 : 0.1; */
$fn = $preview ? 0 : 100;

// For helping preview flush differences
view_fix = $preview ? 0.005 : 0;

/* [Adjustments] */
magnet_edge_distance = 2.5;

corner_r = 15;

border_width = 20;
border_height = 5;
well_gap = 10;

bottom_thickness = 5;

dice_gap = 5;

/* [Magnet measurements] */
// Magnet height
magnet_h            = 3.175;
magnet_od           = 4.7625;
magnet_h_tolerance  = 0.005;
magnet_od_tolerance = 0.005;

/* [Dice measurements] */
d20_edge = 12.8;
d12_height = 19.16;
d6_edge = 13.93;
d4_edge = 18.76;

/* [Number of dice] */
// Number of dice wells (rows)
wells = 1; //[1:5]
// Number of D20
d20_n = 1; //[0:10]
// Number of D12
d12_n = 1; //[0:10]
// Number of D6
d6_n = 1; //[0:10]
// number of D4
d4_n = 1; //[0:10]

total_dice = d20_n + d12_n + d6_n + d4_n;

/* Radius help
 *
 * ru = circumscribed (touches vertices)
 * rm = midradius (touches middle of edges)
 * ri = inscribed (tangent to faces)
 */
d20_ru = d20_edge * sin(72);
d20_rm = d20_edge * cos(36);

// Dodecahedron module uses height as scale
// Distance from the center to a face is height / 2
// We can use that to find the rest of the numbers we need
d12_ri = d12_height / 2;
d12_edge = d12_height * sqrt(3 - PHI) / PHI_2;
d12_ru = d12_edge * sqrt(3) * PHI / 2;
d12_rm = d12_edge * PHI_2 / 2;

// largest die that we need to make space for
d_max = max(d20_n > 0 ? d20_ru : 0, d12_n > 0 ? d12_ru : 0, d6_n > 0 ? d6_edge / 2 : 0);

// The case will only be as big as it needs to be to hold all the dice
case_width =
  border_width * 2 +
  d20_rm * 2 * d20_n +
  d12_rm * 2 * d12_n +
  d6_edge * d6_n +
  d4_edge * d4_n +
  dice_gap * (total_dice + 1);

case_depth = border_width * 2 + wells * (d_max * 2 + dice_gap * 2) + (wells - 1) * well_gap;
case_bot_h = d20_ru * 2 + bottom_thickness;

well_height = d_max;

mag_h = magnet_h + magnet_h_tolerance;
mag_od = magnet_od + magnet_od_tolerance;

mag_r = mag_od / 2;

recess_w = case_width - border_width * 2;
recess_d = (case_depth - border_width * 2 - (wells - 1) * well_gap) / wells;

// result of finding the triangle in the corner of a circle in a square
corner_magic = (2 - sqrt(2)) / 2;
corner_off = corner_magic * corner_r;
mag_off = magnet_edge_distance + corner_magic * corner_r + mag_r;

difference() {
    color("Navy") hull() {
        translate([corner_r, corner_r, case_bot_h - 1]) cylinder(h = 1, r = corner_r);
        translate([corner_r, corner_r, corner_r / 2]) scale([1, 1, 0.5]) sphere(r = corner_r);

        translate([case_width - corner_r, corner_r, case_bot_h - 1]) cylinder(h = 1, r = corner_r);
        translate([case_width - corner_r, corner_r, corner_r / 2]) scale([1, 1, 0.5]) sphere(r = corner_r);

        translate([corner_r, case_depth - corner_r, case_bot_h - 1]) cylinder(h = 1, r = corner_r);
        translate([corner_r, case_depth - corner_r, corner_r / 2]) scale([1, 1, 0.5]) sphere(r = corner_r);

        translate([case_width - corner_r, case_depth - corner_r, case_bot_h - 1]) cylinder(h = 1, r = corner_r);
        translate([case_width - corner_r, case_depth - corner_r, corner_r / 2]) scale([1, 1, 0.5]) sphere(r = corner_r);
    }

    // magnet holes
    points = [
      [mag_off, mag_off],
      [mag_off, case_depth - mag_off],
      [case_width - mag_off, mag_off],
      [case_width - mag_off, case_depth - mag_off]
    ];
    
    color("Turquoise") for (p = points)
        translate([p.x, p.y, case_bot_h - border_height - mag_h + 0.01 + view_fix])
            cylinder(h = mag_h + view_fix, r = mag_r);
    
    // recessed plane
    color("RoyalBlue") translate([-view_fix, -view_fix, case_bot_h - border_height + view_fix]) difference() {
        cube([case_width + view_fix * 2, case_depth + view_fix * 2, border_height]);

        difference() {
            translate([mag_off, mag_off]) cube([case_width - mag_off * 2, case_depth - mag_off * 2, border_height + view_fix]);
            
            for (p = points) translate(p) cylinder(h = border_height, r = 10);
        }
    }

    for (i = [1:wells]) {
        color("SkyBlue") translate([border_width + corner_r, border_width + corner_r + (recess_d + well_gap) * (i - 1), case_bot_h - well_height + view_fix]) {
            points = [
              [0, 0],
              [0, recess_d - corner_r * 2],
              [recess_w - corner_r * 2, recess_d - corner_r * 2],
              [recess_w - corner_r * 2, 0]
            ];
            
            hull() {
                for (p = points) {
                    translate(p) cylinder(r1 = corner_r, r2 = corner_r, h = well_height);
                }
            }
        }

        translate([0, border_width + recess_d / 2 * (2 * i - 1) + well_gap * (i - 1), 0]) {
            color("Red") if (d20_n > 0) for (i = [1:d20_n])
                translate([border_width + (2 * i - 1) * d20_rm + i * dice_gap, 0, case_bot_h - d20_ru])
                    rotate([0, 31.7, 18]) icosahedron(d20_edge);

            d20_off = border_width + 2 * d20_n * d20_rm + (d20_n + 1) * dice_gap;

            color("Orange") if (d12_n > 0) for (i = [1:d12_n])
                translate([d20_off + (2 * i - 1) * d12_rm + (i - 1) * dice_gap, 0, case_bot_h - well_height])
                    rotate([0, 0, 180]) dodecahedron(d12_height);

            d12_off = d20_off + 2 * d12_n * d12_rm + d12_n * dice_gap;

            color("Yellow") if (d6_n > 0) for (i = [1:d6_n])
                translate([d12_off + (2 * i - 1) * d6_edge / 2 + (i - 1) * dice_gap, 0, case_bot_h - well_height])
                    cube(d6_edge, center = true);
            
            d6_off = d12_off + 2 * d6_n * d6_edge / 2 + (d6_n - 1) * dice_gap;

            color("Green") if (d4_n > 0) for (i = [1:d4_n])
                 translate([d6_off + (2 * i - 1) * d4_edge / 2 + i * dice_gap, 0, case_bot_h - well_height])
                     rotate([-40, 0, 0]) tetrahedron(d4_edge);
         }
    }
}

module icosahedron(edge_length) {
   st = 0.0001; // microscopic sheet thickness
   hull() {
       cube([edge_length * PHI, edge_length, st], true);
       rotate([90, 90, 0]) cube([edge_length * PHI, edge_length, st], true);
       rotate([90, 0, 90]) cube([edge_length * PHI, edge_length, st], true);
   }
}

module dodecahedron(height) {
    dihedral = 116.565;
    intersection() {
        cube([2 * height, 2 * height, height], center = true);
        intersection_for(i = [1:5]) {
            rotate([dihedral, 0, 360 / 5 * i])  cube([2 * height, 2 * height, height], center = true); 
        }
    }
}

module tetrahedron(edge_length = 0) {
    height = sqrt(3) / 2 * edge_length;

    translate([-edge_length / 2, -edge_length * sqrt(3) / 6, -edge_length / sqrt(24)]) polyhedron(
        points = [
            [0, 0, 0],
            [edge_length, 0, 0],
            [edge_length / 2, height, 0],
            [edge_length / 2, height / 3, height]
        ],
        faces = [[0, 1, 2], [0, 2, 3], [1, 3, 2], [0, 3, 1]]
    );
}

module octahedron(size) {
    dihedral = acos(-1/3);
    intersection() {
        cube([2 * size, 2 * size, size], center = true);
        intersection_for(i = [1:3])  { 
            rotate([dihedral, 0, 120 * i])  cube([2 * size, 2 * size, size], center = true);
        }
    }
}

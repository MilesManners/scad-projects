$fa = $preview ? 12 : 0.1;
$fs = $preview ? 2 : 0.1;

magnet_h            = 3.175;
magnet_od           = 4.7625;
magnet_h_tolerance  = 0.005;
magnet_od_tolerance = 0.005;

magnet_edge_distance = 5;

case_width  = 500;
case_depth  = 200;
case_height = 50;

corner_r = 25;

border_width = 15;

recess_height = 5;

mag_h = magnet_h + magnet_h_tolerance;
mag_od = magnet_od + magnet_od_tolerance;

mag_r = mag_od / 2;

case_bot_h = case_height / 2;

recess_w = case_width - border_width * 2;
recess_d = case_depth - border_width * 2;

// result of finding the triangle in the corner of a circle in a square
corner_magic = (2 - sqrt(2)) / 2;
mag_off = magnet_edge_distance + corner_magic * corner_r + mag_r;

difference() {
    translate([corner_r, corner_r, 0]) {
        minkowski() {
            cube([case_width - corner_r * 2, case_depth - corner_r * 2, case_bot_h - 1]);
            cylinder(h = 1, r = corner_r);
        }
    }

    // magnet holes
    points = [
      [mag_off, mag_off],
      [mag_off, case_depth - mag_off],
      [case_width - mag_off, mag_off],
      [case_width - mag_off, case_depth - mag_off]
    ];
    
    for (p = points)
        translate([p.x, p.y, case_bot_h - mag_h + 0.001])
            cylinder(h = mag_h, r = mag_r);
    
    // recessed plane
    translate([border_width + corner_r, border_width + corner_r, case_bot_h - recess_height + 0.001]){
        points = [
          [0, 0, 0],
          [0, recess_d - corner_r * 2, 0],
          [recess_w - corner_r * 2, recess_d - corner_r * 2, 0],
          [recess_w - corner_r * 2, 0, 0]
        ];
        
        hull() {
            for (p = points) {
                translate(p) cylinder(r1 = corner_r, r2 = corner_r, h = recess_height);
            }
        }
    }
 
    // 
}
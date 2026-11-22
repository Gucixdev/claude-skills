// A lidded box 60 x 40 x 25 mm with 2 mm walls: the parameters are the contract, the numbers are checked by scad-measure.
w = 60; d = 40; h = 25; wall = 2;
difference() {
	cube([w, d, h]);
	translate([wall, wall, wall]) cube([w - 2*wall, d - 2*wall, h]);
}

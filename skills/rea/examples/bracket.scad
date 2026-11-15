// A part reverse-engineered for CAD: every number is a measurement, named at the top, so a re-measure is one edit.
// Render: openscad -o bracket.stl [-D 'w=42'] bracket.scad   (checked with OpenSCAD on 2026-11-14)
w = 40; d = 25; t = 3;      // plate, mm, measured with calipers
hole_d = 5.2; hole_dx = 30; // 5 mm screw + 0.2 clearance, centres 30 apart
fit = 0.15;                 // printer tolerance, from a test print (hardware.md, fit)
difference() {
	cube([w, d, t]);
	for (x = [(w - hole_dx) / 2, (w + hole_dx) / 2])
		translate([x, d / 2, -1]) cylinder(d = hole_d + fit, h = t + 2, $fn = 48);
}

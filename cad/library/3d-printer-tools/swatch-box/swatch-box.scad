/* [Assembly display] */
// Note 1.
view = "default"; // [default, together, exploded]

$fn=32;

// Note 2.

include <../../../logos/marks.scad>

/* [Global Settings] */

// Note 3.
part = "both";               // [top, bot, both]
// Note 4.
Pegboard_holder = "no";               // [yes,no]
// Note 5.
swatches = 50;              // [10:100]
// Note 6.
logo_w = 50;
// Note 7.
logo_depth = 0.8;

// Note 8.

logo_taper = 84;  // Note 9.

logo_steps = 5;

// Note 10.
side_by_side_boxes=2;

/* [Case Dimensions] */

// Note 11.
case_w = 2;                 // [2:5]
// Note 12.
case_h = 2;                 // [2:5]
// Note 13.
case_o = 4;                 // [2:5]
// Note 14.
case_t = 30;                // [10:40]
teeth_d=1.5;
teeth_d_wiggle=.3;

/* [Slot Dimensions] */

// Note 15.
slot_l = 3;					// [0:10]
// Note 16.
slot_w = .8;					// [1:3]
// Note 17.
slot_h = 20;				// [10:30]

// [Swatch Dimensions]
// Note 18.
swatch_x = 80;
// Note 19.
swatch_y = 2.5;
// Note 20.
swatch_z = 30;

/* Note 21. */

/* [Hidden] */

eps = 0.01;                 // Note 22.
wiggle_x=.4;
slot_x = swatch_x*side_by_side_boxes + wiggle_x + (side_by_side_boxes-1)*(case_w+wiggle_x);   	// Note 23.
slot_y = swatch_y + 0.2;   	// Note 24.
slot_z = swatch_z + 4;          // Note 25.

inner_x = slot_x;
inner_y = (swatches * (slot_y + slot_w)) + slot_w;

case_w2 = case_w / 2;
case_x = inner_x + (case_w * 2);
case_y = inner_y + (case_w * 2);
case_z = swatch_z + (case_h * 2);

echo (case_x,case_y,case_z);

// Note 26.
wiggle=.4;
dist_horiz=45;
dist_vert=50;
d_pin=5;
d_hole=11;
th_pegboard=1.5;
th_holder=3;
cutoff=.1; // Note 27.

divider_x=case_w+swatch_x + wiggle_x;

module pin()
{
    cutoffcube=2*d_hole;

    difference()
    {
        translate([0,0,d_pin*(.5-cutoff)])
            rotate([90,0,0])
            {
                cylinder(d=d_pin,h=th_pegboard+th_holder);
                translate([0,0,th_pegboard])
                    cylinder(d=d_hole,h=th_holder);
            }

        translate([-cutoffcube/2,-cutoffcube/2,-cutoffcube])
            cube([cutoffcube,cutoffcube,cutoffcube]);
    }
}

// Note 28.

module print_part()
{
    if (slot_h > (swatch_z - case_o))
    {
        echo("Slot height would exceed the height of the case");
    }

	if (part == "top")
    {
        CaseTop();
	}
    else if (part == "bot")
    {
		CaseBot();
	}
    else
    {
		CaseTop();
		CaseBot();
    }
}

module CaseTop()
{
    shiftx=(part == "both" && side_by_side_boxes>1 ? inner_x+2*case_w : -5);
    shifty=(part == "both" && side_by_side_boxes>1 ? inner_y+2*case_w+5 : 0);
    translate([shiftx, shifty, slot_z - slot_h + case_h])
    rotate([0,180,0])
    {
        translate([0, case_y])
        mirror([0, 1, 0])
            TopWallX();
            TopWallX();

        translate([case_x, 0])
        mirror([1, 0, 0])
            TopWallY();
            TopWallY();

        difference()
        {
            color("orange")
            translate([case_w, case_w, slot_z - slot_h])
                cube([inner_x, inner_y, case_h]);

            lid_logo();
        }
    }
}

module CaseBot()
{
    translate([0, case_y])
    mirror([0, 1, 0])
        BotWallX();
        BotWallX();

    translate([case_x, 0])
        mirror([1, 0, 0])
            BotWallY(1);

    BotWallY(1);

    if(side_by_side_boxes>1)
    {
        divider_x=case_w+swatch_x + wiggle_x;
        for(i=[1:1:side_by_side_boxes-1])
            translate([divider_x*i, 0])
            {
                BotWallY(toplid=0);

                translate([case_w, case_w])
                {
                    translate([-slot_l-case_w, 0])
                        Swatches();

                    translate([0, 0])
                        Swatches();
                }
            }
    }

    translate([case_w, case_w])
    {
        // Note 29.
            cube([inner_x, inner_y, case_h]);

        translate([0, 0])
            Swatches();
        translate([inner_x - slot_l, 0])
            Swatches();
    }
}

// Note 30.

module lid_logo() {
    steps = logo_taper >= 90 ? 1 : max(1, logo_steps);
    band  = logo_depth / steps;
    top   = slot_z - slot_h + case_h;   // Note 31.

    for (i = [0 : steps - 1]) {
        // Note 32.

        d_out = band * i;
        d_in  = band * (i + 1);
        erode = logo_taper >= 90 ? 0 : d_out / tan(logo_taper);

        // Note 33.

        translate([case_x / 2, case_y / 2, top - d_in])
            linear_extrude(height = band + eps)
                offset(delta = -erode)
                    feral_logo(logo_w);
    }
}

/* Note 34. */

bigger_lip_to_make_it_fit=.4;

module TopWallX()
{
    color("orange")
    translate([0, 0, case_o+bigger_lip_to_make_it_fit])
    resize([0, 0, slot_z - slot_h - case_o-bigger_lip_to_make_it_fit + case_h])
        WallX();

    color("orange")
    {
        difference()
        {
            resize([0, 0, case_o+bigger_lip_to_make_it_fit])
                WallX();

            translate([case_w, case_w2 - 0.2])
                cube([inner_x, case_w2 + 0.2, case_o+bigger_lip_to_make_it_fit]);

            translate([case_w2 - 0.2, case_w2 - 0.2])
            resize([case_w2 + 0.4, case_w2 + 0.4, case_o+bigger_lip_to_make_it_fit])
                Corner();

            translate([inner_x + case_w + case_w2 + 0.2, case_w2 - 0.2])
            mirror([1, 0, 0])
            resize([case_w2 + 0.4, case_w2 + 0.4, case_o+bigger_lip_to_make_it_fit])
                Corner();
        }
    }

    color("orange")
    translate([(case_x - case_t) / 2, case_w2 - 0.4, case_o / 2])
    rotate([0, 90, 0])
        intersection()
        {
            cylinder(h = case_t, d = teeth_d+teeth_d_wiggle, $fn = 360);
            translate([-teeth_d/2,0,0])
                cube([teeth_d*2,teeth_d*2,case_t]);
        }
}

module TopWallY()
{
    color("orange")
    translate([0, 0, case_o+bigger_lip_to_make_it_fit])
    resize([0, 0, slot_z - slot_h - case_o-bigger_lip_to_make_it_fit + case_h])
        WallY();

    color("orange")
    translate([0, case_w])
        cube([case_w2 - 0.2, inner_y, case_o+bigger_lip_to_make_it_fit]);
}

/* Note 35. */

module BotWallX()
{
    // Note 36.
    resize([0, 0, slot_h + case_h])
        WallX();

    // Note 37.
    translate([case_w2, case_w2, slot_h + case_h])
    {
        resize([case_w2, case_w2, case_o])
            Corner();

        translate([inner_x + case_w, 0])
        mirror([1, 0, 0])
        resize([case_w2, case_w2, case_o])
            Corner();

        translate([case_w2, 0])
        difference()
        {
            cube([inner_x, case_w2, case_o]);
            translate([((inner_x - case_t) / 2) - 0.2, 0, case_o / 2])
            rotate([0, 90, 0])
                cylinder(h = case_t + 0.4, d = teeth_d, $fn = 360);
        }
    }
}

module BotWallY(toplid=0)
{
    color("red")
    resize([0, 0, slot_h + case_h])
        WallY();

    if (toplid==1)
    color("red")
    translate([case_w2, case_w, slot_h + case_h])
        cube([case_w2, inner_y, case_o]);

}

module Swatches()
{
    for (i = [0 : slot_y + slot_w : inner_y])
    {
        color("green")
        translate([0, i, case_h])
            cube([slot_l, slot_w, slot_h]);
    }
}

/* Note 38. */

module WallX()
{
    translate([case_w, 0])
        cube([inner_x, case_w, 1]);

    translate([case_x, 0])
    mirror([1, 0, 0])
        Corner();
        Corner();
}

module WallY()
{
    translate([0, case_w])
        cube([case_w, inner_y, 1]);
}
module Corner()
{
    translate([case_w, case_w])
    difference()
    {
        cylinder(h = 1, r = case_w, $fn = 360);

        translate([-case_w, 0])
            cube([10, case_w, 1]);
        translate([0, -case_w])
            cube([case_w, case_w, 1]);
    }
}

// Note 39.
module feral_default_output_b83d5a7e105b() {
*for(j=[0:1:swatches-1])
for(i=[0:1:side_by_side_boxes-1])
    translate([divider_x*i, j*(slot_y+slot_w), 0])
        translate([case_w,case_w+swatch_y/2,case_h])
            color("white")
                cube([swatch_x,swatch_y,swatch_z]);
if (part != "top" && Pegboard_holder == "yes")
{
    for ( i = [-.5 : 1 : .5] )
    // Note 40.
        translate([i*dist_horiz+case_x/2,0,0])
            pin();

}
print_part();
}

module feral_assembly_view_b83d5a7e105b(explode=false) {
color("SlateGray") CaseBot();
sx=part == "both" && side_by_side_boxes>1 ? inner_x+2*case_w : -5;
sy=part == "both" && side_by_side_boxes>1 ? inner_y+2*case_w+5 : 0;
translate([0,0,slot_h+case_h+(explode ? 40 : 0)]) rotate([0,180,0]) translate([-sx,-sy,-(slot_z-slot_h+case_h)]) CaseTop();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_b83d5a7e105b();
else feral_assembly_view_b83d5a7e105b(view == "exploded");

// Notes

// Note 1. default preserves the original part, coupon and print selectors.

// Note 2. Artwork comes from here, never from a bare import() — a missing import
// prints an ERROR and then exits 0, so the build reports success and hands
// you a lid with no logo on it.

// Note 3. Output Type

// Note 4. Pegboard_holder

// Note 5. Number of swatches to box will hold

// Note 6. Width (mm) of the Feral Creative logo debossed into the lid

// Note 7. How far the logo is cut into the lid (mm). Must stay under case_h.

// Note 8. Wall angle of the cut, from horizontal. 90 is prismatic — no taper.
//
// The proven number on this machine is 70, from the HOBBS wordmark on the chalk
// holder handle. It does not transfer here, and the reason is stroke width. A
// taper narrows the cut as it deepens, eroding the artwork by depth/tan(angle)
// per side, and this logo at logo_w = 50 has strokes only 0.61 mm across at
// their finest. At 70 degrees a 0.80 mm cut erodes 0.29 mm per side and closes
// them; 84 erodes 0.067 and leaves 0.48 mm at the floor, still over one
// extrusion width.
//
// Be honest about what that buys: 0.80 mm at 84 degrees moves the wall 0.084 mm
// in total, less than one 0.42 mm extrusion, so the slicer prints this as a
// straight-walled cut. The bands are here so the angle is a real parameter and
// a wider logo can use a real taper — at logo_w = 100 the strokes double and 70
// degrees becomes affordable.

// Note 9. (deg from horizontal)
// Bands the taper is built from. Each leaves a ledge as deep as the band, so 5
// over 0.80 mm gives 0.16 mm ledges.

// Note 10. Number of boxes side by side

// Note 11. Width (mm) of case walls

// Note 12. Height (mm) of case floor/ceiling

// Note 13. Height (mm) of case overlap

// Note 14. Length (mm) of snap-in teeth

// Note 15. Length (mm) of slot separators

// Note 16. Width (mm) of slot separators

// Note 17. Height (mm) of slot separators

// Note 18. Length (mm) of each swatch

// Note 19. Width (mm) of each swatch

// Note 20. Height (mm) of each swatch

// Note 21. // For Dia frames
// // Length (mm) of slot separators
// slot_l = 0;					// [0:10]
// // Length (mm) of each swatch
// swatch_x = 51;
// // Width (mm) of each swatch
// swatch_y = 1.5;
// // Height (mm) of each swatch
// swatch_z = 51;

// Note 22. overshoot on cuts, so no cut face is coplanar

// Note 23. length of slots

// Note 24. width of slots

// Note 25. height of slots, some extra space to make them fit

// Note 26. Pegboard pin configuration

// Note 27. 10%

// Note 28. cube([dist_horiz,dist_horiz,10]);

// Note 29. color("red")

// Note 30. The logo, debossed into the lid's outer face.
//
// CENTRED IN BOTH DIRECTIONS. The panel runs case_w..case_w+inner_x and
// case_w..case_w+inner_y, so its centre is case_x/2, case_y/2 — which is where
// the text this replaced already sat.
//
// DEBOSSED, never cut through. The feral logo carries its whole wordmark
// floating inside the frame, and a through-cut drops every floating piece on
// the floor. See logos/marks.scad, which says so.
//
// The taper is a stack of prismatic bands rather than a true loft, because
// linear_extrude's scale shrinks the artwork about the origin instead of
// insetting each stroke, which moves the letters rather than narrowing them.
// Same construction as the chalk holder handle, for the same reason.
//
// NOTE ON ORIENTATION. CaseTop turns the whole lid over, so this face is the
// one that lands on the build plate. The rotation is rigid, so the logo reads
// true — but the deboss prints as a first-layer recess, and on a textured plate
// it picks up the plate.

// Note 31. the lid panel's outer face

// Note 32. Depth at this band's outer and inner faces. The erosion is the one at
// the OUTER face, so the topmost band is the artwork at full size and
// the letters read their true width from outside.

// Note 33. Every band overshoots upward by eps: the outermost stands proud of the
// panel so the cut is never coplanar with it, and the rest reach back
// into the band above, which is eroded less and so wider everywhere.
//
// eps is the right size here. The chalk holder needs twice the sagitta
// instead, but only because its mark is wrapped onto a tessellated
// barrel — this face is planar, so there is no facet gap to close.

// Note 34. -------
// Top Box //
// -------

// Note 35. ----------
// Bottom Box //
// ----------

// Note 36. color("red")

// Note 37. color("red")

// Note 38. ---------
// Universal //
// ---------

// Note 39. Assembly display changes placement only; the original output remains the default.

// Note 40. translate([i*dist_horiz,0,j*dist_vert])

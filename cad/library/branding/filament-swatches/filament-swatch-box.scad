/* [Assembly display] */
// Note 1.
view = "default"; // [default, together, exploded]

$fn=32;

/* [Global Settings] */

// Note 2.
part = "both";               // [top, bot, both]
// Note 3.
Pegboard_holder = "no";               // [yes,no]
// Note 4.
swatches = 40;              // [10:100]
// Note 5.
text1 = "FILAMENT";
// Note 6.
text2 = "SWATCHES";
text3 = "";
fontsize=12;
font="Aldo";

// Note 7.
side_by_side_boxes=2;

/* [Case Dimensions] */

// Note 8.
case_w = 2;                 // [2:5]
// Note 9.
case_h = 2;                 // [2:5]
// Note 10.
case_o = 4;                 // [2:5]
// Note 11.
case_t = 30;                // [10:40]
teeth_d=1.5;
teeth_d_wiggle=.3;

/* [Slot Dimensions] */

// Note 12.
slot_l = 3;					// [0:10]
// Note 13.
slot_w = .8;					// [1:3]
// Note 14.
slot_h = 20;				// [10:30]

// [Swatch Dimensions]
// Note 15.
swatch_x = 80;
// Note 16.
swatch_y = 2.5;
// Note 17.
swatch_z = 30;

/* Note 18. */

/* [Hidden] */

wiggle_x=.4;
slot_x = swatch_x*side_by_side_boxes + wiggle_x + (side_by_side_boxes-1)*(case_w+wiggle_x);   	// Note 19.
slot_y = swatch_y + 0.2;   	// Note 20.
slot_z = swatch_z + 4;          // Note 21.

inner_x = slot_x;
inner_y = (swatches * (slot_y + slot_w)) + slot_w;

case_w2 = case_w / 2;
case_x = inner_x + (case_w * 2);
case_y = inner_y + (case_w * 2);
case_z = swatch_z + (case_h * 2);

echo (case_x,case_y,case_z);

// Note 22.
wiggle=.4;
dist_horiz=45;
dist_vert=50;
d_pin=5;
d_hole=11;
th_pegboard=1.5;
th_holder=3;
cutoff=.1; // Note 23.

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

// Note 24.

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

            translate([0, 0, slot_z - slot_h + case_h - 0.5+.01])
            linear_extrude(height = 0.5)
            {
                translate([case_x / 2, (case_y / 2) + fontsize*.8])
                text(
                    text = text1,
                    size = fontsize,
                    font = font,
                    halign = "center",
                    valign = "center"
                );

                translate([case_x / 2, (case_y / 2) - fontsize*.8])
                text(
                    text = text2,
                    size = fontsize,
                    font = font,
                    halign = "center",
                    valign = "center"
                );
                translate([case_x / 2, (case_y / 2) - 3*fontsize*.8])
                text(
                    text = text3,
                    size = fontsize,
                    font = font,
                    halign = "center",
                    valign = "center"
                );
            }
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
        // Note 25.
            cube([inner_x, inner_y, case_h]);

        translate([0, 0])
            Swatches();
        translate([inner_x - slot_l, 0])
            Swatches();
    }
}

/* Note 26. */

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

/* Note 27. */

module BotWallX()
{
    // Note 28.
    resize([0, 0, slot_h + case_h])
        WallX();

    // Note 29.
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

/* Note 30. */

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

// Note 31.
module feral_default_output_06c4714e5c67() {
*for(j=[0:1:swatches-1])
for(i=[0:1:side_by_side_boxes-1])
    translate([divider_x*i, j*(slot_y+slot_w), 0])
        translate([case_w,case_w+swatch_y/2,case_h])
            color("white")
                cube([swatch_x,swatch_y,swatch_z]);
if (part != "top" && Pegboard_holder == "yes")
{
    for ( i = [-.5 : 1 : .5] )
    // Note 32.
        translate([i*dist_horiz+case_x/2,0,0])
            pin();

}
print_part();
}

module feral_assembly_view_06c4714e5c67(explode=false) {
color("SlateGray") CaseBot();
sx=part == "both" && side_by_side_boxes>1 ? inner_x+2*case_w : -5;
sy=part == "both" && side_by_side_boxes>1 ? inner_y+2*case_w+5 : 0;
translate([0,0,slot_h+case_h+(explode ? 40 : 0)]) rotate([0,180,0]) translate([-sx,-sy,-(slot_z-slot_h+case_h)]) CaseTop();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_06c4714e5c67();
else feral_assembly_view_06c4714e5c67(view == "exploded");

// Notes

// Note 1. default preserves the original part, coupon and print selectors.

// Note 2. Output Type

// Note 3. Pegboard_holder

// Note 4. Number of swatches to box will hold

// Note 5. Text to print on top cover (Line 1)

// Note 6. Text to print on top cover (Line 2)

// Note 7. Number of boxes side by side

// Note 8. Width (mm) of case walls

// Note 9. Height (mm) of case floor/ceiling

// Note 10. Height (mm) of case overlap

// Note 11. Length (mm) of snap-in teeth

// Note 12. Length (mm) of slot separators

// Note 13. Width (mm) of slot separators

// Note 14. Height (mm) of slot separators

// Note 15. Length (mm) of each swatch

// Note 16. Width (mm) of each swatch

// Note 17. Height (mm) of each swatch

// Note 18. // For Dia frames
// // Length (mm) of slot separators
// slot_l = 0;					// [0:10]
// // Length (mm) of each swatch
// swatch_x = 51;
// // Width (mm) of each swatch
// swatch_y = 1.5;
// // Height (mm) of each swatch
// swatch_z = 51;
// text1 = "";
// text2 = "";

// Note 19. length of slots

// Note 20. width of slots

// Note 21. height of slots, some extra space to make them fit

// Note 22. Pegboard pin configuration

// Note 23. 10%

// Note 24. cube([dist_horiz,dist_horiz,10]);

// Note 25. color("red")

// Note 26. -------
// Top Box //
// -------

// Note 27. ----------
// Bottom Box //
// ----------

// Note 28. color("red")

// Note 29. color("red")

// Note 30. ---------
// Universal //
// ---------

// Note 31. Assembly display changes placement only; the original output remains the default.

// Note 32. translate([i*dist_horiz,0,j*dist_vert])

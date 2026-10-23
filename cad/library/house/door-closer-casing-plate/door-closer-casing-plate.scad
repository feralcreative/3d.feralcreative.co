// Note 1.

// COUPON-COMPONENTS: fit=coupon
// COUPON-PLATE: coupon

/* [Casing] */
/* [Assembly display] */
// Note 2.
view = "default"; // [default, together, exploded]

casing_w      = 41;    // Note 3.
casing_max_h  = 13.5;  // Note 4.
casing_a      = 3.4;   // Note 5.
casing_b      = 1.5;   // Note 6.

/* [Closer] */
closer_w      = 32.5;  // Note 7.
closer_l      = 126;   // Note 8.
hole_d        = 4;     // Note 9.
hole_len_gap  = 110;   // Note 10.
hole_end      = (closer_l - hole_len_gap - hole_d) / 2; // Note 11.
hole_gap      = 17;    // Note 12.
hole_side     = (closer_w - hole_gap - hole_d) / 2; // Note 13.

/* [Plate] */
plate_w       = casing_w; // Note 14.
casing_x0     = -3;    // Note 15.
closer_x0     = (casing_w - closer_w) / 2; // Note 16.
plate_min_t   = 3;     // Note 17.
plate_hole_d  = 4.4;   // Note 18.

/* [Output] */
show = "part";         // [part, coupon]
coupon_label = "";     // Note 19.
label_size = 4;        // Note 20.
label_depth = 0.6;     // Note 21.
coupon_l = 10;         // Note 22.
flip = true;           // Note 23.

$fn = 48;
eps = 0.01;
profile_steps = 160;   // Note 24.

function face_h(x) = casing_max_h * pow(max(0, 1 - pow(x / casing_w, casing_a)), 1 / casing_b);

// Note 25.
function casing_h(px) = let (x = px - casing_x0)
    x <= 0        ? casing_max_h :
    x <  casing_w ? face_h(x) :
    0;

plate_x0 = 0;
plate_x1 = plate_w;
top_z = max([for (i = [0 : profile_steps]) casing_h(plate_w * i / profile_steps)]) + plate_min_t;

// Note 26.
module plate_section() {
    underside = [for (i = [profile_steps : -1 : 0])
        let (x = plate_w * i / profile_steps) [x, casing_h(x)]];
    polygon(concat([[plate_x0, top_z], [plate_x1, top_z]], underside));
}

module plate(len = closer_l) {
    difference() {
        rotate([90, 0, 0]) translate([0, 0, -len])
            linear_extrude(len, convexity = 4) plate_section();
        for (x = [closer_x0 + hole_side, closer_x0 + closer_w - hole_side],
             y = len < closer_l ? [len / 2] : [hole_end, closer_l - hole_end])
            translate([x, y, -eps]) cylinder(d = plate_hole_d, h = top_z + 2 * eps);
        if (len < closer_l && coupon_label != "")
            translate([plate_w / 2, len / 2, top_z - label_depth])
                linear_extrude(label_depth + eps)
                    text(coupon_label, size = label_size, font = "Liberation Sans:style=Bold",
                         halign = "center", valign = "center");
    }
}

len = show == "coupon" ? coupon_l : closer_l;

// Note 27.

module feral_default_output_5b5cabc73816() {
if (flip) translate([0, 0, top_z]) rotate([0, 180, 0]) translate([-plate_x1, 0, 0]) plate(len);
else plate(len);
}

module feral_assembly_view_5b5cabc73816(explode=false) {
feral_default_output_5b5cabc73816();
}

assert(view == "default" || view == "together" || view == "exploded", "Unknown assembly display");
if(view == "default") feral_default_output_5b5cabc73816();
else feral_assembly_view_5b5cabc73816(view == "exploded");

// Notes

// Note 1. door-closer-casing-plate.scad
//
// A saddle that sits on a sloped, bullnosed door casing and gives a
// spring-loaded door closer a flat face to screw to. The closer's base is
// 32.5 x 126 with a 4 mm hole in each corner (Ziad, 2026-09-25). The
// holes' inside edges are 17 apart across the width and 110 along it,
// miked, which replaces the 3.5 from the sides and 4 from the ends first
// given. Its screws go
// through the closer, through this plate, and into the casing, so the
// plate carries matching holes and
// nothing else — screws need to be longer by the plate's thickness.
//
// THE CASING (Ziad, 2026-09-25): 41 wide, 13.5 proud of the wall at its
// thickest, the outside edge. It slopes gradually in for about 75 % of the
// width and then rounds down to nothing at the door-side edge.
//
// casing_a and casing_b were fitted to a photo of coupon 9 on the casing
// (2026-09-25), its air gap scaled against the coupon's own width — up to
// 2.8 mm near the round, none past 21 mm from the door-side edge — and
// coupon 10, cut from that fit, sat perfectly (Ziad, 2026-09-25).
// ⚠️ ASSUMED: the hole offsets are to hole centres, not hole edges.
// THE PLATE SPANS THE WHOLE CASING, so the underside wraps the bullnose as
// well as the slope (Ziad, 2026-09-25: the first draft stopped at the
// closer's 32.5 and caught only the start of the round). Where the casing
// rounds down to nothing the plate comes down to the wall.
// ⚠️ ASSUMED: the closer is centred across the casing (closer_x0) and its
// face stands parallel to the wall.
//
// Axes, installed: X across the casing, 0 at the outside edge and rising
// toward the door; Y along the casing; Z out of the wall. The underside is
// the casing's profile; the top is flat, plate_min_t above the casing's
// highest point under the plate. flip turns it top-down for printing, so
// the saddle faces up and nothing overhangs.
//
// THE COUPON is a coupon_l slice of the plate, with one pair of holes
// centred along its length: enough to press onto the casing and see whether the underside
// meets the slope and the round, and whether the holes land across it.

// Note 2. default preserves the original part, coupon and print selectors.

// Note 3. mm, full width of the casing face

// Note 4. mm, thickness at the outside edge

// Note 5. exponent across the width: higher keeps the face flatter for longer

// Note 6. exponent through the thickness: above 1 the face ends vertical at the door-side edge

// Note 7. mm, base width (across the casing)

// Note 8. mm, base length (along the casing)

// Note 9. mm, device hole diameter

// Note 10. mm, clear gap between the device holes' inside edges along the length, miked (Ziad, 2026-09-25)

// Note 11. mm, hole centre from each end

// Note 12. mm, clear gap between the device holes' inside edges across the width, miked (Ziad, 2026-09-25)

// Note 13. mm, hole centre from each side

// Note 14. mm, plate width across the casing, from its outside edge

// Note 15. mm, casing's outside edge from the plate's; negative leaves a ledge on the wall past the door-side edge

// Note 16. mm, closer's outside edge from the casing's ⚠️ assumed

// Note 17. mm, thickness at the thinnest point

// Note 18. mm, through-hole: device hole plus clearance

// Note 19. text sunk into the coupon's top face, to tell coupons apart

// Note 20. mm, label text height

// Note 21. mm, label deboss depth

// Note 22. mm, length of the coupon slice along the casing

// Note 23. print orientation: top face on the bed

// Note 24. segments across the plate's underside
// The casing face is one smooth curve, h = max_h * (1 - (x/w)^a)^(1/b):
// flat at the outside edge and steepening all the way to vertical at the
// door-side edge, with no straight run and no handover between a slope and
// a round (Ziad, 2026-09-25: "curved the whole way ever so slightly";
// then "smooth that curve out a bit", after a two-curve blend left a
// visible transition).

// Note 25. Casing thickness at x, 0 beyond the door-side edge.

// Note 26. Cross-section in XZ, extruded along Y.

// Note 27. Assembly display changes placement only; the original output remains the default.
// Single printed piece: both display modes show the same intact part.

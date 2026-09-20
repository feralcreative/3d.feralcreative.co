// phone-shower-holder.scad
//
// One piece. Hangs on the front face of a half-inch glass shower panel by a
// hook over the panel's top edge, and holds a phone by the two long edges of
// its bottom half, leaning the top of the phone out toward the viewer.
//
// Second design. The first was a full-length tray rebuilt from a SketchUp-era
// mesh: it stood the phone flat against the glass in a pocket with nothing in
// front to keep it there, and Ziad scrapped it on 2026-09-20 for this. Nothing
// here is measured off that mesh. Every number is authored, and the hook's are
// the ones the first design settled on.
//
// FRAME. Authored hung, the way it is used:
//
//     x  ->  across the panel, centered
//     y  ->  out from the glass toward the viewer. The glass's front face is
//            y = 0 and the glass itself is y < 0, so the hook's leg is the
//            only thing at negative y.
//     z  ->  up, with z = 0 at the top of the cap. Everything hangs below.
//
// The cradle is authored in its own frame, tilted `tilt` degrees about x, and
// placed with in_cradle(): x is shared, y' is out from the backrest (normal to
// the phone), z' runs up the phone's long axis from the ledge. Every cradle
// dimension is in that frame, so "front" means the phone's screen side and
// "top" means toward the phone's top, whatever those come to in hung z.
//
// WATER. The spine lies on the glass, and water behind it does not drain on
// its own - the first design's slots were for that and were not enough. Two
// shallow bores in the back face at the bottom take stick-on silicone feet,
// which stand the bottom of the spine off the glass by whatever the feet are
// proud of the bore. The part carries no feet of its own.
//
// PRINTING. On a side, one rail down; `orient = "print"` writes the STL that
// way, yawed 45 degrees so 216 mm fits the plate's diagonal inside the safe
// envelope. Every face is then vertical except the upper rail's 45 degree lip,
// the top-end chamfers, the ledge over the notch (a 45 degree underside), and
// the roofs of the two bores. No support. Standing it on the hook end, as the
// first design planned, is worse: the face the phone stands on would be an
// overhang 15 degrees off horizontal, and the part is over the 215 mm safe
// height that way.

include <BOSL2/std.scad>

/* [Which output] */
// "fitcheck" adds the glass in the hook and the phone in the cradle. Not for
// printing - it is the view that proves the tilt and the clearances.
show   = "part";  // [part, fitcheck]
// "print" lies the part on its -x side, yawed 45 degrees, so it lands on the
// plate the way it should be sliced. Same geometry.
orient = "hung";  // [hung, print]

/* [Phone] */
// A 16 Pro Max in its case, as Ziad measured it on 2026-09-20, "about".
// CALIPER BOTH BEFORE PRINTING: the rails are cut to these plus the slack
// below, and a case 1 mm wider than "about" will not go in.
phone_w = 83.0;   // width, in its case (mm)
phone_t = 13.0;   // thickness, in its case (mm)
phone_l = 166.0;  // length, in its case; fitcheck only (mm)
// Free clearance on a 0.4 nozzle is 0.30 per the ladder in
// docs/flashforge-ad5m-pro-scad-reference.md; opened because the phone goes in
// and out wet, one-handed.
phone_fit_w = 1.0;  // total slack across the width (mm)
phone_fit_t = 0.6;  // slack between the backrest and the root of the lips (mm)

/* [Hang] */
tilt        = 15;     // deg; the top of the phone leans out toward the viewer
overall_len = 216.0;  // top of the cap to the lowest point of the cradle (mm)

/* [Hook - over the glass] */
glass_t   = 12.0;  // panel thickness, calipered 2026-09-20 (mm)
glass_fit = 0.40;  // total slack across the channel; it goes on and off wet (mm)
// Both faces exposed, so the rungs are 0.84, 1.29, 1.74, 2.19, 2.64, 3.09.
leg_t     = 2.19;  // the leg that drops behind the glass (mm)
cap_t     = 5.0;   // material over the glass's top edge (mm)
wrap      = 15.0;  // how far the leg reaches down the back face (mm)
// 45 deg, eating into the leg; held to 1.0 so the flat left on the leg's end
// stays over the 0.84 floor for a load-bearing feature.
lead_in   = 1.0;   // guide at the channel's mouth (mm)

/* [Spine] */
// The plate down the glass from the hook to the cradle. It is the channel's
// front wall and it carries the cradle's whole moment.
spine_t = 3.09;  // (mm)

/* [Silicone feet] */
// Two recesses in the back face at the bottom corners, for stick-on silicone
// bumpers. Sized to the feet Ziad has, 2026-09-20. Where the bores sit the
// wedge is behind the spine, so a 2 mm bore leaves over 5 mm of solid.
foot_bore_d     = 13.0;  // (mm)
foot_bore_depth = 2.0;   // (mm)
foot_inset      = 3.0;   // bore edge to the part's side face and bottom (mm)

/* [Cradle] */
cradle_len = 82.0;  // how much of the phone's edge is held, up from its bottom (mm)
wall       = 2.19;  // the rail walls, outside the phone's edges (mm)
// The lip is a 45 degree bevel, not a flat tab, so that it prints with the
// part on its side: the upper rail's lip hangs from its wall and 45 is the
// steepest it can hang. Its reach is measured at the front face; at the level
// of the phone's own face the bevel is just leaving the wall.
lip_r      = 5.0;   // reach of each lip, inward from its wall (mm)
ledge_t    = 3.09;  // the shelf the phone's bottom edge stands on (mm)
back_min   = 2.64;  // backrest thickness at the ledge, where the wedge is thinnest (mm)
// Open at the front, so the lanyard drops in from the front rather than being
// fed through. Its width is at the face the phone stands on; the sides flare
// out at 45 degrees through the ledge so the ledge over it prints on its side.
notch_w    = 40.0;  // lanyard gap in the ledge, centered (mm)
// Chamfer on the rails' inner edges at the top end, where the phone goes in.
// Small, because the walls are only 2.19.
flare      = 1.0;   // (mm)

/* [Quality] */
$fn = 64;  // segments per full circle; the bores are the only round thing

// Small overshoot used on every subtracted solid so its faces are never
// coplanar with the parent's.
eps = 0.01;

// Long enough to pass through anything here.
tall = 300;

// ---------------------------------------------------------------- derived

gch   = glass_t + glass_fit;          // the channel the glass sits in
ch_w  = phone_w + phone_fit_w;        // between the rail walls
W     = ch_w + 2 * wall;              // the part's width
h_ch  = phone_t + phone_fit_t;        // backrest to the root of the lips
front = h_ch + lip_r;                 // backrest to the cradle's front face

s = sin(tilt);
c = cos(tilt);

// Cradle origin: the phone's bottom-back corner. In front of the spine by the
// thinnest the backrest gets, and as far down as puts the lowest point of the
// cradle - the front-bottom corner of the ledge - at overall_len.
y0 = spine_t + back_min;
z0 = -overall_len + front * s + ledge_t * c;

// Cradle frame to hung frame. Same map as in_cradle().
function H(yp, zp) = [y0 + yp * c + zp * s, z0 - yp * s + zp * c];

// Where the cradle's top plane runs back into the spine's front face, and
// where its bottom plane runs back to the glass.
yp_top = (spine_t - y0 - cradle_len * s) / c;
yp_bot = -(y0 - ledge_t * s) / c;
z_bot  = H(yp_bot, -ledge_t).y;  // the lowest point of the glass face

y_min = -(gch + leg_t);
y_max = H(front, cradle_len).x;

module in_cradle() {
    translate([0, y0, z0])
        rotate([-tilt, 0, 0])
            children();
}

// ---------------------------------------------------------------- body

// The whole side silhouette - hook, spine, wedge, and the cradle's box - as
// one polygon in (y, z). Everything that is not full width is cut out of the
// sweep of this or added to it afterward. Top level rather than inside body()
// because oriented() reads it too, to center the print pose on the plate.
silhouette = [
    [y_min,   0],                        // leg outer face, top
    [spine_t, 0],                        // cap front, top
    H(yp_top, cradle_len),               // the wedge's top meets the spine
    H(front,  cradle_len),               // cradle front, top
    H(front, -ledge_t),                  // cradle front, bottom: the lowest point
    H(yp_bot, -ledge_t),                 // the bottom runs back to the glass
    [0,    -cap_t],                      // up the glass face to the cap
    [-gch, -cap_t],                      // across the channel's closed end
    [-gch, -cap_t - wrap + lead_in],     // down the leg's inner face
    [-gch - lead_in, -cap_t - wrap],     // the lead-in
    [y_min, -cap_t - wrap],              // leg outer face, bottom
];

module body() {
    rotate([90, 0, 90])
        linear_extrude(height = W, center = true, convexity = 6)
            polygon(silhouette);
}

// What the phone sits in: open at the front and at the top, floored by the
// ledge, backed by the wedge.
module pocket() {
    in_cradle()
        translate([-ch_w / 2, 0, 0])
            cube([ch_w, tall, tall]);
}

// Through the ledge, backrest to front face, so the lanyard drops in from the
// front. notch_w wide at the top face, a ledge thickness wider each side at
// the underside: the 45 degree flanks are what let the ledge over it print
// with the part on its side, where that underside would otherwise be a flat
// 18.6 mm cantilever.
module notch() {
    in_cradle()
        translate([0, front + eps, 0])
            rotate([90, 0, 0])
                linear_extrude(height = front + 2 * eps)
                    polygon([
                        [-notch_w / 2, eps],
                        [ notch_w / 2, eps],
                        [ notch_w / 2 + ledge_t + eps, -ledge_t - eps],
                        [-notch_w / 2 - ledge_t - eps, -ledge_t - eps],
                    ]);
}

// One 45 degree bevel per rail, root on the wall, running the length of the
// cradle, with its top end cut back at 45 degrees so a phone coming down from
// above is steered in behind it rather than stopped on it.
module lips() {
    for (side = [-1, 1])
        in_cradle()
            difference() {
                linear_extrude(height = cradle_len)
                    polygon([
                        [side * (ch_w / 2 + eps), h_ch],
                        [side * (ch_w / 2 + eps), front],
                        [side * (ch_w / 2 - lip_r), front],
                    ]);

                translate([0, h_ch, cradle_len])
                    rotate([-45, 0, 0])
                        translate([-W, 0, 0])
                            cube([2 * W, tall, tall]);
            }
}

// Chamfer on the walls' inner edges at the top end. Confined to the depth
// behind the lips so it never undercuts a lip's root.
module flare_cut() {
    in_cradle()
        hull() {
            translate([-ch_w / 2, 0, cradle_len - flare])
                cube([ch_w, h_ch, eps]);

            translate([-ch_w / 2 - flare, 0, cradle_len])
                cube([ch_w + 2 * flare, h_ch, tall]);
        }
}

// The two recesses for the silicone feet, in the glass face at the bottom
// corners.
module foot_bores() {
    for (side = [-1, 1])
        translate([side * (W / 2 - foot_inset - foot_bore_d / 2),
                   foot_bore_depth,
                   z_bot + foot_inset + foot_bore_d / 2])
            rotate([90, 0, 0])
                cylinder(d = foot_bore_d, h = foot_bore_depth + eps);
}

module phone_holder() {
    difference() {
        union() {
            difference() {
                body();
                pocket();
                notch();
                foot_bores();
            }

            lips();
        }

        flare_cut();
    }
}

// ---------------------------------------------------------------- output

// Hung, or lying on its -x side yawed 45 degrees. The yaw is what fits 216 mm
// inside the 205 mm safe envelope, and the part is centered after it: the
// silhouette is no rectangle, so the center of the yawed footprint is not the
// center of the hung one.
print_yaw = 45;
// Each silhouette vertex after the lay-down and the yaw: hung z runs along
// print -x, hung y along print y.
print_foot = [for (p = silhouette)
    let (px = -p.y, py = p.x)
        [px * cos(print_yaw) - py * sin(print_yaw),
         px * sin(print_yaw) + py * cos(print_yaw)]];
print_xs = [for (p = print_foot) p.x];
print_ys = [for (p = print_foot) p.y];

module oriented() {
    if (orient == "print")
        translate([-(min(print_xs) + max(print_xs)) / 2,
                   -(min(print_ys) + max(print_ys)) / 2,
                   W / 2])
            rotate([0, 0, print_yaw])
                rotate([0, -90, 0])
                    children();
    else
        children();
}

oriented() {
    phone_holder();

    if (show == "fitcheck") {
        // The panel, centered in the channel, its top edge on the cap.
        color("PaleTurquoise", 0.35)
            translate([-W / 2 - 20, -gch + glass_fit / 2, -cap_t - 230])
                cube([W + 40, glass_t, 230]);

        // The phone, on the ledge, centered in the slack.
        color("DimGray", 0.5)
            in_cradle()
                translate([-phone_w / 2, phone_fit_t / 2, 0])
                    cube([phone_w, phone_t, phone_l]);
    }
}

// Friction-fit light shield for the 55 mm square nightlight.
// Service axes: X right, Y up, Z out into the room; light face is Z=0.
// The outlet opens through the -Y underside; the +Z front has only the sensor hole.
// The external scoop is trimmed at the front plane, leaving its back and sides.
// There is no internal light duct.
// Lower outside corners are square; the mating cavity retains its traced round.
// Front corners follow the user's 55 mm-calibrated physical outline trace.
// The rear-body size remains a product-photo estimate, not a measurement.
// Export with utils/build.sh parts/nightlight-floor-hood.scad --backend=CGAL.
// CGAL preserves clean binary-STL topology at the full-width corner joins.

/* [View] */
show = "part"; // [part, assembly, section, fitcheck, body-sweep, body, rib]
flip = true; // Front face flat on the bed; false gives service axes.

/* [Measured nightlight] */
light_w = 55; // mm, overall width
light_h = 55; // mm, overall height
rim_depth = 12.2; // mm, front face to rear shoulder
sensor_d = 9; // mm, sensor opening diameter
wall_standoff = 24; // mm, measured from the nightlight's front face to the wall

/* [Traced front outline] */
light_corner_r = 13.5; // mm, circular fit to photographed pencil trace; approximate

/* [Photo estimates] */
rear_body_w = 46; // mm, mating model only
rear_body_h = 46; // mm, mating model only
rear_corner_r = 12; // mm, retain the initial rear-body estimate independently

/* [Cover] */
fit = 0.15; // mm per side, reduced after user reported a slightly loose fit
wall = 1.74; // mm, 0.42 + 0.45 + 0.45 + 0.42

/* [Sensor] */
sensor_clearance = 0.30; // mm radial allowance
sensor_wall = 1.74; // mm, opaque tube wall
sensor_gap = 0.30; // mm, tube end clearance from light face
sensor_x = 0; // mm, centred in the photo
sensor_y = 0; // mm, centred in the photo
sensor_facets = 64; // Circumscribed bore, not a high global facet count

/* [Outlet] */
outlet_angle = 45; // degrees, external scoop axis downward from horizontal
outlet_h = 8; // mm, clear thickness perpendicular to the beam axis
outlet_front_margin = 0; // mm, 0 puts the opening's forward edge at the front/bottom corner
scoop_drop = 12; // mm, external scoop extension below the cover
scoop_root_overlap = 4; // mm, reach into rounded lower corners; cavity removes internal material

/* [Friction rib] */
grip_projection = 0.25; // mm inward from the cavity, 0.10 mm interference beyond the 0.15 mm fit
grip_width = 1.20; // mm, axial width of the rounded bump
grip_z = -9.00; // mm, moved 2.50 mm toward the front from -11.50
grip_steps = 12; // Segments along the smoothly rounded lead-in and lead-out
// Verification only: assumed outward normal movement of the rib and sleeve.
grip_open = 0; // mm; keep 0 for the printed part

/* [Resolution] */
$fa = 4;
$fs = 0.4;
eps = 0.01; // mm, overshoot on cuts

/* [Derived] */
cavity_w = light_w + 2*fit;
cavity_h = light_h + 2*fit;
outlet_w = cavity_w; // mm, edge-to-edge clear width between the cover's side walls
// A true offset of the traced outline: clearance grows the flats AND radius.
cavity_corner_r = light_corner_r + fit;
outer_w = cavity_w + 2*wall;
outer_h = cavity_h + 2*wall;
face_depth = wall; // mm, panel back is Z=0, directly against the light face
sleeve_rear_z = grip_z-grip_width/2; // mm, trim flush with the back of the friction ring
opening_z_span = outlet_h / sin(outlet_angle);
outlet_front_z = face_depth - outlet_front_margin;
outlet_back_z = outlet_front_z - opening_z_span;
outlet_outer_y = -outer_h/2;
inlet_top_y = -cavity_h/2 + outlet_h; // mm, full-width inlet reaches into the cavity
// End before the ramp crosses the front trim plane, avoiding a solid mouth lip.
scoop_actual_drop = min(scoop_drop,(opening_z_span-eps)*tan(outlet_angle));
scoop_tip_y = outlet_outer_y - scoop_actual_drop;
print_front_z = face_depth;
sensor_bore_d = sensor_d + 2*sensor_clearance;
sensor_outer_d = sensor_bore_d + 2*sensor_wall;

assert(outlet_angle > 0 && outlet_angle < 80);
assert(outlet_front_margin >= 0, "Opening must not extend ahead of the front/bottom corner");
assert(outlet_back_z-wall-scoop_root_overlap/tan(outlet_angle) > -wall_standoff,
       "Scoop must stay ahead of the wall");
assert(sleeve_rear_z < 0 && sleeve_rear_z >= -wall_standoff);
assert(scoop_drop > 0 && scoop_root_overlap > wall);
assert(grip_projection > fit && grip_projection < wall);
assert(grip_z-grip_width/2 > -rim_depth && grip_z+grip_width/2 < 0,
       "Friction rib must grip the measured front rim");
assert(grip_steps >= 4 && grip_open >= 0);

module rounded_rect(w, h, r) {
    offset(r=r) square([w-2*r, h-2*r], center=true);
}

// Extrude a Y,Z polygon along X. Winding is corrected by OpenSCAD.
module across_x(width, profile) {
    multmatrix([[0,0,1,0],[1,0,0,0],[0,1,0,0],[0,0,0,1]])
        linear_extrude(height=width, center=true, convexity=10)
            polygon(profile);
}

module outlet_cut() {
    // One continuous full-width void, with a single 45-degree back surface.
    // The inner opening meets the scoop without a mask, step, or front lip.
    y0 = scoop_tip_y-eps;
    y1 = inlet_top_y+eps;
    shift0 = (y0-outlet_outer_y)/tan(outlet_angle);
    shift1 = (y1-outlet_outer_y)/tan(outlet_angle);
    across_x(outlet_w, [
        [y0,outlet_back_z-shift0],
        [y0,outlet_front_z-shift0+eps],
        [outlet_outer_y,outlet_front_z],
        // Preserve the front panel above its bottom edge.
        [outlet_outer_y,0],
        [y1,0],
        [y1,outlet_back_z-shift1]
    ]);
}

module exterior_scoop() {
    // Swept rectangle below the light. The main cavity subtraction removes
    // every portion inside the cover. Clip at the face to remove the front
    // scoop wall and trim the side walls, retaining the sloping back ramp.
    y0 = scoop_tip_y;
    scoop_w = outlet_w+2*wall;
    module span(width, x, y1) {
        shift0 = (y0-outlet_outer_y)/tan(outlet_angle);
        shift1 = (y1-outlet_outer_y)/tan(outlet_angle);
        translate([x,0,0]) intersection() {
            across_x(width, [
                [y0,outlet_back_z-wall-shift0],
                [y0,outlet_front_z+wall-shift0],
                [y1,outlet_front_z+wall-shift1],
                [y1,outlet_back_z-wall-shift1]
            ]);
            translate([-width/2-eps,y0-eps,sleeve_rear_z])
                cube([width+2*eps,y1-y0+2*eps,face_depth-sleeve_rear_z]);
        }
    }
    span(scoop_w,0,outlet_outer_y+scoop_root_overlap);
}

module cover_outline() {
    rounded_rect(outer_w,outer_h,cavity_corner_r+wall);
    // Fill only the lower exterior corners; the cavity is subtracted separately.
    translate([-outer_w/2,-outer_h/2])
        square([outer_w,cavity_corner_r+wall+eps]);
}

// Smooth axial crest with rounded lead-in from either direction.
function grip_bump(z) = grip_projection *
    pow(cos(180*(z-grip_z)/grip_width),2);

module grip_cavity_slice(z) {
    inset = grip_bump(z)-grip_open;
    translate([0,0,z])
        linear_extrude(height=eps,center=true,convexity=10)
            rounded_rect(cavity_w-2*inset,cavity_h-2*inset,
                         cavity_corner_r-inset);
}

module grip_rib() {
    z0 = grip_z-grip_width/2;
    z1 = grip_z+grip_width/2;
    difference() {
        // Full shell-width root on the remaining mating walls.
        translate([0,0,z0])
            linear_extrude(height=grip_width,convexity=10)
                rounded_rect(outer_w+2*grip_open,outer_h+2*grip_open,
                             cavity_corner_r+wall+grip_open);
        for (i=[0:grip_steps-1]) {
            za = z0 + (z1-z0)*i/grip_steps;
            zb = z0 + (z1-z0)*(i+1)/grip_steps;
            hull() {
                grip_cavity_slice(za);
                grip_cavity_slice(zb);
            }
        }
        // The smooth channel takes priority over the ring's lower segment.
        outlet_cut();
    }
}

module fixed_body() {
    difference() {
        union() {
            translate([0,0,sleeve_rear_z])
                linear_extrude(height=face_depth-sleeve_rear_z, convexity=10)
                    cover_outline();
            exterior_scoop();

        }
        translate([0,0,sleeve_rear_z-eps])
            linear_extrude(height=face_depth-wall-sleeve_rear_z+eps, convexity=10)
                rounded_rect(cavity_w,cavity_h,cavity_corner_r);
        outlet_cut();
        translate([sensor_x,sensor_y,face_depth-wall-eps])
            cylinder(h=wall+2*eps, d=sensor_bore_d/cos(180/sensor_facets),
                     $fn=sensor_facets);
    }
    // Isolated ambient-light passage from the centre eye to the room.
    translate([sensor_x,sensor_y,sensor_gap])
        difference() {
            cylinder(h=face_depth-sensor_gap, d=sensor_outer_d,$fn=sensor_facets);
            translate([0,0,-eps])
                cylinder(h=face_depth-sensor_gap+2*eps,
                         d=sensor_bore_d/cos(180/sensor_facets),$fn=sensor_facets);
        }
}

module hood() {
    fixed_body();
    grip_rib();
}

module mating_light() {
    translate([0,0,-rim_depth])
        linear_extrude(height=rim_depth,convexity=10)
            rounded_rect(light_w,light_h,light_corner_r);
    translate([0,0,-wall_standoff])
        linear_extrude(height=wall_standoff-rim_depth,convexity=10)
            rounded_rect(rear_body_w,rear_body_h,rear_corner_r);
}

module selected_view() {
    if (show == "assembly") {
        color("dimgray") hood();
        color("ivory") mating_light();
    } else if (show == "section") {
        intersection() {
            hood();
            translate([-100,-100,-100]) cube([100+eps,200,200]);
        }
        color("ivory") intersection() {
            mating_light();
            translate([-100,-100,-100]) cube([100+eps,200,200]);
        }
    } else if (show == "fitcheck") {
        intersection() { hood(); mating_light(); }
    } else if (show == "body-sweep") {
        // Continuous conservative envelope from entirely outside to seated.
        // The rib is checked separately in translation/normal-opening space.
        intersection() {
            fixed_body();
            hull() {
                mating_light();
                translate([0,0,-40]) mating_light();
            }
        }
    } else if (show == "body") fixed_body();
    else if (show == "rib") grip_rib();
    else hood();
}

if (flip) translate([0,0,print_front_z]) rotate([0,180,0]) selected_view();
else selected_view();

echo(str("Clear cavity: ",cavity_w," x ",cavity_h," mm; rim ",rim_depth," mm"));
echo(str("Panel back against light at Z=0; rear sleeve flush with ring back at Z=",sleeve_rear_z,
         " mm; total printed depth ",face_depth-sleeve_rear_z," mm"));
echo(str("External scoop axis: ",outlet_angle," degrees; no internal light duct; sensor bore ",sensor_bore_d," mm"));
echo(str("Underside opening: ",outlet_w," mm clear width, edge to edge; -Y wall; Z=",outlet_back_z," to ",outlet_front_z," mm; corner at Z=",face_depth," mm"));
echo(str("External scoop drop: ",scoop_actual_drop," mm; trimmed at Z=",face_depth," mm to leave back and sides"));
echo(str("Rounded friction rib, cleared from channel: ",grip_projection," mm projection; ",
         grip_width," mm axial width; ",grip_projection-fit," mm radial interference; centre Z=",grip_z," mm"));
echo(str("Trace-derived front corner radius: ",light_corner_r," mm; cavity radius: ",cavity_corner_r," mm"));
echo("Front radius is fitted from a photographed trace; rear body is photo-estimated. Physical fit still requires a trial.");

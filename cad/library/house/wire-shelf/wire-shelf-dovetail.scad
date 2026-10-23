// Note 1.

/* [Hidden] */
shelf_dt_mouth_w = 5;    // Note 2.
shelf_dt_root_w = 7;     // Note 3.
shelf_dt_depth = 2.94;   // Note 4.
shelf_dt_clear = 0.2;    // Note 5.
shelf_dt_chamfer = 0.5;  // Note 6.
shelf_dt_extension = 1;  // Note 7.
shelf_dt_eps = 0.01;     // Note 8.

function shelf_dovetail_depth() = shelf_dt_depth;

module shelf_dovetail_profile(joint_z, mount_depth, extra = 0) {
    yc = mount_depth / 2;
    slope = (shelf_dt_root_w - shelf_dt_mouth_w) / 2 / shelf_dt_depth;
    low = joint_z - shelf_dt_extension;
    polygon([[yc - shelf_dt_mouth_w / 2 + slope * (low - joint_z), low],
             [yc + shelf_dt_mouth_w / 2 - slope * (low - joint_z), low],
             [yc + shelf_dt_root_w / 2, joint_z + shelf_dt_depth],
             [yc - shelf_dt_root_w / 2, joint_z + shelf_dt_depth]]);
    if (extra > 0)
        polygon([[yc - shelf_dt_mouth_w / 2 - extra, low],
                 [yc + shelf_dt_mouth_w / 2 + extra, low],
                 [yc + shelf_dt_mouth_w / 2 + extra, joint_z - shelf_dt_eps],
                 [yc + shelf_dt_mouth_w / 2, joint_z + extra],
                 [yc - shelf_dt_mouth_w / 2, joint_z + extra],
                 [yc - shelf_dt_mouth_w / 2 - extra, joint_z - shelf_dt_eps]]);
}

module shelf_dovetail_along_x(length) {
    translate([-length / 2, 0, 0]) rotate([90, 0, 90])
        linear_extrude(height = length, convexity = 10) children();
}

module shelf_dovetail_groove(length, joint_z = 38.7, mount_depth = 12) {
    shelf_dovetail_along_x(length + 2 * shelf_dt_eps)
        shelf_dovetail_profile(joint_z, mount_depth, shelf_dt_chamfer);
}

module shelf_dovetail_tail(length, joint_z = 38.7, mount_depth = 12) {
    shelf_dovetail_along_x(length) intersection() {
        offset(delta = -shelf_dt_clear) shelf_dovetail_profile(joint_z, mount_depth);
        translate([0, joint_z - shelf_dt_eps])
            square([mount_depth, shelf_dt_depth + shelf_dt_eps]);
    }
}

// Notes

// Note 1. The physically printed Gridfinity shelf joint, shared by other wire-shelf parts.
// Keep its section and clearance fixed; adapt only length and joint placement.

// Note 2. mm, groove mouth at the body underside

// Note 3. mm, bridge width at the groove roof

// Note 4. mm, depth of the tested groove

// Note 5. mm per face, sliding/glue clearance

// Note 6. mm, 45-degree mouth chamfer

// Note 7. mm below joint face, retaining the offset flank line

// Note 8. mm boolean overshoot

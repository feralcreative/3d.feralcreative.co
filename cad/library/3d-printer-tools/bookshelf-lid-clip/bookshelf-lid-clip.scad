include <../../../lib/BOSL2/std.scad>
include <../../../logos/marks.scad>

/* [Display] */
view = "default"; // [default, together, exploded]
show = "assembled"; // [assembled, exploded, print-set, clip, platform, fitcheck, rotationcheck, snapcheck, insertioncheck]
position = "hold"; // [hold, release, custom]
swivel_angle = 0; // [0:180]
show_shelf = true;

/* [Shelf] */
shelf_t = 19;
shelf_clearance = 0.6;
clip_width = 40;
clip_depth = 38;
wall = 5.4;
edge_r = 1.5;

/* [Lid contact] */
contact_back = 45; // Note 1.
contact_drop = 26.5;
platform_angle = 45;
platform_length = 42;
platform_width = 34;
platform_t = 5.4;

/* [Logo] */
logo_w = 22;
logo_depth = 0.8;
logo_taper = 84; // Note 5.
logo_steps = 5;
logo_y = 20;

/* [Snap pivot] */
post_d = 10;
pivot_clearance = 0.6;
eye_h = 7;
axial_clearance = 0.5;
head_d = 11.6;
head_h = 3;
flex_length = 14;
slit = 1.6;
core_d = 7.3;

/* [Hidden] */
$fn = 72;
eps = 0.02;
slot_lo = -shelf_clearance/2;
slot_hi = shelf_t+shelf_clearance/2;
clip_lo = slot_lo-wall;
clip_hi = slot_hi+wall;
pad_start = 7;
pad_root_z = 5;
pad_mid_y = pad_start+platform_length*cos(platform_angle)/2;
pad_mid_z = pad_root_z-platform_length*sin(platform_angle)/2;
pivot_y = contact_back-pad_mid_y;
eye_z = -contact_drop-pad_mid_z;
stop_z = eye_z+eye_h+axial_clearance;
head_top = eye_z-axial_clearance;
head_bottom = head_top-head_h;
flex_root = head_bottom+flex_length;
turn = position=="release" ? 180 : position=="custom" ? swivel_angle : 0;
assert(pivot_y>post_d/2 && pivot_y<clip_depth-post_d/2);
assert(stop_z+1.2<clip_lo,"Increase contact_drop for room above the pivot");
assert(flex_root<clip_lo-0.3,"Increase contact_drop or shorten flex_length");
assert(head_d>post_d+pivot_clearance+0.4);
assert(platform_angle>0 && platform_angle<80);
module sleeve() {
    difference() {
        translate([0,(clip_depth-wall)/2,(clip_hi+clip_lo)/2])
            cuboid([clip_width,clip_depth+wall,clip_hi-clip_lo],rounding=edge_r);
        translate([-clip_width,0,slot_lo])
            cube([2*clip_width,clip_depth+2,slot_hi-slot_lo]);
        translate([-clip_width,clip_depth-1,slot_lo-1])
            rotate([90,0,90]) linear_extrude(2*clip_width)
                polygon([[0,1],[2,1],[2,-1]]);
        translate([-clip_width,clip_depth-1,slot_hi])
            rotate([90,0,90]) linear_extrude(2*clip_width)
                polygon([[0,0],[2,0],[2,2]]);
    }
}

module post() { // Note 2.
    difference() {
        union() {
            translate([0,0,head_top]) cylinder(d=post_d,h=clip_lo-head_top+eps);
            translate([0,0,clip_lo-2]) cylinder(d1=post_d,d2=18,h=2+eps);
            translate([0,0,stop_z]) cylinder(d=16,h=1.2);
            translate([0,0,head_bottom]) cylinder(d1=max(post_d-2,core_d+1.8),d2=head_d,h=head_h-0.8);
            translate([0,0,head_top-0.8]) cylinder(d=head_d,h=0.8+eps);
        }
        for(a=[0,90]) rotate([0,0,a]) {
            translate([-slit/2,-15,head_bottom-eps]) cube([slit,30,flex_length-slit/2+eps]);
            translate([0,0,flex_root-slit/2]) rotate([90,0,0])
                cylinder(d=slit,h=30,center=true,$fn=24);
        }
        translate([0,0,head_bottom-eps]) cylinder(d=core_d,h=flex_length+eps);
    }
}

module clip() {
    sleeve();
    translate([0,pivot_y,0]) post();
}

module platform_blank() { // Note 4.
    tip = pad_start+platform_length*cos(platform_angle);
    knee = pad_start+(pad_root_z-eye_h)/tan(platform_angle);
    base_knee = pad_start+(pad_root_z-platform_t/cos(platform_angle))/tan(platform_angle);
    function top(y) = pad_root_z-(y-pad_start)*tan(platform_angle);
    section = [[-platform_width/2-1,0],[base_knee,0],
               [tip+1,top(tip+1)-platform_t/cos(platform_angle)],
               [tip+1,top(tip+1)],[knee,eye_h],[-platform_width/2-1,eye_h]];
    assert(tip>=platform_width);
    minkowski() {
        intersection() {
            linear_extrude(height=160,center=true)
                offset(delta=-edge_r) hull() {
                    circle(d=platform_width);
                    translate([0,tip-platform_width/2]) circle(d=platform_width);
                }
            translate([-platform_width/2+edge_r,0,0]) rotate([90,0,90])
                linear_extrude(height=platform_width-2*edge_r)
                    offset(delta=-edge_r) polygon(section);
        }
        sphere(r=edge_r,$fn=24);
    }
}

module platform_logo() { // Note 5.
    band = logo_depth/logo_steps;
    translate([0,logo_y,pad_root_z-(logo_y-pad_start)*tan(platform_angle)])
        rotate([-platform_angle,0,0])
            for(i=[0:logo_steps-1])
                translate([0,0,-band*(i+1)])
                    linear_extrude(height=band+eps,convexity=20)
                        offset(delta=-band*i/tan(logo_taper)) rotate(180) feral_logo(logo_w);
}

module platform() {
    difference() {
        platform_blank();
        platform_logo();
        translate([0,0,-60]) cylinder(d=post_d+pivot_clearance,h=120);
        translate([0,0,-30]) cylinder(d=head_d+0.8,h=30);
        translate([0,0,eye_h-0.6]) cylinder(d1=post_d+pivot_clearance,d2=post_d+pivot_clearance+1.2,h=0.62);
        translate([0,0,-eps]) cylinder(d1=post_d+pivot_clearance+0.3,d2=post_d+pivot_clearance,h=0.17);
    }
}

module shelf() {
    translate([-60,eps,0]) cube([120,100,shelf_t]);
}

module assembled(explode=0) {
    color("#b770db") clip();
    color("#d6a344") translate([0,pivot_y,eye_z-explode]) rotate([0,0,turn]) platform();
    if(show_shelf) %shelf();
}

module print_clip() {
    translate([0,0,clip_hi]) rotate([180,0,0]) clip();
}

module print_platform() {
    translate([0,0,eye_h]) rotate([180,0,0]) platform();
}

module print_set() {
    translate([-35,0,0]) print_clip();
    translate([30,0,0]) print_platform();
}

module fitcheck() {
    intersection() { clip(); shelf(); }
    intersection() {
        clip();
        translate([0,pivot_y,eye_z]) rotate([0,0,turn]) platform();
    }
}

module rotationcheck() {
    for(a=[0:5:180]) intersection() {
        clip();
        translate([0,pivot_y,eye_z]) rotate([0,0,a]) platform();
    }
}

module compressed_post() { // Note 3.
    intersection() {
        post();
        translate([-30,-30,flex_root]) cube([60,60,100]);
    }
    for(x=[-1,1],y=[-1,1])
        multmatrix([[1,0,x*0.7/flex_length,-x*0.7*flex_root/flex_length],
                    [0,1,y*0.7/flex_length,-y*0.7*flex_root/flex_length],
                    [0,0,1,0],[0,0,0,1]])
            intersection() {
                post();
                translate([x<0?-30:0,y<0?-30:0,head_bottom-1])
                    cube([30,30,flex_length+1]);
            }
}

module snapcheck() {
    intersection() {
        translate([0,pivot_y,0]) compressed_post();
        difference() {
            hull() {
                translate([0,pivot_y,eye_z]) platform();
                translate([0,pivot_y,eye_z-35]) platform();
            }
            translate([0,pivot_y,eye_z-50]) cylinder(d=post_d+pivot_clearance,h=eye_h+55);
        }
    }
    intersection() {
        translate([0,pivot_y,0]) compressed_post();
        translate([0,pivot_y,head_bottom-20])
            difference() {
                cylinder(d=20,h=eye_z+eye_h-head_bottom+20);
                translate([0,0,-eps]) cylinder(d=post_d+pivot_clearance,h=eye_z+eye_h-head_bottom+20+2*eps);
            }
    }
}

module insertioncheck() {
    intersection() {
        clip();
        translate([-60,eps,0]) cube([120,160,shelf_t]);
    }
    snapcheck();
}

if(view=="together") assembled();
else if(view=="exploded") assembled(25);
else if(show=="print-set") print_set();
else if(show=="clip") print_clip();
else if(show=="platform") print_platform();
else if(show=="fitcheck") fitcheck();
else if(show=="rotationcheck") rotationcheck();
else if(show=="snapcheck") snapcheck();
else if(show=="insertioncheck") insertioncheck();
else assembled(show=="exploded" ? 25 : 0);

// Note 1. Back is +Y into the shelf. The contact face is centred 45 mm back
// and 26.5 mm below the shelf underside, leaving about 4 mm under the clip.
// Note 2. Four split prongs flex inward as the platform passes over the
// tapered tip, then spring outward so their ledges retain the platform.
// Their 7.3 mm core leaves 1.35 mm radial walls along the shorter fingers.
// The 10.6 mm bore turns on a 10 mm post with 0.5 mm axial space at each end.
// Note 3. The snap check models the prongs bending inward by 0.7 mm per axis
// at the tip. This verifies a geometrical insertion path, not printed strain.
// The sleeve prints upside down with removable supports inside its channel;
// the platform prints eye-top down. Lift the lid slightly before turning it.

// Note 4. One pill-shaped outline wraps around the pivot hole and blends
// from its flat bearing area into the 45-degree support face. Both ends
// and the outer edges are rounded; the snap-fit bore is unchanged.

// Note 5. Recess the full Feral Creative mark 0.8 mm in five bevelled bands.
// The small-logo 84-degree taper preserves fine lettering that a 70-degree
// cut would close. Artwork comes from the shared logo library.

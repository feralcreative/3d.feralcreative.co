include <../../../lib/BOSL2/std.scad>
include <../../../lib/BOSL2/rounding.scad>

/* [Washcloth plate] */
hole_count = 4;
hole_d = 30;
hole_pitch = 44;
plate_width = 54;
plate_thickness = 8.04;
plate_start = 48;
edge_round = 1.2;
plate_setback = 14.24; // Note 2.

/* [Shelf hook] */
hook_width = 23;
neck_width = 32;
bend_start = 28;
bend_end = 58;
shoulder_blend = 6;
print_angle = 45;

/* [Display] */
show = "mounted"; // [mounted, print, hook-detail]
view = "default"; // [default, together, exploded]

/* [Colors] */
holder_color = "MediumPurple";

/* [Hidden] */
$fn = 96;
eps = 0.01;
hook_centre_y = -3.329674;
hook_centre_z = 7.225;
rear_slot_min_x = 161.38 - 162.486557;
rear_slot_max_x = 164.18 - 162.486557;
rear_slot_split_y = -3.329674;
rear_slot_end_z = 27.875;
clip_rear_y = -6.42967-plate_thickness;
hook_join_z = 18;
loft_z_step = 0.4;
corner_steps = 12;
crown_steps = 72;
plate_border = (plate_width-hole_d)/2;
plate_end_r = plate_width/2;
plate_height = plate_width+(hole_count-1)*hole_pitch;
plate_end = plate_start+plate_height;
hole_first_z = plate_start+plate_width/2;
hole_centers = [for(i=[0:hole_count-1]) [0,i*hole_pitch]];

contact_curve = [ // Note 1.
  [
    -0.22967,
    7.22524
  ],
  [
    -0.2577,
    6.88703
  ],
  [
    -0.27195,
    6.71499
  ],
  [
    -0.35526,
    6.38601
  ],
  [
    -0.39764,
    6.21867
  ],
  [
    -0.53396,
    5.90788
  ],
  [
    -0.6033,
    5.7498
  ],
  [
    -0.78892,
    5.46569
  ],
  [
    -0.88334,
    5.32118
  ],
  [
    -1.11319,
    5.0715
  ],
  [
    -1.2301,
    4.94449
  ],
  [
    -1.36632,
    4.83847
  ],
  [
    -1.63413,
    4.63002
  ],
  [
    -1.78595,
    4.54786
  ],
  [
    -2.08442,
    4.38634
  ],
  [
    -2.24769,
    4.33029
  ],
  [
    -2.56867,
    4.2201
  ],
  [
    -2.73894,
    4.19168
  ],
  [
    -3.07368,
    4.13583
  ],
  [
    -3.2463,
    4.13583
  ],
  [
    -3.58567,
    4.13583
  ],
  [
    -3.75594,
    4.16424
  ],
  [
    -4.09068,
    4.2201
  ],
  [
    -4.25395,
    4.27615
  ],
  [
    -4.57493,
    4.38634
  ],
  [
    -4.72674,
    4.4685
  ],
  [
    -5.02521,
    4.63002
  ],
  [
    -5.16143,
    4.73605
  ],
  [
    -5.42925,
    4.94449
  ],
  [
    -5.6591,
    5.19418
  ],
  [
    -5.77601,
    5.32118
  ],
  [
    -5.96163,
    5.60529
  ],
  [
    -6.05604,
    5.7498
  ],
  [
    -6.19237,
    6.06059
  ],
  [
    -6.26171,
    6.21867
  ],
  [
    -6.34502,
    6.54766
  ],
  [
    -6.38739,
    6.71499
  ],
  [
    -6.41542,
    7.05321
  ],
  [
    -6.42967,
    7.22524
  ],
  [
    -6.42967,
    14.51652
  ],
  [
    -6.42967,
    18.22524
  ],
  [
    -6.2514,
    18.92069
  ],
  [
    -6.16072,
    19.27443
  ],
  [
    -6.07801,
    19.98759
  ],
  [
    -6.03595,
    20.35034
  ],
  [
    -5.72038,
    21.03701
  ],
  [
    -5.55986,
    21.38629
  ],
  [
    -7.55796,
    20.12806
  ],
  [
    -10.57967,
    18.22524
  ],
  [
    -10.57967,
    11.6037
  ],
  [
    -10.57967,
    7.22524
  ]
];
inner_front_y = contact_curve[0].x;
stem_front_y = inner_front_y+plate_thickness;
plate_front_y = stem_front_y-plate_setback;
plate_rear_y = plate_front_y-plate_thickness;
print_base_y = min(clip_rear_y,plate_rear_y);
outer_rear_r = hook_centre_y-clip_rear_y;
// Note 3.
rear_extra = contact_curve[38].x-plate_thickness-contact_curve[50].x;
reinforced_contact_curve = [for(i=[0:len(contact_curve)-1])
    i<47 ? contact_curve[i] :
    [contact_curve[i].x+rear_extra*(i==47 ?
        (contact_curve[47].x-contact_curve[46].x)/(contact_curve[48].x-contact_curve[46].x) : 1),
     contact_curve[i].y]];
outer_front_r = stem_front_y-hook_centre_y;

assert(hole_count==4);
assert(bend_end>bend_start && bend_start>=rear_slot_end_z);
assert(hook_width<=neck_width && neck_width<plate_width);
assert(plate_thickness>2*edge_round && plate_border>edge_round);
assert(hole_pitch>hole_d+2*edge_round);

function smooth01(t) = let(u=max(0,min(1,t))) u*u*u*(10+u*(-15+6*u));
function front_y(z) = stem_front_y-plate_setback*smooth01((z-bend_start)/(bend_end-bend_start));
function cap_width(z) = z<plate_start ? 0 : z<hole_first_z ?
    2*sqrt(max(0,plate_end_r*plate_end_r-pow(z-hole_first_z,2))) : plate_width;
function smooth_max(a,b,k) = max(a,b)+pow(max(k-abs(a-b),0),2)/(4*k);
function body_width(z) = smooth_max(
    hook_width+(neck_width-hook_width)*smooth01((z-bend_start)/(bend_end-bend_start)),
    cap_width(z),shoulder_blend);
function body_ring(z) = let(w=body_width(z), yf=front_y(z), yb=yf-plate_thickness, r=edge_round)
    [for(q=[0:3],j=[0:corner_steps])
        let(a=q*90+j*90/corner_steps,
            cx=(q==0 || q==3)?w/2-r:-w/2+r,
            cy=q<2?yf-r:yb+r)
        [cx+r*cos(a),cy+r*sin(a),z]];
function crown_point(i) = let(t=i/crown_steps,a=180+180*t,
    r=outer_rear_r+(outer_front_r-outer_rear_r)*smooth01(t))
    [hook_centre_y+r*cos(a),hook_centre_z+r*sin(a)];

module continuous_hook() { // Note 4.
    profile=concat(reinforced_contact_curve,[for(i=[1:crown_steps]) crown_point(i)],
        [[stem_front_y,hook_join_z],[inner_front_y,hook_join_z]]);
    multmatrix([[0,0,1,-hook_width/2],[1,0,0,0],[0,1,0,0],[0,0,0,1]])
        offset_sweep(profile,height=hook_width,
            bottom=os_circle(r=edge_round,steps=corner_steps),
            top=os_circle(r=edge_round,steps=corner_steps),convexity=10);
}

module continuous_stem() { // Note 5.
    end_z=hole_first_z+1;
    n=ceil((end_z-hook_centre_z)/loft_z_step);
    rows=[for(i=[0:n]) body_ring(hook_centre_z+(end_z-hook_centre_z)*i/n)];
    vnf_vertex_array(rows,col_wrap=true,caps=true,reverse=true,convexity=10);
}

module lower_plate() { // Note 6.
    intersection() {
        hull()
            for(z=[hole_first_z,hole_first_z+(hole_count-1)*hole_pitch],
                y=[plate_rear_y+edge_round,plate_front_y-edge_round])
                translate([0,y,z]) rotate([90,0,0])
                    rotate_extrude($fn=96,convexity=10)
                        translate([plate_end_r-edge_round,0]) circle(r=edge_round,$fn=48);
        translate([-plate_width,plate_rear_y-eps,hole_first_z])
            cube([2*plate_width,plate_thickness+2*eps,plate_height]);
    }
}

module rear_wire_slot() {
    translate([rear_slot_min_x,clip_rear_y-plate_width,-plate_width])
        cube([rear_slot_max_x-rear_slot_min_x,
            rear_slot_split_y-(clip_rear_y-plate_width),rear_slot_end_z+plate_width]);
}

module washcloth_holes() {
    hole_r=hole_d/2/cos(180/$fn);
    round_step=7.5;
    profile=concat([[0,-eps],[hole_r+edge_round,-eps]],
        [for(a=[-90:round_step:0])
            [hole_r+edge_round-edge_round*cos(a),edge_round+edge_round*sin(a)]],
        [for(a=[0:round_step:90])
            [hole_r+edge_round-edge_round*cos(a),plate_thickness-edge_round+edge_round*sin(a)]],
        [[hole_r+edge_round,plate_thickness+eps],[0,plate_thickness+eps]]);
    for(p=hole_centers)
        translate([p.x,plate_front_y,hole_first_z+p.y]) rotate([90,0,0])
            rotate_extrude(convexity=10) polygon(profile);
}

module washcloth_hook() {
    color(holder_color) difference() {
        union() { continuous_hook(); continuous_stem(); lower_plate(); }
        rear_wire_slot();
        washcloth_holes();
    }
}

module presentation() {
    if(view=="default" && show=="print")
        rotate([0,0,print_angle]) rotate([90,0,0])
            translate([0,-print_base_y,0]) washcloth_hook();
    else if(view=="default" && show=="hook-detail")
        rotate([180,0,0]) intersection() {
            washcloth_hook();
            translate([-plate_width,-plate_width,-plate_width])
                cube([2*plate_width,2*plate_width,plate_width+hole_first_z]);
        }
    else rotate([180,0,0]) washcloth_hook();
}
presentation();

/*
Notes

Dimensions are in mm; angles are in degrees. Mounted coordinates: +Z down,
+Y toward the person facing the shelf.

1. Measured Y/Z contact profile from mostman's Elfa Hat Large hook:
   https://www.thingiverse.com/thing:5461648 — Creative Commons Attribution.
   The inner seat and return tip remain unchanged; side-face rounding leaves
   the middle contact path intact.
2. Setback = 6.20 gap + 8.04 wall, aligning the plate and rear hook backs.
3. Reinforcement grows only the outer rear surface to match the front wall.
4. Hook uses one swept profile with rounded side edges.
5. Constant-wall loft blends the setback and shoulders; its 1 mm overlap
   joins the straight plate.
6. Loft forms the upper cap; the capsule supplies the lower plate.
*/

# SimpliSafe Entry Sensor Cover
# Window → Ruby Console → paste → Enter

model = Sketchup.active_model
entities = model.active_entities
model.start_operation('Sensor Cover', true)

# ── Parameters (mm) ──────────────────────────────────────
SENSOR_W   = 30.5   # short dimension
SENSOR_L   = 40.5   # long dimension
SENSOR_D   = 19.0   # depth
CORNER_R   = 5.0    # inner corner radius — matches sensor
ARC_SEGS   = 16     # segments per corner arc

TOL_W      = 0.6    # total width tolerance  (0.3/side)
TOL_L      = 0.6    # total length tolerance (0.3/side)
TOL_D      = 0.3    # depth tolerance

WALL       = 0.8    # wall thickness (2 perimeters at 0.4 mm nozzle)

LIGHT_W    = 7.0
LIGHT_H    = 2.0
LIGHT_TOL  = 0.3
LIGHT_EDGE = 1.8    # distance from closed end to top of slot

BTN_D      = 4.0    # reset button diameter
BTN_TOL    = 0.4    # total tolerance
BTN_EDGE   = 4.5    # distance from inner top surface to button center

# ── Derived ──────────────────────────────────────────────
int_w  = SENSOR_W + TOL_W    # 31.1
int_l  = SENSOR_L + TOL_L    # 41.1
int_d  = SENSOR_D + TOL_D    # 19.3
out_w  = int_w + 2 * WALL    # 32.7
out_l  = int_l + 2 * WALL    # 42.7
out_d  = int_d + WALL        # 20.1 (pocket + end cap)
r_in   = CORNER_R            # 5.0
r_out  = r_in + WALL         # 5.8 — parallel offset of inner radius
cut_w  = LIGHT_W + 2 * LIGHT_TOL   # 7.6
cut_h  = LIGHT_H + 2 * LIGHT_TOL   # 2.6
btn_r  = (BTN_D + BTN_TOL) / 2.0   # 2.2
btn_cx = out_w / 2.0               # centered in X (width)
btn_cz = out_d - WALL - BTN_EDGE   # 4.5 mm from inner top surface

# ── Helper: rounded-rectangle perimeter points ───────────
# Generates points CCW from +Z view so face normal = +Z (upward).
# Corners: BL → BR → TR → TL, connected by straight edges.
def rrect_pts(x0, y0, x1, y1, r, z = 0, segs = 16)
  pi  = Math::PI
  pts = []
  arc = ->(cx, cy, a) {
    Geom::Point3d.new((cx + r * Math.cos(a)).mm, (cy + r * Math.sin(a)).mm, z)
  }

  # BL corner  (pi → 3pi/2) — all segs+1 points including both endpoints
  (0..segs).each { |i| pts << arc.call(x0+r, y0+r, pi       + (pi/2) * i.to_f / segs) }
  pts << Geom::Point3d.new((x1-r).mm, y0.mm, z)          # bottom straight end

  # BR corner  (3pi/2 → 2pi) — skip i=0 (already added as bottom straight end)
  (1..segs).each { |i| pts << arc.call(x1-r, y0+r, 3*pi/2   + (pi/2) * i.to_f / segs) }
  pts << Geom::Point3d.new(x1.mm, (y1-r).mm, z)          # right straight end

  # TR corner  (0 → pi/2) — skip i=0
  (1..segs).each { |i| pts << arc.call(x1-r, y1-r, 0        + (pi/2) * i.to_f / segs) }
  pts << Geom::Point3d.new((x0+r).mm, y1.mm, z)          # top straight end

  # TL corner  (pi/2 → pi) — skip i=0; last point closes to BL start via implicit left edge
  (1..segs).each { |i| pts << arc.call(x0+r, y1-r, pi/2     + (pi/2) * i.to_f / segs) }

  pts
end

# ── Helper: circle perimeter on the Y = y_wall face (X-Z plane) ─────────────
# Points CCW from the -Y view so face normal = -Y (outward from Y=0 wall).
# pushpull(-WALL.mm) then punches inward (+Y) through the wall.
def circle_pts(y_wall, cx, cz, r, segs = 32)
  (0...segs).map { |i|
    a = 2 * Math::PI * i.to_f / segs
    Geom::Point3d.new((cx + r * Math.cos(a)).mm, y_wall.mm, (cz + r * Math.sin(a)).mm)
  }
end

# ── Helper: pill-shaped perimeter on the X = x_wall face (Y-Z plane) ────────
# r_pill = cut_h/2 gives a true stadium (semicircle on each short end).
# Points are CCW from the +X view so face normal = +X (outward).
def pill_pts(x_wall, slot_y0, slot_z0, slot_w, slot_h, segs = 16)
  pi     = Math::PI
  r      = slot_h / 2.0
  rc_y   = slot_y0 + slot_w - r   # right arc center Y
  lc_y   = slot_y0 + r            # left  arc center Y
  arc_cz = slot_z0 + r            # both arc centers share this Z

  pts = []
  arc = ->(cy, a) {
    Geom::Point3d.new(x_wall.mm, (cy + r * Math.cos(a)).mm, (arc_cz + r * Math.sin(a)).mm)
  }

  # Right semicircle (-pi/2 → +pi/2), segs+1 points
  (0..segs).each { |i| pts << arc.call(rc_y, -pi/2 + pi * i.to_f / segs) }

  # Top straight endpoint (start of left arc)
  pts << Geom::Point3d.new(x_wall.mm, lc_y.mm, (slot_z0 + slot_h).mm)

  # Left semicircle (pi/2 → 3pi/2), skip i=0 (same as top straight end)
  # Last point lands at (lc_y, slot_z0); face closes to right arc start via implicit bottom edge
  (1..segs).each { |i| pts << arc.call(lc_y, pi/2 + pi * i.to_f / segs) }

  pts
end

# ── Build geometry ────────────────────────────────────────
grp = entities.add_group
g   = grp.entities

# 1. Outer shell — open at Z=0, closed cap at Z=out_d
outer_face = g.add_face(rrect_pts(0, 0, out_w, out_l, r_out, 0, ARC_SEGS))
outer_face.pushpull(out_d.mm)

# 2. Inner pocket — open at Z=0 (slide-on end), closed at Z=out_d (end cap)
#    If the pocket extrudes DOWNWARD instead, change int_d.mm to -int_d.mm
inner_face = g.add_face(rrect_pts(WALL, WALL, WALL+int_w, WALL+int_l, r_in, 0, ARC_SEGS))
inner_face.pushpull(int_d.mm)

# 3. Status light slot — pill shape on the long wall (X = out_w)
#    Centered along Y (the 40.5 mm dimension), 1.8 mm from closed end.
#    If your light is on the SHORT wall instead, swap this face to Y=0.
slot_y0 = out_l / 2.0 - cut_w / 2.0
slot_z0 = out_d - WALL - LIGHT_EDGE - cut_h

cut_face = g.add_face(pill_pts(out_w, slot_y0, slot_z0, cut_w, cut_h, ARC_SEGS))
cut_face.pushpull(-WALL.mm)

# 4. Reset button hole — circle on the right short wall (Y=0)
#    "Right" when facing the front (X=out_w) with the pill at top.
#    Centered in X (width), 4.5 mm from inner top surface.
#    If it ends up on the wrong short wall, change y_wall to out_l and pushpull to +WALL.mm.
btn_face = g.add_face(circle_pts(0, btn_cx, btn_cz, btn_r))
btn_face.pushpull(-WALL.mm)

model.commit_operation

UI.messagebox(
  "Cover built!\n" \
  "Outer:    #{out_w.round(1)} x #{out_l.round(1)} x #{out_d.round(1)} mm\n" \
  "Interior: #{int_w.round(1)} x #{int_l.round(1)} x #{int_d.round(1)} mm\n" \
  "Corners:  #{r_in} mm inside / #{r_out} mm outside\n" \
  "Light slot: #{cut_w.round(1)} x #{cut_h.round(1)} mm pill\n" \
  "Button hole: #{(btn_r*2).round(1)} mm dia, #{BTN_EDGE} mm from inner top"
)

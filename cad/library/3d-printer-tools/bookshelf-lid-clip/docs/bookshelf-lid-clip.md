# Bookshelf lid clip

Two printed pieces: a shelf sleeve with a four-prong snap post and a swivelling 45° platform with a pivot hole. The platform has one pill-shaped outline with a rounded end surrounding the post and a rounded support end. Push the platform over the tapered post end; the prongs compress, pass through the hole and spring out to retain it. There are no threads or separate retainers.

The relaxed sleeve channel is exactly 19 mm at the closed base and tapers symmetrically to 18 mm at the open end over its 38 mm depth. Each arm leans inward 0.5 mm; the inner and outer faces slope together, preserving the existing 5.4 mm wall thickness. A 19 mm shelf must spread each tip outward 0.5 mm. This is intentional interference; printed insertion force, spring recovery and grip remain untested. `shelf_clearance=0` sets the base gap and `shelf_mouth_gap=18` sets the opening. The middle of the contact face is 45 mm behind the shelf edge. Its contact centre is 26.5 mm below the shelf underside, leaving about 4 mm between the clip and the platform’s flat pivot area. Change `contact_drop` to adjust this position. `position="hold"` / `position="release"` shows the rearward and forward positions, and `view="exploded"` separates the two pieces.

The sloped top carries the shared Feral Creative logo, 22 mm wide and recessed 0.8 mm with an 84° taper in five bands. The crest faces the pivot and the lettering faces the rounded support end. The shallow taper preserves the fine lettering; printed readability remains untested.

1. Print the mount and platform. The mount is upside down in the supplied layout and needs removable supports inside the open shelf channel. Keep supports out of the four snap-prong slits. The platform prints with the eye’s upper face on the bed. Slicing and support removal have not been validated.
2. Push the platform onto the post from below until all four retaining ledges pass the hole. Check that all four prongs expand and the platform turns freely.
3. Spread the sleeve arms to pass the 19 mm shelf edge and slide the sleeve home. Turn the platform back to support the lid; lift the lid slightly and turn it forward to release. The geometric `fitcheck` and straight swept `insertioncheck` use arms spread to a 19 mm opening; they do not establish the force required or whether the printed arms tolerate the deflection.

Latest STLs live only in `_work/stl/`, beside the numbered print-set history. `bookshelf-lid-clip-print-set.stl` contains both pieces; the `-mount` and `-platform` files contain the individual pieces. The obsolete collar export has been removed.

The pivot is 10 mm in a 10.6 mm hole; retaining ledges reach 11.6 mm. A 7.3 mm hollow core and crossed slots provide four 14 mm-long flexible prongs with 1.35 mm radial walls. The flat bearing area blends into the 34 mm-wide pill-shaped platform; it remains 7 mm thick at the pivot, with 0.5 mm axial clearance at each end. The model checks an insertion path with the prongs deflected inward and free rotation once expanded. This establishes geometrical clearance, not printed flex life, insertion force, retention strength or actual lid fit.

Rebuild from the repository root:

```bash
utils/build.sh bookshelf-lid-clip -D 'show="print-set"' --name bookshelf-lid-clip-print-set --backend=Manifold
python3 cad/library/3d-printer-tools/bookshelf-lid-clip/utils/check-mesh.py
```

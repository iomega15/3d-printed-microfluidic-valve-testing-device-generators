# Parametric device generators for a geometry-first 3D-printed microfluidic valve framework

OpenSCAD source for the two test devices used in *"A Geometry-First Design Framework
and Interactive Design Tool for 3D-Printed Microfluidic Valves Using New Photopolymer
Resins."* Both files are self-contained: no `include<>`, no `use<>`, no external
libraries. Open in OpenSCAD and press F6, or render headlessly:

    openscad -o device.stl printability_device.scad

Both files render manifold with no errors and take well under a second.

| File | Device | Used for |
|---|---|---|
| `printability_device.scad` | **Printability Device** — arrays of enclosed rigid channels; the roof bridges two sidewalls with the front and back faces open | Stage I, the printability sweep (manuscript Section 3.1, Figures 3-5) |
| `functionality_device.scad` | **Functionality Device** — the same channel plus an enclosed control chamber above the membrane, open-faced front and back for transmitted-light imaging | Stage II onward, membrane functionality and seat geometry (Sections 3.2-3.4, Figures 6-8) |

`examples/` holds one STL rendered from each file at the committed default parameters,
for anyone who wants the geometry without installing OpenSCAD.

The seat radius and penetration these devices need come from the companion interactive
design tool, kept in its own repository (`microfluidic-valve-design-calculator`) and also
provided in the ESI of the paper.

## Choosing the printer

Both files select the machine the same way, with a 1-based `PRINTER_NUMBER`:

```
PRINTER_NUMBER = 2;                 // 1 = Pro 4K (65 um), 2 = Ultra (32 um)
PRINTER_NAMES              = ["Pro 4K 65um", "Ultra 32um"];
PRINTER_BUILD_PLATE_X_SIZES = [175.49, 120.76];
PRINTER_BUILD_PLATE_Y_SIZES = [ 98.75,  67.94];
PRINTER_PIXEL_SIZES         = [ 0.065,   0.032];
PRINTER_LAYER_THICKNESSES   = [ 0.020,   0.050];
```

The pixel pitch and layer height follow from that choice, so every pixel- and layer-denominated parameter rescales with the
machine and nothing else needs touching. Add a printer by appending to each array and selecting its number; an out-of-range
number stops the render with a message naming the machines that are defined. The devices reported in the paper were printed on
the Ultra (`PRINTER_NUMBER = 2`), which is the shipped default.

All dimensions are expressed in **printer pixels** (in-plane) and **print layers**
(vertical), so the geometry ports to another printer by changing only the pixel pitch
and layer height. For the Asiga machine used in the paper, 1 px = 32 um and
1 layer = 50 um.

---

## printability_device.scad

Generates a rectangular array of enclosed channels. Two parameters are swept across the
array so that one print yields a whole design matrix under identical process conditions.

**Channel geometry**

| Parameter | Default | Meaning |
|---|---|---|
| `DEFAULT_intra_cell_posts_gap_X_pixels` | 100 | Channel **width** in px. The paper sweeps 1-20 in steps of 1, then 20-150 in steps of 10. |
| `DEFAULT_post_height_layers` | 5 | Channel **height** in layers (5 layers = 250 um in the paper). |
| `DEFAULT_post_size_x_pixels` | 40 | Half-width of the wall between neighbouring channels. Interior walls are formed by two adjacent posts, so the finished wall is **twice** this value; the two outermost walls are exactly this value. |
| `DEFAULT_post_size_y_pixels` | 40 | Channel length per array cell. Total channel length = this x `array_cells_y`. |
| `array_cells_y` | 4 | Number of rows. With the defaults, channel length = 40 x 4 = 160 px. |

**The sweeps**

Both sweeps are always active. To vary only one, pin the other by setting its `min` and
`max` to the same value.

| Parameter | Default | Meaning |
|---|---|---|
| `SWEPT_A_label` | `"membrane_thickness_layers"` | Quantity swept along the columns. |
| `SWEPT_A_min` / `SWEPT_A_max` / `SWEPT_A_step` | 1 / 10 / 1 | Roof (membrane) thickness, 1-10 layers = 50-500 um. |
| `SWEPT_B_label` | `"post_height_layers"` | Quantity swept along the rows. |

Base thickness and the engraved labels can be edited directly; they do not affect the
measurement.

---

## functionality_device.scad

Adds the pneumatic control chamber above the membrane, and the optional raised seat
("doormat") with its spherical recess. `THROUGH_CHANNEL = true` selects the open-faced
form used in the paper, in which the flow channel runs clear through both Y faces so the
lumen can be imaged in transmitted light. `DEBUG_ARRAY_MODE` switches between a single
device and a strip of devices.

> **Legacy naming.** Several parameters are still called `default_cutout_*` for
> historical reasons. They set the dimensions of the **flow channel**, not of a cutout
> pocket; the blind-pocket ("cutout") variant this file grew out of has been retired.

**How many devices, and at what widths**

`DEBUG_ARRAY_MODE = 1` renders one device at the defaults below. `DEBUG_ARRAY_MODE = 0`
renders a strip, and the strip is defined by the width range rather than by a device
count: set the range and the interval, and the number of devices follows.

| Parameter | Default | Meaning |
|---|---|---|
| `WIDTH_SWEEP_ENABLE` | `true` | Drive the strip from the width range below. Set `false` to fall back to the generic `swept_param_1_*` sweep capped by `MAX_DEVICES_X`. |
| `WIDTH_MIN_PX` | 110 | Narrowest channel in the strip. |
| `WIDTH_MAX_PX` | 140 | Widest channel in the strip. |
| `WIDTH_STEP_PX` | 10 | Interval between neighbouring devices. |

So 60 / 120 / 10 emits seven devices at 60, 70, 80, 90, 100, 110 and 120 px, each
engraved with its own width (`CX60`, `CX70`, ...). If the range does not divide evenly
by the interval the last device stops short of `WIDTH_MAX_PX` and the console says so.
If the strip will not fit the build plate, the count is reduced and that is reported too
-- generate wide sweeps in batches.

**Devices are always emitted as a single row, and there is no row-count parameter.**
The lumen is imaged in transmitted light *through* the device along Y, so a device
placed behind another sits in its optical path and neither can be read. Butting devices
together along X is harmless, since nothing is imaged through X, so the whole sweep goes
there. To print more devices than fit one plate, run the width range in batches.

**Flow channel**

| Parameter | Default | Meaning |
|---|---|---|
| `default_cutout_x_size_in_pixels` | 150 | Channel width in px, used for the single-device mode and whenever the width sweep is off. The paper's valves run 60-120 px. |
| `default_cutout_y_size_in_pixels` | follows X | Channel length. With `SQUARE_CUTOUT` it tracks the width, which keeps the imaged region square. |
| `default_cutout_z_size_in_layers` | 5 | Channel height in layers: 5 for a plain square channel, 20 for doormat designs, so that the open gap above the doormat is again 5 layers. |

**Control chamber**

| Parameter | Default | Meaning |
|---|---|---|
| `default_membrane_cavity_x_pixel_multiple` | 170 | Chamber width. The paper uses channel width + 20 px. |
| `default_membrane_cavity_y_pixel_multiple` | 250 | Chamber length. |
| `MEMBRANE_CAVITY_Z_LAYERS` | 12 | Chamber height in layers. |

In through-channel mode the chamber can never exceed the lumen in Y: the block depth is
the chamber depth plus two wall pads while the lumen spans the whole block, so raising
the Y multiple simply grows the whole device.

**Valve seat**

`ENABLE_DOORMAT` and `DOORMAT_SPHERE_RADIUS` are independent, and all four combinations
build one of the geometries in Figure 10 of the paper:

| `ENABLE_DOORMAT` | `DOORMAT_SPHERE_RADIUS` | Geometry |
|---|---|---|
| `true` | > 0 | Raised doormat with a spherical recess in its top (Fig 10-CENTRE). **The configuration the paper characterises** -- every reported leak, burst and lifetime figure comes from it. |
| `true` | 0 | Plain raised doormat, no recess. |
| `false` | > 0 | Recess cut straight into the channel floor, no raised feature (Fig 10-RIGHT), removing the in-channel obstruction. Hypothesised in the paper but not built there. |
| `false` | 0 | Plain channel, no seat. |

**The seat derives itself from the closure model.** `DOORMAT_SPHERE_RADIUS = -1` (the default) computes the recess
radius and depth per device from `KAPPA`, the open lumen left above the seat, and that device's channel width, using the same
closed form the interactive design tool solves. The recess therefore spans the lumen by construction and rescales correctly
across a width sweep. A positive radius overrides the model with a fixed value in mm, which does *not* scale -- use it only to
reproduce a specific historical print. `0` removes the recess.

| Parameter | Default | Meaning |
|---|---|---|
| `KAPPA` | 0.075 | Membrane deflection coefficient s/C for **your** resin and process. Required only when the seat is derived. The default is the value measured for single-layer NanoClear membranes in the paper and will not transfer to another material. |

**In derived mode the control chamber is sized by the model too.** The closure model returns C, the width the deflected
membrane must have; the chamber is what clamps the membrane, so the chamber width is set to C rather than to
`cutout + MEMBRANE_MARGIN_PX`. That makes the arc's chord at the membrane plane coincide with the chamber walls, which is the
geometric condition the seat is solved for. It also makes the device a little wider than the fixed-margin version, and the
width follows the sweep. With an explicit radius the chamber falls back to the margin rule.

**You do not need `KAPPA` to start.** Print with `ENABLE_DOORMAT = false` -- a plain channel, no seat -- measure the sagitta
across a range of widths, and fit the slope: that measurement *is* kappa. Only then does the seated geometry mean anything,
which is why a derived recess is tied to the doormat being enabled. The console prints the full derivation per device (sagitta,
membrane width, radius, depth in mm and in layers) and warns if the required depth exceeds the seat thickness, which means the
doormat is too thin to contain the recess.

`DOORMAT_SPHERE_PENETRATION` is measured down from whichever surface carries the seat --
the doormat top when the doormat is on, the channel floor when it is off -- so a 0.5 mm
recess is 0.5 mm deep either way. The console states which of the four it built on every
render.

| Parameter | Default | Meaning |
|---|---|---|
| `DOORMAT_X_PIXELS` | `-1` | *(doormat only)* Seat width across the channel. **`-1` means match the lumen**, so the seat follows the width sweep automatically -- a 110 px device gets a 110 px seat. A positive value pins the seat to that fixed width on every device instead, which is only what you want if you deliberately need a seat narrower than the channel. With the default, looking through the lumen at seat height shows no opening: that is correct, the flow path runs *over* the seat, which is shorter than the channel is tall. |
| `DOORMAT_Y_PIXELS` | 72 | Seat length. |
| `DOORMAT_THICKNESS_LAYERS` | 3 | Seat height. Set it to `channel height - 5` layers to leave a 5-layer opening above the seat. |
| `DOORMAT_RAMP_ANGLE` | 45 | Chamfer on the seat edges: 45 for the plain doormat, 0 for the cut valve seat. |
| `DOORMAT_SPHERE_RADIUS` | 0.5 | Radius of the spherical recess cut into the seat, in mm. **0 disables the recess.** |
| `DOORMAT_SPHERE_PENETRATION` | 0.5 | Depth of that recess, in mm. |

The radius and penetration are not free parameters: they come from the interactive
design tool in the ESI, evaluated for the resin, printer and channel width in use. For
the framework reported in the paper a 60 px channel takes an effective sphere radius of
64.5 px with 0.25 um penetration. **A different printer, resin or exposure setting gives
different values** -- that is the entire point of measuring the membrane deflection
coefficient first.

---

## Reproducing the paper's devices

1. Set the pixel pitch and layer height to your printer.
2. Print the printability array and classify the channels to find your own printable
   width and roof-thickness window (Stage I).
3. Print the functionality device across widths inside that window and measure the
   membrane sagitta to fit the membrane deflection coefficient (Stage II).
4. Feed that coefficient into the design tool in the ESI to obtain the seat radius and
   penetration for your target channel, and set `DOORMAT_SPHERE_RADIUS` and
   `DOORMAT_SPHERE_PENETRATION` accordingly (Stage III).

## Licence

[PLACEHOLDER: choose on upload -- CC-BY-4.0 is conventional for CAD geometry, MIT or
BSD-3-Clause if you prefer to treat the .scad as source code.]

## Versioning and citation

Each tagged release here is archived to Zenodo automatically. Zenodo issues two kinds of
DOI: one per version, and one "concept" DOI that always resolves to the newest version.
**Cite the concept DOI** -- that way a later bug fix reaches anyone following the
reference, rather than freezing them on the release that was current at press time.

If you use these files, please cite both the paper and this deposit:

[PLACEHOLDER: paper citation once published]
[PLACEHOLDER: Zenodo concept DOI once the first release is archived]

## Reporting problems

Please open an issue on this repository. Fixes go out as a new tagged release, which
Zenodo archives as a new version under the same concept DOI.

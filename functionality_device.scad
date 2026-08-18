// ===============================================================================
// MEMBRANE DEVICE — V30 FIXED WITH DOORMAT HALF-VIEW PROPERLY SCOPED
// ===============================================================================
//
// REORGANIZED VERSION - ALL USER INPUTS AT TOP
//
// This version places all user-configurable parameters at the top of the file
// with comprehensive documentation for easy modification.
//
// Fix pack:
// - Half-view cutter ONLY affects doormat visibility, not entire device
// - Y-min/Y-max horizontal ports: epsilon over-travel to prevent coplanar artifacts
// - Doormats properly preserved with correct CSG operations
// - Z-limited pads with z_guard to avoid coplanar faces
// - Higher $fn for smoother cylinders
// - DEBUG_ARRAY_MODE = 1 now shows EXACT user defaults (no parameter sweep)
// - Complete port routing flexibility: all 4 ports independently configurable
// - All membrane cavities maintain TWO ports for effective flushing
// - User-controllable Y-padding thickness overrides (front/back)
// - Diagonal bracing supports under front overhang (print-support-free)
//
// ===============================================================================


// ===============================================================================
// ================================
// DEBUG CONFIGURATION
// ================================
// ===============================================================================

// DEBUG_ECHO: Master debug control - set to true to enable extensive console 
// logging of all dimensions, calculations, and geometry operations. When enabled,
// every major calculation will echo its values to the console for verification.
// Set to false for production to minimize console output.
DEBUG_ECHO = true;

// DEBUG_ARRAY_MODE: Controls how many devices are rendered and with what parameters
//   0 = FULL ARRAY MODE: Renders maximum number of devices that fit on build plate
//       with full parameter sweep (swept_param_1 and swept_param_2)
//   1 = SINGLE DEVICE MODE: Renders exactly ONE device using your exact default 
//       parameters (no parameter sweep). Use this for testing specific configurations.
//   2 = 2x2 GRID MODE: Renders 4 devices (2x2 grid) showing min/max values of 
//       swept parameters. Useful for quick parameter range visualization.
DEBUG_ARRAY_MODE = 0;

// CONFIGURATION_SETTING: Currently set to "solid" for full device rendering.
// This parameter is available for future configuration options.
CONFIGURATION_SETTING = "solid";


// ===============================================================================
// ================================
// USER PARAMETERS - DEVICE CONFIGURATION
// ================================
// ===============================================================================

// ---------------------
// ARRAY SPACING PARAMETERS
// ---------------------
// These parameters control the minimum gap between adjacent devices when 
// rendering arrays on the build plate.

// MIN_GAP_X_MM: Minimum spacing between devices in X direction (mm)
// Ensures devices don't touch and allows for support removal and handling
MIN_GAP_X_MM = 0.01;

// MIN_GAP_Y_MM: Minimum spacing between devices in Y direction (mm)
// Ensures devices don't touch and allows for support removal and handling
MIN_GAP_Y_MM = 0.5;



// ---------------------
// THROUGH-CHANNEL CONFIGURATION  (added for the published device)
// ---------------------
// The devices reported in the paper are imaged in transmitted light, which needs
// an unobstructed optical path straight through the lumen. THROUGH_CHANNEL builds
// the flow channel as a slot that runs the full device depth and opens on BOTH the
// Y-min and Y-max faces, rather than as two blind pockets sharing a back wall.
//
//   true  = one through-channel per device, open front and back (PUBLISHED DEVICE)
//   false = original behaviour: blind pockets alternating front/back face
//
// NOTE: doormat features are cut away by the through-slot, so THROUGH_CHANNEL is
// meant to be used with ENABLE_DOORMAT = false (or a zero-thickness doormat).
THROUGH_CHANNEL = true;

// SQUARE_CUTOUT: force the cutout length (Y) to equal its width (X).
// Every device is then a scaled copy of every other, which is what makes the
// membrane deflection coefficient kappa = s/C a single constant across widths.
// Setting this false lets width and length vary independently, which changes the
// membrane aspect ratio from device to device -- see the paper's limitations section.
SQUARE_CUTOUT = true;

// MEMBRANE_MARGIN_PX: control chamber size = cutout size + this margin, in X and Y.
// Set to -1 to fall back to the explicit membrane-cavity parameters below.
MEMBRANE_MARGIN_PX = 20;

// ---------------------------------------------------------------------------
// CHANNEL-WIDTH SWEEP (drives how many devices are emitted along X)
// ---------------------------------------------------------------------------
// Set the range of channel widths you want and the interval between them; the
// number of devices in the strip follows from that. e.g. 60 -> 120 in steps of 10
// emits seven devices at 60, 70, 80, 90, 100, 110, 120 px, each labelled with its
// own width. This replaces having to work out a device count by hand.
//
// Applies when DEBUG_ARRAY_MODE = 0. A full 1-150 px sweep is slow to render and
// slow to print, so generate the series in batches if you need all of it.
WIDTH_SWEEP_ENABLE = true;
WIDTH_MIN_PX       = 110;   // [px] narrowest channel in the strip
WIDTH_MAX_PX       = 140;   // [px] widest channel in the strip
WIDTH_STEP_PX      = 10;    // [px] interval between neighbouring devices

// MAX_DEVICES_X: only used when WIDTH_SWEEP_ENABLE = false, in which case the strip
// is driven by swept_param_1_* below and capped at this many columns.
MAX_DEVICES_X = 4;

// Devices are always emitted as a SINGLE ROW along X. There is deliberately no
// row-count parameter: the lumen runs clear through both Y faces so it can be imaged
// in transmitted light along Y, which means a device placed behind another sits
// directly in its optical path and neither can be read. Butting devices together
// along X is harmless -- nothing is imaged through X -- so the whole sweep goes there.
// To print more devices than fit one plate, run the width range in batches.

// THROUGH_CHANNEL_Y_PAD_MM: wall left in front of and behind the control chamber.
// In through-channel mode the device depth is set by the CHAMBER (membrane cavity)
// plus this wall on each side -- not by the cutout -- because the chamber is the
// part that has to hold pressure. Too small and the chamber opens onto the face.
THROUGH_CHANNEL_Y_PAD_MM = 0.2;
assert(!THROUGH_CHANNEL || THROUGH_CHANNEL_Y_PAD_MM > 0, "ERROR: THROUGH_CHANNEL_Y_PAD_MM must be > 0 - it alone walls the control chamber off from the Y faces in through-channel mode.");

// ---------------------
// CUTOUT CONFIGURATION
// ---------------------

// num_cutouts_per_face: Number of cutouts on EACH face (front and back)
// Total device cutouts = 2 × num_cutouts_per_face
// Example: If set to 5, device will have 5 front cutouts + 5 back cutouts = 10 total
// Front cutouts are indexed as EVEN numbers (0, 2, 4, 6, 8...)
// Back cutouts are indexed as ODD numbers (1, 3, 5, 7, 9...)
num_cutouts_per_face = 1;

// CREATE_MICROSCOPE_VIEWPORTS: Enable/disable viewing windows on back face
// true = Creates transparent viewing ports above BACK face cutouts for microscopy
// false = Solid material above back cutouts (no viewing access)
// These viewports allow optical access to membrane cavities from above
CREATE_MICROSCOPE_VIEWPORTS = false;


// ---------------------
// CUTOUT STYLE CONFIGURATION
// ---------------------
// Each face can have a different cutout style to optimize for specific use cases

// FRONT_FACE_CUTOUT_STYLE: Style for all FRONT (Y-min) face cutouts
//   "VALVE_SEAT" = Creates cavity with raised doormat feature (elastic membrane seal)
//                  Best for pressure-sensitive applications requiring valve action
//   "SQUEEZE"    = Simple cavity without doormat (flat bottom)
//                  Best for direct compression or simpler membrane mechanics
FRONT_FACE_CUTOUT_STYLE = "VALVE_SEAT";

// BACK_FACE_CUTOUT_STYLE: Style for all BACK (Y-max) face cutouts
//   "VALVE_SEAT" = Creates cavity with raised doormat feature (elastic membrane seal)
//   "SQUEEZE"    = Simple cavity without doormat (flat bottom)
BACK_FACE_CUTOUT_STYLE  = "SQUEEZE";


// ---------------------
// PORT ROUTING CONFIGURATION
// ---------------------
// Each membrane cavity has TWO ports for effective flushing. These parameters
// control where each port exits the device. This allows routing ports away from
// crowded device faces or positioning them for specific experimental setups.

// FRONT FACE PORT ROUTING (for all FRONT/even-numbered cutouts):

// UPPER_CHAMBER_PORT_1_DIRECTION: First horizontal port routing for FRONT face
//   "Y_MIN" = Port exits through FRONT side (Y-min face) - DEFAULT
//             Use this for traditional front-side access
//   "Y_MAX" = Port exits through BACK side (Y-max face)
//             Use this to move port away from front, useful if front is crowded
UPPER_CHAMBER_PORT_1_DIRECTION = "Z_MAX";

// UPPER_CHAMBER_PORT_2_DIRECTION: Second port routing for FRONT face (flushing port)
//   "Z_MAX" = Port exits upward through TOP surface - DEFAULT
//             Provides independent access from above, good for gravity-fed systems
//   "Y_MAX" = Port exits through BACK side (Y-max face)
//             Use this to consolidate all ports on back face for cleaner front
UPPER_CHAMBER_PORT_2_DIRECTION = "Z_MAX";

// BACK FACE PORT ROUTING (for all BACK/odd-numbered cutouts):

// LOWER_CHAMBER_PORT_1_DIRECTION: First horizontal port routing for BACK face
//   "Y_MAX" = Port exits through BACK side (Y-max face) - DEFAULT
//             Standard back-side access
//   "Y_MIN" = Port exits through FRONT side (Y-min face)
//             Use this to move port to front side if back is crowded
LOWER_CHAMBER_PORT_1_DIRECTION = "Y_MIN";

// LOWER_CHAMBER_PORT_2_DIRECTION: Second port routing for BACK face (flushing port)
//   "Z_MIN" = Port exits downward through BOTTOM surface - DEFAULT
//             Provides drainage access from below, good for gravity drainage
//   "Y_MIN" = Port exits through FRONT side (Y-min face)
//             Use this to consolidate all ports on front face for cleaner back
LOWER_CHAMBER_PORT_2_DIRECTION = "Z_MIN";

// ---------------------
// PORT ROLES
// ---------------------
// Designate each port as "inlet" or "outlet".
// Inlets use MIN_INLET_STUB_LENGTH; outlets use MIN_OUTLET_STUB_LENGTH.
UPPER_CHAMBER_PORT_1_ROLE  = "outlet";   // horizontal port on Y-min face
UPPER_CHAMBER_PORT_2_ROLE = "inlet";  // Z-max or Y-max flushing port (front)
LOWER_CHAMBER_PORT_1_ROLE   = "outlet";  // horizontal port on Y-max face
LOWER_CHAMBER_PORT_2_ROLE  = "inlet";   // Z-min or Y-min flushing port (back)

// ---------------------
// NEEDLE PORT DIMENSIONS

// ---------------------
// NEEDLE PORT DIMENSIONS
// ---------------------
// These parameters define the physical size of fluid access ports

// INLET_PORT_DIAMETER: Diameter of inlet ports (mm)
// Typical range: 0.4-1.0mm for microfluidics
INLET_PORT_DIAMETER  = 1.2;
// OUTLET_PORT_DIAMETER: Diameter of outlet ports (mm)
OUTLET_PORT_DIAMETER = 0.68;

// Conservative bound used for structural/validation calculations
MAX_PORT_DIAMETER = max(INLET_PORT_DIAMETER, OUTLET_PORT_DIAMETER);

// Returns port diameter for a given role
function port_diameter(role) =
    (role == "outlet") ? OUTLET_PORT_DIAMETER : INLET_PORT_DIAMETER;

// MIN_INLET_STUB_LENGTH: Minimum wall thickness for INLET ports (mm)
MIN_INLET_STUB_LENGTH  = 0.1;
// MIN_OUTLET_STUB_LENGTH: Minimum wall thickness for OUTLET ports (mm)
MIN_OUTLET_STUB_LENGTH = 0.1;

// Returns stub length for a given port role
function port_stub(role) =
    (role == "outlet") ? MIN_OUTLET_STUB_LENGTH : MIN_INLET_STUB_LENGTH;


// ---------------------
// Y-PADDING OVERRIDE CONTROLS
// ---------------------
// By default, the device automatically calculates Y-padding (front and back)
// based on membrane overhang and port requirements. These overrides let you
// manually specify exact padding thicknesses when needed.

// YMIN_PADDING_Y_THICKNESS: Override for front (Y-min) padding thickness
//   -1 = AUTO (default) - Device calculates based on membrane size and port requirements
//   >0 = Manual override in millimeters - Use this value exactly regardless of calculations
//        Example: Set to 2.0 to force exactly 2.0mm of front padding
// Auto calculation ensures: max(port_stub(role), membrane_overhang + MAX_PORT_DIAMETER/2)
YMIN_PADDING_Y_THICKNESS = 0;

// YMAX_PADDING_Y_THICKNESS: Override for back (Y-max) padding thickness
//   -1 = AUTO (default) - Device calculates based on membrane size and port requirements
//   >0 = Manual override in millimeters - Use this value exactly regardless of calculations
//        Example: Set to 3.5 to force exactly 3.5mm of back padding
// Auto calculation ensures: max(port_stub(role), membrane_overhang + MAX_PORT_DIAMETER/2)
YMAX_PADDING_Y_THICKNESS = 0;


// ---------------------
// DIAGONAL BRACING SUPPORTS
// ---------------------
// When front padding extends beyond the device core (membrane overhang),
// it creates an unsupported horizontal surface that may sag during printing.
// Diagonal braces provide self-supporting triangular reinforcement.

// ENABLE_DIAGONAL_BRACES: Enable/disable diagonal support structures
//   true  = Add triangular wedge braces under front padding overhang
//           Braces span from device bottom to membrane plane at 45° angle
//           One brace per gap between front cutouts (no braces under cutouts)
//   false = No diagonal braces (may cause front padding to sag on printer)
ENABLE_DIAGONAL_BRACES = false;

// DIAGONAL_BRACE_WIDTH: Legacy parameter (mm) - kept for API compatibility
// With the new wedge-based bracing system, this parameter is no longer used
// for geometry but is retained to avoid breaking existing code that passes it.
// The actual brace width is now auto-calculated based on gap widths.
DIAGONAL_BRACE_WIDTH = 0.32;


// ===============================================================================
// ================================
// USER PARAMETERS - CUTOUT SIZE DEFAULTS (in printer-native units)
// ================================
// ===============================================================================

// These are the DEFAULT sizes for cutouts when DEBUG_ARRAY_MODE = 1 (single device)
// or when parameter sweep doesn't override them.
//
// IMPORTANT: Sizes are specified in PRINTER-NATIVE UNITS:
//   - X and Y dimensions use PIXELS (converted via PIXEL_SIZE_CONST)
//   - Z dimensions use LAYERS (converted via LAYER_THICKNESS_CONST)
//
// The actual mm size = value × printer constant
// See PRINTER CONFIGURATION section below for current printer constants

// default_cutout_x_size_in_pixels: Cutout width in X direction (pixels)
// This is the horizontal width of each squeeze cavity
// Example: 80 pixels × 0.032mm/pixel = 2.56mm width
default_cutout_x_size_in_pixels = 150;

// default_cutout_y_size_in_pixels: Cutout depth in Y direction (pixels)
// NOTE (through-channel mode): the lumen is a SLOT that spans the full device
// depth so light can pass through, so this no longer sets the lumen length. It
// sets the doormat/seat footprint in Y and feeds the block sizing.
// Example: 60 pixels × 0.032mm/pixel = 1.92mm depth
// Must be ≥ MAX_PORT_DIAMETER to fit horizontal ports
default_cutout_y_size_in_pixels = SQUARE_CUTOUT ? default_cutout_x_size_in_pixels : 100;

// default_cutout_z_size_in_layers: Cutout height in Z direction (layers)
// This is the vertical height of the squeeze cavity
// Example: 25 layers × 0.050mm/layer = 1.25mm height
default_cutout_z_size_in_layers = 5;


// ===============================================================================
// ================================
// USER PARAMETERS - DOORMAT CONFIGURATION
// ================================
// ===============================================================================

// The doormat is a raised feature at the bottom of VALVE_SEAT style cutouts.
// It creates an elastic seal that can act as a pressure-sensitive valve.

// ENABLE_DOORMAT and DOORMAT_SPHERE_RADIUS are independent, and all four
// combinations build something real (see Figure 10 of the paper):
//
//   doormat ON,  sphere > 0  -> raised seat with a spherical recess in its top
//                               (Fig 10-CENTRE). What the paper characterises; every
//                               reported leak, burst and lifetime figure comes from it.
//   doormat ON,  sphere = 0  -> plain raised seat, no recess.
//   doormat OFF, sphere > 0  -> recess cut straight into the channel floor, with no
//                               raised feature (Fig 10-RIGHT). Hypothesised in the
//                               paper but not built there.
//   doormat OFF, sphere = 0  -> plain channel, no seat.
//
// DOORMAT_SPHERE_PENETRATION is measured down from whichever surface carries the seat --
// the doormat top when the doormat is on, the channel floor when it is off -- so a
// 0.5 mm recess is 0.5 mm deep either way.
//
// ENABLE_DOORMAT: master enable for the raised doormat feature
//   true  = Create doormat features in all VALVE_SEAT style cutouts
//   false = All cutouts are simple cavities (no raised features)
ENABLE_DOORMAT             = false;

// DOORMAT_HALF_VIEW_ENABLE: Visualization control for doormat features
//   true  = Cut away half of doormat for cross-section view (visualization only)
//           Only the Y-min half is removed, showing internal structure
//           DOES NOT affect device structure, only doormat visibility
//   false = Full doormat rendered (production setting)
DOORMAT_HALF_VIEW_ENABLE   = true;

// DOORMAT_X_PIXELS: seat width across the channel (the X direction), in pixels.
//
//   -1 (the default)  = MATCH THE LUMEN. The seat spans the full channel width, so it
//                       follows the width sweep automatically: a 110 px device gets a
//                       110 px seat, a 140 px device gets a 140 px seat. This is the
//                       normal case -- a seat narrower than the channel leaves an open
//                       gap down each side of it for fluid to bypass.
//   a positive value  = FIXED width in pixels, independent of the channel width. Use
//                       this only when you deliberately want a seat narrower than the
//                       lumen; it does NOT scale with WIDTH_MIN_PX/WIDTH_MAX_PX.
//
// Note for anyone checking the render: with the default, looking straight through the
// lumen at seat height shows no opening, because the seat spans the full width. That is
// correct -- the flow path runs OVER the seat (the channel is taller than the seat), not
// around it. Only a seat taller than the channel would actually block the lumen.
DOORMAT_X_PIXELS           = -1;

// DOORMAT_Y_PIXELS: Doormat depth in Y direction (pixels)
// Should span most of cutout depth but leave clearance at walls
// Example: 72 pixels × 0.032mm = 2.304mm depth
DOORMAT_Y_PIXELS           = 72;

// DOORMAT_THICKNESS_LAYERS: Doormat height in Z direction (layers)
// This is how far the raised platform extends up from cutout bottom
// Thicker = stiffer seal, Thinner = more compliant valve action
// Example: 20 layers × 0.050mm = 1.0mm thickness
DOORMAT_THICKNESS_LAYERS   = 3;

// DOORMAT_RAMP_ANGLE: Angle of tapered sides (degrees from vertical)
//   0  = Vertical walls (no taper) - maximum material
//   >0 = Angled walls sloping outward toward bottom
//        Example: 35° creates gradual taper for easier demolding
//        Larger angles = more taper = easier to print overhang
DOORMAT_RAMP_ANGLE         = 45;

// KAPPA: the membrane deflection coefficient, s/C -- the dimensionless sagitta-to-width
// ratio of the deflected membrane, measured on YOUR resin, printer and exposure recipe.
//
// You do not need it to run this device the first time. Print with ENABLE_DOORMAT = false,
// measure the sagitta of the plain membranes across a range of widths, and fit the slope
// of s against C; that measurement IS kappa. Only once it is known does the seat below
// become meaningful, which is why kappa is required only when the doormat is enabled.
//
// 0.075 is the value measured for single-layer NanoClear membranes at a 5-layer channel
// height in the accompanying paper. It is specific to that material and process -- it
// will not transfer to yours.
KAPPA = 0.075;

// DOORMAT_SPHERE_RADIUS: radius of the spherical seat recess, in mm.
//   -1 (the default) = DERIVE IT from the closure model, per device, from KAPPA, the open
//                      lumen above the seat, and that device's channel width. The recess
//                      then scales correctly across a width sweep, and its width at the
//                      seat top comes out equal to the channel width by construction.
//    0               = no recess (flat or ramped seat top, per DOORMAT_RAMP_ANGLE).
//   >0               = fixed radius in mm, ignoring the closure model. Use this only to
//                      reproduce a specific historical print; it does NOT scale with the
//                      width sweep, so on a multi-width strip it is right for at most one
//                      device.
DOORMAT_SPHERE_RADIUS      = -1;

// DOORMAT_SPHERE_PENETRATION: depth of the recess below the seat top, in mm.
//   -1 (the default) = derive alongside the radius (this is s - g, the distance the
//                      membrane travels past the seat top).
//   >0               = fixed depth in mm; only used when DOORMAT_SPHERE_RADIUS > 0.
DOORMAT_SPHERE_PENETRATION = -1;


// ===============================================================================
// ================================
// USER PARAMETERS - MEMBRANE CAVITY DEFAULTS (in printer-native units)
// ================================
// ===============================================================================

// Membrane cavities are the horizontal chambers between cutouts that contain
// the actual flexible membrane. They define the active membrane area.

// default_membrane_cavity_x_pixel_multiple: Membrane width multiplier (pixels)
// Defines how wide the membrane chamber extends in X direction
// Can be larger than cutout to provide membrane overlap/strain relief
// Example: 100 pixels × 0.032mm = 3.2mm membrane width
// If larger than cutout_x, creates overhang requiring front/back padding
default_membrane_cavity_x_pixel_multiple = 170;

// default_membrane_cavity_y_pixel_multiple: Membrane depth in Y direction (pixels)
// Should match or slightly exceed cutout_y for proper sealing
// Example: 60 pixels × 0.032mm = 1.92mm membrane depth
default_membrane_cavity_y_pixel_multiple = 250 ;

// default_membrane_z_thickness_layer_multiple: Membrane thickness (layers)
// This is the Z-thickness of the flexible membrane itself (NOT the cavity height)
// Thinner = more flexible/compliant, Thicker = stiffer/more robust
// Example: 2 layers × 0.050mm = 0.1mm membrane thickness
default_membrane_z_thickness_layer_multiple = 1;


// ---------------------
// MEMBRANE CAVITY CONFIGURATION
// ---------------------

// MEMBRANE_CAVITY_Z_LAYERS: Membrane cavity chamber height (layers)
// This is the vertical height of the chamber above/below the membrane
// Provides space for membrane deflection under pressure
// Example: 12 layers × 0.050mm = 0.6mm chamber height
MEMBRANE_CAVITY_Z_LAYERS = 12;


// ===============================================================================
// ================================
// USER PARAMETERS - BLOCK Z-PADDING
// ================================
// ===============================================================================

// These parameters add solid material above and below the membrane cavities
// to ensure adequate structural support and port clearance.

// BLOCK_Z_PADDING_TOP_IN_LAYERS: Solid material above highest feature (layers)
// Ensures top surface has adequate thickness for:
//   - Structural integrity
//   - Z-max port exit holes
//   - Handling during demolding
// Example: 10 layers × 0.050mm = 0.5mm top cap
BLOCK_Z_PADDING_TOP_IN_LAYERS    = 10;

// BLOCK_Z_PADDING_BOTTOM_IN_LAYERS: Solid material below lowest feature (layers)
// Ensures bottom surface has adequate thickness for:
//   - Structural base
//   - Z-min port exit holes  
//   - Build plate adhesion during printing
// Example: 10 layers × 0.050mm = 0.5mm bottom base
BLOCK_Z_PADDING_BOTTOM_IN_LAYERS = 15;


// ===============================================================================
// ================================
// USER PARAMETERS - WALL THICKNESS
// ================================
// ===============================================================================

// WALL_THICKNESS_X_PIXELS: Wall thickness between cutouts in X direction (pixels)
// This is the solid material separating adjacent cutouts
// Must be thick enough for:
//   - Structural integrity (prevent collapse between chambers)
//   - Printability (minimum feature size)
//   - Sealing (prevent cross-talk between adjacent membranes)
// Example: 10 pixels × 0.032mm = 0.32mm wall thickness
WALL_THICKNESS_X_PIXELS          = 20;


// ===============================================================================
// ================================
// USER PARAMETERS - PARAMETER SWEEP CONFIGURATION
// ================================
// ===============================================================================

// Parameter sweep allows rendering multiple devices with systematically varied
// dimensions to explore design space. Only active when DEBUG_ARRAY_MODE = 0 or 2.

// ---------------------
// PARAMETER INDEX DEFINITIONS
// ---------------------
// These constants define which parameter each index refers to.
// Use these values for swept_param_1_idx and swept_param_2_idx below.

// Available parameters to sweep:
//   PARAM_MEMBRANE_X = 0  : Membrane cavity width (pixels → mm)
//   PARAM_MEMBRANE_Y = 1  : Membrane cavity depth (pixels → mm)
//   PARAM_MEMBRANE_Z = 2  : Membrane thickness (layers → mm)
//   PARAM_CUTOUT_X   = 3  : Cutout width (pixels → mm)
//   PARAM_CUTOUT_Y   = 4  : Cutout depth (pixels → mm)
//   PARAM_CUTOUT_Z   = 5  : Cutout height (layers → mm)
PARAM_MEMBRANE_X = 0;
PARAM_MEMBRANE_Y = 1;
PARAM_MEMBRANE_Z = 2;
PARAM_CUTOUT_X   = 3;
PARAM_CUTOUT_Y   = 4;
PARAM_CUTOUT_Z   = 5;


// ---------------------
// FIRST SWEPT PARAMETER
// ---------------------

// swept_param_1_idx: Which parameter to vary across COLUMNS
// Set to one of the PARAM_* constants above
// Example: 3 = PARAM_CUTOUT_X (vary cutout width across columns)
swept_param_1_idx   = 3;

// swept_param_1_min: Minimum value for parameter 1 (in native units)
// For PIXEL parameters: value in pixels
// For LAYER parameters: value in layers
// Example: 30 pixels minimum cutout width
swept_param_1_min   = 110;

// swept_param_1_max: Maximum value for parameter 1 (in native units)
// For PIXEL parameters: value in pixels
// For LAYER parameters: value in layers
// Example: 50 pixels maximum cutout width
swept_param_1_max   = 140;

// swept_param_1_steps: Number of steps to divide range into
// Devices will be spaced evenly across columns with this many discrete values
// Example: 4 steps gives values at 30, 36.67, 43.33, 50 pixels
swept_param_1_steps = 4;


// ---------------------
// SECOND SWEPT PARAMETER
// ---------------------

// swept_param_2_idx: Which parameter to vary across ROWS
// Set to one of the PARAM_* constants above (should differ from param_1)
// Example: 4 = PARAM_CUTOUT_Y (vary cutout depth across rows)
swept_param_2_idx   = 4;

// swept_param_2_min: Minimum value for parameter 2 (in native units)
// For PIXEL parameters: value in pixels
// For LAYER parameters: value in layers
// Example: 30 pixels minimum cutout depth
swept_param_2_min   = 30;

// swept_param_2_max: Maximum value for parameter 2 (in native units)
// For PIXEL parameters: value in pixels
// For LAYER parameters: value in layers
// Example: 45 pixels maximum cutout depth
swept_param_2_max   = 45;

// swept_param_2_steps: Number of steps to divide range into
// Devices will be spaced evenly across rows with this many discrete values
// Example: 3 steps gives values at 30, 37.5, 45 pixels
swept_param_2_steps = 3;


// ===============================================================================
// DERIVED SWEEP VALUES  (do not edit -- computed from the knobs above)
// ===============================================================================
// When WIDTH_SWEEP_ENABLE is on, the first swept parameter is forced to channel
// width and its range comes from WIDTH_MIN_PX / WIDTH_MAX_PX / WIDTH_STEP_PX.
// WIDTH_SWEEP_N is both the number of steps and the number of devices, so the
// interpolation in get_param_val_with_cycling() lands exactly on the requested
// widths (min, min+step, ... , max) with no rounding drift.
WIDTH_SWEEP_N = WIDTH_SWEEP_ENABLE
    ? max(1, floor((WIDTH_MAX_PX - WIDTH_MIN_PX) / WIDTH_STEP_PX) + 1)
    : 1;

// Largest width actually emitted -- WIDTH_MAX_PX is only reached when the range
// divides evenly by the interval (60->120 step 10 reaches 120; step 7 stops at 116).
WIDTH_SWEEP_LAST_PX = WIDTH_MIN_PX + (WIDTH_SWEEP_N - 1) * WIDTH_STEP_PX;

SWEEP1_idx   = WIDTH_SWEEP_ENABLE ? PARAM_CUTOUT_X      : swept_param_1_idx;
SWEEP1_min   = WIDTH_SWEEP_ENABLE ? WIDTH_MIN_PX        : swept_param_1_min;
SWEEP1_max   = WIDTH_SWEEP_ENABLE ? WIDTH_SWEEP_LAST_PX : swept_param_1_max;
SWEEP1_steps = WIDTH_SWEEP_ENABLE ? WIDTH_SWEEP_N       : swept_param_1_steps;

// Columns requested: the width sweep decides, otherwise the manual cap does.
REQUESTED_COLS = WIDTH_SWEEP_ENABLE ? WIDTH_SWEEP_N : MAX_DEVICES_X;

// Defined here rather than up beside ENABLE_DOORMAT: OpenSCAD evaluates top-level
// assignments in file order, so reading the DOORMAT_SPHERE_* parameters before they are
// assigned yields undef and silently disables the seat.
// 0 switches the recess off; -1 derives it from the closure model; >0 is an explicit radius.
//
// A DERIVED recess belongs to the seated design, which only exists once kappa is known, so
// it is tied to the doormat: with the doormat off, -1 means "no recess" and you get a plain
// channel -- exactly what you want for the kappa measurement itself, and kappa is then never
// consulted. An EXPLICIT radius still works with the doormat off, which is how you get the
// recess-cut-straight-into-the-floor variant.
SEAT_SPHERE_DERIVED = DOORMAT_SPHERE_RADIUS < 0 && ENABLE_DOORMAT;
SEAT_SPHERE_ENABLED = DOORMAT_SPHERE_RADIUS > 0 || SEAT_SPHERE_DERIVED;

assert(!(SEAT_SPHERE_ENABLED && SEAT_SPHERE_DERIVED) || KAPPA > 0,
       str("KAPPA = ", KAPPA, " but the spherical seat is set to derive itself from the ",
           "closure model. Either measure kappa first (print with ENABLE_DOORMAT = false, ",
           "fit the sagitta against the membrane width) and set it here, or set ",
           "DOORMAT_SPHERE_RADIUS to an explicit radius in mm, or to 0 for no recess."));

assert(!(SEAT_SPHERE_ENABLED && !SEAT_SPHERE_DERIVED) || DOORMAT_SPHERE_PENETRATION > 0,
       str("DOORMAT_SPHERE_RADIUS = ", DOORMAT_SPHERE_RADIUS, " is an explicit radius, so ",
           "DOORMAT_SPHERE_PENETRATION must be an explicit depth in mm too, but it is ",
           DOORMAT_SPHERE_PENETRATION, ". Set both explicitly, or set the radius to -1 to ",
           "derive both from the closure model."));

// The strip is a single row, so the row-wise sweep has nowhere to vary: every device
// would silently receive swept_param_2_min. Ignore it in that mode (the affected
// dimensions fall back to their documented defaults) rather than applying a value the
// user never asked every device to have. It still works in the 2x2 preview (mode 2).
SWEEP2_idx = (DEBUG_ARRAY_MODE == 0) ? -1 : swept_param_2_idx;

if (DEBUG_ARRAY_MODE == 0 && swept_param_2_min != swept_param_2_max)
    echo(str("*** NOTE: swept_param_2 (", code_of(swept_param_2_idx), ", ",
             swept_param_2_min, " to ", swept_param_2_max, ") is ignored -- devices are ",
             "emitted as a single row along X, so there is no row axis to sweep. Width ",
             "varies via WIDTH_MIN_PX/WIDTH_MAX_PX/WIDTH_STEP_PX; anything else keeps its ",
             "default value."));

echo(str("  Seat configuration: doormat ", ENABLE_DOORMAT ? "ON" : "OFF",
         ", spherical recess ",
         !SEAT_SPHERE_ENABLED ? "OFF"
           : SEAT_SPHERE_DERIVED
             ? str("derived per device from kappa=", KAPPA, ", cut into the doormat top")
             : str("r=", DOORMAT_SPHERE_RADIUS, " mm, ", DOORMAT_SPHERE_PENETRATION,
                   " mm deep into the ", ENABLE_DOORMAT ? "doormat top" : "channel floor")));

assert(WIDTH_STEP_PX > 0,
       str("WIDTH_STEP_PX = ", WIDTH_STEP_PX, " -- the interval must be positive. ",
           "Set WIDTH_STEP_PX to the spacing you want between devices, or set ",
           "WIDTH_SWEEP_ENABLE = false to drive the strip from swept_param_1_* instead."));

assert(WIDTH_MAX_PX >= WIDTH_MIN_PX,
       str("WIDTH_MAX_PX = ", WIDTH_MAX_PX, " is below WIDTH_MIN_PX = ", WIDTH_MIN_PX,
           ". Swap them, or set WIDTH_MIN_PX = WIDTH_MAX_PX for a single device."));



// ===============================================================================
// ================================
// USER PARAMETERS - PRINTER CONFIGURATION
// ================================
// ===============================================================================

// This section defines physical printer capabilities. The code supports multiple
// printers with different resolutions and build volumes. Select which printer
// to use via SELECTED_PRINTER index.

// SELECTED_PRINTER: Which printer configuration to use (0-based index)
//   0 = First printer in arrays below (larger build volume, coarser resolution)
//   1 = Second printer in arrays below (smaller build volume, finer resolution)
// Add more printer configs by expanding arrays and incrementing index
SELECTED_PRINTER = 1;

// ---------------------
// PRINTER BUILD PLATE DIMENSIONS
// ---------------------
// These arrays store the build plate size for each printer.
// Array index corresponds to SELECTED_PRINTER value.

// PRINTER_BUILD_PLATE_X_SIZES: Build plate width (X direction) for each printer (mm)
//   Index 0: 175.49mm - Larger printer X dimension
//   Index 1: 120.76mm - Smaller/finer printer X dimension
// When SELECTED_PRINTER = 1, the value 120.76mm is used
PRINTER_BUILD_PLATE_X_SIZES = [175.49, 120.76];

// PRINTER_BUILD_PLATE_Y_SIZES: Build plate depth (Y direction) for each printer (mm)
//   Index 0: 98.75mm - Larger printer Y dimension
//   Index 1: 67.94mm - Smaller/finer printer Y dimension
// When SELECTED_PRINTER = 1, the value 67.94mm is used
PRINTER_BUILD_PLATE_Y_SIZES = [98.75,  67.94];


// ---------------------
// PRINTER RESOLUTION PARAMETERS
// ---------------------
// These arrays store the resolution characteristics for each printer.

// PRINTER_PIXEL_SIZES: XY resolution (mm per pixel) for each printer
//   Index 0: 0.065mm/pixel - Larger printer, coarser XY resolution
//   Index 1: 0.032mm/pixel - Smaller printer, finer XY resolution
// This value converts PIXEL-based dimensions to millimeters
// Example: 80 pixels × 0.032mm/pixel = 2.56mm
// Lower values = finer resolution = smoother features
PRINTER_PIXEL_SIZES         = [0.065,   0.032];

// PRINTER_LAYER_THICKNESSES: Z resolution (mm per layer) for each printer
//   Index 0: 0.020mm/layer - Larger printer, finer Z resolution (thinner layers)
//   Index 1: 0.050mm/layer - Smaller printer, coarser Z resolution (thicker layers)
// This value converts LAYER-based dimensions to millimeters
// Example: 25 layers × 0.050mm/layer = 1.25mm
// Lower values = finer Z resolution = smoother vertical features but longer print time
PRINTER_LAYER_THICKNESSES   = [0.020,   0.050];


// ===============================================================================
// ================================
// USER PARAMETERS - PHYSICAL MARKS CONFIGURATION
// ================================
// ===============================================================================

// Physical marks are text labels embossed or engraved on device faces to identify
// which parameter values each device in an array uses.

// ENABLE_PHYSICAL_ARRAY_MARKS: Enable/disable parameter identification marks
//   true  = Add text labels showing swept parameter values on device faces
//           Helps identify devices in parameter sweep arrays
//   false = No marks (clean faces)
ENABLE_PHYSICAL_ARRAY_MARKS   = true;

// PHYSICAL_MARK_TYPE: How marks interact with device surface
//   "indented" = Carve marks INTO device faces (recessed text)
//                Text is subtracted from device geometry
//                Best for reading after printing without post-processing
//   "raised"   = Marks PROTRUDE from device faces (embossed text)
//                Text is added to device geometry
//                May require support material during printing
PHYSICAL_MARK_TYPE            = "indented";

// PHYSICAL_MARK_DEPTH_LAYERS: How deep/tall marks extend (layers)
// For "indented": How far text carves INTO the face
// For "raised": How far text PROTRUDES from the face
// Must be deep/tall enough to be visible but not compromise structure
// Example: 4 layers × 0.050mm = 0.2mm depth/height
PHYSICAL_MARK_DEPTH_LAYERS    = 4;

// PHYSICAL_MARK_TEXT_FONT: OpenSCAD font specification for mark text
// Format: "FontName:style=StyleName"
// Must be a font installed on your system and available to OpenSCAD
// Bold style recommended for better visibility at small sizes
PHYSICAL_MARK_TEXT_FONT       = "Liberation Sans:style=Bold";

// PHYSICAL_MARK_TEXT_SIZE_MM: Text height in millimeters
// Balance between readability and device size constraints
// Too large: Text may not fit or weaken structure
// Too small: Text may not print clearly or be readable
// 1.0mm is a good starting point for typical microfluidic devices
PHYSICAL_MARK_TEXT_SIZE_MM    = 1.0;


// ===============================================================================
// ================================
// USER PARAMETERS - BUILD PLATE GRID PADDING
// ================================
// ===============================================================================

// When rendering device arrays, these parameters define buffer zones around
// the build plate edges to avoid edge effects and ensure reliable printing.

// TOTAL_GRID_PADDING_X: Total padding in X direction (both sides combined) (mm)
// This amount is subtracted from BUILD_PLATE_X_SIZE before calculating array
// Example: 2.0mm leaves 1.0mm margin on left and right edges
TOTAL_GRID_PADDING_X = 2.0;

// TOTAL_GRID_PADDING_Y: Total padding in Y direction (front+back combined) (mm)
// This amount is subtracted from BUILD_PLATE_Y_SIZE before calculating array
// Example: 2.0mm leaves 1.0mm margin on front and back edges
TOTAL_GRID_PADDING_Y = 2.0;


// ===============================================================================
// ================================
// CALCULATED VALUES - DO NOT MODIFY
// ================================
// ===============================================================================

// The following values are automatically calculated from user parameters above.
// DO NOT MODIFY these directly - instead, modify the user parameters above.

// ---------------------
// ACTIVE PRINTER CONFIGURATION
// ---------------------
// These extract the selected printer's parameters from the arrays

BUILD_PLATE_X_SIZE    = PRINTER_BUILD_PLATE_X_SIZES[SELECTED_PRINTER];
BUILD_PLATE_Y_SIZE    = PRINTER_BUILD_PLATE_Y_SIZES[SELECTED_PRINTER];
PIXEL_SIZE_CONST      = PRINTER_PIXEL_SIZES[SELECTED_PRINTER];
LAYER_THICKNESS_CONST = PRINTER_LAYER_THICKNESSES[SELECTED_PRINTER];

// ---------------------------------------------------------------------------
// CONTROL-CHAMBER SIZE: which knob wins
// ---------------------------------------------------------------------------
// The explicit variables below are authoritative. MEMBRANE_MARGIN_PX only takes
// over while they are left at their derived value (cutout + margin) -- that case
// is what a width sweep needs, because the cutout changes from column to column.
// Edit default_membrane_cavity_x/y_pixel_multiple and it is used verbatim.
// Open lumen left above the seat, in mm, from the layer counts (the g of the closure model).
function open_lumen_mm() =
    (default_cutout_z_size_in_layers - (ENABLE_DOORMAT ? DOORMAT_THICKNESS_LAYERS : 0))
        * LAYER_THICKNESS_CONST;

// The membrane width the closure model requires for a given channel width, in pixels.
// This is the C the design tool returns: the deflected membrane's chord at the membrane
// plane. The control chamber is what clamps the membrane, so the chamber must be this
// wide -- build it narrower and the membrane is too narrow to close the channel.
function required_membrane_width_px(cxp) =
    round(seat_membrane_width(open_lumen_mm(), KAPPA, cxp*PIXEL_SIZE_CONST) / PIXEL_SIZE_CONST);

function chamber_x_px(cxp) =
    SEAT_SPHERE_DERIVED ? required_membrane_width_px(cxp)
    : (MEMBRANE_MARGIN_PX >= 0 &&
       default_membrane_cavity_x_pixel_multiple == default_cutout_x_size_in_pixels + MEMBRANE_MARGIN_PX)
        ? cxp + MEMBRANE_MARGIN_PX
        : default_membrane_cavity_x_pixel_multiple;
function chamber_y_px(cyp) =
    (MEMBRANE_MARGIN_PX >= 0 &&
     default_membrane_cavity_y_pixel_multiple == default_cutout_y_size_in_pixels + MEMBRANE_MARGIN_PX)
        ? cyp + MEMBRANE_MARGIN_PX
        : default_membrane_cavity_y_pixel_multiple;

// A membrane narrower than the channel is buildable -- it simply covers part of
// the lumen rather than spanning it -- so this is a note, not a restriction.
if (chamber_x_px(default_cutout_x_size_in_pixels) < default_cutout_x_size_in_pixels)
    echo(str("NOTE: control chamber X (", chamber_x_px(default_cutout_x_size_in_pixels),
             " px) is narrower than the flow channel (", default_cutout_x_size_in_pixels,
             " px), so the membrane spans only part of the lumen width. Intentional? ",
             "If not, raise default_membrane_cavity_x_pixel_multiple."));
if (chamber_y_px(default_cutout_y_size_in_pixels) < default_cutout_y_size_in_pixels)
    echo(str("NOTE: control chamber Y (", chamber_y_px(default_cutout_y_size_in_pixels),
             " px) is shorter than the flow channel (", default_cutout_y_size_in_pixels,
             " px), so the membrane covers only part of the lumen length."));

if (DEBUG_ECHO) {
    echo("===============================================================================");
    echo("=== ACTIVE PRINTER CONFIGURATION ===");
    echo(str("  Selected printer index: ", SELECTED_PRINTER));
    echo(str("  Build plate: ", BUILD_PLATE_X_SIZE, " x ", BUILD_PLATE_Y_SIZE, " mm"));
    echo(str("  XY resolution: ", PIXEL_SIZE_CONST, " mm/pixel"));
    echo(str("  Z resolution: ", LAYER_THICKNESS_CONST, " mm/layer"));
    echo("===============================================================================");
}


// ---------------------
// AVAILABLE BUILD AREA
// ---------------------
// Build plate dimensions minus padding margins

AVAILABLE_BUILD_PLATE_X_SIZE = BUILD_PLATE_X_SIZE - TOTAL_GRID_PADDING_X;
AVAILABLE_BUILD_PLATE_Y_SIZE = BUILD_PLATE_Y_SIZE - TOTAL_GRID_PADDING_Y;

if (DEBUG_ECHO) {
    echo(str("  Available build area: ", AVAILABLE_BUILD_PLATE_X_SIZE, " x ", 
             AVAILABLE_BUILD_PLATE_Y_SIZE, " mm"));
}


// ---------------------
// GEOMETRIC CONSTANTS
// ---------------------

// $fn: OpenSCAD circle/cylinder facet count - higher = smoother but slower
// 72 facets provides good visual quality for cylinders without excessive render time
$fn = 70;

// epsilon: Tiny offset for CSG operations to prevent coplanar surface artifacts
// Used to ensure clean Boolean operations by slightly overlapping surfaces
epsilon = 0.01;

// z_guard: Vertical clearance offset (2× epsilon for extra safety)
// Used when features must clearly separate in Z to avoid coplanar faces
z_guard = 2*epsilon;

if (DEBUG_ECHO) {
    echo(str("  Geometric constants: $fn=", $fn, " epsilon=", epsilon, " z_guard=", z_guard));
}


// ===============================================================================
// ================================
// PARAMETER VALIDATION
// ================================
// ===============================================================================

// These assertions verify that user parameters meet minimum requirements
// If any assertion fails, OpenSCAD will halt and display the error message

// Calculate minimum cutout sizes needed to fit needle ports
MIN_CUTOUT_Y_PIXELS = ceil(MAX_PORT_DIAMETER / PIXEL_SIZE_CONST);
MIN_CUTOUT_X_PIXELS = ceil(MAX_PORT_DIAMETER / PIXEL_SIZE_CONST);

// Needle ports must not overlap across the wall between neighboring cutouts
_actual_cx = default_cutout_x_size_in_pixels * PIXEL_SIZE_CONST;
_min_wall_for_ports = max(0, MAX_PORT_DIAMETER - _actual_cx);  // CX provides separation too
_actual_wall_x = WALL_THICKNESS_X_PIXELS * PIXEL_SIZE_CONST;
// Only meaningful when a block holds more than one cutout: the rule keeps the
// port bores of ADJACENT cutouts (centres CX + WX apart) from merging. A single
// through-channel device has no neighbour inside the block.
_ports_adjacent = (THROUGH_CHANNEL ? num_cutouts_per_face : 2*num_cutouts_per_face) > 1;
// ---------------------------------------------------------------------------
// TOP-FACE PORT GEOMETRY (both upper ports exit Z_MAX in through-channel mode)
// ---------------------------------------------------------------------------
// The two bores are placed at cutout_y_center +/- 0.28 * membrane_y.
_zz_both_top   = (UPPER_CHAMBER_PORT_1_DIRECTION == "Z_MAX") &&
                 (UPPER_CHAMBER_PORT_2_DIRECTION == "Z_MAX");
_zz_membrane_y = chamber_y_px(default_cutout_y_size_in_pixels) * PIXEL_SIZE_CONST;
_zz_block_y    = _zz_membrane_y + 2*THROUGH_CHANNEL_Y_PAD_MM;
_zz_sep        = 0.56 * _zz_membrane_y;
_zz_d1         = port_diameter(UPPER_CHAMBER_PORT_1_ROLE);
_zz_d2         = port_diameter(UPPER_CHAMBER_PORT_2_ROLE);
_zz_need_sep   = (_zz_d1 + _zz_d2)/2;
_zz_dmax       = max(_zz_d1, _zz_d2);
_zz_min_chamber_y_px = ceil((_zz_need_sep/0.56) / PIXEL_SIZE_CONST);
_zz_fit_chamber_y_px = ceil(((_zz_dmax - 2*THROUGH_CHANNEL_Y_PAD_MM)/(1 - 0.56)) / PIXEL_SIZE_CONST);

assert(!_zz_both_top || _zz_sep >= _zz_need_sep,
       str("ERROR: the two top-face ports overlap. Their centres are ", _zz_sep,
           "mm apart but the bores are ", _zz_d1, "mm and ", _zz_d2,
           "mm wide, so they need at least ", _zz_need_sep,
           "mm. The spacing is 0.56 x the chamber depth, which is set by ",
           "default_membrane_cavity_y_pixel_multiple (now ",
           chamber_y_px(default_cutout_y_size_in_pixels), " px = ", _zz_membrane_y,
           "mm). Set default_membrane_cavity_y_pixel_multiple to at least ", _zz_min_chamber_y_px,
           " px, or reduce INLET_PORT_DIAMETER / OUTLET_PORT_DIAMETER (now ", _zz_d1, "mm / ", _zz_d2,
           "mm), or route one port off the top face via UPPER_CHAMBER_PORT_1_DIRECTION.",
           " NOTE: default_membrane_cavity_y_pixel_multiple may still be defined as ",
           "'= default_cutout_y_size_in_pixels', in which case editing it does nothing until you ",
           "replace that expression with a number (or raise default_cutout_y_size_in_pixels)."));

assert(!_zz_both_top || (_zz_sep + _zz_dmax) <= _zz_block_y,
       str("ERROR: a top-face port does not fit inside the device. The outer bore edge sits ",
           (_zz_sep + _zz_dmax)/2, "mm from the device centre but the device is only ",
           _zz_block_y, "mm deep in Y (half-depth ", _zz_block_y/2,
           "mm), so the port breaks out through the Y face and the control chamber cannot hold pressure. ",
           "Set default_membrane_cavity_y_pixel_multiple to at least ", _zz_fit_chamber_y_px,
           " px, or reduce INLET_PORT_DIAMETER / OUTLET_PORT_DIAMETER (largest is now ",
           _zz_dmax, "mm), or increase THROUGH_CHANNEL_Y_PAD_MM (now ",
           THROUGH_CHANNEL_Y_PAD_MM, "mm).",
           " NOTE: default_membrane_cavity_y_pixel_multiple may still be defined as ",
           "'= default_cutout_y_size_in_pixels', in which case editing it does nothing until you ",
           "replace that expression with a number (or raise default_cutout_y_size_in_pixels)."));

assert(!_ports_adjacent || _actual_wall_x >= _min_wall_for_ports,
       str("ERROR: neighbouring needle ports would merge. Their centres are ",
           _actual_cx + _actual_wall_x, "mm apart (cutout ", _actual_cx,
           "mm + wall ", _actual_wall_x, "mm) but must be at least ", MAX_PORT_DIAMETER,
           "mm (MAX_PORT_DIAMETER). Fix EITHER by widening the channel ",
           "(default_cutout_x_size_in_pixels, now ", default_cutout_x_size_in_pixels,
           " px) OR by thickening the wall (WALL_THICKNESS_X_PIXELS, now ",
           WALL_THICKNESS_X_PIXELS, " px; ", ceil(_min_wall_for_ports / PIXEL_SIZE_CONST),
           " px would suffice at the current channel width)."));

// Verify port direction parameters have valid values
assert(UPPER_CHAMBER_PORT_1_DIRECTION == "Y_MIN" || UPPER_CHAMBER_PORT_1_DIRECTION == "Y_MAX"
       || UPPER_CHAMBER_PORT_1_DIRECTION == "Z_MAX", 
       "ERROR: UPPER_CHAMBER_PORT_1_DIRECTION must be 'Y_MIN', 'Y_MAX' or 'Z_MAX'");

assert(UPPER_CHAMBER_PORT_2_DIRECTION == "Z_MAX" || UPPER_CHAMBER_PORT_2_DIRECTION == "Y_MAX", 
       "ERROR: UPPER_CHAMBER_PORT_2_DIRECTION must be 'Z_MAX' or 'Y_MAX'");

assert(LOWER_CHAMBER_PORT_1_DIRECTION == "Y_MAX" || LOWER_CHAMBER_PORT_1_DIRECTION == "Y_MIN", 
       "ERROR: LOWER_CHAMBER_PORT_1_DIRECTION must be 'Y_MAX' or 'Y_MIN'");

assert(LOWER_CHAMBER_PORT_2_DIRECTION == "Z_MIN" || LOWER_CHAMBER_PORT_2_DIRECTION == "Y_MIN", 
       "ERROR: LOWER_CHAMBER_PORT_2_DIRECTION must be 'Z_MIN' or 'Y_MIN'");

if (DEBUG_ECHO) {
    echo("=== PARAMETER VALIDATION COMPLETE ===");
    echo(str("  All parameters validated successfully"));
}


// ===============================================================================
// ================================
// HELPER CONSTANTS FOR PARAMETER SWEEP
// ================================
// ===============================================================================

// Unit type indicators for parameter conversion
PARAM_UNIT_PIXEL = 0;  // Parameter uses pixels (converted via PIXEL_SIZE_CONST)
PARAM_UNIT_LAYER = 1;  // Parameter uses layers (converted via LAYER_THICKNESS_CONST)


// ===============================================================================
// ================================
// HELPER FUNCTIONS
// ================================
// ===============================================================================

// Get the unit type (pixel or layer) for a given parameter index
// ---------------------------------------------------------------------------
// CLOSURE MODEL -- the same equations the interactive design tool solves.
// Given the open lumen height g above the seat, the membrane deflection coefficient
// kappa, and the channel width W (all in mm), these return the deflected membrane's
// sagitta, its width, the radius of the matching spherical seat, and how far the
// membrane travels below the seat top. Linear model (n = 1), which has a closed form.
// ---------------------------------------------------------------------------
function seat_sagitta(g, k, W) =
    (g*(1 - 4*k*k) + sqrt(g*g*(1 + 4*k*k)*(1 + 4*k*k) + 4*k*k*W*W)) / 2;
function seat_membrane_width(g, k, W) = seat_sagitta(g, k, W) / k;
function seat_radius(g, k, W) =
    let (s = seat_sagitta(g, k, W), C = s/k) (C*C + 4*s*s) / (8*s);
function seat_depth(g, k, W) = seat_sagitta(g, k, W) - g;


function get_param_unit_type(param_idx) =
    (param_idx == PARAM_MEMBRANE_X || param_idx == PARAM_MEMBRANE_Y ||
     param_idx == PARAM_CUTOUT_X   || param_idx == PARAM_CUTOUT_Y) ? PARAM_UNIT_PIXEL :
    (param_idx == PARAM_MEMBRANE_Z || param_idx == PARAM_CUTOUT_Z) ? PARAM_UNIT_LAYER :
    PARAM_UNIT_PIXEL;


// Calculate parameter value with proper unit conversion and cycling for arrays
function get_param_val_with_cycling(p_min, p_max, p_steps, array_idx, p_unit) =
let(
    i = array_idx % p_steps,  // Cycle through steps if more devices than steps
    denom = max(1, p_steps-1),  // Avoid division by zero
    vq = p_min + (p_steps>1 ? i*(p_max-p_min)/denom : 0),  // Linear interpolation
    q = (p_unit==PARAM_UNIT_PIXEL || p_unit==PARAM_UNIT_LAYER) ? round(vq) : vq,  // Quantize to integer
    mm = (p_unit==PARAM_UNIT_PIXEL) ? q*PIXEL_SIZE_CONST :  // Convert to mm
         (p_unit==PARAM_UNIT_LAYER) ? q*LAYER_THICKNESS_CONST : q
) max(mm, (p_unit==PARAM_UNIT_PIXEL)?PIXEL_SIZE_CONST:  // Ensure minimum one unit
          (p_unit==PARAM_UNIT_LAYER)?LAYER_THICKNESS_CONST:0.0001);


// Convert parameter index to short code string for physical marks
function code_of(idx) =
    idx==PARAM_MEMBRANE_X?"MX":  // Membrane X
    idx==PARAM_MEMBRANE_Y?"MY":  // Membrane Y
    idx==PARAM_MEMBRANE_Z?"MZ":  // Membrane Z
    idx==PARAM_CUTOUT_X?  "CX":  // Cutout X
    idx==PARAM_CUTOUT_Y?  "CY":  // Cutout Y
    idx==PARAM_CUTOUT_Z?  "CZ":  // Cutout Z
    "P";  // Unknown parameter


// ===============================================================================
// ================================
// DIAGONAL WEDGE BRACE MODULE
// ================================
// ===============================================================================

// Creates a right-triangle wedge extruded along X axis for diagonal bracing
// Wedge spans from (y0, z0) to (0, z1) in YZ plane, extruded to length len_x
module zy_wedge_extruded_x(len_x=10, y0=0, y_width=3, z0=0, z1=1,
                           y_overlap=0.05, z_overlap=0.05) {
    
    // y_width parameter kept for API compatibility but not used in geometry
    // Add slight overlap for watertight CSG unions
    _y0 = y0 - y_overlap;  // Extend into front pad
    _z0 = z0 - z_overlap;  // Extend downward
    _z1 = z1 + z_overlap;  // Extend upward
    
    // Define vertices of triangular prism
    // Two triangular faces (at x=0 and x=len_x) connected by rectangles
    points = [
        // Front face (x = 0)
        [0,      _y0, _z0],   // A0 - right angle corner
        [0,      0,   _z0],   // B0 - Y-max edge
        [0,      0,   _z1],   // C0 - top corner
        // Back face (x = len_x)
        [len_x,  _y0, _z0],   // A1
        [len_x,  0,   _z0],   // B1
        [len_x,  0,   _z1]    // C1
    ];
    
    // Define faces with consistent winding (all counterclockwise from outside)
    faces = [
        [0,1,2],      // Front triangle (A0-B0-C0)
        [3,5,4],      // Back triangle (A1-C1-B1)
        [0,3,4,1],    // Bottom rectangle (A0-A1-B1-B0)
        [1,4,5,2],    // Y-max rectangle (B0-B1-C1-C0)
        [2,5,3,0]     // Hypotenuse rectangle (C0-C1-A1-A0)
    ];
    
    polyhedron(points=points, faces=faces, convexity=10);
}


// ===============================================================================
// ================================
// DIAGONAL BRACING MODULE
// ================================
// ===============================================================================

// Creates diagonal wedge braces under front padding overhang
// One brace per gap between FRONT cutouts (no braces under cutouts themselves)
module create_diagonal_braces(
    wall_thickness_x, spacing_x, total_cutouts,
    cutout_x, y_extension_front,
    cutout_bottom_z, cutout_z, membrane_plane_z,
    total_block_len_x  
){
    // Only build if feature enabled and there is overhang to support
    if (ENABLE_DIAGONAL_BRACES && y_extension_front > 0) {

        if (DEBUG_ECHO)
            echo("  Creating diagonal braces: single wedge per FRONT gap");

        // Vertical placement of brace (from mid-cutout to membrane plane)
        brace_start_z = cutout_bottom_z + cutout_z/2;
        brace_end_z   = membrane_plane_z;
        brace_height  = brace_end_z - brace_start_z;

        // Only create braces if they would have positive height
        if (brace_height > 0) {

            hull_y_thickness = MAX_PORT_DIAMETER/2;  // Legacy, kept for minimal diffs

            // Calculate X positions for wall segments
            mem_ext_x = max(0, (chamber_x_px(cutout_x/PIXEL_SIZE_CONST)*PIXEL_SIZE_CONST - cutout_x)/2);
            X_BASE    = wall_thickness_x + mem_ext_x;
            total_len_x = total_block_len_x;

            // Find last FRONT cutout index (FRONT = even indices)
            last_front = (total_cutouts % 2 == 0) ? (total_cutouts - 2) : (total_cutouts - 1);

            // Build list of wall segment X ranges (where braces go)
            // Segments are:
            //   1. Left outer wall [0, X_BASE]
            //   2. Gaps between FRONT cutouts
            //   3. Right outer wall [last_front_end, total_len_x]
            wall_segments = concat(
                [[0, X_BASE]],  // Left wall
                [ for (i = [0:2:last_front-2])  // Gaps between fronts
                    [ X_BASE + i*spacing_x + cutout_x,  X_BASE + (i+2)*spacing_x ] ],
                [[ X_BASE + last_front*spacing_x + cutout_x, total_len_x ]]  // Right wall
            );

            // Small clearance from cutout edges for clean geometry
            x_clear = 0;

            // Create one brace per wall segment
            for (seg = wall_segments) {
                seg_start = max(0, seg[0]) + x_clear;
                seg_end   = min(total_len_x, seg[1]) - x_clear;
                brace_w   = seg_end - seg_start;

                if (DEBUG_ECHO)
                    echo(str("    FRONT-gap brace [", seg_start, ", ", seg_end, "] width=", brace_w));

                if (brace_w > 0) {
                    // Create wedge and rotate to proper orientation
                    // Original wedge: Y–Z triangle extruded in X
                    // After rotation: diagonal support under front padding
                    front_pad_z_start = membrane_plane_z - epsilon;
                    
                    color("SteelBlue", 0.6)
                    translate([seg_start, 0, front_pad_z_start])
                    rotate([90,0,0])  // Rotate 90° about X axis
                    zy_wedge_extruded_x(
                      len_x   = brace_w,
                      y0      = -(brace_end_z - brace_start_z),  // Becomes Z thickness
                      z0      = 0,                                // Becomes Y min
                      z1      = y_extension_front,                // Y thickness
                      y_overlap = 5*epsilon,
                      z_overlap = -epsilon
                    );
                }
            }
        }
    }
}


// ===============================================================================
// ================================
// DEVICE DIMENSIONS CALCULATOR
// ================================
// ===============================================================================

// Calculates all device dimensions from input parameters
// Returns: [total_x, core_y, total_z, y_front_pad, y_back_pad, membrane_z, cutout_bottom_z]
function get_device_dimensions_with_z_limits(cxp, cyp, czl, mxp, myp, mzl) =
let(
    _d1 = DEBUG_ECHO ? echo("=== get_device_dimensions_with_z_limits START ===") : 0,
    _d2 = DEBUG_ECHO ? echo(str("  Input pixels/layers: cutout=[", cxp, ",", cyp, ",", czl, 
                                 "] membrane=[", mxp, ",", myp, ",", mzl, "]")) : 0,
    
    // Convert pixels/layers to millimeters
    CX = cxp*PIXEL_SIZE_CONST,
    CY = cyp*PIXEL_SIZE_CONST,
    CZ = czl*LAYER_THICKNESS_CONST,
    WX = WALL_THICKNESS_X_PIXELS*PIXEL_SIZE_CONST,
    MX = mxp*PIXEL_SIZE_CONST,
    MY = myp*PIXEL_SIZE_CONST,
    MZ = MEMBRANE_CAVITY_Z_LAYERS*LAYER_THICKNESS_CONST,
    MT = mzl*LAYER_THICKNESS_CONST,
    PAD_TOP    = BLOCK_Z_PADDING_TOP_IN_LAYERS*LAYER_THICKNESS_CONST,
    PAD_BOTTOM = BLOCK_Z_PADDING_BOTTOM_IN_LAYERS*LAYER_THICKNESS_CONST,

    _d3 = DEBUG_ECHO ? echo(str("  Sizes in mm: CX=", CX, " CY=", CY, " CZ=", CZ)) : 0,
    _d3a = DEBUG_ECHO ? echo(str("  Input pixels: cxp=", cxp, " cyp=", cyp)) : 0,
    _d3b = DEBUG_ECHO ? echo(str("  Membrane pixels: mxp=", mxp, " myp=", myp)) : 0,
    _d3c = DEBUG_ECHO ? echo(str("  PIXEL_SIZE_CONST=", PIXEL_SIZE_CONST, " mm")) : 0,
    _d3d = DEBUG_ECHO ? echo(str("  Calculated: CY = ", cyp, " * ", PIXEL_SIZE_CONST, " = ", CY, " mm")) : 0,
    _d3e = DEBUG_ECHO ? echo(str("  Calculated: MY = ", myp, " * ", PIXEL_SIZE_CONST, " = ", MY, " mm")) : 0,
    _d4 = DEBUG_ECHO ? echo(str("  Membrane in mm: MX=", MX, " MY=", MY, " MZ=", MZ, " MT=", MT)) : 0,

    // Core device Y dimension (2.5× cutout depth provides standard layout)
    standard_y_for_cutout = 2.5*CY,

    // Body grows to guarantee MIN_NEEDLE_PORT_STUB_LENGTH between body face and
    // cutout start on every Y face that carries a needle port.
    // Padding (y_extension_front/back) is always additive beyond the body face.
    _has_y_min = (UPPER_CHAMBER_PORT_1_DIRECTION == "Y_MIN") ||
                 (LOWER_CHAMBER_PORT_1_DIRECTION   == "Y_MIN") ||
                 (LOWER_CHAMBER_PORT_2_DIRECTION  == "Y_MIN"),
    _has_y_max = (UPPER_CHAMBER_PORT_1_DIRECTION  == "Y_MAX") ||
                 (UPPER_CHAMBER_PORT_2_DIRECTION  == "Y_MAX") ||
                 (LOWER_CHAMBER_PORT_1_DIRECTION    == "Y_MAX"),
    // y_stub: per-face stub uses the maximum port_stub() of all ports exiting that face.
    // This sets the core body thickness needed to guarantee wall material around each port.
    y_stub_front = _has_y_min ? max(
        (_has_y_min && (UPPER_CHAMBER_PORT_1_DIRECTION == "Y_MIN")) ? port_stub(UPPER_CHAMBER_PORT_1_ROLE)  : 0,
        (_has_y_min && (LOWER_CHAMBER_PORT_1_DIRECTION  == "Y_MIN")) ? port_stub(LOWER_CHAMBER_PORT_1_ROLE)   : 0,
        (_has_y_min && (LOWER_CHAMBER_PORT_2_DIRECTION == "Y_MIN")) ? port_stub(LOWER_CHAMBER_PORT_2_ROLE)  : 0,
        MAX_PORT_DIAMETER/2
    ) : MAX_PORT_DIAMETER/2,
    y_stub_back  = _has_y_max ? max(
        (_has_y_max && (UPPER_CHAMBER_PORT_1_DIRECTION  == "Y_MAX")) ? port_stub(UPPER_CHAMBER_PORT_1_ROLE)  : 0,
        (_has_y_max && (UPPER_CHAMBER_PORT_2_DIRECTION == "Y_MAX")) ? port_stub(UPPER_CHAMBER_PORT_2_ROLE) : 0,
        (_has_y_max && (LOWER_CHAMBER_PORT_1_DIRECTION   == "Y_MAX")) ? port_stub(LOWER_CHAMBER_PORT_1_ROLE)   : 0,
        MAX_PORT_DIAMETER/2
    ) : MAX_PORT_DIAMETER/2,

    block_width_y_core = THROUGH_CHANNEL
        ? MY + 2*THROUGH_CHANNEL_Y_PAD_MM
        : standard_y_for_cutout + y_stub_front + y_stub_back,
    
    _d5 = DEBUG_ECHO ? echo(str("  Core block width Y: ", block_width_y_core, " mm")) : 0,

    // Calculate cutout and membrane positions
    front_cutout_center_y = THROUGH_CHANNEL ? block_width_y_core/2 : y_stub_front + CY/2,
    back_cutout_center_y = THROUGH_CHANNEL ? block_width_y_core/2
                                          : block_width_y_core - y_stub_back - CY/2,
    
    front_mem_min_y = front_cutout_center_y - MY/2,
    front_mem_max_y = front_cutout_center_y + MY/2,
    back_mem_min_y = back_cutout_center_y - MY/2,
    back_mem_max_y = back_cutout_center_y + MY/2,
    
    _d6 = DEBUG_ECHO ? echo(str("  Front membrane Y range: ", front_mem_min_y, " to ", front_mem_max_y)) : 0,
    _d7 = DEBUG_ECHO ? echo(str("  Back membrane Y range: ", back_mem_min_y, " to ", back_mem_max_y)) : 0,

    // Calculate required padding based on membrane overhang
    REQ_WALL = MAX_PORT_DIAMETER/2,
    
    front_overhang = front_mem_min_y < 0 ? -front_mem_min_y : 0,
    back_overhang = back_mem_max_y > block_width_y_core ? back_mem_max_y - block_width_y_core : 0,
    
   // Determine which Y faces actually have ports exiting through them
    has_y_min_port = (UPPER_CHAMBER_PORT_1_DIRECTION == "Y_MIN") ||
                     (LOWER_CHAMBER_PORT_1_DIRECTION   == "Y_MIN") ||
                     (LOWER_CHAMBER_PORT_2_DIRECTION  == "Y_MIN"),
    has_y_max_port = (UPPER_CHAMBER_PORT_1_DIRECTION  == "Y_MAX") ||
                     (UPPER_CHAMBER_PORT_2_DIRECTION  == "Y_MAX") ||
                     (LOWER_CHAMBER_PORT_1_DIRECTION    == "Y_MAX"),

    // Only enforce stub on faces that actually have Y ports.
    // Faces with no Y ports still need padding to cover membrane overhang + REQ_WALL.
    // Stub = max of all port_stub() values for ports exiting through that face.
    y_min_face_stub = max(
        (UPPER_CHAMBER_PORT_1_DIRECTION == "Y_MIN") ? port_stub(UPPER_CHAMBER_PORT_1_ROLE) : 0,
        (LOWER_CHAMBER_PORT_1_DIRECTION  == "Y_MIN") ? port_stub(LOWER_CHAMBER_PORT_1_ROLE)  : 0,
        (LOWER_CHAMBER_PORT_2_DIRECTION == "Y_MIN") ? port_stub(LOWER_CHAMBER_PORT_2_ROLE) : 0
    ),
    y_max_face_stub = max(
        (UPPER_CHAMBER_PORT_1_DIRECTION  == "Y_MAX") ? port_stub(UPPER_CHAMBER_PORT_1_ROLE)  : 0,
        (UPPER_CHAMBER_PORT_2_DIRECTION == "Y_MAX") ? port_stub(UPPER_CHAMBER_PORT_2_ROLE) : 0,
        (LOWER_CHAMBER_PORT_1_DIRECTION   == "Y_MAX") ? port_stub(LOWER_CHAMBER_PORT_1_ROLE)   : 0
    ),
    y_extension_front = THROUGH_CHANNEL ? 0 :
                        YMIN_PADDING_Y_THICKNESS > 0 ? YMIN_PADDING_Y_THICKNESS :
                        has_y_min_port ? max(y_min_face_stub, front_overhang + REQ_WALL)
                                       : max(REQ_WALL, front_overhang + REQ_WALL),
    y_extension_back  = THROUGH_CHANNEL ? 0 :
                        YMAX_PADDING_Y_THICKNESS > 0 ? YMAX_PADDING_Y_THICKNESS :
                        has_y_max_port ? max(y_max_face_stub, back_overhang + REQ_WALL)
                                       : max(REQ_WALL, back_overhang + REQ_WALL),    
                                       
    _dy1 = DEBUG_ECHO ? echo(str("  Y-min face has port: ", has_y_min_port, 
                                  " | Y-max face has port: ", has_y_max_port)) : 0,
    _d8 = DEBUG_ECHO ? echo(str("  Front overhang: ", front_overhang, " mm, pad: ", y_extension_front, 
                                 " mm", YMIN_PADDING_Y_THICKNESS > 0 ? " (USER OVERRIDE)" : " (auto)")) : 0,
    _d9 = DEBUG_ECHO ? echo(str("  Back overhang: ", back_overhang, " mm, pad: ", y_extension_back, 
                                 " mm", YMAX_PADDING_Y_THICKNESS > 0 ? " (USER OVERRIDE)" : " (auto)")) : 0,

    // Calculate total X dimension
    mem_ext_x = max(0, (MX - CX)/2),
    total_cutouts = THROUGH_CHANNEL ? num_cutouts_per_face : 2*num_cutouts_per_face,
    spacing_x = CX + WX,
    total_length_x = (total_cutouts-1)*spacing_x + CX + 2*WX + 2*mem_ext_x,

    // Calculate Z positions and dimensions
    tcb = -CZ/2,  // Cutout bottom (centered at Z=0)
    tct = CZ/2,   // Cutout top (membrane plane)
    ub = tct + MT,  // Upper cavity base
    ut = ub + MZ,   // Upper cavity top
    lt = tcb - MT,  // Lower cavity top
    lb = lt - MZ,   // Lower cavity base
// Only expand Z bounds if a port actually exits through that Z face
    has_z_max_port = (UPPER_CHAMBER_PORT_2_DIRECTION == "Z_MAX"),
    has_z_min_port = (LOWER_CHAMBER_PORT_2_DIRECTION  == "Z_MIN"),
    highest = has_z_max_port ? ut + port_diameter(UPPER_CHAMBER_PORT_2_ROLE)/2 : ut,
    lowest  = has_z_min_port ? lb - port_diameter(LOWER_CHAMBER_PORT_2_ROLE)/2 : lb,

    // Enforce minimum Z padding for stub length only on faces with Z ports
    effective_pad_top    = has_z_max_port ?
                           max(PAD_TOP,    port_stub(UPPER_CHAMBER_PORT_2_ROLE)) : PAD_TOP,
    effective_pad_bottom = has_z_min_port ?
                           max(PAD_BOTTOM, port_stub(LOWER_CHAMBER_PORT_2_ROLE))  : PAD_BOTTOM,
    final_h = (highest-lowest) + effective_pad_top + effective_pad_bottom,
    membrane_plane_z = tct,
    cutout_bottom_z  = tcb

) [total_length_x, block_width_y_core, final_h, y_extension_front, y_extension_back,
   membrane_plane_z, cutout_bottom_z, y_stub_front, y_stub_back];


// ===============================================================================
// ================================
// DOORMAT SOLID MODULE
// ================================
// ===============================================================================

// Creates raised doormat feature at bottom of valve seat cutouts
// Optionally applies half-view for visualization
module doormat_solid(center_x, cutout_y_pos, base_z, cutout_x_mm, cutout_y_mm) {
    // -1 (or any non-positive value) means "span the lumen", which is what makes the
    // seat track the channel-width sweep. A positive value is taken as a fixed width.
    dx = DOORMAT_X_PIXELS > 0 ? DOORMAT_X_PIXELS*PIXEL_SIZE_CONST : cutout_x_mm;
    dy = DOORMAT_Y_PIXELS*PIXEL_SIZE_CONST;
    dz = DOORMAT_THICKNESS_LAYERS*LAYER_THICKNESS_CONST;
    zc = base_z + dz/2;
    ext = DOORMAT_RAMP_ANGLE>0 ? (dz/2)/tan(DOORMAT_RAMP_ANGLE) : 0;

    if (DEBUG_ECHO) echo(str("    Creating doormat solid at X=", center_x, " Y=",
        cutout_y_pos + cutout_y_mm/2, " Z=", zc, " | seat width ", dx, " mm (",
        DOORMAT_X_PIXELS > 0 ? str("fixed ", DOORMAT_X_PIXELS, " px")
                             : str("matched to the ", round(cutout_x_mm/PIXEL_SIZE_CONST), " px lumen"), ")"));
    if (DOORMAT_HALF_VIEW_ENABLE && DEBUG_ECHO) echo("      Half-view enabled for doormat visualization");

    intersection() {
        translate([center_x, cutout_y_pos + cutout_y_mm/2, zc]) {
            if (DOORMAT_RAMP_ANGLE==0) 
                cube([dx,dy,dz],center=true);
            else hull() {
                translate([0,0,-dz/2]) linear_extrude(height=epsilon)
                    square([dx+2*ext, dy+2*ext], center=true);
                translate([0,0, dz/2-epsilon]) linear_extrude(height=epsilon)
                    square([dx,dy], center=true);
            }
        }
        // Restrict doormat to cutout bounds
        translate([center_x - cutout_x_mm/2, cutout_y_pos, base_z - epsilon])
            cube([cutout_x_mm, cutout_y_mm, dz + 2*epsilon]);
    }
}


// ===============================================================================
// ================================
// NEGATIVE GEOMETRY MODULE
// ================================
// ===============================================================================

// Creates all subtractive features: cutouts, membrane cavities, ports, ducts
module negative_geometry_complete_v30_zlimited(
    cutout_x, cutout_y, cutout_z,
    membrane_x, membrane_y, membrane_z,
    duct_x, duct_z,
    wall_thickness_x,
    block_width_y, spacing_x, total_cutouts, total_length_x,
    final_cb, up_center_z, lo_center_z,
    up_base, up_top, lo_base, lo_top,
    final_block_height_z, control_port_y_position,
    y_extension_front, y_extension_back,
    y_stub_front, y_stub_back,
    upper_chamber_port_1_dir,
    upper_chamber_port_2_dir,
    lower_chamber_port_1_dir,
    lower_chamber_port_2_dir
){
    if (DEBUG_ECHO) echo("=== negative_geometry_complete_v30_zlimited START ===");
    if (DEBUG_ECHO) echo(str("  Processing ", total_cutouts, " cutouts"));
    if (DEBUG_ECHO) echo(str("  Membrane size: ", membrane_x, " x ", membrane_y, " x ", membrane_z, " mm"));
    if (DEBUG_ECHO) echo(str("  Y extensions: front=", y_extension_front, " back=", y_extension_back, " mm"));
    
    for (i=[0:total_cutouts-1]) {
        is_front = THROUGH_CHANNEL ? true : (i%2==0);

        mem_ext_x = max(0,(membrane_x-cutout_x)/2);
        cutout_x_pos = wall_thickness_x + mem_ext_x + i*spacing_x;

        // Cutout is centered within its membrane chamber.
        // FRONT: membrane sits from y_stub_front onward, cutout centered in it.
        // BACK:  membrane sits ending at block_width_y - y_stub_back, cutout centered in it.
        cutout_y_pos = is_front ? 0 : (block_width_y - cutout_y);
        cutout_y_center = THROUGH_CHANNEL ? block_width_y/2 : cutout_y_pos + cutout_y/2;
        center_x = cutout_x_pos + cutout_x/2;

        // Membrane is co-centered with the cutout on the same Y axis.
        mem_y_min = cutout_y_center - membrane_y/2;
        mem_y_max = cutout_y_center + membrane_y/2;

        // Comprehensive Y-dimension debug output
        if (DEBUG_ECHO) {
            echo(str("  === Cutout #", i, " Y-DIMENSION ANALYSIS ==="));
            echo(str("    Face: ", is_front ? "FRONT (Y-min)" : "BACK (Y-max)"));
            echo(str("    block_width_y = ", block_width_y, " mm"));
            echo(str("    cutout_y = ", cutout_y, " mm (input parameter)"));
            echo(str("    membrane_y = ", membrane_y, " mm (input parameter)"));
            echo(str("    --- CUTOUT BOUNDS ---"));
            echo(str("    cutout_y_pos = ", cutout_y_pos, " mm (Y start)"));
            echo(str("    cutout_y_end = ", cutout_y_pos + cutout_y, " mm (Y end)"));
            echo(str("    cutout_y_center = ", cutout_y_center, " mm"));
            echo(str("    cutout_y_size = ", cutout_y, " mm (span)"));
            echo(str("    --- MEMBRANE CAVITY BOUNDS ---"));
            echo(str("    mem_y_min = ", mem_y_min, " mm (Y start)"));
            echo(str("    mem_y_max = ", mem_y_max, " mm (Y end)"));
            echo(str("    mem_y_center = ", (mem_y_min + mem_y_max)/2, " mm"));
            echo(str("    mem_y_size = ", mem_y_max - mem_y_min, " mm (span)"));
            echo(str("    membrane_y (parameter) = ", membrane_y, " mm"));
            echo(str("    --- SIZE COMPARISON ---"));
            echo(str("    Cutout Y span: ", cutout_y, " mm"));
            echo(str("    Membrane Y span: ", mem_y_max - mem_y_min, " mm"));
            echo(str("    Difference: ", (mem_y_max - mem_y_min) - cutout_y, " mm"));
            echo(str("    Position: X=", cutout_x_pos, " Y=", cutout_y_pos));
        }

        // Main cavity with doormat handling
        is_valve_seat = is_front ? (FRONT_FACE_CUTOUT_STYLE=="VALVE_SEAT") 
                                 : (BACK_FACE_CUTOUT_STYLE=="VALVE_SEAT");
        
        if (!THROUGH_CHANNEL && is_valve_seat && ENABLE_DOORMAT) {
            if (DEBUG_ECHO) echo("    VALVE_SEAT with doormat");
            
            // Subtract cavity minus doormat solid
            difference() {
                // The cavity
                translate([cutout_x_pos, cutout_y_pos, final_cb])
                    color("Red",0.95)
                    cube([cutout_x, cutout_y, cutout_z]);
                
                // Preserve doormat solid UNLESS half-view is cutting it
                if (DOORMAT_HALF_VIEW_ENABLE) {
                    // Half-view: only preserve half the doormat
                    if (DEBUG_ECHO) echo("      Applying half-view to doormat");
                    intersection() {
                        doormat_solid(center_x,
                                  THROUGH_CHANNEL ? (block_width_y - cutout_y)/2 : cutout_y_pos,
                                  final_cb, cutout_x, cutout_y);
                        // Keep only the Y-max half of the doormat
                        translate([center_x - cutout_x, cutout_y_pos + cutout_y/2, final_cb - epsilon])
                            cube([cutout_x*2, cutout_y/2 + epsilon, cutout_z + 2*epsilon]);
                    }
                } else {
                    // Full doormat preservation
                    doormat_solid(center_x,
                                  THROUGH_CHANNEL ? (block_width_y - cutout_y)/2 : cutout_y_pos,
                                  final_cb, cutout_x, cutout_y);
                }
            }
        } else {
            // Standard cavity without doormat
            if (DEBUG_ECHO) echo("    Standard cavity (no doormat)");
            if (!THROUGH_CHANNEL)
                translate([cutout_x_pos, cutout_y_pos, final_cb])
                    color("Red",0.95)
                    cube([cutout_x, cutout_y, cutout_z]);
        }

        // Through-channel slot: opens the lumen on BOTH Y faces so transmitted
        // light can pass straight through for imaging. Cut at the lumen Z band only,
        // so the membrane above and the port stubs stay solid.
        if (THROUGH_CHANNEL) {
            if (DEBUG_ECHO) echo(str("    Through-channel slot: y=-eps to ", block_width_y, "+eps"));
            // Subtract the doormat back out of the slot, exactly as the blind-pocket
            // cavity does -- otherwise the slot removes the doormat it was built around.
            difference() {
                translate([cutout_x_pos, -epsilon, final_cb])
                    color("Coral",0.6)
                    cube([cutout_x, block_width_y + 2*epsilon, cutout_z]);
                if (is_valve_seat && ENABLE_DOORMAT) {
                    // Half-view is a visualisation aid: keep only the Y-max half of the
                    // doormat so the cross-section is visible. Same rule the blind-pocket
                    // branch uses; through mode skips that branch, so repeat it here.
                    if (DOORMAT_HALF_VIEW_ENABLE) {
                        if (DEBUG_ECHO) echo("      Half-view: preserving Y-max half of doormat");
                        intersection() {
                            doormat_solid(center_x,
                                          THROUGH_CHANNEL ? (block_width_y - cutout_y)/2 : cutout_y_pos,
                                          final_cb, cutout_x, cutout_y);
                            translate([center_x - cutout_x,
                                       (THROUGH_CHANNEL ? (block_width_y - cutout_y)/2 : cutout_y_pos)
                                           + cutout_y/2,
                                       final_cb - epsilon])
                                cube([cutout_x*2, cutout_y/2 + epsilon, cutout_z + 2*epsilon]);
                        }
                    } else {
                        doormat_solid(center_x,
                                      THROUGH_CHANNEL ? (block_width_y - cutout_y)/2 : cutout_y_pos,
                                      final_cb, cutout_x, cutout_y);
                    }
                }
            }
        }

        // Visual access slot: extends cutout channel to device face at cutout Z level only.
        // The membrane Z level above remains solid — needle port stubs are preserved.
        if (is_front && cutout_y_pos > 0) {
            if (DEBUG_ECHO) echo(str("    Front visual slot: y=0 to ", cutout_y_pos, " (stub preserved at membrane Z)"));
            translate([cutout_x_pos, 0, final_cb])
                color("Coral",0.6)
                cube([cutout_x, cutout_y_pos, cutout_z]);
        }
        if (!is_front && (cutout_y_pos + cutout_y) < block_width_y) {
            if (DEBUG_ECHO) echo(str("    Back visual slot: y=", cutout_y_pos + cutout_y, " to ", block_width_y, " (stub preserved at membrane Z)"));
            translate([cutout_x_pos, cutout_y_pos + cutout_y, final_cb])
                color("Coral",0.6)
                cube([cutout_x, block_width_y - (cutout_y_pos + cutout_y), cutout_z]);
        }

        membrane_x_pos = center_x - membrane_x/2;

        // FRONT FACE ports and cavities - CONFIGURABLE PORT ROUTING
        if (is_front) {
            // First horizontal port - can go to Y-min or Y-max
            if (upper_chamber_port_1_dir == "Z_MAX") {
                // Port straight up through the top face. Offset in Y from the
                // second Z-port so the two do not intersect.
                if (DEBUG_ECHO) echo("    FRONT FACE: First port to Z-MAX (upward)");
                color("LimeGreen",0.9)
                translate([center_x, cutout_y_center - membrane_y*0.28, up_top - epsilon])
                    cylinder(h=final_block_height_z - up_top + 2*epsilon,
                             d=port_diameter(UPPER_CHAMBER_PORT_1_ROLE));
            } else if (upper_chamber_port_1_dir == "Y_MIN") {
                // Default: Port to Y-min (front)
                port_external_y = -y_extension_front - epsilon;
                port_internal_y = mem_y_min + epsilon;
                port_length = port_internal_y - port_external_y;
                
                if (DEBUG_ECHO) {
                    echo(str("    FRONT FACE: First port to Y-MIN: ", port_external_y, " to ", port_internal_y));
                    echo(str("    Port length: ", port_length, " mm"));
                }
                
                if (port_length > 0) {
                    color("LimeGreen",0.9)
                    translate([center_x, port_external_y, up_center_z])
                        rotate([-90,0,0]) 
                        cylinder(h=port_length, d=port_diameter(UPPER_CHAMBER_PORT_1_ROLE));
                }
            } else {
                // Port to Y-max (back)
                port_internal_y = mem_y_max - epsilon;
                port_external_y = block_width_y + y_extension_back + port_stub(UPPER_CHAMBER_PORT_1_ROLE) + epsilon;
                port_length = port_external_y - port_internal_y;
                
                if (DEBUG_ECHO) {
                    echo(str("    FRONT FACE: First port to Y-MAX: ", port_internal_y, " to ", port_external_y));
                }
                
                if (port_length > 0) {
                    color("LimeGreen",0.9)
                    translate([center_x, port_external_y, up_center_z])
                        rotate([90,0,0]) 
                        cylinder(h=port_length, d=port_diameter(UPPER_CHAMBER_PORT_1_ROLE));
                }
            }

            // Z_MAX port must be concentric with cutout/membrane Y-center
                z_port_y = cutout_y_center
                           + (upper_chamber_port_1_dir == "Z_MAX" ? membrane_y*0.28 : 0);
                if (DEBUG_ECHO) echo(str("    Z_MAX port Y center: ", z_port_y, " (cutout_y_center)"));
            
            // Second port - can go to Y-max or Z-max
            if (upper_chamber_port_2_dir == "Y_MAX") {
                // Second port to Y-max (back)
                if (DEBUG_ECHO) echo("    FRONT FACE: Second port to Y-MAX for flushing");
                
                port_internal_y_back = mem_y_max - epsilon;
                port_external_y_back = block_width_y + y_extension_back + port_stub(UPPER_CHAMBER_PORT_2_ROLE) + epsilon;
                port_length_back = port_external_y_back - port_internal_y_back;
                
                if (DEBUG_ECHO) {
                    echo(str("    Second Y-port: ", port_internal_y_back, " to ", port_external_y_back, " (", port_length_back, " mm)"));
                }
                
                if (port_length_back > 0) {
                    color("Magenta",0.9)
                    translate([center_x, port_external_y_back, up_center_z])
                        rotate([90,0,0]) 
                        cylinder(h=port_length_back, d=port_diameter(UPPER_CHAMBER_PORT_2_ROLE));
                }
            } else {
                // Second port to Z-max (upward)
                if (DEBUG_ECHO) echo("    FRONT FACE: Second port to Z-MAX (upward) for flushing");
                
                color("SpringGreen",0.9)
                translate([center_x, z_port_y, up_top - epsilon])
                    cylinder(h=final_block_height_z - up_top + 2*epsilon, d=port_diameter(UPPER_CHAMBER_PORT_2_ROLE));
            }

            // Upper membrane cavity (always present)
            color("Purple",0.8)
            translate([membrane_x_pos, mem_y_min, up_base])
                cube([membrane_x, membrane_y, membrane_z]);
        }
        // BACK FACE ports and cavities - CONFIGURABLE PORT ROUTING
        else {
            // First horizontal port - can go to Y-max or Y-min
            if (lower_chamber_port_1_dir == "Y_MAX") {
                // Default: Port to Y-max (back)
                port_internal_y = mem_y_max - epsilon;
                port_external_y = block_width_y + y_extension_back + port_stub(LOWER_CHAMBER_PORT_1_ROLE) + epsilon;
                port_length = port_external_y - port_internal_y;
                
                if (DEBUG_ECHO) {
                    echo(str("    BACK FACE: First port to Y-MAX: ", port_internal_y, " to ", port_external_y));
                }
                
                if (port_length > 0) {
                    color("Yellow",0.9)
                    translate([center_x, port_external_y, lo_center_z])
                        rotate([90,0,0]) 
                        cylinder(h=port_length, d=port_diameter(LOWER_CHAMBER_PORT_1_ROLE));
                }
            } else {
                // Port to Y-min (front)
                port_internal_y = mem_y_min + epsilon;
                port_external_y = -y_extension_front - port_stub(LOWER_CHAMBER_PORT_1_ROLE) - epsilon;
                port_length = port_internal_y - port_external_y;
                
                if (DEBUG_ECHO) {
                    echo(str("    BACK FACE: First port to Y-MIN: ", port_external_y, " to ", port_internal_y));
                }
                
                if (port_length > 0) {
                    color("Yellow",0.9)
                    translate([center_x, port_external_y, lo_center_z])
                        rotate([-90,0,0]) 
                        cylinder(h=port_length, d=port_diameter(LOWER_CHAMBER_PORT_1_ROLE));
                }
            }

            // Second port - can go to Y-min or Z-min
            if (lower_chamber_port_2_dir == "Y_MIN") {
                // Second port to Y-min (front)
                if (DEBUG_ECHO) echo("    BACK FACE: Second port to Y-MIN for flushing");
                
                port_internal_y_front = mem_y_min + epsilon;
                port_external_y_front = -y_extension_front - port_stub(LOWER_CHAMBER_PORT_2_ROLE) - epsilon;
                port_length_front = port_internal_y_front - port_external_y_front;
                
                if (DEBUG_ECHO) {
                    echo(str("    Second Y-port: ", port_external_y_front, " to ", port_internal_y_front, " (", port_length_front, " mm)"));
                }
                
                if (port_length_front > 0) {
                    color("Cyan",0.9)
                    translate([center_x, port_external_y_front, lo_center_z])
                        rotate([-90,0,0]) 
                        cylinder(h=port_length_front, d=port_diameter(LOWER_CHAMBER_PORT_2_ROLE));
                }
                
            } else {
                // Second port to Z-min (downward)
                if (DEBUG_ECHO) echo("    BACK FACE: Second port to Z-MIN (downward) for flushing");
                
                // L-duct to Z-port position
                z_port_y = mem_y_max - port_diameter(LOWER_CHAMBER_PORT_2_ROLE)/2;
                
                // Z-port downward
                color("Gold",0.9)
                translate([center_x, z_port_y, -epsilon])
                    cylinder(h=lo_base + 2*epsilon, d=port_diameter(LOWER_CHAMBER_PORT_2_ROLE));
            }

            // Lower membrane cavity (always present)
            color("DarkViolet",0.8)
            translate([membrane_x_pos, mem_y_min, lo_base])
                cube([membrane_x, membrane_y, membrane_z]);
        }
    }
    
    // When UPPER_CHAMBER_PORT_1 exits Y_MIN, the Y_MAX side of the device above
    // the cutout plane is structurally unused. Remove it entirely to reduce material.
    // Slot spans: Z = [up_base, device top], Y = [back_mem_max_y, device Y_MAX]
    if (upper_chamber_port_1_dir == "Y_MIN") {
        back_mem_max_y = block_width_y - y_stub_back;
        slot_z_start   = up_base - epsilon;
        slot_z_height  = final_block_height_z - slot_z_start + epsilon;
        slot_y_start   = back_mem_max_y;
        slot_y_depth   = (block_width_y + y_extension_back) - slot_y_start + epsilon;
        if (DEBUG_ECHO) echo(str("  Y_MIN port back clearance slot: Y=", slot_y_start, " to ", slot_y_start+slot_y_depth, " Z=", slot_z_start, " to ", slot_z_start+slot_z_height));
        color("Orange", 0.5)
        translate([0, slot_y_start, slot_z_start])
            cube([total_length_x, slot_y_depth, slot_z_height]);
    }

    if (DEBUG_ECHO) echo("=== negative_geometry_complete_v30_zlimited END ===");
}


// ===============================================================================
// ================================
// SPHERICAL CUTOUTS MODULE
// ================================
// ===============================================================================

// Creates optional spherical indentations in doormat tops
module create_constrained_spherical_cutouts(
    wall_thickness, block_width_y, total_cutouts, spacing_x,
    cutout_x_mm, cutout_y_mm, final_cb_param, membrane_plane_z_param
){
    // Cut whenever a recess is requested, independently of the doormat: with the
    // doormat on it lands in the doormat top, with it off in the channel floor.
    if (SEAT_SPHERE_ENABLED) {
        if (DEBUG_ECHO) echo("  Creating spherical cutouts");
        for(i=[0:total_cutouts-1]) {
            is_front = THROUGH_CHANNEL ? true : (i%2==0);
            if ((is_front && FRONT_FACE_CUTOUT_STYLE=="VALVE_SEAT") ||
                (!is_front && BACK_FACE_CUTOUT_STYLE=="VALVE_SEAT")) {
                mem_ext_x = max(0, (chamber_x_px(cutout_x_mm/PIXEL_SIZE_CONST)*PIXEL_SIZE_CONST - cutout_x_mm)/2);
                cutout_x_pos = wall_thickness + i*spacing_x;
                cutout_y_pos = THROUGH_CHANNEL ? (block_width_y - cutout_y_mm)/2
                             : is_front ? 0 : (block_width_y - cutout_y_mm);
                center_x = cutout_x_pos + cutout_x_mm/2;

                // Seat surface: the doormat top when there is a doormat, otherwise the
                // channel floor. Penetration is measured down from it in both cases.
                dz = ENABLE_DOORMAT ? DOORMAT_THICKNESS_LAYERS*LAYER_THICKNESS_CONST : 0;

                // Open lumen above the seat, taken from the geometry rather than assumed:
                // membrane plane minus seat top. This is the g of the closure model, so a
                // derived seat follows the channel height and the seat height automatically.
                g_open = membrane_plane_z_param - (final_cb_param + dz);

                // A derived seat scales with THIS device's width; an explicit radius does not.
                seat_R   = SEAT_SPHERE_DERIVED ? seat_radius(g_open, KAPPA, cutout_x_mm)
                                               : DOORMAT_SPHERE_RADIUS;
                seat_pen = SEAT_SPHERE_DERIVED ? seat_depth(g_open, KAPPA, cutout_x_mm)
                                               : DOORMAT_SPHERE_PENETRATION;

                sphere_bottom = final_cb_param + dz - seat_pen;
                sphere_z = sphere_bottom + seat_R;

                if (DEBUG_ECHO && SEAT_SPHERE_DERIVED)
                    echo(str("    Seat derived for W=", round(cutout_x_mm/PIXEL_SIZE_CONST),
                             " px: g=", g_open/LAYER_THICKNESS_CONST, " layers, kappa=", KAPPA,
                             " -> s=", seat_sagitta(g_open, KAPPA, cutout_x_mm),
                             " mm, C=", seat_membrane_width(g_open, KAPPA, cutout_x_mm),
                             " mm, R=", seat_R, " mm, depth=", seat_pen, " mm (",
                             seat_pen/LAYER_THICKNESS_CONST, " layers), recess width=",
                             2*sqrt(max(0, 2*seat_R*seat_pen - seat_pen*seat_pen)), " mm"));
                if (DEBUG_ECHO && SEAT_SPHERE_DERIVED && ENABLE_DOORMAT && seat_pen > dz)
                    echo(str("*** NOTE: the derived recess depth (", seat_pen,
                             " mm) exceeds the doormat thickness (", dz, " mm), so the seat ",
                             "cannot contain it and the recess cuts below the channel floor. ",
                             "Raise DOORMAT_THICKNESS_LAYERS - the paper's recipe leaves a ",
                             "5-layer opening above a seat that fills the rest of the channel ",
                             "height - or narrow the channel."));
                if (DEBUG_ECHO && !SEAT_SPHERE_DERIVED)
                    echo(str("    Sphere #", i, " at X=", center_x, " Z=", sphere_z,
                             " (explicit R=", seat_R, " mm, depth=", seat_pen, " mm)"));

                color("Crimson",0.7)
                intersection() {
                    translate([center_x, cutout_y_pos + cutout_y_mm/2, sphere_z])
                        sphere(r=seat_R);
                    // Floor of the constraint volume: normally just under the channel
                    // floor, but if the requested penetration is deeper than the doormat
                    // the cap genuinely extends below it -- follow the sphere instead of
                    // slicing it off, which is what produced a flat-bottomed seat.
                    // ...and bounded in X and Y by the LUMEN FOOTPRINT. This matters:
                    // the sphere widens as it rises, so above the seat top it is wider than
                    // the channel. Inside the lumen that is harmless (already void), but a
                    // volume wider than the lumen would carve into the solid side walls.
                    // The cube used to be 2x the cutout, which is exactly how the derived
                    // seat cut straight through the walls of the device.
                    let (_cz = min(final_cb_param - z_guard, sphere_bottom - epsilon))
                    translate([center_x - cutout_x_mm/2, cutout_y_pos, _cz])
                        cube([cutout_x_mm, cutout_y_mm, membrane_plane_z_param - _cz]);
                }
            }
        }
    }
}


// ===============================================================================
// ================================
// MICROSCOPE VIEWPORTS MODULE
// ================================
// ===============================================================================

// Creates transparent viewing windows above BACK face cutouts
module create_microscope_viewports(
    cutout_x, cutout_y, cutout_z, wall_thickness, spacing_x, total_cutouts,
    final_cb, final_h, block_width_y,
    mem_ext_x, y_stub_back, membrane_y
){
    if (DEBUG_ECHO) echo("  Creating microscope viewports");
    for (i=[1:2:total_cutouts-1]) {  // Only odd indices (BACK face)
        cutout_x_pos = wall_thickness + mem_ext_x + i*spacing_x;

        // Match negative_geometry BACK face formula exactly:
        // red cutout is centered within its membrane span on the back side.
        red_cutout_y_pos = block_width_y - y_stub_back - (membrane_y + cutout_y)/2;
        red_cutout_y_end = red_cutout_y_pos + cutout_y;

        // Orange viewport starts at top of red cutout and opens to Y-max face.
        vp_y_start = red_cutout_y_pos;   // viewport opens at bottom edge of red cutout
        vp_y_size  = block_width_y - vp_y_start;

        z0 = final_cb + cutout_z;
        zh = final_h - z0 + epsilon;
        
        if (DEBUG_ECHO) echo(str("    Viewport #", i, " at [", cutout_x_pos, ",", vp_y_start, ",", z0, "]"));
        if (DEBUG_ECHO) echo(str("    Viewport Y: ", vp_y_start, " to ", block_width_y, " (size=", vp_y_size, ")"));
        
        if (vp_y_size > 0)
            translate([cutout_x_pos, vp_y_start, z0])
                color("Orange",0.6)
                cube([cutout_x, vp_y_size, zh]);
    }
}


// ===============================================================================
// ================================
// PHYSICAL MARKS MODULE
// ================================
// ===============================================================================

// Creates parameter identification text on device faces
module create_physical_marks_v30(row_idx, col_idx, p1_idx, v1, p2_idx, v2, W, H, Z) {
    if (ENABLE_PHYSICAL_ARRAY_MARKS) {
        if (DEBUG_ECHO) echo(str("  Creating physical marks for [", row_idx, ",", col_idx, "]"));
        
        p1_code = code_of(p1_idx); 
        p2_code = code_of(p2_idx);

        u1 = get_param_unit_type(p1_idx); 
        u2 = get_param_unit_type(p2_idx);
        q1 = (u1==PARAM_UNIT_PIXEL)? round(v1/PIXEL_SIZE_CONST) :
             (u1==PARAM_UNIT_LAYER)? round(v1/LAYER_THICKNESS_CONST) : v1;
        q2 = (u2==PARAM_UNIT_PIXEL)? round(v2/PIXEL_SIZE_CONST) :
             (u2==PARAM_UNIT_LAYER)? round(v2/LAYER_THICKNESS_CONST) : v2;

        t1 = str(p1_code, q1);
        t2 = str(p2_code, q2);

        if (DEBUG_ECHO) echo(str("    Mark texts: '", t1, "' and '", t2, "'"));

        y_pos = 0.25 * H;
        z_pos = Z / 2;
        depth = PHYSICAL_MARK_DEPTH_LAYERS * LAYER_THICKNESS_CONST;
        
        if (DEBUG_ECHO) {
            echo(str("    Mark positioning: Y=", y_pos, " Z=", z_pos, " depth=", depth, "mm"));
            echo(str("    Device dimensions: W=", W, " H=", H, " Z=", Z));
        }

        if (PHYSICAL_MARK_TYPE == "indented") {
            // Indented marks - carved into the device faces
            
            if (THROUGH_CHANNEL) {
                // Run them along Y at the two X edges: the port bores sit on the X centre
                // line, so a centred string collides with them.
                translate([0.6, H/2, Z - depth]) rotate([0, 0, 90])
                    linear_extrude(height=depth + epsilon)
                        text(text=t1, size=PHYSICAL_MARK_TEXT_SIZE_MM,
                             font=PHYSICAL_MARK_TEXT_FONT, halign="center", valign="center");
                translate([W - 0.6, H/2, Z - depth]) rotate([0, 0, 90])
                    linear_extrude(height=depth + epsilon)
                        text(text=t2, size=PHYSICAL_MARK_TEXT_SIZE_MM,
                             font=PHYSICAL_MARK_TEXT_FONT, halign="center", valign="center");
            }
            // X-min face - carve inward in +X direction
            if (!THROUGH_CHANNEL)
            translate([0, y_pos, z_pos])
                rotate([90, -90, 90])
                    linear_extrude(height=depth)
                        text(text=t1, size=PHYSICAL_MARK_TEXT_SIZE_MM,
                             font=PHYSICAL_MARK_TEXT_FONT, halign="center", valign="center");

            // X-max face - carve inward in -X direction
            if (!THROUGH_CHANNEL)
            translate([W - depth, y_pos, z_pos])
                rotate([90, -90, 90])
                    linear_extrude(height=depth)
                        text(text=t2, size=PHYSICAL_MARK_TEXT_SIZE_MM,
                             font=PHYSICAL_MARK_TEXT_FONT, halign="center", valign="center");
        } else {
            // Raised marks - protruding from the device faces
            
            // X-min face - start OUTSIDE device, extrude inward
            translate([-depth, y_pos, z_pos])
                rotate([90, -90, 90])
                    linear_extrude(height=depth)
                        text(text=t1, size=PHYSICAL_MARK_TEXT_SIZE_MM,
                             font=PHYSICAL_MARK_TEXT_FONT, halign="center", valign="center");

            // X-max face - start at device face, extrude outward
            translate([W, y_pos, z_pos])
                rotate([90, -90, 90])
                    linear_extrude(height=depth)
                        text(text=t2, size=PHYSICAL_MARK_TEXT_SIZE_MM,
                             font=PHYSICAL_MARK_TEXT_FONT, halign="center", valign="center");
        }
    }
}


// ===============================================================================
// ================================
// MAIN DEVICE BLOCK MODULE
// ================================
// ===============================================================================

// Builds complete device with Z-limited padding and all features
module membrane_device_solid_block_z_limited(cxp, cyp, czl, mxp, myp, mzl,
                                             row_idx, col_idx, p1_idx, p1_val, p2_idx, p2_val)
{
    if (DEBUG_ECHO) echo("===============================================================================");
    if (DEBUG_ECHO) echo("=== membrane_device_solid_block_z_limited START ===");
    if (DEBUG_ECHO) echo(str("  Parameters: cutout=[", cxp, ",", cyp, ",", czl, "] membrane=[", mxp, ",", myp, ",", mzl, "]"));
    
    //assert(cxp >= MIN_CUTOUT_X_PIXELS && cyp >= MIN_CUTOUT_Y_PIXELS);

    dims = get_device_dimensions_with_z_limits(cxp, cyp, czl, mxp, myp, mzl);
    total_block_length_x = dims[0];
    block_width_y = dims[1];
    final_block_height_z = dims[2];
    y_extension_front = dims[3];
    y_extension_back = dims[4];
    base_membrane_plane = dims[5];
    base_cutout_bottom  = dims[6];
    y_stub_front        = dims[7];
    y_stub_back         = dims[8];

    if (DEBUG_ECHO) echo(str("  Block: ", total_block_length_x, " x ", block_width_y, " x ", final_block_height_z, " mm"));
    if (DEBUG_ECHO) echo(str("  Y padding: front=", y_extension_front, " back=", y_extension_back, " mm"));

    CX = cxp*PIXEL_SIZE_CONST;
    CY = cyp*PIXEL_SIZE_CONST;
    CZ = czl*LAYER_THICKNESS_CONST;
    MX = mxp*PIXEL_SIZE_CONST;
    MY = myp*PIXEL_SIZE_CONST;
    MT = mzl*LAYER_THICKNESS_CONST;
    MZ = MEMBRANE_CAVITY_Z_LAYERS*LAYER_THICKNESS_CONST;
    WX = WALL_THICKNESS_X_PIXELS*PIXEL_SIZE_CONST;

    if (DEBUG_ECHO) echo(str("  LOCAL CALCULATIONS IN membrane_device_solid_block_z_limited:"));
    if (DEBUG_ECHO) echo(str("    Input: cyp=", cyp, " pixels, myp=", myp, " pixels"));
    if (DEBUG_ECHO) echo(str("    PIXEL_SIZE_CONST=", PIXEL_SIZE_CONST, " mm/pixel"));
    if (DEBUG_ECHO) echo(str("    Calculated: CY = ", cyp, " * ", PIXEL_SIZE_CONST, " = ", CY, " mm"));
    if (DEBUG_ECHO) echo(str("    Calculated: MY = ", myp, " * ", PIXEL_SIZE_CONST, " = ", MY, " mm"));
    if (DEBUG_ECHO) echo(str("    MX=", MX, " MZ=", MZ, " MT=", MT, " mm"));

    YDX = floor(MAX_PORT_DIAMETER / PIXEL_SIZE_CONST) * PIXEL_SIZE_CONST;
    YDZ = floor(MAX_PORT_DIAMETER / LAYER_THICKNESS_CONST) * LAYER_THICKNESS_CONST;

    CONTROL_PORT_Y_POSITION = block_width_y*0.25;

    temp_cb = base_cutout_bottom;
    temp_ct = base_membrane_plane;

    ub = temp_ct + MT; 
    ut = ub + MZ;
    lt = temp_cb - MT; 
    lb = lt - MZ;

    _eff_pad_bot = (LOWER_CHAMBER_PORT_2_DIRECTION == "Z_MIN") ?
        max(BLOCK_Z_PADDING_BOTTOM_IN_LAYERS*LAYER_THICKNESS_CONST, port_stub(LOWER_CHAMBER_PORT_2_ROLE)) :
        BLOCK_Z_PADDING_BOTTOM_IN_LAYERS*LAYER_THICKNESS_CONST;
    v_off = _eff_pad_bot - (lb - port_diameter(LOWER_CHAMBER_PORT_2_ROLE)/2);
    
    final_cb = temp_cb + v_off;
    final_ct = temp_ct + v_off;
    up_base  = ub + v_off; 
    up_top   = ut + v_off;
    lo_top   = lt + v_off;
    lo_base  = lb + v_off;

    up_center_z = (up_base + up_top)/2;
    lo_center_z = (lo_base + lo_top)/2;
    
    local_membrane_plane_z = final_ct;

    if (DEBUG_ECHO) echo(str("  Z-LIMITED PADDING: Front pad ABOVE z=", local_membrane_plane_z, ", Back pad BELOW z=", final_cb));
    if (DEBUG_ECHO) echo(str("  Z coords: cb=", final_cb, " ct=", final_ct, " membrane_plane=", local_membrane_plane_z));
    if (DEBUG_ECHO) echo(str("  Upper cavity: base=", up_base, " top=", up_top));
    if (DEBUG_ECHO) echo(str("  Lower cavity: base=", lo_base, " top=", lo_top));
    if (DEBUG_ECHO) echo("  Building CSG: union(core+z-limited-pads) - negatives");

    total_cutouts = THROUGH_CHANNEL ? num_cutouts_per_face : 2*num_cutouts_per_face;
    spacing_x = CX + WX;

    // MAIN CSG STRUCTURE - NO HALF-VIEW ON ENTIRE DEVICE
    difference() {
        // ALL POSITIVE GEOMETRY
        union() {
            // Core block
            if (DEBUG_ECHO) echo(str("  Adding core block: [", total_block_length_x, ",", block_width_y, ",", final_block_height_z, "]"));
            color("LightSteelBlue",0.8)
            cube([total_block_length_x, block_width_y, final_block_height_z]);

            // Front padding (Y-min) - Z-LIMITED
            if (y_extension_front > 0) {
                front_pad_z_start = local_membrane_plane_z - epsilon;
                front_pad_height  = final_block_height_z - front_pad_z_start;
                if (DEBUG_ECHO) echo(str("  Adding front pad: height=", front_pad_height, " mm"));
                color("SteelBlue",0.7)
                translate([0, -y_extension_front, front_pad_z_start])
                    cube([total_block_length_x, y_extension_front, max(0,front_pad_height)]);
            }

            // Back padding (Y-max) - Z-LIMITED
            if (y_extension_back > 0) {
                back_pad_height = max(0, final_cb + epsilon);
                if (DEBUG_ECHO) echo(str("  Adding back pad: height=", back_pad_height, " mm"));
                color("SteelBlue",0.7)
                translate([0, block_width_y, 0])
                    cube([total_block_length_x, y_extension_back, back_pad_height]);
            }

            // Raised marks
            if (ENABLE_PHYSICAL_ARRAY_MARKS && PHYSICAL_MARK_TYPE=="raised") {
                create_physical_marks_v30(row_idx, col_idx, p1_idx, p1_val, p2_idx, p2_val,
                                          total_block_length_x, block_width_y, final_block_height_z);
            }
            
            // Diagonal bracing supports
            if (ENABLE_DIAGONAL_BRACES) {
                create_diagonal_braces(
                    WX, spacing_x, total_cutouts,
                    CX, y_extension_front,
                    final_cb, CZ, local_membrane_plane_z,
                    total_block_length_x  
                );
            }
        }

        // ALL NEGATIVE GEOMETRY
        union() {
            if (DEBUG_ECHO) echo("  Subtracting negative geometry (cavities, ports, ducts)");
            if (DEBUG_ECHO) echo(str("  Passing to negative_geometry: CY=", CY, " mm, MY=", MY, " mm"));
            
            negative_geometry_complete_v30_zlimited(
                CX, CY, CZ,
                MX, MY, MZ,
                YDX, YDZ,
                WX,
                block_width_y, spacing_x, total_cutouts, total_block_length_x,
                final_cb, up_center_z, lo_center_z,
                up_base, up_top, lo_base, lo_top,
                final_block_height_z, CONTROL_PORT_Y_POSITION,
                y_extension_front, y_extension_back,
                y_stub_front, y_stub_back,
                UPPER_CHAMBER_PORT_1_DIRECTION,
                UPPER_CHAMBER_PORT_2_DIRECTION,
                LOWER_CHAMBER_PORT_1_DIRECTION,
                LOWER_CHAMBER_PORT_2_DIRECTION
            );

            // Microscope viewports
            if (CREATE_MICROSCOPE_VIEWPORTS) {
                mem_ext_x = max(0,(MX - CX)/2);
                create_microscope_viewports(
                    CX, CY, CZ, WX, spacing_x, total_cutouts,
                    final_cb, final_block_height_z, block_width_y,
                    mem_ext_x, y_stub_back, MY
                );
            }

            // Indented marks
            if (ENABLE_PHYSICAL_ARRAY_MARKS && PHYSICAL_MARK_TYPE=="indented") {
                create_physical_marks_v30(row_idx, col_idx, p1_idx, p1_val, p2_idx, p2_val,
                                          total_block_length_x, block_width_y, final_block_height_z);
            }

            // Spherical seat (doormat top or channel floor -- see VALVE_SEAT)
            if (SEAT_SPHERE_ENABLED) {
                mem_ext_x = max(0,(MX-CX)/2);
                create_constrained_spherical_cutouts(
                    WX + mem_ext_x, block_width_y, total_cutouts, spacing_x,
                    CX, CY, final_cb, local_membrane_plane_z
                );
            }
        }
    }

    if (DEBUG_ECHO) echo("=== membrane_device_solid_block_z_limited END ===");
    if (DEBUG_ECHO) echo("===============================================================================");
}

// ======================================================================
// INTERNALS-ONLY VIEW (v30 z-limited geometry)
// Shows only the negative geometry (cutouts, cavities, ports, ducts),
// optionally with viewports, indented marks, and doormat spheres.
// ======================================================================
module membrane_device_internals_z_limited(
    cxp, cyp, czl, mxp, myp, mzl,
    row_idx, col_idx, p1_idx, p1_val, p2_idx, p2_val
){
    if (DEBUG_ECHO) echo("===============================================================================");
    if (DEBUG_ECHO) echo("=== membrane_device_internals_z_limited START ===");
    if (DEBUG_ECHO) echo(str("  Parameters: cutout=[", cxp, ",", cyp, ",", czl,
                             "] membrane=[", mxp, ",", myp, ",", mzl, "]"));

    // Same basic validation as solid-block module
    assert(cxp >= MIN_CUTOUT_X_PIXELS && cyp >= MIN_CUTOUT_Y_PIXELS,
           str("ERROR: cutout ", cxp, " x ", cyp, " px is below the minimum printable size (",
               MIN_CUTOUT_X_PIXELS, " x ", MIN_CUTOUT_Y_PIXELS,
               " px). Raise default_cutout_x_size_in_pixels / default_cutout_y_size_in_pixels",
               " (or the sweep range swept_param_1_min / swept_param_1_max if the sweep is driving them)."));

    // Use the same z-limited dimensions helper
    dims = get_device_dimensions_with_z_limits(cxp, cyp, czl, mxp, myp, mzl);
    total_block_length_x = dims[0];
    block_width_y        = dims[1];
    final_block_height_z = dims[2];
    y_extension_front    = dims[3];
    y_extension_back     = dims[4];
    base_membrane_plane  = dims[5];
    base_cutout_bottom   = dims[6];

    // Convert to mm
    CX = cxp * PIXEL_SIZE_CONST;
    CY = cyp * PIXEL_SIZE_CONST;
    CZ = czl * LAYER_THICKNESS_CONST;
    MX = mxp * PIXEL_SIZE_CONST;
    MY = myp * PIXEL_SIZE_CONST;
    MT = mzl * LAYER_THICKNESS_CONST;
    MZ = MEMBRANE_CAVITY_Z_LAYERS * LAYER_THICKNESS_CONST;
    WX = WALL_THICKNESS_X_PIXELS * PIXEL_SIZE_CONST;

    if (DEBUG_ECHO) {
        echo("  LOCAL CALCULATIONS IN membrane_device_internals_z_limited:");
        echo(str("    CY = ", CY, " mm, MY = ", MY, " mm"));
        echo(str("    MX=", MX, " MZ=", MZ, " MT=", MT, " mm"));
    }

    // Quantized port sizes
    YDX = floor(MAX_PORT_DIAMETER / PIXEL_SIZE_CONST)      * PIXEL_SIZE_CONST;
    YDZ = floor(MAX_PORT_DIAMETER / LAYER_THICKNESS_CONST) * LAYER_THICKNESS_CONST;

    // Same control-port Y as solid block
    CONTROL_PORT_Y_POSITION = block_width_y * 0.25;

    // Reconstruct cavity Z coordinates with z-offset
    temp_cb = base_cutout_bottom;
    temp_ct = base_membrane_plane;

    ub = temp_ct + MT;
    ut = ub + MZ;
    lt = temp_cb - MT;
    lb = lt - MZ;

    _eff_pad_bot = (LOWER_CHAMBER_PORT_2_DIRECTION == "Z_MIN") ?
        max(BLOCK_Z_PADDING_BOTTOM_IN_LAYERS*LAYER_THICKNESS_CONST, MIN_NEEDLE_PORT_STUB_LENGTH) :
        BLOCK_Z_PADDING_BOTTOM_IN_LAYERS*LAYER_THICKNESS_CONST;
    v_off = _eff_pad_bot - (lb - port_diameter(LOWER_CHAMBER_PORT_2_ROLE)/2);

    final_cb = temp_cb + v_off;
    final_ct = temp_ct + v_off;
    up_base  = ub + v_off;
    up_top   = ut + v_off;
    lo_top   = lt + v_off;
    lo_base  = lb + v_off;

    up_center_z = (up_base + up_top) / 2;
    lo_center_z = (lo_base + lo_top) / 2;

    local_membrane_plane_z = final_ct;

    if (DEBUG_ECHO) {
        echo(str("  INTERNALS: cb=", final_cb,
                 " ct=", final_ct, " membrane_plane=", local_membrane_plane_z));
        echo(str("  Upper cavity: base=", up_base, " top=", up_top));
        echo(str("  Lower cavity: base=", lo_base, " top=", lo_top));
    }

    total_cutouts = THROUGH_CHANNEL ? num_cutouts_per_face : 2 * num_cutouts_per_face;
    spacing_x     = CX + WX;

    if (DEBUG_ECHO) echo("  Building INTERNALS ONLY geometry");

    // Show only negative + helper geometry (NO outer block)
    union() {

        // Core negative geometry: cutouts, membrane cavities, ducts, ports
        negative_geometry_complete_v30_zlimited(
            CX, CY, CZ,
            MX, MY, MZ,
            YDX, YDZ,
            WX,
            block_width_y, spacing_x, total_cutouts, total_block_length_x,
            final_cb, up_center_z, lo_center_z,
            up_base, up_top, lo_base, lo_top,
            final_block_height_z, CONTROL_PORT_Y_POSITION,
            y_extension_front, y_extension_back,
            y_stub_front, y_stub_back,
            UPPER_CHAMBER_PORT_1_DIRECTION,
            UPPER_CHAMBER_PORT_2_DIRECTION,
            LOWER_CHAMBER_PORT_1_DIRECTION,
            LOWER_CHAMBER_PORT_2_DIRECTION
        );

        // Microscope viewports (still “negative” features)
        if (CREATE_MICROSCOPE_VIEWPORTS) {
            mem_ext_x = max(0, (MX - CX) / 2);
            create_microscope_viewports(
                CX, CY, CZ, WX, spacing_x, total_cutouts,
                final_cb, final_block_height_z, block_width_y,
                mem_ext_x, y_stub_back, MY
            );
        }

        // Indented physical marks (also negative geometry)
        if (ENABLE_PHYSICAL_ARRAY_MARKS && PHYSICAL_MARK_TYPE == "indented") {
            create_physical_marks_v30(
                row_idx, col_idx, p1_idx, p1_val, p2_idx, p2_val,
                total_block_length_x, block_width_y, final_block_height_z
            );
        }

        // Spherical seat (doormat top or channel floor -- see VALVE_SEAT)
        if (SEAT_SPHERE_ENABLED) {
            mem_ext_x = max(0, (MX - CX) / 2);
            create_constrained_spherical_cutouts(
                WX + mem_ext_x, block_width_y, total_cutouts, spacing_x,
                CX, CY, final_cb, local_membrane_plane_z
            );
        }
    }

    if (DEBUG_ECHO) echo("=== membrane_device_internals_z_limited END ===");
    if (DEBUG_ECHO) echo("===============================================================================");
}


// ===============================================================================
// ================================
// ARRAY DIMENSIONS CALCULATOR
// ================================
// ===============================================================================

// Calculates individual device dimensions including padding
function calc_individual_array_dimensions(cxp,cyp,czl,mxp,myp,mzl) =
let(
    _d1 = DEBUG_ECHO ? echo("=== calc_individual_array_dimensions START ===") : 0,
    d = get_device_dimensions_with_z_limits(cxp,cyp,czl,mxp,myp,mzl),
    _d2 = DEBUG_ECHO ? echo(str("  Individual dimensions: [", d[0], ", ", d[1] + d[3] + d[4], ", ", d[2], "]")) : 0,
    _d3 = DEBUG_ECHO ? echo("=== calc_individual_array_dimensions END ===") : 0
) [d[0], d[1] + d[3] + d[4], d[2]];


// ===============================================================================
// ================================
// PARAMETER GRID GENERATOR MODULE
// ================================
// ===============================================================================

// Main array generator - creates grid of devices with parameter sweep
// Per-column geometry, so a width sweep can be packed without overlap: the pitch
// has to follow each device's own width, not one pitch taken from the default device.
function _cxp_of(c) = round(get_param_val_with_cycling(
        SWEEP1_min, SWEEP1_max, SWEEP1_steps, c,
        get_param_unit_type(SWEEP1_idx)) / PIXEL_SIZE_CONST);
function _cyp_of(c) = SQUARE_CUTOUT ? _cxp_of(c) : default_cutout_y_size_in_pixels;
function _dev_w(c) = calc_individual_array_dimensions(
        _cxp_of(c), _cyp_of(c), default_cutout_z_size_in_layers,
        chamber_x_px(_cxp_of(c)),
        chamber_y_px(_cyp_of(c)),
        default_membrane_z_thickness_layer_multiple)[0];
function _x_off(c) = c <= 0 ? 0 : _x_off(c-1) + _dev_w(c-1) + MIN_GAP_X_MM;

module swept_parameter_grid_generator(){
    if (DEBUG_ECHO) echo("===============================================================================");
    if (DEBUG_ECHO) echo("=== swept_parameter_grid_generator START ===");
    
    dims0 = calc_individual_array_dimensions(
        default_cutout_x_size_in_pixels,
        default_cutout_y_size_in_pixels,
        default_cutout_z_size_in_layers,
        default_membrane_cavity_x_pixel_multiple,
        default_membrane_cavity_y_pixel_multiple,
        default_membrane_z_thickness_layer_multiple
    );
    IND_W = dims0[0]; 
    IND_H = dims0[1];

    if (DEBUG_ECHO) echo(str("  Default array size: ", IND_W, " x ", IND_H, " mm"));

    FULL_COLS = max(1, floor((AVAILABLE_BUILD_PLATE_X_SIZE + MIN_GAP_X_MM)/(IND_W + MIN_GAP_X_MM)));
    FULL_ROWS = max(1, floor((AVAILABLE_BUILD_PLATE_Y_SIZE + MIN_GAP_Y_MM)/(IND_H + MIN_GAP_Y_MM)));

    COLS = DEBUG_ARRAY_MODE==0?min(FULL_COLS, REQUESTED_COLS):DEBUG_ARRAY_MODE==1?1:2;
    // Always one row -- see the note by the width sweep. Mode 2 is the on-screen
    // 2x2 sweep preview only; it is not a layout to print.
    ROWS = DEBUG_ARRAY_MODE==2 ? 2 : 1;

    // Tell the user when the build plate, not their request, decided the count.
    if (DEBUG_ARRAY_MODE==0 && COLS < REQUESTED_COLS)
        echo(str("*** WARNING: ", REQUESTED_COLS, " devices requested but only ", COLS,
                 " fit the build plate. Narrow the range, raise WIDTH_STEP_PX, or run ",
                 "the sweep in batches."));
    if (DEBUG_ARRAY_MODE==0 && WIDTH_SWEEP_ENABLE)
        echo(str("  Width sweep: ", COLS, " device(s) from ", WIDTH_MIN_PX, " to ",
                 WIDTH_SWEEP_LAST_PX, " px in steps of ", WIDTH_STEP_PX,
                 WIDTH_SWEEP_LAST_PX != WIDTH_MAX_PX
                   ? str(" (WIDTH_MAX_PX = ", WIDTH_MAX_PX,
                         " is not reached: the range does not divide evenly by the interval)")
                   : ""));

    if (DEBUG_ECHO) echo(str("  Grid: ", COLS, " cols x ", ROWS, " rows"));
    if (DEBUG_ECHO && DEBUG_ARRAY_MODE==1) echo("  DEBUG MODE 1: Displaying single device with EXACT user default parameters");

    SPX = IND_W + MIN_GAP_X_MM; 
    SPY = IND_H + MIN_GAP_Y_MM;
    START_X = (BUILD_PLATE_X_SIZE - (COLS-1)*SPX - IND_W)/2;
    START_Y = (BUILD_PLATE_Y_SIZE - (ROWS-1)*SPY - IND_H)/2;

    if (DEBUG_ECHO) echo(str("  Grid spacing: X=", SPX, " Y=", SPY, " mm"));
    if (DEBUG_ECHO) echo(str("  Grid start: X=", START_X, " Y=", START_Y, " mm"));

    // MODE 1: Single device with EXACT user defaults (bypass sweep entirely)
    if (DEBUG_ARRAY_MODE == 1) {
        if (DEBUG_ECHO) echo("  === Single Device Mode - Using User Defaults ===");
        
        cxp = default_cutout_x_size_in_pixels;
        cyp = default_cutout_y_size_in_pixels;
        czl = default_cutout_z_size_in_layers;
        mxp = default_membrane_cavity_x_pixel_multiple;
        myp = default_membrane_cavity_y_pixel_multiple;
        mzl = default_membrane_z_thickness_layer_multiple;
        
        if (DEBUG_ECHO) {
            echo(str("    User defaults: cutout=[", cxp, ",", cyp, ",", czl, "] pixels/layers"));
            echo(str("    User defaults: membrane=[", mxp, ",", myp, ",", mzl, "] pixels/layers"));
        }
        
      translate([START_X, START_Y, 0]) {
          if (CONFIGURATION_SETTING == "solid") {
              membrane_device_solid_block_z_limited(
                  cxp,
                  SQUARE_CUTOUT ? cxp : cyp,
                  czl,
                  chamber_x_px(cxp),
                  chamber_y_px(SQUARE_CUTOUT ? cxp : cyp),
                  mzl,
                  0, 0,
                  PARAM_CUTOUT_X, cxp*PIXEL_SIZE_CONST,
                  PARAM_CUTOUT_Y, (SQUARE_CUTOUT ? cxp : cyp)*PIXEL_SIZE_CONST
              );
          } else {
              membrane_device_internals_z_limited(
                  cxp,
                  SQUARE_CUTOUT ? cxp : cyp,
                  czl,
                  chamber_x_px(cxp),
                  chamber_y_px(SQUARE_CUTOUT ? cxp : cyp),
                  mzl,
                  0, 0,
                  PARAM_CUTOUT_X, cxp*PIXEL_SIZE_CONST,
                  PARAM_CUTOUT_Y, (SQUARE_CUTOUT ? cxp : cyp)*PIXEL_SIZE_CONST
              );
          }
      }

    }
    // MODE 0 or 2: Array with parameter sweep
    else {
        for (r=[0:ROWS-1]) {
            for (c=[0:COLS-1]) {
                if (DEBUG_ECHO) echo(str("  === Processing grid position [", r, ",", c, "] ==="));
                
                u1 = get_param_unit_type(SWEEP1_idx);
                u2 = get_param_unit_type(SWEEP2_idx);
                
                v1 = (DEBUG_ARRAY_MODE==0) ? get_param_val_with_cycling(SWEEP1_min,SWEEP1_max,SWEEP1_steps,c,u1)
                    : (c==0 ? SWEEP1_min : SWEEP1_max)*(u1==PARAM_UNIT_PIXEL?PIXEL_SIZE_CONST:LAYER_THICKNESS_CONST);

                v2 = (DEBUG_ARRAY_MODE==0) ? get_param_val_with_cycling(swept_param_2_min,swept_param_2_max,swept_param_2_steps,r,u2)
                    : (r==0 ? swept_param_2_min : swept_param_2_max)*(u2==PARAM_UNIT_PIXEL?PIXEL_SIZE_CONST:LAYER_THICKNESS_CONST);

                if (DEBUG_ECHO) echo(str("    Param 1 (", code_of(SWEEP1_idx), "): ", v1, " mm"));
                if (DEBUG_ECHO) echo(str("    Param 2 (", code_of(SWEEP2_idx), "): ", v2, " mm"));

                cxp = (SWEEP1_idx==PARAM_CUTOUT_X)?round(v1/PIXEL_SIZE_CONST):
                      (SWEEP2_idx==PARAM_CUTOUT_X)?round(v2/PIXEL_SIZE_CONST):default_cutout_x_size_in_pixels;
                cyp = (SWEEP1_idx==PARAM_CUTOUT_Y)?round(v1/PIXEL_SIZE_CONST):
                      (SWEEP2_idx==PARAM_CUTOUT_Y)?round(v2/PIXEL_SIZE_CONST):default_cutout_y_size_in_pixels;
                czl = (SWEEP1_idx==PARAM_CUTOUT_Z)?round(v1/LAYER_THICKNESS_CONST):
                      (SWEEP2_idx==PARAM_CUTOUT_Z)?round(v2/LAYER_THICKNESS_CONST):default_cutout_z_size_in_layers;

                mxp = (SWEEP1_idx==PARAM_MEMBRANE_X)?round(v1/PIXEL_SIZE_CONST):
                      (SWEEP2_idx==PARAM_MEMBRANE_X)?round(v2/PIXEL_SIZE_CONST):default_membrane_cavity_x_pixel_multiple;
                myp = (SWEEP1_idx==PARAM_MEMBRANE_Y)?round(v1/PIXEL_SIZE_CONST):
                      (SWEEP2_idx==PARAM_MEMBRANE_Y)?round(v2/PIXEL_SIZE_CONST):default_membrane_cavity_y_pixel_multiple;
                mzl = (SWEEP1_idx==PARAM_MEMBRANE_Z)?round(v1/LAYER_THICKNESS_CONST):
                      (SWEEP2_idx==PARAM_MEMBRANE_Z)?round(v2/LAYER_THICKNESS_CONST):default_membrane_z_thickness_layer_multiple;

                tx = START_X + (THROUGH_CHANNEL ? _x_off(c) : c*SPX); 
                ty = START_Y + r*SPY;
                
                if (DEBUG_ECHO) echo(str("    Placing device at [", tx, ",", ty, ",0]"));
                // Report the values that are actually passed to the builder below --
                // cyp is overridden by SQUARE_CUTOUT and the chamber is derived per
                // device, so printing the raw sweep values here misreports the build.
                if (DEBUG_ECHO) echo(str("    Device params: cutout=[", cxp, ",",
                    SQUARE_CUTOUT ? cxp : cyp, ",", czl, "] chamber=[",
                    chamber_x_px(cxp), ",", chamber_y_px(SQUARE_CUTOUT ? cxp : cyp),
                    "] membrane_layers=", mzl,
                    SQUARE_CUTOUT ? "  (cutout Y = X: SQUARE_CUTOUT)" : ""));
                
            translate([tx,ty,0]) {
                if (CONFIGURATION_SETTING == "solid") {
                    membrane_device_solid_block_z_limited(
                        cxp,
                        SQUARE_CUTOUT ? cxp : cyp,
                        czl,
                        chamber_x_px(cxp),
                        chamber_y_px(SQUARE_CUTOUT ? cxp : cyp),
                        mzl,
                        r, c,
                        PARAM_CUTOUT_X, cxp*PIXEL_SIZE_CONST,
                        PARAM_CUTOUT_Y, (SQUARE_CUTOUT ? cxp : cyp)*PIXEL_SIZE_CONST
                    );
                } else {
                    membrane_device_internals_z_limited(
                        cxp,
                        SQUARE_CUTOUT ? cxp : cyp,
                        czl,
                        chamber_x_px(cxp),
                        chamber_y_px(SQUARE_CUTOUT ? cxp : cyp),
                        mzl,
                        r, c,
                        PARAM_CUTOUT_X, cxp*PIXEL_SIZE_CONST,
                        PARAM_CUTOUT_Y, (SQUARE_CUTOUT ? cxp : cyp)*PIXEL_SIZE_CONST
                    );
                }
            }

            }
        }
    }
    
    if (DEBUG_ECHO) echo("=== swept_parameter_grid_generator END ===");
    if (DEBUG_ECHO) echo("===============================================================================");
}


// ===============================================================================
// ================================
// MAIN EXECUTION
// ================================
// ===============================================================================

if (DEBUG_ECHO) {
    echo("===============================================================================");
    echo("=== MEMBRANE DEVICE V30 FIXED - DOORMAT HALF-VIEW PROPERLY SCOPED ===");
    echo("=== CRITICAL FIX: Half-view only affects doormat, not entire device ===");
    echo("===   - Front padding (Y-min): Only ABOVE squeeze cutout top ===");
    echo("===   - Back padding (Y-max): Only BELOW microscopy cutout bottom ===");
    echo("===   - Doormat half-view cuts ONLY the doormat for visualization ===");
    echo(str("===   - Front face ports: ", UPPER_CHAMBER_PORT_1_DIRECTION, " + ", UPPER_CHAMBER_PORT_2_DIRECTION));
    echo(str("===   - Back face ports: ", LOWER_CHAMBER_PORT_1_DIRECTION, " + ", LOWER_CHAMBER_PORT_2_DIRECTION));
    echo(str("===   - Y-padding: Front=", YMIN_PADDING_Y_THICKNESS > 0 ? str(YMIN_PADDING_Y_THICKNESS, " mm (override)") : "auto",
             ", Back=", YMAX_PADDING_Y_THICKNESS > 0 ? str(YMAX_PADDING_Y_THICKNESS, " mm (override)") : "auto"));
    echo(str("===   - Diagonal braces: ", ENABLE_DIAGONAL_BRACES ? "ENABLED" : "DISABLED"));
    echo(str("===   - Diagonal Brace Axis Fix: Applied 90 deg rotation about +X with CORRECTED Y-translation. ==="));
    echo(str("===   - DEBUG_ARRAY_MODE = ", DEBUG_ARRAY_MODE, ": ", 
             DEBUG_ARRAY_MODE==0 ? "FULL ARRAY with parameter sweep" :
             DEBUG_ARRAY_MODE==1 ? "SINGLE DEVICE with USER DEFAULTS (exact match)" :
             "2x2 GRID showing sweep min/max"));
    echo("===============================================================================");
}

// Describes the DEFAULT device only. In a width sweep each device derives its own
// chamber from its own lumen, so the numbers below do not apply there.
echo(str(DEBUG_ARRAY_MODE == 0
             ? "CHAMBER (default device; each swept device derives its own): X = "
             : "CHAMBER: X = ", chamber_x_px(default_cutout_x_size_in_pixels),
         " px, Y = ", chamber_y_px(default_cutout_y_size_in_pixels),
         " px  (source: ",
         SEAT_SPHERE_DERIVED
             ? "required membrane width C from the closure model, so the membrane chord matches the chamber walls"
             : chamber_x_px(default_cutout_x_size_in_pixels) == default_membrane_cavity_x_pixel_multiple
                 ? "explicit default_membrane_cavity_*_pixel_multiple"
                 : str("MEMBRANE_MARGIN_PX = ", MEMBRANE_MARGIN_PX, ", i.e. cutout + margin"), ")"));

swept_parameter_grid_generator();

if (DEBUG_ECHO) {
    echo("===============================================================================");
    echo("=== EXECUTION COMPLETE ===");
    echo("===============================================================================");
}

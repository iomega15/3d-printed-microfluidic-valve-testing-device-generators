///////////////////////////////////////////////////////////////////////////////

// ================================
// DEBUG CONFIGURATION FLAGS
// ================================
DEBUG_MODE = true;                  // Enable comprehensive debug output
DEBUG_GEOMETRY = true;              // Log geometry calculations
DEBUG_LABELS = true;                // Log label autoscaling calculations
DEBUG_VALIDATION = true;            // Enable runtime validation checks
DEBUG_TEXT_METRICS = true;          // Log text size calculations

// ================================
// USER INPUTS - MODIFY THESE ONLY
// ================================

/* --- Printer & resolution (physical units) --- */
PIXEL_SIZE        = 0.032;          // [mm/px] projector pixel size in XY
LAYER_THICKNESS   = 0.05;          // [mm/layer] slice height in Z

/* --- Array layout --- */
array_cells_x     = 10;              // [count] columns (X)
array_cells_y     = 4;              // [count] rows (Y)

/* --- Safety buffers (outer-to-outer clearances during compact packing) --- */
safety_buffer_x_pixels = 0;         // [px] horizontal buffer added between columns
safety_buffer_y_pixels = 0;         // [px] vertical buffer added between rows

// Add near top with other constants
//OVERLAP_MM = 0.002;  // [mm] tiny overlap for seamless fusion when buffer=0


/* --- Rectangular post geometry (defaults, before sweeps) --- */
DEFAULT_post_size_x_pixels = 40;     // [px] sx baseline (X width of a post)
DEFAULT_post_size_y_pixels = 40;     // [px] sy baseline (Y depth of a post)
DEFAULT_post_height_layers = 5;     // [layers] post height

/* --- Intra-cell gaps (defaults, before sweeps) --- */
DEFAULT_intra_cell_posts_gap_X_pixels = 100  ; // [px] gap between left/right post pairs (X)
DEFAULT_intra_cell_posts_gap_Y_pixels = 0; // [px] gap between bottom/top post pairs (Y)

/* --- Membrane (inner film, drawn on top of posts) --- */
DEFAULT_membrane_Z_thickness_layers = 1;   // [layers] (0 disables membranes)
// Fractional overlap into posts (0 = only void; >0 intrudes into posts)
DEFAULT_membrane_post_coverage_x  = 1;     // [fraction of sx] along X
DEFAULT_membrane_post_coverage_y  = 1;     // [fraction of sy] along Y



/* --- Two-Selector, Unit-Aware Sweeps (SWEPT) ---
   Choose any TWO labels (one per selector). Native units per label:
   
   Absolute (sets parameter directly):
     • "post_size_x"                                 [px]
     • "post_size_y"                                 [px]
     • "intra_cell_post_gap_x"                       [px] (gap between cell columns (X))
     • "intra_cell_post_gap_y"                       [px] (gap between cell rows (Y))
     • "membrane_post_coverage_x"                    [0 to 1 fraction]
     • "membrane_post_coverage_y"                    [0 to 1 fraction]
     • "membrane_thickness_layers"                   [layers]
     • "post_height_layers"                          [layers]
     • "cell_aspect_ratio_post_Z_to_cell_gap_X"      [layers/px]  (post_Z : gap_X) - 2nd swept variable must be one of the variables in this ratio to make senes, otherwise nothing will be swept over 
     • "cell_aspect_ratio_post_Z_to_cell_gap_Y"      [layers/px]  (post_Z : gap_Y) - 2nd swept variable must be one of the variables in this ratio to make senes, otherwise nothing will be swept over
   
   Coupled / scale (unitless ratio; multiplies parameters relative to their DEFAULTs):
     • "post_size_scale_both_xy"                     [fraction]
     • "intra_cell_post_gap_scale_both_xy"           [fraction]
     • "membrane_post_coverage_both_xy"              [fraction]
       (special handling: if the default coverage is 0, the scale is
        interpreted as an ABSOLUTE coverage value in [0,1])

   NEW Coupled aspect-preserving scalers (unitless ratio; multiplies DEFAULTs):
     • "post_Z_and_cell_gap_X_scale_both"            [ratio]  // scales DEFAULT_post_height_layers and DEFAULT_intra_cell_posts_gap_X_pixels together
     • "post_Z_and_cell_gap_Y_scale_both"            [ratio]  // scales DEFAULT_post_height_layers and DEFAULT_intra_cell_posts_gap_Y_pixels together

   Sweep A varies by COLUMN (cx); Sweep B varies by ROW (cy).
   If a selector is not used, set its label to "".
   If both selectors target the same label, the cell uses MAX(base, A, B).
*/
SWEPT_A_label = "membrane_thickness_layers";  // "", or any label above
SWEPT_A_min   = 1;                     // native unit of SWEPT_A_label
SWEPT_A_max   = 10;                    // native unit of SWEPT_A_label
SWEPT_A_step  = 1;                    // per-column increment

SWEPT_B_label = "post_height_layers";  // "", or any label above
SWEPT_B_min   = 5;                     // native unit of SWEPT_B_label
SWEPT_B_max   = 5;                     // native unit of SWEPT_B_label
SWEPT_B_step  = 1;                     // per-row increment

/* --- Edge Labels (optional) ---
   Right (Xmax) explains rows / Sweep B
   Top   (Ymax) explains columns / Sweep A */
enable_edge_labels           = false;                 // show labels?
edge_label_style             = "indented";             // "raised" | "indented"
edge_label_font              = "Liberation Sans";    // installed font

// AUTOSCALING: These are NOT used directly - text size is calculated automatically
edge_label_thickness_mm      = 0.2;                 // raised thickness (mm)
edge_label_indent_mm         = 0.2;                 // indent depth (mm)

// Space allocated for labels (in pixels - converted to mm internally)
label_margin_right_pixels    = 10;   // [px] space on +X (for ROW label / Sweep B)
label_margin_top_pixels      = 10;   // [px] space on +Y (for COL label / Sweep A)

// Minimum gap between array and text (safety margin)
label_safety_gap_mm          = 0.1;  // [mm] minimum gap between array and text

/* --- Base plate (optional) --- */
draw_base_plate         = true;
base_plate_thick_layers = 50;      // [layers]

// ================================
// CALCULATED VALUES - AUTO-COMPUTED
// ================================
px = PIXEL_SIZE;                           // [mm/px]
mm_buffer_x = safety_buffer_x_pixels * px; // [mm]
mm_buffer_y = safety_buffer_y_pixels * px; // [mm]

post_h_mm = DEFAULT_post_height_layers * LAYER_THICKNESS; // [mm]

label_margin_right_mm = label_margin_right_pixels * px;
label_margin_top_mm   = label_margin_top_pixels * px;

// Echo all calculated base values for debugging
echo("======== CALCULATED BASE VALUES ========");
echo("px (mm/pixel):", px);
echo("mm_buffer_x:", mm_buffer_x, "mm");
echo("mm_buffer_y:", mm_buffer_y, "mm");
echo("post_h_mm:", post_h_mm, "mm");
echo("label_margin_right_mm:", label_margin_right_mm, "mm");
echo("label_margin_top_mm:", label_margin_top_mm, "mm");

// Replace the OVERLAP_MM line with:
OVERLAP_MM = LAYER_THICKNESS;  // Use one layer thickness - guaranteed to merge properly

// And simplify the overlap logic - apply to the SIZE only, not position:
overlap_x = (safety_buffer_x_pixels == 0) ? OVERLAP_MM : 0;
overlap_y = (safety_buffer_y_pixels == 0) ? OVERLAP_MM : 0;
// ================================
// HELPER FUNCTIONS WITH VALIDATION
// ================================

function clamp(x, lo, hi) = min(max(x, lo), hi);

// Robust max over a list (OpenSCAD 2021.01 compatible — no slicing)
function list_max(v) = list_max_i(v, 0);
function list_max_i(v, i) =
    (len(v) == 0)            ? 0 :                 // define a value for empty lists
    (i >= len(v) - 1)        ? v[i] :              // last element -> return it
                               max(v[i], list_max_i(v, i + 1));


// base value for a label, in its native unit
function base_value_for_label(label) =
    label == "post_size_x"                                 ? DEFAULT_post_size_x_pixels :
    label == "post_size_y"                                 ? DEFAULT_post_size_y_pixels :
    label == "intra_cell_post_gap_x"                       ? DEFAULT_intra_cell_posts_gap_X_pixels :
    label == "intra_cell_post_gap_y"                       ? DEFAULT_intra_cell_posts_gap_Y_pixels :
    label == "membrane_post_coverage_x"                    ? DEFAULT_membrane_post_coverage_x :
    label == "membrane_post_coverage_y"                    ? DEFAULT_membrane_post_coverage_y :
    label == "membrane_thickness_layers"                   ? DEFAULT_membrane_Z_thickness_layers :
    label == "post_height_layers"                          ? DEFAULT_post_height_layers :
    // NEW aspect-ratio sweep labels default to 1 (layers/px)
    label == "cell_aspect_ratio_post_Z_to_cell_gap_X"      ? 0 :
    label == "cell_aspect_ratio_post_Z_to_cell_gap_Y"      ? 0 :
    // Existing scalers (unitless)
    label == "post_size_scale_both_xy"                     ? 1 :    // ratio
    label == "intra_cell_post_gap_scale_both_xy"           ? 1 :    // ratio
    // NEW coupled aspect-preserving scalers (unitless, multiply DEFAULTs)
    label == "post_Z_and_cell_gap_X_scale_both"            ? 1 :
    label == "post_Z_and_cell_gap_Y_scale_both"            ? 1 :
    // IMPORTANT: scale default 0 so it doesn't force ≥1 coverage
    label == "membrane_post_coverage_both_xy"              ? 0 : // ratio (0 means "no scaling" when base==0)
    0;

// sweep values in native units
function SWEPT_A_value_at(cx) =
    clamp(SWEPT_A_min + cx*SWEPT_A_step, min(SWEPT_A_min,SWEPT_A_max), max(SWEPT_A_min,SWEPT_A_max));
function SWEPT_B_value_at(cy) =
    clamp(SWEPT_B_min + cy*SWEPT_B_step, min(SWEPT_B_min,SWEPT_B_max), max(SWEPT_B_min,SWEPT_B_max));

// final (native-unit) value for a label at a cell, using MAX(base, A?, B?)
function value_for_label_at_cell(label, cx, cy) =
    let(base = base_value_for_label(label),
        a    = (SWEPT_A_label == label) ? SWEPT_A_value_at(cx) : base,
        b    = (SWEPT_B_label == label) ? SWEPT_B_value_at(cy) : base)
    max(base, a, b);

// Coupled scale factors (unitless ratios)
function size_scale_at(cx,cy)   = value_for_label_at_cell("post_size_scale_both_xy", cx, cy);
function gap_scale_at(cx,cy)    = value_for_label_at_cell("intra_cell_post_gap_scale_both_xy", cx, cy);

// NEW: aspect-preserving coupled scalers (unitless ratios; multiply DEFAULTs)
function z_gapX_coupled_scale_at(cx,cy) = value_for_label_at_cell("post_Z_and_cell_gap_X_scale_both", cx, cy);
function z_gapY_coupled_scale_at(cx,cy) = value_for_label_at_cell("post_Z_and_cell_gap_Y_scale_both", cx, cy);

// Coverage scale handling:
// If base coverage is zero, treat scale as ABSOLUTE coverage in [0,1].
// Else, multiply the base by scale. Always clamp to [0,1].
function cov_scaled_candidate(cx, cy, base_cov) =
    let(scale = value_for_label_at_cell("membrane_post_coverage_both_xy", cx, cy))
    min(1, max(0, base_cov > 0 ? base_cov * scale : scale));

/* ---- Resolve concrete parameters at (cx,cy) ---- */

// Absolute candidates (native units)
function sx_abs_px_at(cx,cy)    = value_for_label_at_cell("post_size_x", cx, cy);
function sy_abs_px_at(cx,cy)    = value_for_label_at_cell("post_size_y", cx, cy);
function gx_abs_px_at(cx,cy)    = value_for_label_at_cell("intra_cell_post_gap_x", cx, cy);
function gy_abs_px_at(cx,cy)    = value_for_label_at_cell("intra_cell_post_gap_y", cx, cy);
function covx_abs_at(cx,cy)     = value_for_label_at_cell("membrane_post_coverage_x", cx, cy);
function covy_abs_at(cx,cy)     = value_for_label_at_cell("membrane_post_coverage_y", cx, cy);
function mem_layers_at(cx,cy)   = value_for_label_at_cell("membrane_thickness_layers", cx, cy);

/* ======== COUPLED Z+GAP SCALE LOGIC (Option A: relative to DEFAULTs) ======== */
// These scales multiply the DEFAULT values of post height (layers) and the corresponding gap (pixels),
// and are then merged with other sources via MAX (so they never reduce a value).

function post_layers_at(cx,cy) =
    let(
        base_layers = value_for_label_at_cell("post_height_layers", cx, cy),
        ratioX_AR   = value_for_label_at_cell("cell_aspect_ratio_post_Z_to_cell_gap_X", cx, cy),
        ratioY_AR   = value_for_label_at_cell("cell_aspect_ratio_post_Z_to_cell_gap_Y", cx, cy),
        // Aspect-based derived heights (layers) if those AR labels are used
        derivedX_AR = (ratioX_AR > 0) ? ratioX_AR * gx_px_at(cx,cy) : 0,
        derivedY_AR = (ratioY_AR > 0) ? ratioY_AR * gy_px_at(cx,cy) : 0,
        // NEW coupled scalers relative to DEFAULTs
        z_gapX_scale = z_gapX_coupled_scale_at(cx,cy),
        z_gapY_scale = z_gapY_coupled_scale_at(cx,cy),
        derivedX_coupled = DEFAULT_post_height_layers * z_gapX_scale,
        derivedY_coupled = DEFAULT_post_height_layers * z_gapY_scale
    )
    max(base_layers, derivedX_AR, derivedY_AR, derivedX_coupled, derivedY_coupled);

// Combine with coupled scales: MAX(DEFAULT, absolute, existing scaler, NEW coupled scaler)
function sx_px_at(cx,cy) =
    max(DEFAULT_post_size_x_pixels,
        max(sx_abs_px_at(cx,cy), DEFAULT_post_size_x_pixels * size_scale_at(cx,cy)));

function sy_px_at(cx,cy) =
    max(DEFAULT_post_size_y_pixels,
        max(sy_abs_px_at(cx,cy), DEFAULT_post_size_y_pixels * size_scale_at(cx,cy)));

function gx_px_at(cx,cy) =
    let(coupled = DEFAULT_intra_cell_posts_gap_X_pixels * z_gapX_coupled_scale_at(cx,cy))
    max(DEFAULT_intra_cell_posts_gap_X_pixels,
        max(gx_abs_px_at(cx,cy),
            max(DEFAULT_intra_cell_posts_gap_X_pixels * gap_scale_at(cx,cy), coupled)));

function gy_px_at(cx,cy) =
    let(coupled = DEFAULT_intra_cell_posts_gap_Y_pixels * z_gapY_coupled_scale_at(cx,cy))
    max(DEFAULT_intra_cell_posts_gap_Y_pixels,
        max(gy_abs_px_at(cx,cy),
            max(DEFAULT_intra_cell_posts_gap_Y_pixels * gap_scale_at(cx,cy), coupled)));

function covx_at(cx,cy) =
    clamp(max(covx_abs_at(cx,cy), cov_scaled_candidate(cx,cy,DEFAULT_membrane_post_coverage_x)), 0, 1);
function covy_at(cx,cy) =
    clamp(max(covy_abs_at(cx,cy), cov_scaled_candidate(cx,cy,DEFAULT_membrane_post_coverage_y)), 0, 1);

// All in [mm]
function sx_mm_at(cx,cy)       = sx_px_at(cx,cy) * px;
function sy_mm_at(cx,cy)       = sy_px_at(cx,cy) * px;
function gx_mm_at(cx,cy)       = gx_px_at(cx,cy) * px;
function gy_mm_at(cx,cy)       = gy_px_at(cx,cy) * px;
function mem_thk_mm_at(cx,cy)  = mem_layers_at(cx,cy)  * LAYER_THICKNESS;
function post_h_mm_at(cx,cy)   = post_layers_at(cx,cy) * LAYER_THICKNESS;

// ================================
// COMPACT PACKING WITH DEBUG OUTPUT (FIXED)
// ================================

// Worst-case band for a given column, scanning all rows
function col_band_xmm(cx) =
    let(
        sx_list = [for (cy=[0:array_cells_y-1]) sx_mm_at(cx,cy)],
        gx_list = [for (cy=[0:array_cells_y-1]) gx_mm_at(cx,cy)],
        max_sx  = list_max(sx_list),
        max_gx  = list_max(gx_list)
    )
    2*max_sx + max_gx + mm_buffer_x;

// Worst-case band for a given row, scanning all columns
function row_band_ymm(cy) =
    let(
        sy_list = [for (cx=[0:array_cells_x-1]) sy_mm_at(cx,cy)],
        gy_list = [for (cx=[0:array_cells_x-1]) gy_mm_at(cx,cy)],
        max_sy  = list_max(sy_list),
        max_gy  = list_max(gy_list)
    )
    2*max_sy + max_gy + mm_buffer_y;

// Build band arrays using the worst-case evaluators above
function build_column_bands_xmm(cx=0, accum=[]) =
    cx >= array_cells_x ? accum :
    build_column_bands_xmm(cx+1, concat(accum, [col_band_xmm(cx)]));

function build_row_bands_ymm(cy=0, accum=[]) =
    cy >= array_cells_y ? accum :
    build_row_bands_ymm(cy+1, concat(accum, [row_band_ymm(cy)]));

// Compute cumulative centers for compact placement
function build_column_centers_xmm(bands, cx=0, start=0, accum=[]) =
    cx >= len(bands) ? accum :
    let(ctr = start + bands[cx]/2)
    build_column_centers_xmm(bands, cx+1, start+bands[cx], concat(accum, [ctr]));

function build_row_centers_ymm(bands, cy=0, start=0, accum=[]) =
    cy >= len(bands) ? accum :
    let(ctr = start + bands[cy]/2)
    build_row_centers_ymm(bands, cy+1, start+bands[cy], concat(accum, [ctr]));

column_bands_xmm   = build_column_bands_xmm();
row_bands_ymm      = build_row_bands_ymm();
column_centers_xmm = build_column_centers_xmm(column_bands_xmm);
row_centers_ymm    = build_row_centers_ymm(row_bands_ymm);

total_array_width  = column_centers_xmm[len(column_centers_xmm)-1] + column_bands_xmm[len(column_bands_xmm)-1]/2;
total_array_height = row_centers_ymm[len(row_centers_ymm)-1]       + row_bands_ymm[len(row_bands_ymm)-1]/2;

echo("======== ARRAY DIMENSIONS ========");
echo("Total array width:", total_array_width, "mm");
echo("Total array height:", total_array_height, "mm");

// ================================
// LABEL TEXT GENERATION (with increments)
// ================================

// Short human-friendly names
function pretty_label_short(lbl) =
    lbl == "post_size_x"                                 ? "post_x" :
    lbl == "post_size_y"                                 ? "post_y" :
    lbl == "intra_cell_post_gap_x"                       ? "intra_cell_post_gap_x" :
    lbl == "intra_cell_post_gap_y"                       ? "intra_cell_post_gap_y" :
    lbl == "membrane_post_coverage_x"                    ? "cov_x" :
    lbl == "membrane_post_coverage_y"                    ? "cov_y" :
    lbl == "membrane_thickness_layers"                   ? "mem_thick_layrs" :
    lbl == "post_height_layers"                          ? "post_height_layers" :
    lbl == "cell_aspect_ratio_post_Z_to_cell_gap_X"      ? "AR(Z:gapX)" :
    lbl == "cell_aspect_ratio_post_Z_to_cell_gap_Y"      ? "AR(Z:gapY)" :
    lbl == "post_size_scale_both_xy"                     ? "post_scale_xy" :
    lbl == "intra_cell_post_gap_scale_both_xy"           ? "gap_scale_xy" :
    lbl == "post_Z_and_cell_gap_X_scale_both"            ? "Z&gapX_scale" :
    lbl == "post_Z_and_cell_gap_Y_scale_both"            ? "Z&gapY_scale" :
    lbl == "membrane_post_coverage_both_xy"              ? "cov_scale_xy" :
    lbl == ""                                            ? "—" : lbl;

// One-liner with min → max (+ step)
function sweep_line_short(which) =
    which == "A"
      ? str(pretty_label_short(SWEPT_A_label), " (",
            SWEPT_A_min, ":", SWEPT_A_step,":", SWEPT_A_max,")")
      : str(pretty_label_short(SWEPT_B_label), " (",
            SWEPT_B_min, ":", SWEPT_B_step,":", SWEPT_B_max,")");

// Text strings that will actually be printed on the part
text_right = sweep_line_short("B");  // vertical on +X side
text_top   = sweep_line_short("A");  // horizontal on +Y side

// ================================
// AUTOSCALING (independent per side, consistent math)
// ================================

// Character width model: avg glyph width ≈ char_width_factor * text_height
char_width_factor = 0.6;

// How much of the array edge length we allow labels to occupy (0..1)
length_allowance  = 0.90;

// Safety gap already reduces usable margin; no extra shrink applied here
avail_margin_right_mm = max(0, label_margin_right_mm - label_safety_gap_mm);
avail_margin_top_mm   = max(0, label_margin_top_mm   - label_safety_gap_mm);

// Length allowances along array edges
avail_len_right_mm = total_array_height * length_allowance; // vertical run
avail_len_top_mm   = total_array_width  * length_allowance; // horizontal run

// Height required to satisfy text LENGTH (for each side)
function height_needed_for_length(text_str, avail_len_mm) =
    len(text_str) > 0
      ? avail_len_mm / (len(text_str) * char_width_factor)
      : 0;

// Per-side candidate heights from length constraint
height_len_right_mm = height_needed_for_length(text_right, avail_len_right_mm);
height_len_top_mm   = height_needed_for_length(text_top,   avail_len_top_mm);

// Per-side caps from margin thickness (font height cannot exceed margin thickness)
cap_right_mm = avail_margin_right_mm;
cap_top_mm   = avail_margin_top_mm;

// Final per-side font sizes (independent)
actual_label_size_right_mm = min(height_len_right_mm, cap_right_mm);
actual_label_size_top_mm   = min(height_len_top_mm,   cap_top_mm);

// Estimated printed lengths with the chosen sizes (diagnostics)
function estimated_text_length(text_str, text_h_mm) =
    len(text_str) * text_h_mm * char_width_factor;

actual_right_text_length_mm = estimated_text_length(text_right, actual_label_size_right_mm);
actual_top_text_length_mm   = estimated_text_length(text_top,   actual_label_size_top_mm);

// Debug echoes
echo("======== LABEL AUTOSCALING (REWRITE) ========");
echo("Right label:", text_right, " (", len(text_right), " chars)");
echo("Top   label:", text_top,   " (", len(text_top),   " chars)");
echo("Margins usable: right=", avail_margin_right_mm, "mm, top=", avail_margin_top_mm, "mm");
echo("Edge length allowances: right=", avail_len_right_mm, "mm, top=", avail_len_top_mm, "mm");
echo("Heights from length: right=", height_len_right_mm, "mm, top=", height_len_top_mm, "mm");
echo("Final font sizes: right=", actual_label_size_right_mm, "mm, top=", actual_label_size_top_mm, "mm");
echo("Resulting text lengths: right=", actual_right_text_length_mm, "mm (<= ", avail_len_right_mm, ")",
                                  ", top=",   actual_top_text_length_mm,   "mm (<= ", avail_len_top_mm,   ")");
echo("Fits: right=", (actual_right_text_length_mm <= avail_len_right_mm) && (actual_label_size_right_mm <= cap_right_mm),
           ", top=", (actual_top_text_length_mm   <= avail_len_top_mm)   && (actual_label_size_top_mm   <= cap_top_mm));

// ================================
// GEOMETRY MODULES
// ================================

// ================================
// EDGE LABELS (use per-side sizes)
// ================================
module edge_labels_solid(style) {
    if (enable_edge_labels) {
        if (DEBUG_LABELS) {
            echo("Creating edge labels (", style, ")");
            echo("Right font size:", actual_label_size_right_mm,
                 " Top font size:", actual_label_size_top_mm);
        }

        h = (style == "raised") ? edge_label_thickness_mm : edge_label_indent_mm;

        // Right side (+X): vertical text for Sweep B
        translate([ total_array_width/2 + label_margin_right_mm, 0, 0 ])
        rotate([0,0,90])
        linear_extrude(height = h)
            text(text_right,
                 size   = actual_label_size_right_mm,
                 font   = edge_label_font,
                 halign = "center",
                 valign = "bottom");

        // Top side (+Y): horizontal text for Sweep A
        translate([ 0, total_array_height/2 + label_margin_top_mm/2, 0 ])
        linear_extrude(height = h)
            text(text_top,
                 size   = actual_label_size_top_mm,
                 font   = edge_label_font,
                 halign = "center",
                 valign = "bottom");
    }
}

module microcell_at(cx, cy, col_center_x_mm, row_center_y_mm) {
    // Base sizes from functions (no overlap yet)
    sx_base = sx_mm_at(cx,cy);
    sy_base = sy_mm_at(cx,cy);
    gx = gx_mm_at(cx,cy);
    gy = gy_mm_at(cx,cy);

    covx = covx_at(cx,cy);
    covy = covy_at(cx,cy);
    mem_thk = mem_thk_mm_at(cx,cy);
    post_h  = post_h_mm_at(cx,cy);

    // Offsets calculated from BASE sizes (positions don't change)
    off_x = sx_base/2 + gx/2;
    off_y = sy_base/2 + gy/2;

    // Actual drawn sizes (WITH overlap for fusion)
    sx = sx_base + overlap_x;
    sy = sy_base + overlap_y;

    // Membrane dimensions (with overlap)
    mem_z = (mem_thk > 0) ? (post_h + mem_thk/2) : 0;
    mem_w = 2*(off_x - sx_base/2 + covx * sx_base) + overlap_x;
    mem_h = 2*(off_y - sy_base/2 + covy * sy_base) + overlap_y;

    translate([col_center_x_mm, row_center_y_mm, 0]) {
        // Four posts - positions unchanged, sizes include overlap
        translate([-off_x, -off_y, post_h/2]) cube([sx, sy, post_h], center=true);
        translate([+off_x, -off_y, post_h/2]) cube([sx, sy, post_h], center=true);
        translate([-off_x, +off_y, post_h/2]) cube([sx, sy, post_h], center=true);
        translate([+off_x, +off_y, post_h/2]) cube([sx, sy, post_h], center=true);

        if (mem_thk > 0 && mem_w > 0 && mem_h > 0) {
            color("lightblue", 0.6)
            translate([0, 0, mem_z]) cube([mem_w, mem_h, mem_thk], center=true);
        }
    }
}

// Use ONLY the original array module - remove continuous_column_strip entirely
module microarray_compact() {
    cx_offset = total_array_width / 2;
    cy_offset = total_array_height / 2;

    if (DEBUG_MODE) echo("Building microarray with", array_cells_x, "×", array_cells_y, "cells");

    for (cx=[0:array_cells_x-1]) {
        col_x_world = column_centers_xmm[cx] - cx_offset;
        for (cy=[0:array_cells_y-1]) {
            row_y_world = row_centers_ymm[cy] - cy_offset;
            microcell_at(cx, cy, col_x_world, row_y_world);
        }
    }
}
// ================================
// ARRAY ASSEMBLY MODULE
// ================================
module microarray_compact() {
    cx_offset = total_array_width / 2;
    cy_offset = total_array_height / 2;

    if (DEBUG_MODE) echo("Building microarray with", array_cells_x, "×", array_cells_y, "cells");

    for (cx=[0:array_cells_x-1]) {
        col_x_world = column_centers_xmm[cx] - cx_offset;
        for (cy=[0:array_cells_y-1]) {
            row_y_world = row_centers_ymm[cy] - cy_offset;
            microcell_at(cx, cy, col_x_world, row_y_world);
        }
    }
}

// ================================
// BASE PLATE MODULE (optional)
// ================================
module base_plate() {
    base_thk = base_plate_thick_layers * LAYER_THICKNESS;

    // Base plate extends to include label margins
    bx = total_array_width  + label_margin_right_mm * 2;
    by = total_array_height + label_margin_top_mm * 2;

    if (DEBUG_MODE) {
        echo("======== BASE PLATE ========");
        echo("Base plate dimensions: X=", bx, "mm, Y=", by, "mm, Z=", base_thk, "mm");
        echo("Base plate enabled:", draw_base_plate);
        echo("Base extends beyond array by: X=", label_margin_right_mm, "mm, Y=", label_margin_top_mm, "mm");
    }

    if (draw_base_plate) {
        if (enable_edge_labels && edge_label_style == "indented") {
            difference() {
                translate([label_margin_right_mm/2, label_margin_top_mm/2, -base_thk/2]) 
                color("gray", 0.5)
                    cube([bx, by, base_thk], center=true);
                translate([0,0,-edge_label_indent_mm])
                    edge_labels_solid("indented");
            }
        } else {
            translate([label_margin_right_mm/2, label_margin_top_mm/2, -base_thk/2]) 
            color("gray", 0.5)
                cube([bx, by, base_thk], center=true);
        }
    }
}

// ================================
// MAIN ASSEMBLY WITH SINGLE TOP-LEVEL UNION
// ================================
$fn = 32;

union() {
    base_plate(); // slab first
    if (enable_edge_labels && edge_label_style == "raised") {
        edge_labels_solid("raised");
    }
    microarray_compact(); // all microcells
}

// ================================
// VALIDATION AND SUMMARY OUTPUT
// ================================
echo("======== ARRAY SUMMARY ========");
echo("Cells: ", array_cells_x, " × ", array_cells_y);
echo("Total size (mm): X=", total_array_width, " Y=", total_array_height);
echo("Sweeps:");
echo(" A (by columns): label=", SWEPT_A_label, " min=", SWEPT_A_min, " max=", SWEPT_A_max, " step=", SWEPT_A_step);
echo(" B (by rows): label=", SWEPT_B_label, " min=", SWEPT_B_min, " max=", SWEPT_B_max, " step=", SWEPT_B_step);
echo("Safety buffers: X=", safety_buffer_x_pixels, " px (", mm_buffer_x, " mm)", " Y=", safety_buffer_y_pixels, " px (", mm_buffer_y, " mm)");
echo("Label texts: Right='", text_right, "', Top='", text_top, "'");

assert(array_cells_x > 0, "ERROR: array_cells_x must be positive");
assert(array_cells_y > 0, "ERROR: array_cells_y must be positive");
assert(PIXEL_SIZE > 0, "ERROR: PIXEL_SIZE must be positive");
assert(LAYER_THICKNESS > 0, "ERROR: LAYER_THICKNESS must be positive");
assert(total_array_width > 0, "ERROR: Calculated array width is invalid");
assert(total_array_height > 0, "ERROR: Calculated array height is invalid");

echo("======== VALIDATION COMPLETE ========");
echo("All parameter validation checks passed successfully");
echo("Label autoscaling: right text height = ", actual_label_size_right_mm,
                 " mm; top text height = ",   actual_label_size_top_mm,   " mm");
echo("Labels positioned OUTSIDE array bounds with ",
     label_safety_gap_mm, " mm safety gap");
echo("Ready for rendering");

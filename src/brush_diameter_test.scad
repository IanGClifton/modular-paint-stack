// Copyright Ian G. Clifton 2026
// Apache 2.0 license
// https://github.com/IanGClifton/modular-paint-stack

// ============================================================
// Paintbrush Handle Hole Gauge
// ============================================================
// Prints a 3mm thick rectangle with holes sized from
// start_hole_diameter to end_hole_diameter in 0.5mm steps.
// Each hole is labeled with its diameter (no units).
// ============================================================

// --- User-configurable constants ---
start_hole_diameter = 5.0;    // Diameter of the smallest hole (mm)
end_hole_diameter   = 14.0;   // Diameter of the largest hole (mm)

// --- Fixed constants ---
THICKNESS          = 3.0;    // Plate thickness (mm)
HOLE_SPACING       = 2.0;    // Gap between edges of adjacent holes (mm)
CIRCLE_RESOLUTION  = 100;    // $fn for cylinders
Z_EXTENSION        = 0.1;    // Extra z on each side to avoid z-fighting
STEP               = 0.5;    // How much to increase the hole diameter each iteration (mm)

// --- Label constants ---
LABEL_SIZE   = (start_hole_diameter * 0.55 < 1.2) ? 1.2 : start_hole_diameter * 0.55;
LABEL_DEPTH  = THICKNESS / 2;
LABEL_OFFSET = 0.3;

// Number of holes
function num_holes() =
    round((end_hole_diameter - start_hole_diameter) / STEP) + 1;

// Diameter of hole at index i
function hole_dia(i) = start_hole_diameter + i * STEP;

// X center of hole at index i (holes laid out left-to-right)
// Each hole occupies: its own radius on the left side, the spacing,
// the previous hole's radius on the right — accumulated.
function hole_center_x(i) =
    (i == 0)
        ? (hole_dia(0) / 2) + HOLE_SPACING
        : hole_center_x(i - 1)
          + hole_dia(i - 1) / 2    // right edge of previous hole
          + HOLE_SPACING           // gap
          + hole_dia(i) / 2;       // left half of current hole

// Width of the plate is sum of all holes + spacing
function plate_width() =
    (hole_center_x(num_holes() - 1) + hole_dia(num_holes() - 1) / 2) + HOLE_SPACING;

// Height of the plate — tall enough so the largest hole fits with spacing,
// plus room below for the label text and its gap from the hole edge.
function plate_height() =
    end_hole_diameter + HOLE_SPACING      // top spacing + hole + bottom spacing above label
    + LABEL_OFFSET + LABEL_SIZE           // gap + label height
    + HOLE_SPACING;                       // margin below the label

// ============================================================
// Main model
// ============================================================
module brush_gauge() {
    n = num_holes();
    w = plate_width();
    h = plate_height();

    difference() {
        // Base plate
        cube([w, h, THICKNESS]);

        // Cut holes + labels
        for (i = [0 : n - 1]) {
            dia    = hole_dia(i);
            radius = dia / 2;
            cx     = hole_center_x(i);
            // Push the hole center up so there's equal spacing above the hole
            // and the label sits in the extra space at the bottom.
            label_area = LABEL_OFFSET + LABEL_SIZE + HOLE_SPACING;
            cy = (h + label_area) / 2;

            // --- Cylinder hole ---
            translate([cx, cy, -Z_EXTENSION])
                cylinder(
                    h  = THICKNESS + (2 * Z_EXTENSION),
                    r1 = radius,
                    r2 = radius,
                    $fn = CIRCLE_RESOLUTION
                );

            // --- Label (cut into the bottom face) ---
            label_str = (dia == floor(dia))
                ? str(floor(dia))   // "6" instead of "6.5"-style for whole numbers
                : str(dia);

            // Center the label below the hole
            label_y = cy - radius - LABEL_OFFSET - LABEL_SIZE;

            translate([cx, label_y, THICKNESS - LABEL_DEPTH])
                linear_extrude(height = LABEL_DEPTH)
                    text(
                        label_str,
                        size    = LABEL_SIZE,
                        halign  = "center",
                        valign  = "top",
                        font    = "Liberation Sans:style=Bold"
                    );
        }
    }
}

brush_gauge();


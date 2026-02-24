// Copyright Ian G. Clifton 2026
// Apache 2.0 license
// https://github.com/IanGClifton/modular-paint-stack

include <constants.scad>

/**
  * Creates an empty shelf
  *
  * The shelf has the support pieces to fit into the walls,
  * but the top of the shelf is flat with no cutouts for
  * paints, brushes, etc.
  */
module uniformShelf(gridfinityWidth, gridfinityDepth = 1) {
    for (i = [0 : gridfinityDepth - 1]) {
        translate([0, GRIDFINITY_DIMENSION * i, 0]) {
            union() {
                // Shelf main
                cube([getShelfFullWidth(gridfinityWidth), GRIDFINITY_DIMENSION, SHELF_THICKNESS]);
                
                // Support on each end
                shelfSupport();
                translate([getShelfFullWidth(gridfinityWidth), 0, 0])
                    mirror([1, 0, 0])
                        shelfSupport();
            }
        }
    }
}

/**
  * Modifies the uniformShelf() to be thicker or thinner
  *
  * This adjusts only the center of the shelf where paints
  * would go, allowing the thickness of this part of the shelf
  * to match the paint neck height.
  */
module thicknessAdjustedShelf(gridfinityWidth, targetThickness, gridfinityDepth = 1) {
    if (targetThickness == SHELF_THICKNESS) {
        uniformShelf(gridfinityWidth, gridfinityDepth);
    } else if (targetThickness > SHELF_THICKNESS) {
        // Thicken the shelf
        union() {
            uniformShelf(gridfinityWidth, gridfinityDepth);
            translate([SHELF_SUPPORT_WIDTH + SHELF_SUPPORT_SPACING, 0, SHELF_THICKNESS])
                cube([getShelfMainWidth(gridfinityWidth) - (SHELF_SUPPORT_SPACING * 2), GRIDFINITY_DIMENSION * gridfinityDepth, targetThickness - SHELF_THICKNESS]);
        }
    } else {
        // Thin the shelf
        difference() {
            uniformShelf(gridfinityWidth, gridfinityDepth);
            translate([SHELF_SUPPORT_WIDTH + SHELF_SUPPORT_SPACING, 0, targetThickness])
                cube([getShelfMainWidth(gridfinityWidth) - (SHELF_SUPPORT_SPACING * 2), GRIDFINITY_DIMENSION * gridfinityDepth, SHELF_THICKNESS - targetThickness]);
        }
    }
}

/**
  * Creates the two triangles and center block used to connect
  * the shelf to the shelf brackets on the sides
  */
module shelfSupport() {
    topPoint = SHELF_THICKNESS + SHELF_SUPPORT_ANGLE_PROTRUSION;
    triangle_points = [
        // Front
        [0, 0, topPoint],                             // 0 TL
        [SHELF_SUPPORT_BLOCK_X, 0, SHELF_THICKNESS],  // 1 BR
        [0, 0, SHELF_THICKNESS],                      // 2 BL
        // Back
        [0, SHELF_SUPPORT_ANGLE_Y, topPoint],                            // 3 TL
        [SHELF_SUPPORT_BLOCK_X, SHELF_SUPPORT_ANGLE_Y, SHELF_THICKNESS], // 4 BR
        [0, SHELF_SUPPORT_ANGLE_Y, SHELF_THICKNESS]                      // 5 BL
    ];
    triangle_faces = [
        [0, 1, 2],    // Front face
        [3, 5, 4],    // Back face
        [3, 0, 2, 5], // Left side
        [3, 4, 1, 0], // Top
        [2, 1, 4, 5]  // Bottom  
    ];
    triangle_offset = SHELF_SUPPORT_ANGLE_Y + SHELF_SUPPORT_BLOCK_Y;
    union() {
        difference() {
            // Two triangles
            for (i = [0 : 1]) {
                translate([0, i * triangle_offset, 0])
                polyhedron(points = triangle_points, faces = triangle_faces);
            }
            // Cube to "cut" the tip of the triangles
            translate([0, 0, topPoint - SHELF_SUPPORT_ANGLE_CUT])
                cube([SHELF_SUPPORT_BLOCK_X, (SHELF_SUPPORT_ANGLE_Y * 2) + SHELF_SUPPORT_BLOCK_Y, SHELF_SUPPORT_ANGLE_CUT]);
        }
        // Add the block protrusion
        translate([0, SHELF_SUPPORT_ANGLE_Y, SHELF_THICKNESS])
            cube([SHELF_SUPPORT_BLOCK_X, SHELF_SUPPORT_BLOCK_Y, SHELF_SUPPORT_BLOCK_PROTRUSION]);
    }
}

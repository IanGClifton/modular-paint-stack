// Copyright Ian G. Clifton 2026
// Apache 2.0 license
// https://github.com/IanGClifton/modular-paint-stack

// Gridfinity units (42mm each) to make the width of the inner shelf part  
shelf_gridfinity_unit_width = 3;
// How many mm to inset the cylinder cutout
cylinder_height = 14.8;
// Diameter of cylinder cutout
cylinder_diameter = 29.5;
// How many cutouts to include
cylinder_count = 3;

include <shelf_base.scad>

/**
  * Creates a solid trapezoid that will be cut into for the paints
  */
module standingPaintSupport(gridfinityUnits, height) {
    fullShelfWidth = getShelfFullWidth(gridfinityUnits);
    points = [
        // Base points
        [0, GRIDFINITY_DIMENSION, 0],              // 0 TL
        [fullShelfWidth, GRIDFINITY_DIMENSION, 0], // 1 TR
        [0, 0, 0],                                 // 2 BL
        [fullShelfWidth, 0, 0],                    // 3 BR
        // Extended points
        [SHELF_SUPPORT_WIDTH, GRIDFINITY_DIMENSION, -height],                  // 4 TL
        [fullShelfWidth - SHELF_SUPPORT_WIDTH, GRIDFINITY_DIMENSION, -height], // 5 TR
        [SHELF_SUPPORT_WIDTH, 0, -height],                                     // 6 BL
        [fullShelfWidth - SHELF_SUPPORT_WIDTH, 0, -height],                    // 7 BR
        
    ];
    faces = [
        [0, 1, 3, 2], // Top
        [0, 2, 6, 4], // Left
        [1, 0, 4, 5], // Back
        [3, 1, 5, 7], // Right
        [2, 3, 7, 6], // Front
        [4, 6, 7, 5]  // Bottom
    ];
    polyhedron(points, faces);
}

/**
  * Creates cylinders to represent each paint tube/bottle
  */
module cylinderCutOuts(shelfMainWidth, cylinderDiameter, cylinderHeight, cylinderCount) {
    holeSpacing = (shelfMainWidth - (cylinderDiameter * cylinderCount)) / cylinderCount;
    xOffset = SHELF_SUPPORT_WIDTH + (holeSpacing / 2) + (cylinderDiameter / 2);
    yOffset = (GRIDFINITY_DIMENSION / 2);
    zOffset = -cylinderHeight - 1;
    translate([xOffset, yOffset, zOffset]) {
        for (i = [0 : cylinderCount - 1]) {
            translate([(holeSpacing + cylinderDiameter) * i, 0, 0]) {
                cylinder(h = cylinderHeight + 1, r = cylinderDiameter/2);
            }
        }
    }
}

/**
  * Creates a shelf with support for standing paints and cylinders cut out
  */
module standingPaintShelf(gridfinityUnits, supportHeight, cylinderDiameter, cylinderCount) {
    difference() {
        union() {
            uniformShelf(gridfinityUnits);
            standingPaintSupport(gridfinityUnits, supportHeight);

        }
        cylinderCutOuts(getShelfMainWidth(gridfinityUnits), cylinderDiameter, supportHeight, cylinderCount);
    }
}

translate([-(getShelfFullWidth(shelf_gridfinity_unit_width) / 2), -(GRIDFINITY_DIMENSION / 2), cylinder_height]) {
    standingPaintShelf(shelf_gridfinity_unit_width, cylinder_height, cylinder_diameter, cylinder_count);
}
// Copyright Ian G. Clifton 2026
// Apache 2.0 license
// https://github.com/IanGClifton/modular-paint-stack

// Gridfinity units (42mm each) to make the width of the inner shelf part  
shelf_gridfinity_unit_width = 3;
// True if you want the Gridfinity base on top of a solid shelf
solid_shelf = false;


GRIDFINITY_BASE_BOTTOM = 0.7;
GRIDFINITY_BASE_MIDDLE = 1.8;
GRIDFINITY_BASE_TOP = 2.15;

GRIDFINITY_BASE_HEIGHT = GRIDFINITY_BASE_BOTTOM  + GRIDFINITY_BASE_MIDDLE + GRIDFINITY_BASE_TOP;
GRIDFINITY_BASE_MIDDLE_HEIGHT = GRIDFINITY_BASE_BOTTOM  + GRIDFINITY_BASE_MIDDLE;
GRIDFINITY_BASE_TOP_WIDTH = 0.25;
GRIDFINITY_BASE_WALL_INSET = GRIDFINITY_BASE_TOP_WIDTH + GRIDFINITY_BASE_TOP;
GRIDFINITY_BASE_FULL_INSET = GRIDFINITY_BASE_WALL_INSET + GRIDFINITY_BASE_BOTTOM;

include <shelf_base.scad>


module gridfinityBasePortion() {
    points = [
        // Front
        [0, 0, GRIDFINITY_BASE_HEIGHT],                                 // 0 TL
        [GRIDFINITY_BASE_TOP_WIDTH, 0, GRIDFINITY_BASE_HEIGHT],         // 1 TR
        [GRIDFINITY_BASE_WALL_INSET, 0, GRIDFINITY_BASE_MIDDLE_HEIGHT], // 2 Wall top
        [GRIDFINITY_BASE_WALL_INSET, 0, GRIDFINITY_BASE_BOTTOM],        // 3 Wall bottom
        [GRIDFINITY_BASE_FULL_INSET, 0, 0],                             // 4 BR
        [0, 0, 0],                                                      // 5 BL
        // Back
        [0, GRIDFINITY_DIMENSION, GRIDFINITY_BASE_HEIGHT],                                 // 6  TL
        [GRIDFINITY_BASE_TOP_WIDTH, GRIDFINITY_DIMENSION, GRIDFINITY_BASE_HEIGHT],         // 7  TR
        [GRIDFINITY_BASE_WALL_INSET, GRIDFINITY_DIMENSION, GRIDFINITY_BASE_MIDDLE_HEIGHT], // 8  Wall top
        [GRIDFINITY_BASE_WALL_INSET, GRIDFINITY_DIMENSION, GRIDFINITY_BASE_BOTTOM],        // 9  Wall bottom
        [GRIDFINITY_BASE_FULL_INSET, GRIDFINITY_DIMENSION, 0],                             // 10 BR
        [0, GRIDFINITY_DIMENSION, 0],                                                      // 11 BL

    ];
    faces = [
        [0, 1, 2, 3, 4, 5],   // Front
        [11, 10, 9, 8, 7, 6], // Back
        [6, 7, 1, 0],         // Top
        [7, 8, 2, 1],         // Top slant
        [2, 8, 9, 3],         // Wall
        [3, 9, 10, 4],        // Bottom slant
        [11, 5, 4, 10],       // Bottom
        [0, 5, 11, 6]         // Left
    ];
    polyhedron(points, faces);
}

module gridfinitySingleBase() {
    union() {
        gridfinityBasePortion();
        translate([GRIDFINITY_DIMENSION, 0, 0]) {
            rotate([0, 0, 90]) {
                gridfinityBasePortion();
            }
        }
        translate([0, GRIDFINITY_DIMENSION, 0]) {
            rotate([0, 0, 270]) {
                gridfinityBasePortion();
            }
        }
        translate([GRIDFINITY_DIMENSION, GRIDFINITY_DIMENSION, 0]) {
            rotate([0, 0, 180]) {
                gridfinityBasePortion();
            }
        }
    }
}

module gridfinityBase(gridfinityWidth) {
    for (i = [0 : gridfinityWidth - 1]) {
        translate([GRIDFINITY_DIMENSION * i, 0, 0]) {
            gridfinitySingleBase();
        }
    }
}

module endTriangle(zDepth) {
    points = [
        // Front
        [0, 0, 0],                        // 0 TL
        [SHELF_SUPPORT_WIDTH, 0, 0],      // 1 TR
        [SHELF_SUPPORT_WIDTH, 0, -zDepth], // 2 BR
        // Back
        [0, GRIDFINITY_DIMENSION, 0],                        // 3 TL
        [SHELF_SUPPORT_WIDTH, GRIDFINITY_DIMENSION, 0],      // 4 TR
        [SHELF_SUPPORT_WIDTH, GRIDFINITY_DIMENSION, -zDepth], // 5 BR
    ];
    faces = [
        [0, 1, 2],    // Front
        [5, 4, 3],    // Back
        [3, 4, 1, 0], // Top
        [1, 4, 5, 2], // Right
        [0, 2, 5, 3]  // Bottom slant
    ];
    polyhedron(points, faces);
}

module endTrianglePair(zDepth, gridfinityWidthGap) {
    endTriangle(zDepth);
    translate([(2 * SHELF_SUPPORT_WIDTH) + (GRIDFINITY_DIMENSION * gridfinityWidthGap), GRIDFINITY_DIMENSION, 0]) {
        rotate([0, 0, 180]) {
            endTriangle(zDepth);
        }
    }
}

module gridfinityShelfOnTop(gridfinityWidth) {
    union() {
        uniformShelf(gridfinityWidth);
        
        translate([SHELF_SUPPORT_WIDTH, GRIDFINITY_DIMENSION, 0]) {
            rotate([180, 0, 0]) {
                gridfinityBase(shelf_gridfinity_unit_width);
            }
        }
        endTrianglePair(GRIDFINITY_BASE_HEIGHT, gridfinityWidth);
    }
}

module gridfinityShelfInset(gridfinityWidth) {
    union() {
        difference() {
            uniformShelf(gridfinityWidth);
            translate([SHELF_SUPPORT_WIDTH, 0, 0]) {
                cube([GRIDFINITY_DIMENSION * gridfinityWidth, GRIDFINITY_DIMENSION, SHELF_THICKNESS]);
            }
        }
        
        translate([SHELF_SUPPORT_WIDTH, GRIDFINITY_DIMENSION, SHELF_THICKNESS]) {
            rotate([180, 0, 0]) {
                gridfinityBase(shelf_gridfinity_unit_width);
            }
        }
        endTrianglePair(GRIDFINITY_BASE_HEIGHT - SHELF_THICKNESS, gridfinityWidth);
    }
}

if (solid_shelf) {
    translate([-getShelfFullWidth(shelf_gridfinity_unit_width) / 2, -GRIDFINITY_DIMENSION / 2, GRIDFINITY_BASE_HEIGHT]) {
        gridfinityShelfOnTop(shelf_gridfinity_unit_width);  
    }
} else {
    translate([-getShelfFullWidth(shelf_gridfinity_unit_width) / 2, -GRIDFINITY_DIMENSION / 2, GRIDFINITY_BASE_HEIGHT - SHELF_THICKNESS]) {
        gridfinityShelfInset(shelf_gridfinity_unit_width);
    }
}

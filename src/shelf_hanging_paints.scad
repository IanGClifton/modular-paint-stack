// Copyright Ian G. Clifton 2026
// Apache 2.0 license
// https://github.com/IanGClifton/modular-paint-stack

// mm thickness between the paint cap and paint tube body
paint_neck_height = 3.5;
// mm diameter of the paint tube's "neck"
paint_neck_diameter = 11.4;
// Number of cutouts for paint
paint_count = 4;
// mm extra to extend paint supports if possible
paint_support_extra_length = 8;
// Gridfinity units (42mm each) to make the width of the inner shelf part  
shelf_gridfinity_unit_width = 3;

include <shelf_base.scad>

// Calculate the paint holes
PAINT_SPACING = (getShelfMainWidth(shelf_gridfinity_unit_width) - (paint_count * paint_neck_diameter)) / paint_count;
PAINT_CUT_Z = max(SHELF_THICKNESS, paint_neck_height);
PAINT_FINGER_Y = max(GRIDFINITY_DIMENSION - (SHELF_MIN_BACK_RAIL + paint_neck_diameter + paint_support_extra_length), 0);

/**
  * Creates a rectangle and a circle to cut out where the paint tube slides in
  *
  * yDepth distance from the start to the end of the rect that aligns with the circle center
  * diameter width of the circle and the rectangle
  * thickness how tall the rectangle is and how high to extrude the circle
*/
module roundHoleCutOut(yDepth, diameter, thickness) {
    union() {
        cube([diameter, yDepth, thickness]);
        translate([diameter / 2, yDepth]) 
            linear_extrude(thickness)
                circle(d = diameter, $fn=CIRCLE_RESOLUTION);        
    }
}

/**
  * Creates the cutting "tool" that will represents what should be removed
  * from the shelf for the paints to slide in
  */
module paintToolShape() {
  union() {
      translate([SHELF_SUPPORT_WIDTH + (PAINT_SPACING / 2),   PAINT_FINGER_Y, 0])
        for(i = [0 : paint_count]) {
            X_OFFSET = (i * paint_neck_diameter) + (i * PAINT_SPACING);
      
            translate([X_OFFSET, 0, 0])
                roundHoleCutOut((paint_neck_diameter / 2) + paint_support_extra_length, paint_neck_diameter, PAINT_CUT_Z);
        }

    translate([SHELF_SUPPORT_WIDTH + SHELF_SUPPORT_SPACING, 0, 0])
        cube([getShelfMainWidth(shelf_gridfinity_unit_width) - (SHELF_SUPPORT_SPACING * 2), PAINT_FINGER_Y, PAINT_CUT_Z]);
    }  
}

/**
  * Draws the triangular pieces that connect from the outside edge of the
  * first and last paint cutout to the inside front edge of the support
  *
  * These aren't strickly triangles, as they have to account for the small
  * gap between the support and the main part of the shelf, which has a
  * different thickness than the support part.
  */
module shelfTriangles() {
    SHELF_INNER_THICKNESS = SHELF_THICKNESS + (paint_neck_height - SHELF_THICKNESS);
    
    // Defined from left to right, back to front, top to bottom
    TRIANGLE_SUPPORT_POINTS = [
        // Highest two 0, 1 
        [SHELF_SUPPORT_SPACING, PAINT_FINGER_Y, SHELF_INNER_THICKNESS],
        [(PAINT_SPACING / 2), PAINT_FINGER_Y, SHELF_INNER_THICKNESS],
        // Outside front 2
        [SHELF_SUPPORT_SPACING, 0, SHELF_THICKNESS],
        // Lowest three 3, 4, 5
        [SHELF_SUPPORT_SPACING, PAINT_FINGER_Y, 0],
        [(PAINT_SPACING / 2), PAINT_FINGER_Y, 0],
        [SHELF_SUPPORT_SPACING, 0, 0],
    ];
    
    TRIANGLE_SUPPORT_FACES = [
        [0, 1, 2],    // Top triangle
        [0, 2, 5, 3], // Outside rectangle
        [2, 1, 4, 5], // Inner rectangle
        [1, 4, 3, 0], // Back rectangle
        [5, 4, 3],    // Bottom triangle
     ];
    translate([SHELF_SUPPORT_WIDTH, 0, 0])
        polyhedron(points = TRIANGLE_SUPPORT_POINTS, faces = TRIANGLE_SUPPORT_FACES);
    translate([getShelfFullWidth(shelf_gridfinity_unit_width) - SHELF_SUPPORT_WIDTH, 0, 0])
        mirror([1, 0, 0])
            polyhedron(points = TRIANGLE_SUPPORT_POINTS, faces = TRIANGLE_SUPPORT_FACES);
}

/**
  * Creates a shelf with cutouts for paint and triangle supports on the end
  */
module paintTubeShelf() {
    union() {
        difference() {
            thicknessAdjustedShelf(shelf_gridfinity_unit_width, paint_neck_height);
            paintToolShape();
        }
        shelfTriangles();
    }
}

translate([-getShelfFullWidth(shelf_gridfinity_unit_width) / 2, -GRIDFINITY_DIMENSION / 2, 0]) {
    paintTubeShelf();
}
// Copyright Ian G. Clifton 2026
// Apache 2.0 license
// https://github.com/IanGClifton/modular-paint-stack

// Whether to generate the front piece
print_front = true;
// Whether to generate the back piece
print_back = true;
// mm from 30 to printer max Z dimension
front_height = 100;
// mm thickness of the front piece
front_thickness = 4;
// mm from 30 to printy max Z dimension
back_height = 100;
// mm thickness of the back piece
back_thickness = 4;
// Cutout (0 = none, 1 = oval, 2 = rectange, 3 = angled rectangle)
cutout_shape_front = 1;
// Cutout (0 = none, 1 = oval, 2 = rectange, 3 = angled rectangle)
cutout_shape_back = 0;
// mm offset to make the dovetail fit (0.05 = extremely tight, 0.10 = tight)
dovetail_clearance = 0.10;
// Gridfinity units (42mm each) to make the width of the main shelf part 
shelf_gridfinity_unit_width = 3;

include <dovetail.scad>


SHELF_FULL_WIDTH = getShelfFullWidth(shelf_gridfinity_unit_width);
FULL_WIDTH = SHELF_FULL_WIDTH + (2 * SIDE_X);


module front(width, depth, height) {
    union() {
        cube([width, depth, height]);
        translate([DOVETAIL_OFFSET, depth, 0])
            dovetailDefault(inset = dovetail_clearance);
        translate([width - SIDE_X + DOVETAIL_OFFSET, depth, 0])
            dovetailDefault(inset = dovetail_clearance);
    }
}

module back(width, depth, height, includeTopTriangle) {
    union() {
        cube([width, depth, height]);
        translate([0, depth, 0])
            dovetailSlot(height);
        translate([width - SIDE_X, depth, 0])
            dovetailSlot(height);

        if (includeTopTriangle) {
            // Hide the top gap with a triangle
            triangleWidth = width - (2 * SIDE_X);
            triangleHeight = 5;
            points = [
                // Left
                [0, 0, triangleHeight],               // 0 Top front
                [0, DOVETAIL_YDEPTH, triangleHeight], // 1 Top back
                [0, 0, 0],                            // 2 Bottom front
                // Right
                [triangleWidth, 0, triangleHeight],               // 3 Top front
                [triangleWidth, DOVETAIL_YDEPTH, triangleHeight], // 4 Top back
                [triangleWidth, 0, 0],                            // 5 Bottom front
            ];
            faces = [
                [0, 2, 1],    // Left
                [0, 3, 5, 2], // Front
                [4, 1, 2, 5], // Back angle
                [3, 4, 5],    // Right
                [3, 0, 1, 4]  // Top
            ];
            translate([SIDE_X, depth, height - triangleHeight])
                polyhedron(points, faces);
        }
    }
}

module cutoutShape(width, depth, height, shape) {
    if (shape == CUTOUT_SHAPE_OVAL) {
        yScale = height / width;
        rotate([90, 0, 0]) {
            translate([SIDE_X + (width / 2), height, -depth]) {
                scale([1, yScale, 1]) {
                    cylinder(h = depth, r = width/2, center = false, $fn=CIRCLE_RESOLUTION);
                }
            }
        }
    } else if (shape == CUTOUT_SHAPE_RECTANGLE) {
        cutout_height = height / 3;
        translate([SIDE_X, 0, height - cutout_height]) {
            cube([width, depth, cutout_height]);
        }
    } else if (shape == CUTOUT_SHAPE_ANGLED_RECTANGLE) {
        cutout_height = height / 3;
        cutout_inset = width / 8;
        translate([SIDE_X, 0, height - cutout_height]) {
            points = [
                // Front
                [0, 0, cutout_height],        // 0 TL
                [width, 0, cutout_height],    // 1 TR
                [cutout_inset, 0, 0],         // 2 BL
                [width - cutout_inset, 0, 0], // 3 BR
                // Back
                [0, depth, cutout_height],        // 4 TL
                [width, depth, cutout_height],    // 5 TR
                [cutout_inset, depth, 0],         // 6 BL
                [width - cutout_inset, depth, 0], // 7 BR
            ];
            faces = [
                [0, 1, 3, 2], // Front
                [4, 0, 2, 6], // Left
                [4, 6, 7, 5], // Back
                [1, 5, 7, 3], // Right
                [0, 4, 5, 1], // Top
                [2, 3, 7, 6]  // Bottom
            ];
            polyhedron(points, faces);
        }
        
    }
}

module cutoutShapeFront() {
    cutoutShape(
        width = SHELF_FULL_WIDTH,
        depth = front_thickness,
        height = front_height,
        shape = cutout_shape_front
    );
}

module cutoutShapeBack() {
    cutoutShape(
        width = SHELF_FULL_WIDTH,
        depth = back_thickness,
        height = back_height,
        shape = cutout_shape_back
    );
}

translate([-(FULL_WIDTH / 2), 0, 0]) {
    if (print_front) {
        difference() {
            front(
                width = FULL_WIDTH,
                depth = front_thickness,
                height = front_height
            );
            cutoutShapeFront();
        }
    }

    if (print_back) {
        translate([0, -1, 0]) {
            mirror([0, 1,0]) {        
                difference() {
                    back(
                        width = FULL_WIDTH,
                        depth = back_thickness,
                        height = back_height,
                        includeTopTriangle = (cutout_shape_back == CUTOUT_SHAPE_NONE)
                    );
                    cutoutShapeBack();
                }
            }
        }
    }
}
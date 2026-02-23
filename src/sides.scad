// Copyright Ian G. Clifton 2026
// Apache 2.0 license
// https://github.com/IanGClifton/modular-paint-stack

// mm from 30 to printer max Z dimension
side_height = 100;
// mm offset to make the dovetail fit (0.05 = extremely tight, 0.10 = tight)
dovetail_clearance = 0.10;
// True to add brackets for a shelf on the top
shelf_brackets_on_top = true;
// True to add brackets for a shelf on the bottom
shelf_brackets_on_bottom = false;
// How many mm to raise the bottom backets
shelf_brackets_bottom_offset = 0;
// Whether to generate the left piece
print_left = true;
// Whether to generate the right piece
print_right = true;

include <dovetail.scad>

/**
  * Creates a side with dovetails but no brackets
  */
module sideWithDovetail() {
    difference() {
        union() {
            cube([SIDE_X, SIDE_Y, side_height]);
            translate([(SIDE_X / 2) - (DOVETAIL_XMAX / 2), SIDE_Y, 0])
                dovetail(
                    xMin = DOVETAIL_XMIN,
                    xMax = DOVETAIL_XMAX,
                    yDepth = DOVETAIL_YDEPTH,
                    zMin = DOVETAIL_ZMIN,
                    zMax = DOVETAIL_ZMAX,
                    inset = dovetail_clearance
                );
                
        }
        translate([(SIDE_X / 2) - (DOVETAIL_XMAX / 2), 0, 0])
            dovetail(
                xMin = DOVETAIL_XMIN,
                xMax = DOVETAIL_XMAX,
                yDepth = DOVETAIL_YDEPTH,
                zMin = DOVETAIL_ZMIN,
                zMax = DOVETAIL_ZMAX
            );
    }
}

/**
  * Creates a single shelf backet
  *
  * Side view
  *
  * |  __
  * | / / 
  * |/ /
  * | /
  * |/
  * |
  *
  */
module shelfBracketSingle(width, openingWidth, openingHeight, connectionHeight, yDepth) {
    insideRight = openingWidth;
    outsideRight = width + openingWidth;
    top = openingHeight + connectionHeight;
    points = [
        // Front
        [insideRight, 0, top],    // 0 TL
        [outsideRight, 0, top],   // 1 TR
        [0, 0, connectionHeight], // 2 top connection
        [0, 0, 0],                // 3 bottom connection
        
        // Back
        [insideRight, yDepth, top],    // 4 TL
        [outsideRight, yDepth, top],   // 5 TR
        [0, yDepth, connectionHeight], // 6 top connection
        [0, yDepth, 0],                // 7 bottom connection
        
    ];
    faces = [
        [0, 1, 3, 2], // Front
        [0, 2, 6, 4], // Left angle
        [2, 3, 7, 6], // Left flat
        [4, 6, 7, 5], // Back
        [1, 5, 7, 3], // Right
        [4, 5, 1, 0], // Top
    ];
    polyhedron(points, faces);
}

/**
  * Creates a pair of shelf brackets
  */
module shelfBracketPair(width, openingWidth, openingHeight, connectionHeight, yDepth, yGap) {
    shelfBracketSingle(
        width = width,
        openingWidth = openingWidth,
        openingHeight = openingHeight,
        connectionHeight = connectionHeight,
        yDepth = yDepth
    );
    translate([0, yGap + yDepth, 0])
        shelfBracketSingle(
            width = width,
            openingWidth = openingWidth,
            openingHeight = openingHeight,
            connectionHeight = connectionHeight,
            yDepth = yDepth
        );
}

// Helper to just use the defaults
module shelfBrackets() {
    shelfBracketPair(
        width = SHELF_BRACKET_WIDTH,
        openingWidth = SHELF_BRACKET_OPENING_WIDTH,
        openingHeight = SHELF_BRACKET_OPENING_HEIGHT,
        connectionHeight = SHELF_BRACKET_CONNECTION_HEIGHT,
        yDepth = SHELF_BRACKET_Y_DEPTH,
        yGap = SHELF_BRACKET_Y_GAP
    );    
}

function getVerticalOffsetForShelfAtHeight(height) =
    height - SHELF_BRACKET_OPENING_HEIGHT - SHELF_BRACKET_CONNECTION_HEIGHT - SHELF_THICKNESS;

/**
  * Creates the complete left side with side, dovetails, and brackets
  */
module leftSide() {
    union() {
        sideWithDovetail();
        if (shelf_brackets_on_bottom) {
            translate([SIDE_X, 0, shelf_brackets_bottom_offset])
                shelfBrackets();
        }
        if (shelf_brackets_on_top) {
            translate([SIDE_X, 0, getVerticalOffsetForShelfAtHeight(side_height)])
                shelfBrackets();
        }
    }
}

/**
  * Mirrors the left side and offsets it -1 unit
  *
  * Visually, this might seem wrong (the right gets added to the left)
  * but this is to maximize printing efficiency since the bulk of the
  * print will be two tall rectangles next to each other.
  */
module rightSide() {
    translate([-1, 0, 0])
        mirror([1, 0, 0])
            leftSide();
}

if (print_left) {
    leftSide();
}
if (print_right) {
    rightSide();
}

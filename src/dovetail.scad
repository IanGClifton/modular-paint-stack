// Copyright Ian G. Clifton 2026
// Apache 2.0 license
// https://github.com/IanGClifton/modular-paint-stack

include <constants.scad>

/**
  * Creates the dovetail shape for connecting pieces
  *
  * Top view
  * ____
  * \__/
  *
  * Side view
  * 
  * |\
  * | \
  * |  |
  * |  |
  * |  |
  * |__|
  *
  * xMin thinnest part of the x dimension where the dovetail connects
  * xMax thickest part of the x dimension on the outside of the dovetail
  * yDepth how far out the dovetail protrudes
  * zMin lowest part of the height/z dimension
  * zMax highest part of the height/z dimension
  * inset how much to "shrink" the dovetail for fitting in another piece
  */
module dovetail(xMin, xMax, yDepth, zMin, zMax, inset = 0) {
    points = [
        // Base
        [0 + inset, yDepth - inset, 0],               // 0 TL
        [xMax - inset, yDepth - inset, 0],            // 1 TR
        [((xMax - xMin) / 2) + inset, 0, 0],          // 2 BL
        [(((xMax - xMin) / 2) + xMin) - inset, 0, 0], // 3 BR
        // Top
        [0 + inset, yDepth - inset, zMin - inset],              // 4 TL
        [xMax - inset, yDepth - inset, zMin - inset],           // 5 TR
        [((xMax - xMin) / 2) + inset, 0, zMax - inset],         // 6 BL
        [(((xMax - xMin) / 2) + xMin) - inset, 0, zMax - inset] // 7 BR
    ];
    
    faces = [
        [0, 2, 3, 1], // Bottom
        [4, 5, 7, 6], // Top
        [6, 7, 3, 2], // Front
        [4, 6, 2, 0], // Left
        [4, 0, 1, 5], // Back
        [7, 5, 1, 3], // Right
        
    ];
    polyhedron(points, faces);
}

/**
 * Creates a dovetail using the default constants
 */
module dovetailDefault(inset = 0) {
    dovetail(
        xMin = DOVETAIL_XMIN,
        xMax = DOVETAIL_XMAX,
        yDepth = DOVETAIL_YDEPTH,
        zMin = DOVETAIL_ZMIN,
        zMax = DOVETAIL_ZMAX,
        inset = inset
    );
}

module dovetailSlot(height) {
    difference() {
        cube([SIDE_X, DOVETAIL_YDEPTH, height]);
        rotate([0, 0, 180]) {
            translate([-DOVETAIL_XMAX - DOVETAIL_OFFSET, -DOVETAIL_YDEPTH, 0]) {
                dovetailDefault();
            }
        }
    }
}
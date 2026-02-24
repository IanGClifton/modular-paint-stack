// Copyright Ian G. Clifton 2026
// Apache 2.0 license
// https://github.com/IanGClifton/modular-paint-stack

// Gridfinity units (42mm each) to make the width of the inner shelf part  
shelf_gridfinity_unit_width = 3;

// The following would be better as an array of array pairs,
// but makerworld.com doesn't seem to support that well in the GUI

// Diameter in mm for the first (front) row of holes
hole_diameter_1 = 5.5;
// Number of holes in the first row
hole_count_1 = 8;
// Diameter in mm for the second row of holes
hole_diameter_2 = 7.5;
// Number of holes in the second row
hole_count_2 = 7;
// Diameter in mm for the second row of holes
hole_diameter_3 = 10;
// Number of holes in the second row
hole_count_3 = 6;
// Diameter in mm for the second row of holes
hole_diameter_4 = 12;
// Number of holes in the second row
hole_count_4 = 5;
// How much wider the top of the hole should be than the bottom in mm
hole_variance = 0.1;

hole_diameter_and_count = [
    [hole_diameter_1, hole_count_1],
    [hole_diameter_2, hole_count_2],
    [hole_diameter_3, hole_count_3],
    [hole_diameter_4, hole_count_4]
];

include <shelf_base.scad>

/**
  * Creates cylinders to represent each paint tube/bottle
  */
module cylinderCutOuts(shelfMainWidth, cylinderDiameter, cylinderHeight, cylinderCount) {
    holeSpacing = (shelfMainWidth - (cylinderDiameter * cylinderCount)) / cylinderCount;
    xOffset = SHELF_SUPPORT_WIDTH + (holeSpacing / 2) + (cylinderDiameter / 2);
    radius1 = (cylinderDiameter / 2) + hole_variance;
    radius2 = (cylinderDiameter / 2);
    translate([xOffset, 0, 0]) {
        for (i = [0 : cylinderCount - 1]) {
            translate([(holeSpacing + cylinderDiameter) * i, 0, 0]) {
                cylinder(h = cylinderHeight + 1, r1 = radius1, r2 = radius2, $fn=CIRCLE_RESOLUTION);
            }
        }
    }
}

function sum(v) = [ for (p = v) 1 ] * v;
function flatten(v) = [ for (a = v) for (b = a) b ];
function vectorHasAZero(v) = len( [ for (i = v) if (i == 0) i ] ) > 0;
function filterZeros(v) = [ for (pair = v) if (!vectorHasAZero(pair)) pair ];
function sumHoleDiameter(v) = sum(flatten([ for (pair = v) pair[0] ]));
function diametersOnly(v) = flatten([ for (pair = v) pair[0] ]);
function slice(v, size) = [ for(i = [0 : size - 1]) v[i] ];
function sumOfPreviousDiameters(diameters, index) = (index == 0) ? 0 : sum(slice(diameters, index));
function calculateYOffset(diameters, index, spacing) = 1 + sumOfPreviousDiameters(diameters, index) + (spacing * (index + 0.5)) + (diameters[index] / 2);

/**
  * Creates the full shelf with holes cut out for paint brushes
  */
module shelfWithPaintCutouts(
    gridfinityUnits,
    holeDiameterAndCountArray
) {
    nonzeroHoleDiameterAndCountArray = filterZeros(holeDiameterAndCountArray);
    diameters = diametersOnly(nonzeroHoleDiameterAndCountArray);
    totalCutout = sum(diameters);
    totalNotCutOut = GRIDFINITY_DIMENSION - totalCutout - 2; // Minimum 1 mm on each side
    rowCount = len(nonzeroHoleDiameterAndCountArray);
    spacing = totalNotCutOut / rowCount;
    
    shelfMainWidth = getShelfMainWidth(gridfinityUnits);
    
    difference() {        
        uniformShelf(gridfinityUnits);
        
        for (i = [0 : len(diameters) - 1]) {
            translate([0, calculateYOffset(diameters, i, spacing), 0]) {
                cylinderCutOuts(shelfMainWidth, nonzeroHoleDiameterAndCountArray[i][0], SHELF_THICKNESS, nonzeroHoleDiameterAndCountArray[i][1]);            
            }
        }
    }
}

shelfWithPaintCutouts(shelf_gridfinity_unit_width, hole_diameter_and_count);

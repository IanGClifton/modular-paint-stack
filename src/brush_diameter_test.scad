// Copyright Ian G. Clifton 2026
// Apache 2.0 license
// https://github.com/IanGClifton/modular-paint-stack

holes_to_test = [
    5.0,
    5.5,
    6.0,
    6.5,
    7.0,
    7.5,
    8.0,
    8.5,
    9.0,
    9.5,
    10.0,
    10.5,
    11.0,
    11.5,
    12.0,
    12.5,
    13.0,
    13.5,
    14.0
];

distance_between_holes = 2;
shelf_thickness = 3;
hole_variance = 0.1;

CIRCLE_RESOLUTION = 100;
FONT_SIZE = 2;
FONT_HEIGHT = 0.4;

function sum(v) = [ for (p = v) 1 ] * v;
function slice(v, size) = [ for(i = [0 : size - 1]) v[i] ];
function sumOfPreviousValues(v, index) = (index == 0) ? 0 : sum(slice(v, index));

module createTestPiece(holesArray, spacing, thickness) {
    sum = sum(holesArray);
    largestHole = max(holesArray);
    xDimension = sum(holesArray) + ((len(holesArray) + 1) * spacing);
    yDimension = largestHole + (spacing * 2);
    zExtension = 0.1;

    union() {
        difference() {
            cube([xDimension, yDimension, thickness]);
            translate([spacing, largestHole / 2 + spacing, 0]) {
                for (i = [0 : len(holesArray) - 1]) {
                    holesSizeSoFar = sumOfPreviousValues(holesArray, i);
                    spacingSoFar = spacing * i;
                    radius1 = (holesArray[i] / 2) + hole_variance;
                    radius2 = (holesArray[i] / 2);

                    translate([holesSizeSoFar + spacingSoFar + radius2, 0, -zExtension]) {
                        cylinder(h = thickness + (2 * zExtension), r1 = radius1, r2 = radius2, $fn=CIRCLE_RESOLUTION);                
                    }
                }
            }
        }
        translate([spacing, 0, thickness]) {
            for (i = [0 : len(holesArray) - 1]) {
                holesSizeSoFar = sumOfPreviousValues(holesArray, i);
                spacingSoFar = spacing * i;
                radius = (holesArray[i] / 2);
                translate([holesSizeSoFar + spacingSoFar + radius, 0, -zExtension]) {
                    linear_extrude(height = FONT_HEIGHT) {
                        text(str(holesArray[i]), size = FONT_SIZE, font = "Arial:style=Regular", halign = "center", valign = "bottom");
                    }
                }
            }
        }
    }
}

createTestPiece(
    holesArray = holes_to_test,
    spacing = distance_between_holes,
    thickness = shelf_thickness
);

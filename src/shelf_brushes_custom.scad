// Copyright Ian G. Clifton 2026
// Apache 2.0 license
// https://github.com/IanGClifton/modular-paint-stack

hole_variance = 0.1;

include <shelf_base.scad>

// Gridfinity units (42mm each) to make the width of the inner shelf part  
shelf_gridfinity_unit_width = 5;
// Gridfinity units (42mm each) to make the depth of the shelf  
shelf_gridfinity_unit_depth = 1;
// Minimum space between brushes holes in millimeters
min_brush_spacing = 2;
// Minimum space between brush holes of different sizes in millimeters
min_brush_group_spacing = 4;

hole_rows_diameter_and_count = [
    [
        [6.0, 7],
        [6.5, 1],
        [7.5, 1],
        [8.0, 3],
    ],
    [
        [8.5, 1],
        [9.0, 2],
        [9.5, 2],
        [10.0, 1],
        [10.5, 1],
        [14.0, 2]
    ]
];

module customBrushShelfDefaults() {
    customBrushShelf(
        holeRowsDiameterAndCountArray = hole_rows_diameter_and_count,
        gridfinityWidth = shelf_gridfinity_unit_width,
        gridfinityDepth = shelf_gridfinity_unit_depth,
        minBrushSpacing = min_brush_spacing,
        minBrushGroupSpacing = min_brush_group_spacing
    );
}


module customBrushShelf(holeRowsDiameterAndCountArray, gridfinityWidth, gridfinityDepth, minBrushSpacing, minBrushGroupSpacing) {
    difference() {
        uniformShelf(gridfinityWidth, gridfinityDepth);
        customCylinderCutOuts(holeRowsDiameterAndCountArray, gridfinityWidth, gridfinityDepth, minBrushSpacing, minBrushGroupSpacing);
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

function calculateSpaceNeeded(holeDiameterAndCountArray, minBrushSpacing, minBrushGroupSpacing) =
    let(
        // Sum of all hole diameters across all groups
        totalHoleDiameters = sum([
            for (group = holeDiameterAndCountArray)
                group[0] * group[1]  // diameter * count
        ]),

        // Sum of spacing between holes within each group
        // A group with N holes has (N-1) gaps between them
        totalIntraGroupSpacing = sum([
            for (group = holeDiameterAndCountArray)
                (group[1] - 1) * minBrushSpacing
        ]),

        // Spacing between groups: (number of groups - 1) gaps
        totalInterGroupSpacing = 
            (len(holeDiameterAndCountArray) - 1) * minBrushGroupSpacing
    )
    totalHoleDiameters + totalIntraGroupSpacing + totalInterGroupSpacing;


function calculateRowYOffsets(rows, shelfDepth) =
    let(
        numRows = len(rows),
        
        // Largest diameter in each row
        rowMaxDiameters = [for (row = rows) max([for (group = row) group[0]])],
        
        // Total space consumed by hole diameters
        totalDiameters = sum(rowMaxDiameters),
        
        // Remaining space divided evenly between rows
        spacing = (shelfDepth - totalDiameters) / (numRows + 1)
    )
    [
        for (rowIdx = [0 : numRows - 1])
            (rowIdx == 0 ? spacing : (sum([for (i = [0 : rowIdx - 1]) rowMaxDiameters[i]])) + (spacing * (rowIdx + 1)))
    ];

module customCylinderCutOuts(holeRowsDiameterAndCountArray, gridfinityWidth, gridfinityDepth, minBrushSpacing, minBrushGroupSpacing) {
    // Figure out shelf space available
    shelfMainWidth = getShelfMainWidth(gridfinityWidth) - (SHELF_SUPPORT_SPACING * 2);
    shelfDepth = (GRIDFINITY_DIMENSION * gridfinityDepth) - (minBrushSpacing * 2);
    yOffsets = calculateRowYOffsets(holeRowsDiameterAndCountArray, shelfDepth);
    zExtension = 0.1;

    // i == index for row
    for (i = [0 : len(holeRowsDiameterAndCountArray) - 1]) {
        translate([SHELF_SUPPORT_SPACING + SHELF_SUPPORT_WIDTH, yOffsets[i], -zExtension]) {
            let(
                row = holeRowsDiameterAndCountArray[i],
                yOffset = yOffsets[i],
                biggestRadius = max(diametersOnly(holeRowsDiameterAndCountArray[i])) / 2,
                totalHoleDiameters = sum([for (g = row) g[0] * g[1]]),
                numGroups          = len(row),
                totalHoles         = sum([for (g = row) g[1]]),
                totalGapUnits      = totalHoles + numGroups,
                spacingUnit        = (shelfMainWidth - totalHoleDiameters) / totalGapUnits,
                intraSpacing       = spacingUnit,

                // Pre-calculate x offset for each group
                groupXOffsets = [
                    for (offsetIndex = [0 : len(row) - 1])
                        let(
                            // Total gaps = (holes-1) intra-group gaps + (groups-1) inter-group gaps
                            // Inter-group gap counts as 2x, so total "gap units":
                            interSpacing = spacingUnit * 2
                        )
                        (offsetIndex == 0 ? 0 : 
                            sum([
                                for (g = [0 : offsetIndex - 1])
                                    row[g][0] * row[g][1] + (row[g][1] - 1) * intraSpacing
                            ])
                        ) + (offsetIndex * interSpacing)
                ]
            )
            // groupIndex == index of group within row
            for (groupIndex = [0 : len(row) - 1]) {
                let(
                    diameter = row[groupIndex][0],
                    count    = row[groupIndex][1],
                    groupX   = groupXOffsets[groupIndex],
                    radius1 = (diameter / 2) + hole_variance,
                    radius2 = (diameter / 2)                
                )
                // holeIndex == index of individual hole within group
                for (holeIndex = [0 : count - 1]) {
                    let(x = groupX + ((holeIndex + 1) * (diameter + intraSpacing)))
                    translate([x - diameter/2, biggestRadius, 0])
                        cylinder(h = SHELF_THICKNESS + (2 * zExtension), r1 = radius1, r2 = radius2, center = false, $fn=CIRCLE_RESOLUTION);
                }
            }
        }
    }
}

module unitTest() {
    sampleArray1 = [[5.0, 2], [6.5, 1]];
    expectedFirstResult = 5.0 + 2 + 5.0 + 4.0 + 6.5;
    firstResult = calculateSpaceNeeded(sampleArray1, 2, 4);
    if (firstResult == expectedFirstResult) {
        echo("Correct first result: ", firstResult);
    } else {
        echo("Incorrect first result. Received ", firstResult, " but expected ", expectedFirstResult);
    }
    
    sampleRows1 = [
        [
            [5.0, 7]
        ],
        [
            [5.0, 3]
        ]
    ];
    expectedRowOffsets1 = [7, 19];
    rowOffsets1 = calculateRowYOffsets(rows = sampleRows1, shelfDepth = 31);
    if (rowOffsets1 == expectedRowOffsets1) {
        echo("Correct rowOffsets1: ", rowOffsets1);
    } else {
        echo("Incorrect rowOffsets1. Received ", rowOffsets1, " but expected ", expectedRowOffsets1);
    }
}

//unitTest();

translate([-getShelfFullWidth(shelf_gridfinity_unit_width) / 2, -GRIDFINITY_DIMENSION / 2, 0]) {
    customBrushShelfDefaults();
}
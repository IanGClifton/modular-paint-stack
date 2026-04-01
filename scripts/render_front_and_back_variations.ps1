# Renders all front and back variations from front_and_back.scad

# ── Configuration ────────────────────────────────────────────────────────────

$ScadFile       = "../src/front_and_back.scad"
$OpenScadExe    = "C:\Program Files\OpenSCAD\openscad.exe"
$OutputDir      = "output"
$DateStamp      = "20260331"
$Version        = "v1"

# ── Lookup tables ─────────────────────────────────────────────────────────────

$CutoutNames = @{
    0 = "blank"
    1 = "oval"
    2 = "rectangle"
    3 = "angled rectangle"
}

$Heights      = @(30, 50, 80, 100)
$CutoutShapes = @(0, 1, 2, 3)
$GfuWidths    = @(3, 4, 5)

# ── Preflight checks ──────────────────────────────────────────────────────────

if (-not (Test-Path $OpenScadExe)) {
    Write-Error "OpenSCAD not found at:`n  $OpenScadExe`nEdit `$OpenScadExe in this script to match your installation."
    exit 1
}

if (-not (Test-Path $ScadFile)) {
    Write-Error "SCAD file '$ScadFile' not found. Run this script from the same folder as the .scad file."
    exit 1
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

# ── Helper function ───────────────────────────────────────────────────────────

function Render-Variation {
    param(
        [string]  $Side,           # "front" or "back"
        [int]     $Height,
        [int]     $Cutout,
        [int]     $Gfu
    )

    $cutoutLabel = $CutoutNames[$Cutout]
    $fileName    = "$Side $cutoutLabel ${Height}mm ${Gfu}gfu $Version-$DateStamp.stl"
    $outPath     = Join-Path $OutputDir $fileName

    # Build -D override flags
    if ($Side -eq "front") {
        $defines = @(
            "-D", "print_front=true",
            "-D", "print_back=false",
            "-D", "front_height=$Height",
            "-D", "cutout_shape_front=$Cutout",
            "-D", "shelf_gridfinity_unit_width=$Gfu"
        )
    } else {
        $defines = @(
            "-D", "print_front=false",
            "-D", "print_back=true",
            "-D", "back_height=$Height",
            "-D", "cutout_shape_back=$Cutout",
            "-D", "shelf_gridfinity_unit_width=$Gfu"
        )
    }

    $args = $defines + @("-o", $outPath, $ScadFile)

    Write-Host "Rendering: $fileName"
    & $OpenScadExe $args

    if ($LASTEXITCODE -ne 0) {
        Write-Warning "  OpenSCAD exited with code $LASTEXITCODE for: $fileName"
    }
}

# ── Main loop ─────────────────────────────────────────────────────────────────

$total   = 2 * $Heights.Count * $CutoutShapes.Count * $GfuWidths.Count  # 2 × 4 × 4 × 3 = 96
$current = 0

foreach ($side in @("front", "back")) {
    foreach ($height in $Heights) {
        foreach ($cutout in $CutoutShapes) {
            foreach ($gfu in $GfuWidths) {
                $current++
                Write-Host "[$current/$total]" -NoNewline -ForegroundColor Cyan
                Write-Host " " -NoNewline
                Render-Variation -Side $side -Height $height -Cutout $cutout -Gfu $gfu
            }
        }
    }
}

Write-Host ""
Write-Host "Done! $total STL files written to: $OutputDir" -ForegroundColor Green

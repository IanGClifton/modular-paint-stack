# Renders all gridfinity shelf variations from shelf_gridfinity.scad

# ── Configuration ────────────────────────────────────────────────────────────

$ScadFile       = "../src/shelf_gridfinity.scad"
$OpenScadExe    = "C:\Program Files\OpenSCAD\openscad.exe"
$OutputDir      = "output"
$DateStamp      = "20260331"
$Version        = "v1"

# ── Lookup tables ─────────────────────────────────────────────────────────────

$GfuWidths  = @(3, 4, 5)
$ShelfModes = @(
    @{ Value = "true";  Label = "solid" },
    @{ Value = "false"; Label = "skeleton" }
)

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

# ── Main loop ─────────────────────────────────────────────────────────────────

$total   = $ShelfModes.Count * $GfuWidths.Count   # 2 × 3 = 6
$current = 0

foreach ($mode in $ShelfModes) {
    foreach ($gfu in $GfuWidths) {
        $current++

        $fileName = "gridfinity shelf $($mode.Label) ${gfu}gfu $Version-$DateStamp.stl"
        $outPath  = Join-Path $OutputDir $fileName

        $args = @(
            "-D", "solid_shelf=$($mode.Value)",
            "-D", "shelf_gridfinity_unit_width=$gfu",
            "-o", $outPath,
            $ScadFile
        )

        Write-Host "[$current/$total]" -NoNewline -ForegroundColor Cyan
        Write-Host " Rendering: $fileName"
        & $OpenScadExe $args

        if ($LASTEXITCODE -ne 0) {
            Write-Warning "  OpenSCAD exited with code $LASTEXITCODE for: $fileName"
        }
    }
}

Write-Host ""
Write-Host "Done! $total STL files written to: $OutputDir" -ForegroundColor Green

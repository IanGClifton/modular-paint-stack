# Renders all sides variations from sides.scad

# ── Configuration ────────────────────────────────────────────────────────────

$ScadFile    = "../src/sides.scad"
$OpenScadExe = "C:\Program Files\OpenSCAD\openscad.exe"
$OutputDir   = "output"
$DateStamp   = "20260331"
$Version     = "v1"

# ── Lookup tables ─────────────────────────────────────────────────────────────

$Heights = @(30, 50, 80, 100, 120, 140, 160, 180, 200)

$BracketModes = @(
    @{ Top = "true";  Bottom = "false"; Label = "top" },
    @{ Top = "false"; Bottom = "true";  Label = "bottom" }
)

# ── Preflight checks ──────────────────────────────────────────────────────────

if (-not (Test-Path $OpenScadExe)) {
    Write-Error "OpenSCAD not found at:`n  $OpenScadExe`nEdit `$OpenScadExe in this script to match your installation."
    exit 1
}

if (-not (Test-Path $ScadFile)) {
    Write-Error "SCAD file '$ScadFile' not found. Check the path relative to where you are running this script."
    exit 1
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

# ── Main loop ─────────────────────────────────────────────────────────────────

$total   = $BracketModes.Count * $Heights.Count   # 2 × 9 = 18
$current = 0

foreach ($mode in $BracketModes) {
    foreach ($height in $Heights) {
        $current++

        $fileName = "sides ${height}mm $($mode.Label) brackets $Version-$DateStamp.stl"
        $outPath  = Join-Path $OutputDir $fileName

        $args = @(
            "-D", "side_height=$height",
            "-D", "shelf_brackets_on_top=$($mode.Top)",
            "-D", "shelf_brackets_on_bottom=$($mode.Bottom)",
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

# Renders variations from ../src/shelf_standing_paints.scad

# ── Configuration ────────────────────────────────────────────────────────────

$ScadFile    = "../src/shelf_standing_paints.scad"
$OpenScadExe = "C:\Program Files\OpenSCAD\openscad.exe"
$OutputDir   = "output"
$DateStamp   = "20260331"
$Version     = "v1"

# ── Brand menu ────────────────────────────────────────────────────────────────

$Brands = @(
    @{ Name = "liquitex heavy body acrylic 59ml";  CylinderHeight = 14.8; CylinderDiameter = 29.5 },
    @{ Name = "liquitex heavy body acrylic 138ml"; CylinderHeight = 19.2; CylinderDiameter = 39.5 },
    @{ Name = "liquitex soft body acrylic 59ml";   CylinderHeight = 20;   CylinderDiameter = 41   }
)

Write-Host ""
Write-Host "Select a paint brand:" -ForegroundColor Yellow
for ($i = 0; $i -lt $Brands.Count; $i++) {
    Write-Host "  $($i + 1). $($Brands[$i].Name)"
}
Write-Host ""

do {
    $raw = Read-Host "Enter number (1-$($Brands.Count))"
    $selection = $raw -as [int]
} while ($null -eq $selection -or $selection -lt 1 -or $selection -gt $Brands.Count)

$chosen           = $Brands[$selection - 1]
$PaintBrand       = $chosen.Name
$CylinderHeight   = $chosen.CylinderHeight
$CylinderDiameter = $chosen.CylinderDiameter

Write-Host ""
Write-Host "Generating STLs for: $PaintBrand" -ForegroundColor Green
Write-Host ""

# ── Variable values ───────────────────────────────────────────────────────────

$GfuWidths   = @(3, 4, 5)
$TopInsets   = @($false, $true)
# cylinder_count always matches shelf_gridfinity_unit_width

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

$total   = $GfuWidths.Count * $TopInsets.Count   # 3 widths × 2 inset variants = 6
$current = 0

foreach ($gfu in $GfuWidths) {
    $paintCount = $gfu

    foreach ($topInset in $TopInsets) {
        $current++

        $sidesLabel   = if ($topInset) { "slanted sides" } else { "straight sides" }
        $topInsetScad = if ($topInset) { "true" } else { "false" }

        $fileName = "shelf $PaintBrand ${gfu}gfu ${paintCount}pc $sidesLabel $Version-$DateStamp.stl"
        $outPath  = Join-Path $OutputDir $fileName

        $args = @(
            "-D", "shelf_gridfinity_unit_width=$gfu",
            "-D", "cylinder_height=$CylinderHeight",
            "-D", "cylinder_diameter=$CylinderDiameter",
            "-D", "cylinder_count=$paintCount",
            "-D", "top_inset=$topInsetScad",
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
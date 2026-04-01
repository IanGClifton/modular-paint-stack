# Renders variations from ../src/shelf_hanging_paints.scad

# ── Configuration ────────────────────────────────────────────────────────────

$ScadFile    = "../src/shelf_hanging_paints.scad"
$OpenScadExe = "C:\Program Files\OpenSCAD\openscad.exe"
$OutputDir   = "output"
$DateStamp   = "20260331"
$Version     = "v1"

# ── Brand definitions ─────────────────────────────────────────────────────────
# PaintCountOffsets: list of offsets added to gfu to get paint_count values
# e.g. @(0, 1, 2) means gfu, gfu+1, gfu+2

$Brands = @(
    @{ Name = "charvin extra fine acrylics 20ml";           NeckHeight = 4.0;  NeckDiameter = 12.9; SupportExtraLen = 8; PaintCountOffsets = @(0, 1, 2) },
    @{ Name = "golden open acrylics 22ml";                  NeckHeight = 3.5;  NeckDiameter = 11.4; SupportExtraLen = 8; PaintCountOffsets = @(0, 1, 2) },
    @{ Name = "golden open acrylics 59ml";                  NeckHeight = 6.8;  NeckDiameter = 17.4; SupportExtraLen = 4; PaintCountOffsets = @(0, 1)    },
    @{ Name = "shinhan professional designers gouache 15ml"; NeckHeight = 3.9;  NeckDiameter = 12.0; SupportExtraLen = 8; PaintCountOffsets = @(0, 1, 2) },
    @{ Name = "schmincke horadam gouache 15ml";              NeckHeight = 2.7;  NeckDiameter = 8.5;  SupportExtraLen = 8; PaintCountOffsets = @(0, 1, 2) },
    @{ Name = "winsor & newton designers gouache 14ml";      NeckHeight = 3.0;  NeckDiameter = 13.2; SupportExtraLen = 8; PaintCountOffsets = @(0, 1, 2) },
    @{ Name = "winsor & newton designers gouache 37ml";      NeckHeight = 3.0;  NeckDiameter = 13.2; SupportExtraLen = 8; PaintCountOffsets = @(0, 1)    },
    @{ Name = "winsor & newton galleria acrylic 60ml";       NeckHeight = 6.0;  NeckDiameter = 16.8; SupportExtraLen = 4; PaintCountOffsets = @(0, 1)    },
    @{ Name = "winsor & newton galleria acrylic 200ml";      NeckHeight = 4.8;  NeckDiameter = 20.8; SupportExtraLen = 2; PaintCountOffsets = @(0)        },
    @{ Name = "winsor & newton professional acrylic 60ml";   NeckHeight = 3.0;  NeckDiameter = 13.8; SupportExtraLen = 4; PaintCountOffsets = @(0, 1)    },
    @{ Name = "winsor & newton professional acrylic 200ml";  NeckHeight = 4.8;  NeckDiameter = 20.8; SupportExtraLen = 2; PaintCountOffsets = @(0)        }
)

# ── Brand menu ────────────────────────────────────────────────────────────────

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

$chosen         = $Brands[$selection - 1]
$PaintBrand     = $chosen.Name
$NeckHeight     = $chosen.NeckHeight
$NeckDiameter   = $chosen.NeckDiameter
$SupportExtraLen = $chosen.SupportExtraLen
$PaintCountOffsets = $chosen.PaintCountOffsets

Write-Host ""
Write-Host "Generating STLs for: $PaintBrand" -ForegroundColor Green
Write-Host ""

# ── Variable values ───────────────────────────────────────────────────────────

$GfuWidths = @(3, 4, 5)

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

$total   = $GfuWidths.Count * $PaintCountOffsets.Count
$current = 0

foreach ($gfu in $GfuWidths) {
    foreach ($offset in $PaintCountOffsets) {
        $current++
        $paintCount = $gfu + $offset

        $fileName = "shelf $PaintBrand ${gfu}gfu ${paintCount}pc $Version-$DateStamp.stl"
        $outPath  = Join-Path $OutputDir $fileName

        $args = @(
            "-D", "paint_neck_height=$NeckHeight",
            "-D", "paint_neck_diameter=$NeckDiameter",
            "-D", "paint_count=$paintCount",
            "-D", "paint_support_extra_length=$SupportExtraLen",
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

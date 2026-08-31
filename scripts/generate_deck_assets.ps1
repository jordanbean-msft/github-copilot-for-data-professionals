$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$assetDir = Join-Path $root 'deck\assets'
New-Item -ItemType Directory -Force -Path $assetDir | Out-Null

function Color-Hex($hex) {
    return [System.Drawing.ColorTranslator]::FromHtml("#$hex")
}

function New-Canvas($width = 1400, $height = 820, $bg = 'FFFFFF') {
    $bmp = New-Object System.Drawing.Bitmap $width, $height
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
    $g.Clear((Color-Hex $bg))
    [pscustomobject]@{ Bitmap = $bmp; Graphics = $g; Width = $width; Height = $height }
}

function Save-Canvas($canvas, $name) {
    $path = Join-Path $assetDir $name
    $canvas.Bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $canvas.Graphics.Dispose()
    $canvas.Bitmap.Dispose()
}

function Fill-RoundRect($g, $x, $y, $w, $h, $r, $color) {
    $brush = New-Object System.Drawing.SolidBrush (Color-Hex $color)
    if ($r -le 0) {
        $g.FillRectangle($brush, $x, $y, $w, $h)
        $brush.Dispose()
        return
    }
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    $g.FillPath($brush, $path)
    $brush.Dispose()
    $path.Dispose()
}

function Draw-Text($g, $text, $x, $y, $w, $h, $size, $color, $bold = $false, $align = 'Near') {
    $style = if ($bold) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }
    $font = [System.Drawing.Font]::new('Segoe UI', [float]$size, $style, [System.Drawing.GraphicsUnit]::Pixel)
    $brush = New-Object System.Drawing.SolidBrush (Color-Hex $color)
    $fmt = New-Object System.Drawing.StringFormat
    $fmt.Alignment = [System.Drawing.StringAlignment]::$align
    $fmt.LineAlignment = [System.Drawing.StringAlignment]::Center
    $g.DrawString($text, $font, $brush, [System.Drawing.RectangleF]::new($x, $y, $w, $h), $fmt)
    $fmt.Dispose(); $brush.Dispose(); $font.Dispose()
}

function Draw-Line($g, $x1, $y1, $x2, $y2, $color, $width = 8) {
    $pen = New-Object System.Drawing.Pen (Color-Hex $color), $width
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $g.DrawLine($pen, $x1, $y1, $x2, $y2)
    $pen.Dispose()
}

function Draw-Circle($g, $cx, $cy, $r, $color) {
    $brush = New-Object System.Drawing.SolidBrush (Color-Hex $color)
    $g.FillEllipse($brush, $cx - $r, $cy - $r, $r * 2, $r * 2)
    $brush.Dispose()
}

# Hero
$c = New-Canvas 1400 900 '000041'; $g = $c.Graphics
Fill-RoundRect $g 740 95 560 600 38 '0078D3'
Draw-Circle $g 1180 165 160 '50E6FF'; Draw-Circle $g 1030 590 230 '000041'
Fill-RoundRect $g 820 200 330 420 28 'FFFFFF'
Draw-Circle $g 930 365 85 '50E6FF'; Draw-Circle $g 1038 455 118 '0078D3'; Draw-Circle $g 910 560 65 '107C10'
Fill-RoundRect $g 95 150 520 475 32 '11145A'
Fill-RoundRect $g 145 210 380 45 12 '50E6FF'
foreach ($i in 0..4) { Fill-RoundRect $g 145 (310 + $i * 52) (360 + (($i % 2) * 85)) 24 8 'FFFFFF' }
Draw-Text $g 'GitHub Copilot' 125 48 760 80 58 'FFFFFF' $true
Draw-Text $g 'for supply-chain data teams' 130 112 700 50 34 '50E6FF' $true
Draw-Text $g 'Orders + Shipments + Inventory' 155 520 470 60 31 'FFFFFF' $true
Draw-Text $g 'Accelerates operational insights' 825 670 420 65 32 'FFFFFF' $true 'Center'
Save-Canvas $c 'hero-data-copilot.png'

# Workflow
$c = New-Canvas 1600 600 'F6FBFF'; $g = $c.Graphics
$steps = @(
    @('Source',160,300,'0078D3'), @('Profile',405,165,'50E6FF'), @('Validate',650,350,'F7630C'),
    @('Transform',895,190,'5C2D91'), @('Analyze',1140,350,'107C10'), @('Predict',1385,210,'0078D3')
)
for ($i=0; $i -lt $steps.Count-1; $i++) { Draw-Line $g $steps[$i][1] $steps[$i][2] $steps[$i+1][1] $steps[$i+1][2] 'CADCFC' 22 }
for ($i=0; $i -lt $steps.Count; $i++) {
    $s = $steps[$i]; Draw-Circle $g $s[1] $s[2] 92 $s[3]
    Draw-Text $g $s[0] ($s[1]-92) ($s[2]-34) 184 68 25 'FFFFFF' $true 'Center'
    Draw-Text $g ("{0:D2}" -f ($i+1)) ($s[1]-35) ($s[2]+100) 70 40 28 '000041' $true 'Center'
}
Save-Canvas $c 'workflow-map.png'

# Architecture
$c = New-Canvas 1500 720 'EBEBEB'; $g = $c.Graphics
Fill-RoundRect $g 55 65 1390 585 34 'FFFFFF'
$boxes = @(
    @('GitHub repo','supply-chain scripts + prompts',110,225,210,150,'000041'),
    @('VS Code + Copilot','generate, explain, test',420,225,270,150,'0078D3'),
    @('Fabric notebook','supplier + inventory transforms',805,165,270,120,'5C2D91'),
    @('Lakehouse','orders, shipments, inventory',805,335,270,120,'107C10'),
    @('Power BI','risk scorecards',1190,250,220,150,'F7630C')
)
foreach ($b in $boxes) {
    Fill-RoundRect $g $b[2] $b[3] $b[4] $b[5] 24 $b[6]
    Draw-Text $g $b[0] ($b[2]+15) ($b[3]+34) ($b[4]-30) 38 29 'FFFFFF' $true 'Center'
    Draw-Text $g $b[1] ($b[2]+15) ($b[3]+78) ($b[4]-30) 42 20 'FFFFFF' $false 'Center'
}
Draw-Line $g 325 300 410 300 '0078D3' 10; Draw-Line $g 700 300 795 225 '0078D3' 10; Draw-Line $g 700 300 795 395 '0078D3' 10; Draw-Line $g 1080 310 1180 325 '0078D3' 10
Draw-Text $g 'Microsoft Fabric demo architecture' 90 90 700 60 38 '000041' $true
Draw-Text $g 'Synthetic data only: purchase orders + shipments + inventory snapshots' 92 565 1000 38 25 '75757A'
Save-Canvas $c 'fabric-architecture.png'

# Code window
$c = New-Canvas 1200 760 '000041'; $g = $c.Graphics
Draw-Circle $g 75 70 16 'D13438'; Draw-Circle $g 125 70 16 'F7630C'; Draw-Circle $g 175 70 16 '107C10'
Fill-RoundRect $g 75 145 430 42 12 '50E6FF'
foreach ($i in 0..5) { Fill-RoundRect $g 75 (240 + $i * 60) (650 - ($i % 3) * 120) 28 8 $(if ($i % 2) { 'FFFFFF' } else { '50E6FF' }) }
Fill-RoundRect $g 75 610 1020 86 22 '0078D3'
Draw-Text $g 'Copilot prompt -> runnable data workflow' 110 618 950 66 39 'FFFFFF' $true 'Center'
Save-Canvas $c 'code-window.png'

# Quality dashboard
$c = New-Canvas 1200 720 'F6FBFF'; $g = $c.Graphics
Fill-RoundRect $g 70 60 1060 105 25 '000041'; Draw-Text $g 'Data Quality Results' 120 82 600 58 42 'FFFFFF' $true
$quality = @(@('28','failed rows','D13438',90), @('4','active rules','F7630C',425), @('1','passing rule','107C10',760))
foreach ($q in $quality) { Fill-RoundRect $g $q[3] 230 280 300 28 'FFFFFF'; Draw-Text $g $q[0] ($q[3]+35) 270 180 95 86 $q[2] $true; Draw-Text $g $q[1] ($q[3]+38) 382 200 45 31 '000041' $true }
Fill-RoundRect $g 130 575 900 48 20 'EBEBEB'; Fill-RoundRect $g 130 575 680 48 20 '0078D3'
Draw-Text $g 'Prompt: generate quarantine logic with reason codes' 128 640 900 45 28 '000041' $true
Save-Canvas $c 'quality-dashboard.png'

# SQL
$c = New-Canvas 1200 720 '000041'; $g = $c.Graphics
Draw-Text $g 'SQL analytics from plain English' 75 60 700 55 42 '50E6FF' $true
Fill-RoundRect $g 75 165 455 390 28 'FFFFFF'; Draw-Text $g 'Business question' 115 210 350 45 30 '000041' $true
Draw-Text $g 'Which suppliers are at risk?' 115 292 355 90 34 '0078D3' $true
Draw-Text $g 'By lane, plant, and part' 115 410 330 45 26 '75757A'
Fill-RoundRect $g 615 165 500 390 28 '11145A'
foreach ($i in 0..5) { Fill-RoundRect $g 680 (230 + $i * 48) (315 + ($i % 2) * 80) 22 8 $(if ($i % 2) { 'FFFFFF' } else { '50E6FF' }) }
Save-Canvas $c 'sql-analytics.png'

# Model
$c = New-Canvas 1200 720 'FFFFFF'; $g = $c.Graphics
Draw-Text $g 'Supply-Chain Feature Flow' 70 42 620 56 40 '000041' $true
Fill-RoundRect $g 85 140 470 420 30 'F6FBFF'
Draw-Text $g 'Risk Features' 115 170 280 42 29 '000041' $true

$features = @(
    @('Supplier history','F7630C',230),
    @('Lane performance','D13438',310),
    @('Expedite flag','5C2D91',390),
    @('Days of supply','107C10',470)
)
foreach ($f in $features) {
    Fill-RoundRect $g 130 $f[2] 360 58 18 $f[1]
    Draw-Text $g $f[0] 160 ($f[2]+8) 300 38 24 'FFFFFF' $true 'Center'
}

Fill-RoundRect $g 650 230 450 120 26 '0078D3'
Draw-Text $g 'Late-Delivery Risk Score' 700 260 350 54 34 'FFFFFF' $true 'Center'
Fill-RoundRect $g 650 395 450 120 26 '107C10'
Draw-Text $g 'Decision: Expedite / Monitor' 700 425 350 54 30 'FFFFFF' $true 'Center'

# Straight, non-crossing connectors
Draw-Line $g 490 260 650 270 '0078D3' 8
Draw-Line $g 490 340 650 300 '0078D3' 8
Draw-Line $g 490 420 650 430 '107C10' 8
Draw-Line $g 490 500 650 455 '107C10' 8
Draw-Line $g 875 350 875 395 '000041' 8

Save-Canvas $c 'model-features.png'

# Metrics
$c = New-Canvas 1250 720 'EBEBEB'; $g = $c.Graphics
Fill-RoundRect $g 70 65 1110 110 28 '000041'; Draw-Text $g 'Measure adoption and outcomes' 120 92 780 58 42 'FFFFFF' $true
foreach ($x in 90,380,670,960) { Fill-RoundRect $g $x 240 220 330 26 'FFFFFF' }
Fill-RoundRect $g 135 385 55 145 0 '0078D3'; Fill-RoundRect $g 215 325 55 205 0 '50E6FF'
Draw-Circle $g 490 405 80 '107C10'; Draw-Circle $g 490 405 45 'FFFFFF'
Draw-Line $g 715 500 765 450 '0078D3' 14; Draw-Line $g 765 450 825 470 '0078D3' 14; Draw-Line $g 825 470 890 345 '0078D3' 14
Draw-Text $g '4x' 1005 350 130 100 82 '000041' $true 'Center'
Save-Canvas $c 'metrics-dashboard.png'

Write-Host "Generated deck PNG assets in $assetDir"

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$assetDir = Join-Path $root 'deck\assets'
New-Item -ItemType Directory -Force -Path $assetDir | Out-Null

function Color-Hex($hex) {
    return [System.Drawing.ColorTranslator]::FromHtml("#$hex")
}

function New-Canvas($width = 1200, $height = 944, $bg = 'FFFFFF') {
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

# ---- Step 1: Generate supply-chain data quickly ----
$c = New-Canvas 1200 944 '000041'; $g = $c.Graphics
Draw-Text $g 'Supply-Chain Data Generator' 70 55 900 60 40 '50E6FF' $true

$tables = @(
    @('Purchase Orders','500 rows',70,'0078D3'),
    @('Shipments','480 rows',430,'5C2D91'),
    @('Inventory Snapshots','365 rows',790,'107C10')
)
foreach ($t in $tables) {
    Fill-RoundRect $g $t[2] 165 340 400 26 '11145A'
    Fill-RoundRect $g ($t[2]+30) 200 280 46 12 $t[3]
    Draw-Text $g $t[0] ($t[2]+40) 205 260 40 24 'FFFFFF' $true 'Center'
    foreach ($i in 0..5) { Fill-RoundRect $g ($t[2]+30) (280 + $i * 44) (220 - ($i % 2) * 60) 20 6 $(if ($i % 2) { 'FFFFFF' } else { '50E6FF' }) }
    Fill-RoundRect $g ($t[2]+30) 520 190 40 10 $t[3]
    Draw-Text $g $t[1] ($t[2]+30) 522 190 36 22 'FFFFFF' $true 'Center'
}

Draw-Text $g 'Anomalies injected for realistic testing' 70 610 900 40 26 'FFFFFF' $true
$chips = @(
    @('missing plant',70,'D13438'),
    @('blank carrier',330,'F7630C'),
    @('negative cost',600,'D13438'),
    @('low stock',870,'F7630C')
)
foreach ($ch in $chips) {
    Fill-RoundRect $g $ch[1] 665 245 62 20 $ch[2]
    Draw-Text $g $ch[0] $ch[1] 665 245 62 24 'FFFFFF' $true 'Center'
}

Fill-RoundRect $g 70 790 1060 90 22 '0078D3'
Draw-Text $g 'Prompt: generate PO + shipment + inventory data with anomalies' 100 800 1000 70 26 'FFFFFF' $true 'Center'
Save-Canvas $c 'step1-generate-data.png'

# ---- Step 2: Profile operational data and surface risks ----
$c = New-Canvas 1200 944 'F6FBFF'; $g = $c.Graphics
Fill-RoundRect $g 70 55 1060 100 25 '000041'
Draw-Text $g 'Data Profile Summary' 115 75 700 58 40 'FFFFFF' $true

$rows = @(
    @('plant_id','3% missing','D13438',0.03),
    @('carrier','5% blank','F7630C',0.05),
    @('unit_cost','range $12 - $980','0078D3',0.55),
    @('ship_date','12 dates out of range','5C2D91',0.18)
)
$rowY = 195
foreach ($r in $rows) {
    Fill-RoundRect $g 90 $rowY 1020 145 24 'FFFFFF'
    Draw-Text $g $r[0] 125 ($rowY+18) 260 44 30 '000041' $true
    Fill-RoundRect $g 125 ($rowY+72) 760 34 14 'EBEBEB'
    Fill-RoundRect $g 125 ($rowY+72) ([int](760*$r[3])) 34 14 $r[2]
    Draw-Text $g $r[1] 900 ($rowY+62) 180 55 22 $r[2] $true
    $rowY += 165
}

Fill-RoundRect $g 90 855 1020 60 20 '0078D3'
Draw-Text $g 'Prompt: profile PO / shipment / inventory tables for risk signals' 110 860 1000 50 24 'FFFFFF' $true 'Center'
Save-Canvas $c 'step2-profile-data.png'

# ---- Step 4: Transform supplier and inventory signals ----
$c = New-Canvas 1200 944 'EBEBEB'; $g = $c.Graphics
Fill-RoundRect $g 55 55 1090 640 34 'FFFFFF'
Draw-Text $g 'Pandas -> PySpark Transform' 90 85 900 55 38 '000041' $true

Fill-RoundRect $g 110 220 380 220 26 '0078D3'
Draw-Text $g 'pandas DataFrame' 140 250 320 48 30 'FFFFFF' $true 'Center'
foreach ($i in 0..3) { Fill-RoundRect $g 140 (320 + $i * 32) (280 - ($i % 2) * 60) 16 6 'FFFFFF' }

Draw-Line $g 500 330 690 330 '000041' 12

Fill-RoundRect $g 700 220 380 220 26 '5C2D91'
Draw-Text $g 'PySpark + Delta Table' 730 250 320 48 28 'FFFFFF' $true 'Center'
foreach ($i in 0..3) { Fill-RoundRect $g 730 (320 + $i * 32) (280 - ($i % 2) * 60) 16 6 'FFFFFF' }

$outputs = @(
    @('supplier_delivery_risk','F7630C',110),
    @('inventory_risk_score','107C10',610)
)
foreach ($o in $outputs) {
    Fill-RoundRect $g $o[2] 500 480 110 22 $o[1]
    Draw-Text $g $o[0] $o[2] 500 480 110 26 'FFFFFF' $true 'Center'
}

Fill-RoundRect $g 90 640 1020 30 12 '0078D3'
Draw-Text $g 'Prompt: convert pandas transforms to PySpark and write Delta tables' 90 725 1020 60 26 '000041' $true 'Center'
Save-Canvas $c 'step4-transform-signals.png'

Write-Host "Generated step-specific PNG assets in $assetDir"

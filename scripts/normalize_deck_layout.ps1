param(
    [string]$DeckPath = "\\wsl.localhost\Ubuntu\home\jordanbean\source\repos\github-copilot-for-data-professionals\deck\github-copilot-for-data-professionals.pptx"
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $DeckPath)) { throw "Deck not found: $DeckPath" }

$tmpRoot = Join-Path $env:TEMP "copilot-deck-normalize"
New-Item -ItemType Directory -Force -Path $tmpRoot | Out-Null
$localDeck = Join-Path $tmpRoot "deck-layout-normalize.pptx"
$localOut = Join-Path $tmpRoot "deck-layout-normalize-out.pptx"
Copy-Item -LiteralPath $DeckPath -Destination $localDeck -Force
[System.IO.File]::SetAttributes($localDeck, [System.IO.FileAttributes]::Normal)
if (Test-Path $localOut) { Remove-Item $localOut -Force }
[System.IO.File]::SetAttributes($localDeck, [System.IO.FileAttributes]::Normal)

$app = $null
$presentation = $null
try {
    $app = New-Object -ComObject PowerPoint.Application
    $presentation = $app.Presentations.Open($localDeck, $true, $false, $false)

    # msoAutoSizeTextToFitShape = 2
    foreach ($slide in $presentation.Slides) {
        foreach ($shape in $slide.Shapes) {
            if ($shape.HasTextFrame -eq -1 -and $shape.TextFrame2.HasText -eq -1) {
                $shape.TextFrame2.WordWrap = -1
                $shape.TextFrame2.AutoSize = 2
                if ($shape.TextFrame2.MarginTop -lt 1) { $shape.TextFrame2.MarginTop = 1 }
                if ($shape.TextFrame2.MarginBottom -lt 1) { $shape.TextFrame2.MarginBottom = 1 }
            }
        }
    }

    $presentation.SaveAs($localOut)
    $presentation.Close()
    $presentation = $null
    Copy-Item -LiteralPath $localOut -Destination $DeckPath -Force
    Write-Host "Normalized text fit for slide shapes."
}
finally {
    if ($presentation) { $presentation.Close() }
    if ($app) { $app.Quit() }
}

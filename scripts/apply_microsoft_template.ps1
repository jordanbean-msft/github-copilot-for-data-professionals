param(
    [string]$DeckPath = "\\wsl.localhost\Ubuntu\home\jordanbean\source\repos\github-copilot-for-data-professionals\deck\github-copilot-for-data-professionals.pptx",
    [string]$TemplatePath = "C:\Users\jordanbean\OneDrive - Microsoft\000 - Core Team\WTH-Marketing\Presentations\0-WTH-Lectures-Template.pptx"
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path $DeckPath)) { throw "Deck not found: $DeckPath" }
if (-not (Test-Path $TemplatePath)) { throw "Template not found: $TemplatePath" }

$tmpRoot = Join-Path $env:TEMP "copilot-deck-template"
New-Item -ItemType Directory -Force -Path $tmpRoot | Out-Null
$localDeck = Join-Path $tmpRoot "deck-to-template.pptx"
$localOut = Join-Path $tmpRoot "deck-templated.pptx"

Copy-Item -LiteralPath $DeckPath -Destination $localDeck -Force
if (Test-Path $localOut) { Remove-Item $localOut -Force }
[System.IO.File]::SetAttributes($localDeck, [System.IO.FileAttributes]::Normal)

$app = $null
$presentation = $null
try {
    $app = New-Object -ComObject PowerPoint.Application
    $presentation = $app.Presentations.Open($localDeck, $true, $false, $false)
    $presentation.ApplyTemplate($TemplatePath)
    $presentation.SaveAs($localOut)
    $presentation.Close()
    $presentation = $null
    Copy-Item -LiteralPath $localOut -Destination $DeckPath -Force
    Write-Host "Applied template: $TemplatePath"
} finally {
    if ($presentation) { $presentation.Close() }
    if ($app) { $app.Quit() }
}

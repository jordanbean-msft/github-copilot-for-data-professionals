$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$iconDir = Join-Path $root 'deck\assets\icons'
New-Item -ItemType Directory -Force -Path $iconDir | Out-Null

$downloads = @(
    @{ Url = 'https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png'; Out = 'github-mark.png' },
    @{ Url = 'https://github.githubassets.com/images/modules/logos_page/GitHub-Logo.png'; Out = 'github-logo.png' },
    @{ Url = 'https://github.githubassets.com/images/modules/site/copilot/copilot.png'; Out = 'github-copilot.png' },
    @{ Url = 'https://learn.microsoft.com/en-us/fabric/media/fabric-icon.png'; Out = 'microsoft-fabric.png' }
)
# Architecture diagram icons (slide 4: vscode.png, power-bi.png, fabric-lakehouse.png,
# fabric-notebook.png) were rasterized from Iconify (api.iconify.design) SVG sources:
#   vscode.png            <- logos:visual-studio-code (SVG Logos set, CC0)
#   power-bi.png          <- logos:microsoft-power-bi (SVG Logos set, CC0)
#   fabric-lakehouse.png  <- fluent-color:database-48 (Fluent UI System Icons, MIT)
#   fabric-notebook.png   <- fluent-color:notebook-32 (Fluent UI System Icons, MIT)
# These are committed directly to deck/assets/icons/ since PNG rasterization requires a
# browser/graphics renderer rather than a simple download.

foreach ($item in $downloads) {
    $outPath = Join-Path $iconDir $item.Out
    Invoke-WebRequest -Uri $item.Url -OutFile $outPath -TimeoutSec 30
    Write-Host "Downloaded $($item.Out)"
}

Write-Host "Product icons available in $iconDir"

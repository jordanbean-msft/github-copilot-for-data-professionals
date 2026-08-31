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

foreach ($item in $downloads) {
    $outPath = Join-Path $iconDir $item.Out
    Invoke-WebRequest -Uri $item.Url -OutFile $outPath -TimeoutSec 30
    Write-Host "Downloaded $($item.Out)"
}

Write-Host "Product icons available in $iconDir"

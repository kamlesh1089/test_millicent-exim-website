$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$html = Get-Content -Raw (Join-Path $root 'index.html')

function Assert-Contains([string]$pattern, [string]$message) {
  if ($html -notmatch [regex]::Escape($pattern)) { throw $message }
}

function Assert-NotContains([string]$pattern, [string]$message) {
  if ($html -match [regex]::Escape($pattern)) { throw $message }
}

Assert-Contains '<header id="site-header"' 'Missing semantic site header.'
Assert-Contains '<main id="main-content"' 'Missing main content landmark.'
Assert-Contains '<footer id="site-footer"' 'Missing semantic site footer.'
Assert-NotContains 'src="assets/reference.png"' 'Desktop must not render the reference screenshot.'
Assert-NotContains 'class="hotspot' 'Transparent screenshot click zones must be removed.'
Assert-Contains 'assets/market-map-corrected.png' 'Corrected India map asset is not used.'
Assert-Contains 'id="mobile-menu"' 'Missing mobile menu control.'
Assert-Contains 'aria-expanded="false"' 'Mobile menu must expose its initial state.'

$requiredIds = @('home','categories','packaging','sourcing','markets','about','contact')
foreach ($id in $requiredIds) {
  Assert-Contains ('id="' + $id + '"') "Missing section target #$id."
  Assert-Contains ('href="#' + $id + '"') "Missing navigation link to #$id."
}

$imageSources = [regex]::Matches($html, 'src="([^"]+)"') | ForEach-Object { $_.Groups[1].Value }
foreach ($src in $imageSources) {
  if ($src -notmatch '^assets/') { throw "Image source is outside the approved assets directory: $src" }
}

Write-Output 'Homepage contract: PASS'

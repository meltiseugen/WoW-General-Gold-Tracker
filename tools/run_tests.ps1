$ErrorActionPreference = "Stop"

$localBin = Join-Path $env:USERPROFILE ".local\bin"
if (Test-Path -LiteralPath $localBin -PathType Container) {
    $env:PATH = "$localBin;$env:PATH"
}

busted tests
luacheck tests

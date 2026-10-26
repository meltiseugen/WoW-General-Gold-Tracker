$ErrorActionPreference = "Stop"
$repoPath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$addonsPath = [IO.Path]::GetFullPath((Join-Path $repoPath ".."))

# Development checkout only. Release packages place these folders beside GGT
# through .pkgmeta. Junctions keep local catalogs in sync without copying data.
foreach ($moduleName in @("Rares", "Instances", "Drops", "Materials", "Farms", "TSMRealmData", "MapData")) {
    $folderName = "General-Gold-Tracker_$moduleName"
    $sourcePath = [IO.Path]::GetFullPath((Join-Path $repoPath "Data\$folderName"))
    $targetPath = [IO.Path]::GetFullPath((Join-Path $addonsPath $folderName))
    if (-not $sourcePath.StartsWith($repoPath + '\', [StringComparison]::OrdinalIgnoreCase) -or
        [IO.Path]::GetDirectoryName($targetPath) -ne $addonsPath) {
        throw "Catalog path escapes the intended addon directories."
    }
    if (-not (Test-Path -LiteralPath (Join-Path $sourcePath "$folderName.toc"))) {
        throw "Missing catalog manifest: $sourcePath"
    }
    if (Test-Path -LiteralPath $targetPath) {
        $existing = Get-Item -LiteralPath $targetPath -Force
        if ($existing.LinkType -ne "Junction" -or $existing.Target -ne $sourcePath) {
            throw "Existing catalog folder is not this checkout's junction: $targetPath"
        }
        Write-Host "Already linked: $folderName"
    } else {
        New-Item -ItemType Junction -Path $targetPath -Target $sourcePath | Out-Null
        Write-Host "Linked: $folderName"
    }
}
Write-Host "Restart WoW completely once so it discovers the new data addons."

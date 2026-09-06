$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$AddOnsRoot = Split-Path -Parent $RepoRoot
$RareScannerRoot = Join-Path $AddOnsRoot "RareScanner"
$OutputPath = Join-Path $RepoRoot "Data\RareDrops.lua"

function ConvertTo-LuaString {
    param([string] $Value)

    $builder = [System.Text.StringBuilder]::new()
    [void] $builder.Append('"')
    foreach ($byte in [System.Text.Encoding]::UTF8.GetBytes($Value)) {
        if ($byte -eq 92) {
            [void] $builder.Append("\\")
        } elseif ($byte -eq 34) {
            [void] $builder.Append('\"')
        } elseif ($byte -ge 32 -and $byte -le 126) {
            [void] $builder.Append([char] $byte)
        } else {
            [void] $builder.Append("\" + $byte.ToString("000"))
        }
    }
    [void] $builder.Append('"')
    return $builder.ToString()
}

function Add-Location {
    param(
        [hashtable] $LocationsByNpc,
        [int] $NpcID,
        [Nullable[int]] $MapID,
        [string] $Body
    )

    if (-not $MapID -or $MapID -le 0) {
        return
    }

    $location = [ordered] @{ mapID = [int] $MapID }
    $xMatch = [regex]::Match($Body, "\bx\s*=\s*(\d+)")
    $yMatch = [regex]::Match($Body, "\by\s*=\s*(\d+)")
    if ($xMatch.Success -and $yMatch.Success) {
        $location.x = [int] $xMatch.Groups[1].Value
        $location.y = [int] $yMatch.Groups[1].Value
    }

    if (-not $LocationsByNpc.ContainsKey($NpcID)) {
        $LocationsByNpc[$NpcID] = @()
    }

    foreach ($existing in $LocationsByNpc[$NpcID]) {
        if ($existing.mapID -eq $location.mapID -and $existing.x -eq $location.x -and $existing.y -eq $location.y) {
            return
        }
    }
    $LocationsByNpc[$NpcID] = @($LocationsByNpc[$NpcID]) + $location
}

function Get-RareScannerVersion {
    $tocPath = Join-Path $RareScannerRoot "RareScanner.toc"
    foreach ($line in [System.IO.File]::ReadLines($tocPath)) {
        $match = [regex]::Match($line, "^##\s*Version:\s*(.+?)\s*$")
        if ($match.Success) {
            return $match.Groups[1].Value
        }
    }
    return "unknown"
}

function Get-LootTable {
    $lootPath = Join-Path $RareScannerRoot "Tables\NpcLootTables.lua"
    $rares = @{}
    foreach ($line in [System.IO.File]::ReadLines($lootPath)) {
        $match = [regex]::Match($line, "^\s*\[(\d+)\]\s*=\s*\{([^}]*)\};\s*--(.*)$")
        if (-not $match.Success) {
            continue
        }

        $itemIDs = @()
        foreach ($itemMatch in [regex]::Matches($match.Groups[2].Value, "\d+")) {
            $itemIDs += [int] $itemMatch.Value
        }
        if ($itemIDs.Count -eq 0) {
            continue
        }

        $rares[[int] $match.Groups[1].Value] = [ordered] @{
            name = $match.Groups[3].Value.Trim()
            loot = $itemIDs
            locations = @()
        }
    }
    return $rares
}

function Get-InfoLocations {
    $infoPath = Join-Path $RareScannerRoot "Tables\NpcInfoTables.lua"
    $locationsByNpc = @{}
    $currentID = $null
    $currentLines = @()

    function Flush-InfoEntry {
        param(
            [Nullable[int]] $NpcID,
            [string[]] $Lines,
            [hashtable] $Locations
        )

        if (-not $NpcID -or $Lines.Count -eq 0) {
            return
        }

        $body = $Lines -join "`n"
        if ([regex]::IsMatch($body, "\bzoneID\s*=\s*\{")) {
            foreach ($entryLine in $Lines) {
                $subMatch = [regex]::Match($entryLine, "\[(\d+)\]\s*=\s*\{(.*)\};")
                if ($subMatch.Success) {
                    Add-Location -LocationsByNpc $Locations -NpcID $NpcID -MapID ([int] $subMatch.Groups[1].Value) -Body $subMatch.Groups[2].Value
                }
            }
        } else {
            $zoneMatch = [regex]::Match($body, "\bzoneID\s*=\s*(\d+)")
            if ($zoneMatch.Success) {
                Add-Location -LocationsByNpc $Locations -NpcID $NpcID -MapID ([int] $zoneMatch.Groups[1].Value) -Body $body
            }
        }
    }

    foreach ($line in [System.IO.File]::ReadLines($infoPath)) {
        $startMatch = [regex]::Match($line, "^\s*\[(\d+)\]\s*=\s*\{")
        if ($startMatch.Success -and $null -eq $currentID) {
            $currentID = [int] $startMatch.Groups[1].Value
            $currentLines = @($line)
            if ($line.Contains("}; --")) {
                Flush-InfoEntry -NpcID $currentID -Lines $currentLines -Locations $locationsByNpc
                $currentID = $null
                $currentLines = @()
            }
            continue
        }

        if ($null -ne $currentID) {
            $currentLines += $line
            if ($line.Contains("}; --")) {
                Flush-InfoEntry -NpcID $currentID -Lines $currentLines -Locations $locationsByNpc
                $currentID = $null
                $currentLines = @()
            }
        }
    }

    return $locationsByNpc
}

function Get-MapEntityLocations {
    $mapPath = Join-Path $RareScannerRoot "Tables\MapEntitiesTables.lua"
    $locationsByNpc = @{}
    $currentMapID = $null

    foreach ($line in [System.IO.File]::ReadLines($mapPath)) {
        $mapMatch = [regex]::Match($line, "^\t\[(\d+)\]\s*=\s*\{$")
        if ($mapMatch.Success) {
            $currentMapID = [int] $mapMatch.Groups[1].Value
            continue
        }

        if ($null -eq $currentMapID) {
            continue
        }

        $npcMatch = [regex]::Match($line, "^\t\t\t\[1\]\s*=\s*\{([^}]*)\};")
        if (-not $npcMatch.Success) {
            continue
        }

        foreach ($npcMatchID in [regex]::Matches($npcMatch.Groups[1].Value, "\d+")) {
            $npcID = [int] $npcMatchID.Value
            if (-not $locationsByNpc.ContainsKey($npcID)) {
                $locationsByNpc[$npcID] = @()
            }
            $exists = $false
            foreach ($location in $locationsByNpc[$npcID]) {
                if ($location.mapID -eq $currentMapID) {
                    $exists = $true
                    break
                }
            }
            if (-not $exists) {
                $locationsByNpc[$npcID] = @($locationsByNpc[$npcID]) + ([ordered] @{ mapID = $currentMapID })
            }
        }
    }

    return $locationsByNpc
}

function Get-ExpansionFilters {
    $zonePath = Join-Path $RareScannerRoot "Tables\ZoneTables.lua"
    $options = @()
    $mapToExpansionID = @{}
    $currentID = $null

    foreach ($line in [System.IO.File]::ReadLines($zonePath)) {
        $match = [regex]::Match($line, "^\s*\[(\d+)\]\s*=\s*\{(.+)\};\s*--(.+)$")
        if (-not $match.Success) {
            continue
        }

        $continentMapID = [int] $match.Groups[1].Value
        $body = $match.Groups[2].Value
        $label = $match.Groups[3].Value.Trim()
        $idMatch = [regex]::Match($body, "\bid\s*=\s*(\d+)")
        $zonesMatch = [regex]::Match($body, "\bzones\s*=\s*\{([^}]*)\}")
        if (-not $idMatch.Success -or -not $zonesMatch.Success) {
            continue
        }

        $expansionID = [int] $idMatch.Groups[1].Value
        $zones = @()
        foreach ($zoneMatch in [regex]::Matches($zonesMatch.Groups[1].Value, "\d+")) {
            $zones += [int] $zoneMatch.Value
        }
        if ($zones.Count -eq 0) {
            continue
        }

        $isCurrent = [regex]::IsMatch($body, "\bcurrent\s*=\s*\{")
        if ($isCurrent -and ($null -eq $currentID -or $expansionID -gt $currentID)) {
            $currentID = $expansionID
        }

        $options += [ordered] @{
            id = $expansionID
            label = $label
            continentMapID = $continentMapID
            zones = $zones
            isCurrent = $isCurrent
        }

        $mapToExpansionID[$continentMapID] = $expansionID
        foreach ($zoneID in $zones) {
            $mapToExpansionID[$zoneID] = $expansionID
        }
    }

    return [ordered] @{
        currentID = $currentID
        options = $options
        mapToExpansionID = $mapToExpansionID
    }
}

if (-not (Test-Path -LiteralPath $RareScannerRoot -PathType Container)) {
    throw "Could not find sibling RareScanner addon at $RareScannerRoot."
}

$version = Get-RareScannerVersion
$rares = Get-LootTable
$infoLocations = Get-InfoLocations
$mapEntityLocations = Get-MapEntityLocations
$expansionFilters = Get-ExpansionFilters
$totalDrops = 0

foreach ($npcID in @($rares.Keys)) {
    if ($infoLocations.ContainsKey($npcID)) {
        $rares[$npcID].locations = $infoLocations[$npcID]
    } elseif ($mapEntityLocations.ContainsKey($npcID)) {
        $rares[$npcID].locations = $mapEntityLocations[$npcID]
    }
    $totalDrops += $rares[$npcID].loot.Count
}

$outputDirectory = Split-Path -Parent $OutputPath
if (-not (Test-Path -LiteralPath $outputDirectory -PathType Container)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$writer = [System.IO.StreamWriter]::new($OutputPath, $false, $utf8NoBom)
try {
    $writer.WriteLine("local _, NS = ...")
    $writer.WriteLine("")
    $writer.WriteLine("-- Generated by tools/generate_rarescanner_snapshot.ps1 from the installed RareScanner addon.")
    $writer.WriteLine("-- Re-run the generator after updating RareScanner to refresh this snapshot.")
    $writer.WriteLine("NS.RareDropsData = {")
    $writer.WriteLine("    source = `"RareScanner`",")
    $writer.WriteLine("    sourceVersion = $(ConvertTo-LuaString $version),")
    $writer.WriteLine("    generatedAt = $(ConvertTo-LuaString ([DateTime]::Today.ToString("yyyy-MM-dd"))),")
    $writer.WriteLine("    rareCount = $($rares.Count),")
    $writer.WriteLine("    itemDropCount = $totalDrops,")
    $writer.WriteLine("    expansions = {")
    if ($null -ne $expansionFilters.currentID) {
        $writer.WriteLine("        currentID = $($expansionFilters.currentID),")
    } else {
        $writer.WriteLine("        currentID = nil,")
    }
    $writer.WriteLine("        options = {")
    foreach ($expansion in ($expansionFilters.options | Sort-Object {[int] $_.id})) {
        $writer.Write("            { id = $($expansion.id), label = $(ConvertTo-LuaString $expansion.label), continentMapID = $($expansion.continentMapID), current = ")
        if ($expansion.isCurrent) {
            $writer.Write("true")
        } else {
            $writer.Write("false")
        }
        $writer.Write(", zones = {")
        foreach ($zoneID in $expansion.zones) {
            $writer.Write(" $zoneID,")
        }
        $writer.WriteLine(" } },")
    }
    $writer.WriteLine("        },")
    $writer.WriteLine("        mapToExpansionID = {")
    foreach ($mapID in ($expansionFilters.mapToExpansionID.Keys | Sort-Object {[int] $_})) {
        $writer.WriteLine("            [$mapID] = $($expansionFilters.mapToExpansionID[$mapID]),")
    }
    $writer.WriteLine("        },")
    $writer.WriteLine("    },")
    $writer.WriteLine("    rares = {")

    foreach ($npcID in ($rares.Keys | Sort-Object {[int] $_})) {
        $rare = $rares[$npcID]
        $writer.Write("        [$npcID] = { name = $(ConvertTo-LuaString $rare.name), locations = {")
        foreach ($location in $rare.locations) {
            if ($null -ne $location.x -and $null -ne $location.y) {
                $writer.Write(" { mapID = $($location.mapID), x = $($location.x), y = $($location.y) },")
            } else {
                $writer.Write(" { mapID = $($location.mapID) },")
            }
        }
        $writer.Write(" }, loot = {")
        foreach ($itemID in $rare.loot) {
            $writer.Write(" $itemID,")
        }
        $writer.WriteLine(" } },")
    }

    $writer.WriteLine("    },")
    $writer.WriteLine("}")
} finally {
    $writer.Dispose()
}

Write-Host "Wrote Data\RareDrops.lua"
Write-Host "RareScanner ${version}: $($rares.Count) rares, $totalDrops item drops"

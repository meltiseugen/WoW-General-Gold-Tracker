$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$AddOnsRoot = Split-Path -Parent $RepoRoot
$OutputPath = Join-Path $RepoRoot "Data\InstanceDrops.lua"

$ModuleLabels = [ordered] @{
    AtlasLoot_Classic = "Classic"
    AtlasLoot_BurningCrusade = "Burning Crusade"
    AtlasLoot_WrathoftheLichKing = "Wrath of the Lich King"
    AtlasLoot_Cataclysm = "Cataclysm"
    AtlasLoot_MistsofPandaria = "Mists of Pandaria"
    AtlasLoot_WarlordsofDraenor = "Warlords of Draenor"
    AtlasLoot_Legion = "Legion"
    AtlasLoot_BattleforAzeroth = "Battle for Azeroth"
    AtlasLoot_Shadowlands = "Shadowlands"
    AtlasLoot_Dragonflight = "Dragonflight"
    AtlasLoot_TheWarWithin = "The War Within"
    AtlasLoot_Midnight = "Midnight"
}

function ConvertTo-LuaString {
    param([string] $Value)

    if ($null -eq $Value) {
        $Value = ""
    }

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

function Get-AddonMetadata {
    param([string] $ModuleName)

    $tocPath = Join-Path $AddOnsRoot "$ModuleName\$ModuleName.toc"
    $metadata = [ordered] @{
        version = "unknown"
        license = "GPL v2"
        website = "https://github.com/nanderson11/AtlasLootEnhanced"
    }
    if (-not (Test-Path -LiteralPath $tocPath -PathType Leaf)) {
        return $metadata
    }

    foreach ($line in [System.IO.File]::ReadLines($tocPath)) {
        $match = [regex]::Match($line, "^##\s*Version:\s*(.+?)\s*$")
        if ($match.Success) {
            $metadata.version = $match.Groups[1].Value.Trim()
            continue
        }
        $match = [regex]::Match($line, "^##\s*X-License:\s*(.+?)\s*$")
        if ($match.Success) {
            $metadata.license = $match.Groups[1].Value.Trim()
            continue
        }
        $match = [regex]::Match($line, "^##\s*X-Website:\s*(.+?)\s*$")
        if ($match.Success) {
            $metadata.website = $match.Groups[1].Value.Trim()
        }
    }
    if ($metadata.license -match "^GPL\s*v?2$") {
        $metadata.license = "GPL-2.0"
    }
    return $metadata
}

function Find-LuaMatchingBrace {
    param(
        [string] $Text,
        [int] $OpenBraceIndex
    )

    $depth = 0
    $inString = $false
    $quote = [char] 0
    $inLineComment = $false
    $inLongComment = $false
    for ($i = $OpenBraceIndex; $i -lt $Text.Length; $i++) {
        $ch = $Text[$i]
        $next = if ($i + 1 -lt $Text.Length) { $Text[$i + 1] } else { [char] 0 }
        $next2 = if ($i + 2 -lt $Text.Length) { $Text[$i + 2] } else { [char] 0 }
        $next3 = if ($i + 3 -lt $Text.Length) { $Text[$i + 3] } else { [char] 0 }

        if ($inLineComment) {
            if ($ch -eq "`n") {
                $inLineComment = $false
            }
            continue
        }
        if ($inLongComment) {
            if ($ch -eq "]" -and $next -eq "]") {
                $inLongComment = $false
                $i++
            }
            continue
        }
        if ($inString) {
            if ($ch -eq "\") {
                $i++
            } elseif ($ch -eq $quote) {
                $inString = $false
            }
            continue
        }

        if ($ch -eq "-" -and $next -eq "-") {
            if ($next2 -eq "[" -and $next3 -eq "[") {
                $inLongComment = $true
                $i += 3
            } else {
                $inLineComment = $true
                $i++
            }
            continue
        }
        if ($ch -eq '"' -or $ch -eq "'") {
            $inString = $true
            $quote = $ch
            continue
        }
        if ($ch -eq "{") {
            $depth++
            continue
        }
        if ($ch -eq "}") {
            $depth--
            if ($depth -eq 0) {
                return $i
            }
        }
    }

    throw "Could not find matching Lua table brace near offset $OpenBraceIndex."
}

function Get-TableChildren {
    param(
        [string] $Text,
        [int] $OpenBraceIndex
    )

    $closeBraceIndex = Find-LuaMatchingBrace -Text $Text -OpenBraceIndex $OpenBraceIndex
    $children = @()
    $i = $OpenBraceIndex + 1
    while ($i -lt $closeBraceIndex) {
        if ($Text[$i] -eq "{") {
            $childClose = Find-LuaMatchingBrace -Text $Text -OpenBraceIndex $i
            $children += $Text.Substring($i, $childClose - $i + 1)
            $i = $childClose + 1
        } else {
            $i++
        }
    }

    return $children
}

function Get-FirstTableValue {
    param(
        [string] $Text,
        [string] $PropertyName
    )

    $match = [regex]::Match($Text, "\b$([regex]::Escape($PropertyName))\s*=\s*(\d+)")
    if ($match.Success) {
        return [int] $match.Groups[1].Value
    }
    return $null
}

function Get-BossName {
    param(
        [string] $BossBlock,
        [int] $BossIndex
    )

    $nameMatch = [regex]::Match($BossBlock, "\bname\s*=\s*`"([^`"]+)`"")
    if ($nameMatch.Success) {
        return $nameMatch.Groups[1].Value.Trim()
    }

    $localeMatch = [regex]::Match($BossBlock, "\bname\s*=\s*AL\[`"([^`"]+)`"\]")
    if ($localeMatch.Success) {
        return $localeMatch.Groups[1].Value.Trim()
    }

    $commentMatch = [regex]::Match($BossBlock, "^\s*\{\s*--\s*(?:\[(.+?)\]|(.+?))\s*(?:\r?\n|$)")
    if ($commentMatch.Success) {
        $commentName = if ($commentMatch.Groups[1].Success) { $commentMatch.Groups[1].Value } else { $commentMatch.Groups[2].Value }
        if ($commentName.Trim().Length -gt 0) {
            return $commentName.Trim()
        }
    }

    return "Boss $BossIndex"
}

function Get-DifficultyVariables {
    param([string] $Text)

    $difficultyVariables = @{}
    foreach ($match in [regex]::Matches($Text, "local\s+(\w+)\s*=\s*data:AddDifficulty\([^,]+,\s*`"([^`"]+)`"[^)]*,\s*(\d+)\s*\)")) {
        $variableName = $match.Groups[1].Value
        $difficultyVariables[$variableName] = [ordered] @{
            id = [int] $match.Groups[3].Value
            key = $match.Groups[2].Value
            label = $variableName -replace "_DIFF$", "" -replace "_", " "
        }
    }
    return $difficultyVariables
}

function Get-ContentTypeVariables {
    param([string] $Text)

    $contentTypes = @{}
    foreach ($match in [regex]::Matches($Text, "local\s+(\w+)\s*=\s*data:AddContentType\((DUNGEONS|RAIDS),")) {
        $contentTypes[$match.Groups[1].Value] = if ($match.Groups[2].Value -eq "RAIDS") { "raid" } else { "dungeon" }
    }
    return $contentTypes
}

function Get-DifficultyLoot {
    param(
        [string] $BossBlock,
        [hashtable] $DifficultyVariables
    )

    $lootByItemID = @{}
    foreach ($match in [regex]::Matches($BossBlock, "\[(\w+)\]\s*=\s*\{")) {
        $difficultyVar = $match.Groups[1].Value
        if (-not $DifficultyVariables.ContainsKey($difficultyVar)) {
            continue
        }

        $openBraceIndex = $match.Index + $match.Value.LastIndexOf("{")
        $difficultyBlock = $BossBlock.Substring($openBraceIndex, (Find-LuaMatchingBrace -Text $BossBlock -OpenBraceIndex $openBraceIndex) - $openBraceIndex + 1)
        foreach ($rowBlock in Get-TableChildren -Text $difficultyBlock -OpenBraceIndex 0) {
            $itemMatch = [regex]::Match($rowBlock, "^\s*\{\s*\d+\s*,\s*(\d+)")
            if (-not $itemMatch.Success) {
                continue
            }

            $itemID = [int] $itemMatch.Groups[1].Value
            if (-not $lootByItemID.ContainsKey($itemID)) {
                $lootByItemID[$itemID] = [ordered] @{
                    itemID = $itemID
                    difficulties = @{}
                }
            }
            $difficultyID = $DifficultyVariables[$difficultyVar].id
            $lootByItemID[$itemID].difficulties[$difficultyID] = $true
        }
    }

    return $lootByItemID
}

function Get-InstanceBlocks {
    param([string] $Text)

    $blocks = @()
    foreach ($match in [regex]::Matches($Text, "data\[`"([^`"]+)`"\]\s*=\s*\{")) {
        $openBraceIndex = $match.Index + $match.Value.LastIndexOf("{")
        $closeBraceIndex = Find-LuaMatchingBrace -Text $Text -OpenBraceIndex $openBraceIndex
        $blocks += [ordered] @{
            key = $match.Groups[1].Value
            block = $Text.Substring($openBraceIndex, $closeBraceIndex - $openBraceIndex + 1)
        }
    }
    return $blocks
}

function Get-InstanceLootFromModule {
    param(
        [string] $ModuleName,
        [int] $ExpansionID,
        [string] $ExpansionLabel
    )

    $dataPath = Join-Path $AddOnsRoot "$ModuleName\data.lua"
    if (-not (Test-Path -LiteralPath $dataPath -PathType Leaf)) {
        return @()
    }

    $text = [System.IO.File]::ReadAllText($dataPath, [System.Text.Encoding]::UTF8)
    $difficultyVariables = Get-DifficultyVariables -Text $text
    $contentTypes = Get-ContentTypeVariables -Text $text
    $instances = @()

    foreach ($instanceInfo in Get-InstanceBlocks -Text $text) {
        $instanceBlock = $instanceInfo.block
        $itemsMatch = [regex]::Match($instanceBlock, "\bitems\s*=\s*\{")
        if (-not $itemsMatch.Success) {
            continue
        }

        $contentType = "unknown"
        $contentMatch = [regex]::Match($instanceBlock, "\bContentType\s*=\s*(\w+)")
        if ($contentMatch.Success -and $contentTypes.ContainsKey($contentMatch.Groups[1].Value)) {
            $contentType = $contentTypes[$contentMatch.Groups[1].Value]
        }
        if ($contentType -ne "dungeon" -and $contentType -ne "raid") {
            continue
        }

        $itemsOpenBraceIndex = $itemsMatch.Index + $itemsMatch.Value.LastIndexOf("{")
        $bosses = @()
        $bossIndex = 0
        foreach ($bossBlock in Get-TableChildren -Text $instanceBlock -OpenBraceIndex $itemsOpenBraceIndex) {
            $bossIndex++
            if ($bossBlock -match "CoinTexture\s*=\s*`"Achievement`"") {
                continue
            }

            $lootByItemID = Get-DifficultyLoot -BossBlock $bossBlock -DifficultyVariables $difficultyVariables
            if ($lootByItemID.Count -eq 0) {
                continue
            }

            $bosses += [ordered] @{
                name = Get-BossName -BossBlock $bossBlock -BossIndex $bossIndex
                encounterJournalID = Get-FirstTableValue -Text $bossBlock -PropertyName "EncounterJournalID"
                loot = @($lootByItemID.Values | Sort-Object { [int] $_.itemID })
            }
        }

        if ($bosses.Count -eq 0) {
            continue
        }

        $instances += [ordered] @{
            name = $instanceInfo.key
            expansionID = $ExpansionID
            expansion = $ExpansionLabel
            module = $ModuleName
            encounterJournalID = Get-FirstTableValue -Text $instanceBlock -PropertyName "EncounterJournalID"
            mapID = Get-FirstTableValue -Text $instanceBlock -PropertyName "MapID"
            contentType = $contentType
            bosses = $bosses
        }
    }

    return $instances
}

$modules = @()
foreach ($moduleName in $ModuleLabels.Keys) {
    $moduleRoot = Join-Path $AddOnsRoot $moduleName
    if (-not (Test-Path -LiteralPath $moduleRoot -PathType Container)) {
        continue
    }

    $dataPath = Join-Path $moduleRoot "data.lua"
    if (-not (Test-Path -LiteralPath $dataPath -PathType Leaf)) {
        continue
    }

    $text = [System.IO.File]::ReadAllText($dataPath, [System.Text.Encoding]::UTF8)
    $tierMatch = [regex]::Match($text, "ItemDB:Add\(addonname,\s*(\d+)\)")
    if (-not $tierMatch.Success) {
        continue
    }

    $metadata = Get-AddonMetadata -ModuleName $moduleName
    $modules += [ordered] @{
        module = $moduleName
        id = [int] $tierMatch.Groups[1].Value
        label = $ModuleLabels[$moduleName]
        version = $metadata.version
        license = $metadata.license
        website = $metadata.website
    }
}

if ($modules.Count -eq 0) {
    throw "Could not find installed AtlasLoot expansion data modules next to $RepoRoot."
}

$instances = @()
$bossCount = 0
$itemSourceCount = 0
$uniqueItems = @{}
foreach ($module in ($modules | Sort-Object { [int] $_.id })) {
    $moduleInstances = Get-InstanceLootFromModule -ModuleName $module.module -ExpansionID $module.id -ExpansionLabel $module.label
    foreach ($instance in $moduleInstances) {
        $instances += $instance
        $bossCount += $instance.bosses.Count
        foreach ($boss in $instance.bosses) {
            $itemSourceCount += $boss.loot.Count
            foreach ($loot in $boss.loot) {
                $uniqueItems[$loot.itemID] = $true
            }
        }
    }
}

$outputDirectory = Split-Path -Parent $OutputPath
if (-not (Test-Path -LiteralPath $outputDirectory -PathType Container)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}

$currentModule = $modules | Sort-Object { [int] $_.id } -Descending | Select-Object -First 1
$currentExpansionID = [int] $currentModule.id
$sourceVersion = $currentModule.version
$sourceWebsite = $currentModule.website
$sourceLicense = $currentModule.license

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$writer = [System.IO.StreamWriter]::new($OutputPath, $false, $utf8NoBom)
try {
    $writer.WriteLine("local _, NS = ...")
    $writer.WriteLine("")
    $writer.WriteLine("-- Generated by tools/generate_atlasloot_snapshot.ps1 from the installed AtlasLoot Enhanced addon modules.")
    $writer.WriteLine("-- AtlasLoot Enhanced source: https://github.com/nanderson11/AtlasLootEnhanced")
    $writer.WriteLine("-- AtlasLoot Enhanced license: GPL-2.0. Re-run this generator after updating AtlasLoot to refresh this bundled source.")
    $writer.WriteLine("NS.InstanceDropsData = {")
    $writer.WriteLine("    source = `"AtlasLoot Enhanced`",")
    $writer.WriteLine("    sourceVersion = $(ConvertTo-LuaString $sourceVersion),")
    $writer.WriteLine("    sourceURL = $(ConvertTo-LuaString $sourceWebsite),")
    $writer.WriteLine("    sourceLicense = $(ConvertTo-LuaString $sourceLicense),")
    $writer.WriteLine("    generatedAt = $(ConvertTo-LuaString ([DateTime]::Today.ToString("yyyy-MM-dd"))),")
    $writer.WriteLine("    expansionCount = $($modules.Count),")
    $writer.WriteLine("    instanceCount = $($instances.Count),")
    $writer.WriteLine("    bossCount = $bossCount,")
    $writer.WriteLine("    itemCount = $($uniqueItems.Count),")
    $writer.WriteLine("    itemSourceCount = $itemSourceCount,")
    $writer.WriteLine("    expansions = {")
    $writer.WriteLine("        currentID = $currentExpansionID,")
    $writer.WriteLine("        options = {")
    foreach ($module in ($modules | Sort-Object { [int] $_.id })) {
        $writer.Write("            { id = $($module.id), label = $(ConvertTo-LuaString $module.label), module = $(ConvertTo-LuaString $module.module), current = ")
        $writer.Write($(if ($module.id -eq $currentExpansionID) { "true" } else { "false" }))
        $writer.WriteLine(" },")
    }
    $writer.WriteLine("        },")
    $writer.WriteLine("    },")
    $writer.WriteLine("    instances = {")

    $instanceID = 0
    foreach ($instance in ($instances | Sort-Object { [int] $_.expansionID }, { $_.name })) {
        $instanceID++
        $writer.Write("        [$instanceID] = { name = $(ConvertTo-LuaString $instance.name), expansionID = $($instance.expansionID), expansion = $(ConvertTo-LuaString $instance.expansion), module = $(ConvertTo-LuaString $instance.module), contentType = $(ConvertTo-LuaString $instance.contentType)")
        if ($null -ne $instance.encounterJournalID) {
            $writer.Write(", encounterJournalID = $($instance.encounterJournalID)")
        }
        if ($null -ne $instance.mapID) {
            $writer.Write(", mapID = $($instance.mapID)")
        }
        $writer.WriteLine(", bosses = {")

        $outputBossID = 0
        foreach ($boss in $instance.bosses) {
            $outputBossID++
            $writer.Write("            [$outputBossID] = { name = $(ConvertTo-LuaString $boss.name)")
            if ($null -ne $boss.encounterJournalID) {
                $writer.Write(", encounterJournalID = $($boss.encounterJournalID)")
            }
            $writer.Write(", loot = {")
            foreach ($loot in $boss.loot) {
                $writer.Write(" { itemID = $($loot.itemID), difficulties = {")
                foreach ($difficultyID in ($loot.difficulties.Keys | Sort-Object {[int] $_})) {
                    $writer.Write(" $difficultyID,")
                }
                $writer.Write(" } },")
            }
            $writer.WriteLine(" } },")
        }

        $writer.WriteLine("        } },")
    }

    $writer.WriteLine("    },")
    $writer.WriteLine("}")
} finally {
    $writer.Dispose()
}

Write-Host "Wrote Data\InstanceDrops.lua"
Write-Host "AtlasLoot Enhanced ${sourceVersion}: $($instances.Count) instances, $bossCount bosses, $($uniqueItems.Count) unique items, $itemSourceCount boss/item sources"

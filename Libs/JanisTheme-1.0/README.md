# JanisTheme-1.0

Reusable flat dark/gold window theme for World of Warcraft addons.

## Embedded Usage

Load the library before your addon UI files:

```toc
Libs/JanisTheme-1.0/JanisTheme-1.0.lua
```

Then create an addon-local theme instance:

```lua
local _, NS = ...
NS.Theme = _G.JanisTheme:New({ addon = NS.MyAddon })
```

Use it from windows:

```lua
local Theme = NS.Theme

local frame = CreateFrame("Frame", "MyAddonWindow", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(700, 480)
frame:SetPoint("CENTER")
frame:SetFrameStrata("DIALOG")
frame:SetToplevel(true)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")

local chrome = Theme:ApplyWindowChrome(frame, "My Window")

local body = Theme:CreatePanel(frame, "panel", "goldBorder")
body:SetPoint("TOPLEFT", chrome, "TOPLEFT", 12, -54)
body:SetPoint("BOTTOMRIGHT", chrome, "BOTTOMRIGHT", -12, 12)

local button = Theme:CreateButton(body, 120, 24, "Run", "primary")
button:SetPoint("TOPLEFT", body, "TOPLEFT", 14, -14)
```

## Assets

JanisTheme has a small named asset registry for shared icons and textures.
When embedded inside an addon, pass the embedded asset folder as `assetRoot`:

```lua
NS.Theme = _G.JanisTheme:New({
    addon = NS.MyAddon,
    assetRoot = "Interface\\AddOns\\MyAddon\\Libs\\JanisTheme-1.0\\Assets\\",
})
```

Put texture files in `Libs/JanisTheme-1.0/Assets/`, then register or read them by name:

```lua
Theme:RegisterAsset("sortDescending", "arrow_down.png")
Theme:RegisterAsset("sortAscending", "arrow_up.png")

local icon = Theme:CreateTexture(button, "ARTWORK", "sortDescending", 12, 12)
Theme:SetTexture(icon, "sortAscending")
```

Default asset keys:

- `sortDescending` -> `arrow_down.png`
- `sortAscending` -> `arrow_up.png`

You can also use full WoW texture paths or file IDs:

```lua
Theme:RegisterAsset("gold", "Interface\\Icons\\INV_Misc_Coin_01")
Theme:RegisterAsset("fileDataIcon", 134400)
```

## Standalone Addon Usage

The folder can also be installed as a top-level addon named `JanisTheme-1.0`.
Other addons can then declare it as an optional dependency and use `_G.JanisTheme`.

```toc
## OptionalDeps: JanisTheme-1.0
```

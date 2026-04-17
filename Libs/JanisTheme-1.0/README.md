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

## Standalone Addon Usage

The folder can also be installed as a top-level addon named `JanisTheme-1.0`.
Other addons can then declare it as an optional dependency and use `_G.JanisTheme`.

```toc
## OptionalDeps: JanisTheme-1.0
```

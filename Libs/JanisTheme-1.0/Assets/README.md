# JanisTheme Assets

Put theme-owned texture files in this folder.

Default names for sort direction icons:

- `arrow_down.png`
- `arrow_up.png`

These are available through the default asset keys:

```lua
Theme:GetAssetPath("sortDescending")
Theme:GetAssetPath("sortAscending")
```

When registering custom assets, use file names relative to this folder:

```lua
Theme:RegisterAsset("myIcon", "MyIcon")
```

Or use a full WoW texture path:

```lua
Theme:RegisterAsset("myIcon", "Interface\\AddOns\\MyAddon\\Media\\MyIcon")
```

# General Gold Tracker theme artwork

Ported from the sibling TODO-Planner addon. These original raster assets were generated for TODO Planner with OpenAI's built-in image generation tool and prepared for use as World of Warcraft UI textures.

- `ParchmentFrame.png`: transparent torn-paper frame, consumed as an eight-slice border.
- `ParchmentSurface.png`: low-contrast parchment window surface.
- `SelectorPlate.png`: dark leather/parchment plate for tabs and dropdown selectors.

The four selectable reference designs each live in their own folder:

- `QuietBotanical/`: restrained paper, foliage, and green accents.
- `QuietArcane/`: subdued blue arcane metal and gold accents.
- `FieldLedger/`: practical leather-and-paper field journal styling.
- `MinimalVoidglass/`: compact dark glass with muted violet accents.

Each design contains three purpose-built assets:

- `Frame.png` is an eight-slice atlas. Corners stay at a fixed size while the four edge rails stretch independently. Its transparent center is never rendered.
- `Surface.png` is a seamless square texture tiled across rectangular panels. It is never stretched to the window aspect ratio.
- `Selector.png` is a horizontal three-slice atlas. Its end caps remain fixed while only the plain center rail stretches.
- `QuietBotanical/PanelFrame.png` is an alternate rounded interior frame retained for future experimentation. The active Botanical design reuses `Frame.png` at a smaller fixed corner size so its pointed leaf corners remain consistent throughout the UI.
- `QuietBotanical/LeafCorner.png` is rendered at a fixed square size as a header decoration; it is never stretched to a window or panel.

This slicing and tiling contract is intentional: generated reference compositions must not be applied as a single full-window texture because TODO Planner windows have several different rectangular aspect ratios.

DialogueUI was used only as a functional reference for layered borders, selectors, and popup-menu behavior. No DialogueUI artwork is included or referenced at runtime.

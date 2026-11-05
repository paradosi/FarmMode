# Changelog

## v1.4.4
- Turning farm mode off now puts the minimap back at its own scale and opacity, not at 100%, so it no longer undoes SexyMap's or ElvUI's minimap size
- "Hide minimap buttons" now works on Retail (zoom, tracking, zone text, the addon compartment and the expansion button) and hides the tracking button and top border on TBC Anniversary, which it was missing
- Turning farm mode off only shows the buttons farm mode hid; a button you or another addon had hidden stays hidden
- Minimap dragging no longer removes another addon's minimap drag handling when farm mode is switched off

## v1.4.3
- Updated for the current clients (Retail 12.1.5, TBC Anniversary 2.5.6 and Classic Era 1.15.9), so the addon no longer shows as out of date
- Release notes on CurseForge and Wago are now this changelog instead of the commit log
- Filled in the missing v1.3.2–v1.4.2 entries below

## v1.4.2
- Fixed a Lua error on Classic Era: `SetObeyStepOnDrag` is only called where the client has it

## v1.4.1
- Multi-client support: Classic Era, TBC Anniversary and Retail TOCs
- `GetAddOnMetadata` falls back to the global where `C_AddOns` is missing (Classic Era)

## v1.4.0
- Saves and restores the original minimap position on toggle (works alongside ElvUI, SexyMap, etc.)
- Farm mode can no longer be toggled in combat (prevents taint)
- Minimap zoom is set safely on clients with a lower maximum zoom
- Settings panel title shows the addon version

## v1.3.2
- Fixed README images on Wago

## v1.3.1
- Organized assets into media/ folder (screenshots, textures, art)
- Added art assets (400px and 64px logos)
- Added CHANGELOG.md

## v1.3
- Redesigned sliders to ElvUI style: thin track, label centered above, min/max values flanking, editable value box below
- Added mouse wheel support with smart step sizes (Scale: 0.1, Opacity: 5, X/Y Offset: 10)
- Replaced WoW's built-in frame mover with cursor-tracked dragging for smooth, snap-free movement
- Organized assets into media/ folder (screenshots, textures, art)

## v1.2
- Added ElvUI-styled settings panel (`/farm config`)
- Added Scale, Zoom Level, Opacity, X/Y Offset sliders
- Added Draggable and Hide Clutter checkboxes
- Added Reset Defaults button
- Added keybinding support (Options > Keybindings > FarmMode)
- Added minimap zoom control (auto zoom out in farm mode)
- Added opacity control
- Added hide minimap clutter option
- Added addon icon and Map category grouping
- Settings persist via SavedVariables

## v1.1
- Added settings panel with Scale and X/Y Offset sliders
- Added `/farm config` slash command
- Added SavedVariables for persistent settings

## v1.0
- Initial release
- `/farm` toggles minimap to center screen, enlarged
- `/farm` again restores default position

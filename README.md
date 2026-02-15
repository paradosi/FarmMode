# FarmMode

<img src="https://raw.githubusercontent.com/paradosi/FarmMode/main/media/art/farm_mode_warcraft_400.png" width="200" alt="FarmMode">

A lightweight WoW addon that centers and enlarges the minimap for easier gathering routes.

Type `/farm` to toggle. Type `/farm` again to restore.

## Screenshots

**Farm Mode Off** — default minimap position
![Farm Mode Off](https://raw.githubusercontent.com/paradosi/FarmMode/main/media/screenshots/farm-off.jpg)

**Farm Mode On** — minimap centered and enlarged
![Farm Mode On](https://raw.githubusercontent.com/paradosi/FarmMode/main/media/screenshots/farm-on.jpg)

## Install

Available on [CurseForge](https://www.curseforge.com/wow/addons/farmmode) and [Wago](https://addons.wago.io/addons/56ndEaG9).

**Manual install:** Download the latest release and extract the `FarmMode` folder into your `Interface\AddOns\` directory.

## Usage

- `/farm` — Toggle farm mode on/off
- `/farm config` — Open settings panel

## Settings

Open with `/farm config` or via Interface > AddOns > FarmMode.

![Settings Panel](https://raw.githubusercontent.com/paradosi/FarmMode/main/media/screenshots/farm-config.jpg)

- **Scale** — Minimap size (1.0x to 3.0x)
- **Zoom Level** — Minimap zoom (0 = zoomed out, 5 = zoomed in)
- **Opacity** — Minimap transparency (30% to 100%)
- **X / Y Offset** — Position on screen
- **Draggable** — Left-click drag the minimap to reposition while in farm mode
- **Hide Clutter** — Hides minimap buttons (zoom, tracking, zone text) for a clean view
- **Reset Defaults** — Restore all settings to defaults

All sliders support mouse wheel input. Settings persist across sessions and apply live.

## Keybinding

Bind a hotkey in **Options > Keybindings > FarmMode** to toggle without typing `/farm`.

![Keybinding](https://raw.githubusercontent.com/paradosi/FarmMode/main/media/screenshots/farm-keybind.jpg)

## Features

- Saves and restores original minimap position (compatible with ElvUI, SexyMap, etc.)
- Combat lockdown protection — cannot toggle during combat
- Safe zoom handling with bounds checking
- Minimal memory footprint — single file, no libraries

## Compatibility

| Client | Interface | Status |
|--------|-----------|--------|
| Classic Era | 11507 | ✅ Supported |
| TBC Classic Anniversary | 20505 | ✅ Supported |
| Retail / Mainline | 110105 | ✅ Supported |

## Changelog

### v1.4.1
- Multi-client support: Classic Era, TBC Anniversary, and Retail
- API compatibility fix for Classic Era

### v1.4.0
- Save/restore original minimap position on toggle
- Combat lockdown guard
- Safe zoom with pcall
- Version display in settings title

### v1.3.2
- Draggable minimap in farm mode
- Hide clutter toggle
- ElvUI-styled settings panel

## License

[MIT](LICENSE)

---

[![Buy Me A Coffee](https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=&slug=paradosi&button_colour=5F7FFF&font_colour=ffffff&font_family=Cookie&outline_colour=000000&coffee_colour=FFDD00)](https://www.buymeacoffee.com/paradosi)

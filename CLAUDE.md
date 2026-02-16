# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ZMK firmware configuration for the Corne Wireless split ergonomic keyboard (42 keys, nice_nano_v2 board, nice_view display). Built for the CorneWireless product.

## Build Commands

All builds run inside a devcontainer with the ZMK toolchain. The sibling `../zmk` directory must exist as the devcontainer workspace.

```bash
./devcontainer.sh build    # Start devcontainer and compile firmware (default)
./devcontainer.sh draw     # Generate keymap SVG via keymap-drawer
./devcontainer.sh connect  # Interactive shell into devcontainer
./devcontainer.sh stop     # Stop the devcontainer
```

Inside the devcontainer, `build.sh` runs three `west build` commands producing UF2 files:
- `build/settings_reset/zephyr/zmk.uf2` - Settings reset
- `build/left/zephyr/zmk.uf2` - Left half (includes ZMK Studio RPC snippet)
- `build/right/zephyr/zmk.uf2` - Right half

CI builds via GitHub Actions use the reusable workflow from `zmkfirmware/zmk` with the matrix in `build.yaml`.

## Keymap Architecture

`config/corne.keymap` uses C preprocessor macros heavily. Key concepts:

**Dual modifier scheme**: Every layer that uses home row mods has two variants:
- `_C` suffix = CAGS order (Ctrl-Alt-Gui-Shift) for macOS
- `_G` suffix = GASC order (Gui-Alt-Shift-Ctrl) for Linux/Windows

**Layer indices** (0-10):
| Layer | Index | Purpose |
|-------|-------|---------|
| BASE_C / BASE_G | 0, 1 | QWERTY base layers |
| CURSOR_C / CURSOR_G | 2, 3 | Navigation + macOS shortcuts (left-hand friendly) |
| NUM_PAD_C / NUM_PAD_G | 4, 5 | Numbers, brackets, symbols |
| SYM_PAD_C / SYM_PAD_G | 6, 7 | Shifted symbols without holding Shift |
| FCN_PAD | 8 | Function keys, Bluetooth profiles, bootloader |
| MOUSE | 9 | Mouse movement, scroll, clicks |
| FUNCTION | 10 | Globe key layer |

FCN_PAD activates as a conditional layer when CURSOR + SYM_PAD are both active.

**Home row mods**: 8 custom hold-tap behaviors (`hml_i/m/r/p`, `hmr_i/m/r/p`) with per-finger timing tuned via SUNAKU's HRM spreadsheet. The `LHRM_*` / `RHRM_*` macros wrap these with the appropriate modifier per OS scheme.

**Thumb keys**: Use `thumb_ht` (balanced hold-tap) for layer access — left thumb has MOUSE/CURSOR/NUM_PAD layers, right thumb has SYM_PAD.

**Key position constants**: `LEFT_KEY_POSITIONS` and `RIGHT_KEY_POSITIONS` define which physical keys belong to each half, used by home row mod `hold-trigger-key-positions` to prevent same-hand misfires.

## Config

`config/corne.conf` sets ZMK options: deep sleep, increased BT TX power, eager debouncing (1ms press/10ms release), ZMK Studio support, and pointing device support.

`config/west.yml` pulls ZMK firmware from `zmkfirmware/zmk@main`.

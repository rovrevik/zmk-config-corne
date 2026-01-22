#!/bin/bash

# Cleaning build directories:** If you get "Build directory targets board X, but board Y was specified":
# - Use `--pristine` flag: `west build --pristine ...`
# - Or clean all builds: `rm -rf build/*`
# https://zmk.dev/docs/development/local-toolchain/build-flash#building-from-zmk-config-folder

# Settings reset
west build -s app -d build/settings_reset -b nice_nano_v2 \
  --pristine \
  -- \
  -DSHIELD="settings_reset" \
  -DZMK_CONFIG=/workspaces/zmk-config/config

# zmk/build/reset/zephyr/zmk.uf2

# Left half
west build -s app -d build/left -b nice_nano_v2 -S studio-rpc-usb-uart \
  --pristine \
  -- \
  -DSHIELD="corne_left nice_view_adapter nice_view" \
  -DZMK_CONFIG=/workspaces/zmk-config/config \
  -DZMK_EXTRA_MODULES=/workspaces/zmk-config

# zmk/build/left/zephyr/zmk.uf2

# Right half
west build -s app -d build/right -b nice_nano_v2 \
  --pristine \
  -- \
  -DSHIELD="corne_right nice_view_adapter nice_view" \
  -DZMK_CONFIG=/workspaces/zmk-config/config \
  -DZMK_EXTRA_MODULES=/workspaces/zmk-config

# zmk/build/right/zephyr/zmk.uf2

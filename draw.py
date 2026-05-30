#!/usr/bin/env python3
import io
import shutil
import subprocess
import sys
from pathlib import Path

import yaml

REPO = Path(__file__).resolve().parent
CONFIG = REPO / "keymap_drawer.config.yaml"
KEYMAP = REPO / "config" / "corne.keymap"
OUT = Path("/workspaces/zmk/build/keymap") if Path("/workspaces/zmk").is_dir() else REPO / "build" / "keymap"

# display-name from config/corne.keymap; order controls SVG layout, omit to hide
LAYERS = [
    "BaseCgs",
    "CrsrCgs",
    "NmPdCgs",
    "SyPdCgs",
    "FnPd",
    "Mouse",
    "BaseGsc",
    "CrsrGsc",
    "NmPdGsc",
    "SyPdGsc",
    # "Function",
]

# parsed display-name -> SVG section header (layer_legend_map sets thumb hold labels)
LAYER_RENAME = {
    "BaseCgs": "macOS Base (BaseCgs CAGS)",
    "CrsrCgs": "macOS Cursor (CrsrCgs CAGS)",
    "NmPdCgs": "macOS Number Pad (NmPdCgs CAGS)",
    "SyPdCgs": "macOS Symbol Pad (SyPdCgs CAGS)",
    "FnPd": "Function Pad",
    "Mouse": "Mouse",
    "Function": "Globe",
    "BaseGsc": "Linux Base (BaseGsc GASC)",
    "CrsrGsc": "Linux Cursor (CrsrGsc GASC)",
    "NmPdGsc": "Linux Number Pad (CrsrGsc GASC)",
    "SyPdGsc": "Linux Symbol Pad (SyPdGsc GASC)",
}

if not shutil.which("keymap"):
    raise SystemExit(f"keymap-drawer required")

parsed = subprocess.check_output(
    ["keymap", "-c", str(CONFIG), "parse", "-z", str(KEYMAP)],
    text=True,
)
data = yaml.safe_load(parsed)
layers = data["layers"]

unknown = [name for name in LAYERS if name not in layers]
if unknown:
    raise SystemExit(f"Unknown layer name(s): {', '.join(unknown)}")

name_map = {parsed: LAYER_RENAME.get(parsed, parsed) for parsed in LAYERS if parsed in layers}
data["layers"] = {name_map[parsed]: layers[parsed] for parsed in LAYERS if parsed in layers}

for combo in data.get("combos", []):
    if layer_list := combo.get("l"):
        combo["l"] = [name_map.get(name, name) for name in layer_list]

buf = io.StringIO()
yaml.safe_dump(
    data,
    buf,
    width=160,
    sort_keys=False,
    default_flow_style=None,
    allow_unicode=True,
)

OUT.mkdir(parents=True, exist_ok=True)
KEYMAP_SVG = OUT / "keymap.svg"

subprocess.run(
    ["keymap", "-c", str(CONFIG), "draw", "-", "-o", str(KEYMAP_SVG)],
    input=buf.getvalue(),
    text=True,
    check=True,
)
print(f"Generated {KEYMAP_SVG}")

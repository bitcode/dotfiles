"""Flattens palette.yml plus the --contrast/--accent knobs into a single
Jinja2 rendering context."""

from pathlib import Path

import yaml

from .colorspace import shift_lightness

PALETTE_PATH = Path(__file__).resolve().parent.parent / "palette.yml"

BG_LAYERS = ("base", "lift", "panel", "popup", "line", "gutter")


def load_palette(path=PALETTE_PATH):
    with open(path) as f:
        return yaml.safe_load(f)


def resolve(contrast="medium", accent="vivid", palette=None):
    if palette is None:
        palette = load_palette()

    tiers = palette["meta"]["contrast_tiers"]
    tracks = palette["meta"]["accent_tracks"]
    if contrast not in tiers:
        raise ValueError(f"unknown contrast tier {contrast!r}, expected one of {tiers}")
    if accent not in tracks:
        raise ValueError(f"unknown accent track {accent!r}, expected one of {tracks}")

    delta = palette["meta"]["contrast_delta_l"]
    if contrast == "soft":
        shift = delta
    elif contrast == "hard":
        shift = -delta
    else:
        shift = 0.0

    bg_medium = palette["background"]
    bg = {layer: shift_lightness(bg_medium[layer], shift) if shift else bg_medium[layer] for layer in BG_LAYERS}

    fg_primary = palette["foreground"][accent]
    neutral = palette["neutral"][accent]

    accents_raw = palette["accents"]
    accents = {role: values[accent] for role, values in accents_raw.items()}
    accents["cyan"] = accents["aqua"]  # aqua doubles as terminal cyan

    special = palette["special"]

    cursor_ref = palette["cursor"]
    cursor = {
        "color": cursor_ref["color"],
        "text": bg["base"],  # text_ref: background.base
    }

    selection_ref = palette["selection"]
    selection = {
        "background": selection_ref["background"],
        "foreground": fg_primary,
    }

    return {
        "meta": {"name": palette["meta"]["name"], "contrast": contrast, "accent": accent},
        "bg": bg,
        "fg": {"primary": fg_primary, "dim": palette["foreground"]["dim"]},
        "neutral": neutral,
        "cursor": cursor,
        "selection": selection,
        "accents": accents,
        "special": special,
    }

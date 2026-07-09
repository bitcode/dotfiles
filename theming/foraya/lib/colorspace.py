"""HSL-lightness-delta helpers used to derive Foraya's soft/hard contrast
tiers from the medium tier without hand-baking three separate palettes."""

import colorsys


def hex_to_rgb(hex_color):
    h = hex_color.lstrip("#")
    return tuple(int(h[i : i + 2], 16) / 255 for i in (0, 2, 4))


def rgb_to_hex(rgb):
    r, g, b = rgb
    return "#{:02X}{:02X}{:02X}".format(
        round(max(0.0, min(1.0, r)) * 255),
        round(max(0.0, min(1.0, g)) * 255),
        round(max(0.0, min(1.0, b)) * 255),
    )


def shift_lightness(hex_color, delta):
    """Shift a hex color's HSL lightness by `delta` (fraction, e.g. 0.02745),
    holding hue and saturation constant."""
    r, g, b = hex_to_rgb(hex_color)
    hue, lightness, sat = colorsys.rgb_to_hls(r, g, b)
    lightness = max(0.0, min(1.0, lightness + delta))
    return rgb_to_hex(colorsys.hls_to_rgb(hue, lightness, sat))

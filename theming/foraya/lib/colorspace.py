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


def hex_to_xterm256(hex_color):
    """Nearest xterm-256 palette index for a truecolor hex value. Used for
    apps/scripts that only accept 256-color escape codes (e.g. the Claude
    Code statusline), not 24-bit truecolor."""
    r, g, b = (round(c * 255) for c in hex_to_rgb(hex_color))

    def to6(v):
        return 0 if v < 48 else 1 if v < 115 else round((v - 35) / 40)

    def cube_level(i):
        return 0 if i == 0 else 55 + i * 40

    ri, gi, bi = to6(r), to6(g), to6(b)
    cube_idx = 16 + 36 * ri + 6 * gi + bi
    cr, cg, cb = cube_level(ri), cube_level(gi), cube_level(bi)
    cube_dist = (cr - r) ** 2 + (cg - g) ** 2 + (cb - b) ** 2

    gray_idx = max(0, min(23, round((r * 0.299 + g * 0.587 + b * 0.114 - 8) / 10)))
    gv = 8 + gray_idx * 10
    gray_dist = (gv - r) ** 2 + (gv - g) ** 2 + (gv - b) ** 2

    return 232 + gray_idx if gray_dist < cube_dist else cube_idx


def xterm256_distinct_ramp(hex_colors):
    """Nearest xterm-256 index per color in `hex_colors`, nudged apart when
    two adjacent inputs would otherwise round to the same index. Dark, close
    background tiers (e.g. Foraya's panel/gutter) can collide at 256-color
    resolution even though they're visually distinct in truecolor; apps that
    rely on the indices being different (e.g. a powerline statusline drawing
    a separator between same-color segments) need them kept apart."""
    indices = [hex_to_xterm256(h) for h in hex_colors]
    for i in range(1, len(indices)):
        if indices[i] <= indices[i - 1]:
            indices[i] = indices[i - 1] + 1
    return indices

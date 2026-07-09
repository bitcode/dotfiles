# Foraya color scheme

Foraya is a custom color scheme blending three themes:

- **Ayu Dark** supplies the base/surface structure. Ayu's own `ui.bg` /
  `surface.base` value is `#0D1017` — this is also the anchor background
  color for the whole scheme.
- **Gruvbox** supplies vivid, warm, saturated accent colors (the "vivid"
  accent track).
- **Everforest** supplies muted, soft, natural-toned accent colors (the
  "muted" accent track).

The philosophy mirrors the repo's existing hand-built `Gruvforest` kitty
theme (`files/dotfiles/kitty/.config/kitty/themes/custom.conf`, a
Gruvbox+Everforest blend) — warm accents on a cool backdrop — just widened
to three source themes.

## Source of truth

Everything lives under `theming/foraya/`:

- `palette.yml` — the single source of truth for every color token.
- `generate.py` — the CLI that renders per-app config files from it.
- `targets.yml` — maps each template to the `files/dotfiles/<app>/...`
  file it writes.
- `templates/*.j2` — one Jinja2 template per app.
- `lib/colorspace.py` — derives the soft/hard contrast tiers from the
  medium tier via an HSL lightness shift, rather than hand-baking three
  full palettes.

**Do not hand-edit the generated output files** (anything under
`files/dotfiles/<app>/.../foraya*` or `themes/foraya*`, plus
`i3blocks/.config/i3blocks/config`, `polybar/.config/polybar/colors-foraya.ini`,
and `starship/.config/starship.toml`, which the generator owns outright).
Edit `palette.yml` and regenerate instead.

## Knobs

```
python3 theming/foraya/generate.py --contrast medium --accent vivid
```

- `--contrast {soft,medium,hard}` (default `medium`) — background
  darkness. `medium` is the anchor (`#0D1017`); `soft`/`hard` are
  computed at render time.
- `--accent {vivid,muted}` (default `vivid`) — `vivid` pulls the 7
  semantic accent colors from Gruvbox, `muted` pulls them from
  Everforest. Ayu's own accent (gold `#E6B450`, used for the cursor and a
  few UI highlights) is fixed regardless of this knob.
- `--apps kitty,nvim,...` — regenerate a subset only (default: all 8).
- `--dry-run` — print what would change, write nothing.
- `--diff` — print a diff before writing.

## Apps covered (first pass)

nvim, kitty, alacritty, tmux, i3 (+ i3blocks), polybar, rofi, starship.

Deferred to a later pass: waybar, wofi, swaync, VS Code, ranger, zsh,
hyprland, weston.

## Per-app activation

Most apps have a "foraya" theme file that coexists with other theme
files until you flip one line:

| App | Activation |
|---|---|
| kitty | `include themes/foraya.conf` in `kitty.conf` |
| alacritty | `import = ["~/.config/alacritty/themes/foraya.toml"]` in `alacritty.toml` |
| tmux | `source-file ~/.tmux-foraya.conf` in `.tmux.conf` |
| i3 | `include themes/foraya` in `config` |
| rofi | `@theme "~/.config/rofi/themes/foraya.rasi"` in `config.rasi` |
| nvim | `colorscheme foraya` in `lua/settings/init.lua` |

`polybar` (`colors-foraya.ini` via `include-file`), `i3blocks`
(`config`), and `starship` (`starship.toml`) have no include mechanism,
so the generator owns those files outright — regenerating them *is*
activating them.

## Known follow-ups

- `files/dotfiles/nvim/.config/nvim/lua/settings/init.lua` (lines ~6-53)
  has pre-existing hardcoded `nvim_set_hl` overrides in a mix of
  Gruvbox/Nord/ad-hoc hex (Noice, Notify, Telescope floats, GitGutter).
  These run after `colorscheme foraya` and will visually clash with it.
  Update them to pull from `require("foraya.palette")` in a follow-up.
- Second pass apps (waybar, wofi, swaync, VS Code, ranger, zsh,
  hyprland, weston) are not yet templated.

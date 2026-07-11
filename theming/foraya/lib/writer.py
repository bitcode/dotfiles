"""Renders Foraya templates per targets.yml and writes them under the repo,
always previewing a unified diff first."""

import difflib
from pathlib import Path

import yaml
from jinja2 import Environment, FileSystemLoader

from .colorspace import hex_to_xterm256, xterm256_distinct_ramp

REPO_ROOT = Path(__file__).resolve().parent.parent.parent.parent
FORAYA_DIR = Path(__file__).resolve().parent.parent
TARGETS_PATH = FORAYA_DIR / "targets.yml"
TEMPLATES_DIR = FORAYA_DIR / "templates"


def load_targets(apps=None):
    with open(TARGETS_PATH) as f:
        targets = yaml.safe_load(f)["targets"]
    if apps:
        targets = [t for t in targets if t["app"] in apps]
    return targets


def hexrgb(hex_color):
    """'#RRGGBB' -> 'R,G,B' decimal, the format KDE .colors files use."""
    h = hex_color.lstrip("#")
    return ",".join(str(int(h[i : i + 2], 16)) for i in (0, 2, 4))


def render(target, context):
    env = Environment(
        loader=FileSystemLoader(str(TEMPLATES_DIR)),
        keep_trailing_newline=True,
        trim_blocks=True,
        lstrip_blocks=True,
    )
    env.filters["hexrgb"] = hexrgb
    env.filters["xterm256"] = hex_to_xterm256
    env.filters["xterm256_distinct_ramp"] = xterm256_distinct_ramp
    template = env.get_template(target["template"])
    return template.render(**context)


def print_diff(path, old_text, new_text):
    diff = list(
        difflib.unified_diff(
            old_text.splitlines(keepends=True),
            new_text.splitlines(keepends=True),
            fromfile=f"a/{path}",
            tofile=f"b/{path}",
        )
    )
    if diff:
        print("".join(diff))
    else:
        print(f"(no change) {path}")


def apply(targets, context, dry_run=False, show_diff=False):
    for target in targets:
        out_path = REPO_ROOT / target["output"]
        rendered = render(target, context)
        old_text = out_path.read_text() if out_path.exists() else ""

        if show_diff or dry_run:
            print_diff(target["output"], old_text, rendered)

        if dry_run:
            continue

        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(rendered)
        print(f"wrote {target['output']}")

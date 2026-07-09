#!/usr/bin/env python3
"""Foraya color scheme generator.

Usage:
    python3 theming/foraya/generate.py --contrast medium --accent vivid
    python3 theming/foraya/generate.py --contrast soft --accent muted --apps kitty,nvim
    python3 theming/foraya/generate.py --dry-run
    python3 theming/foraya/generate.py --diff
"""

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from lib import writer
from lib.resolver import resolve


def main():
    parser = argparse.ArgumentParser(description="Generate Foraya per-app theme files.")
    parser.add_argument("--contrast", choices=["soft", "medium", "hard"], default="medium")
    parser.add_argument("--accent", choices=["vivid", "muted"], default="vivid")
    parser.add_argument("--apps", help="comma-separated subset of apps (default: all)")
    parser.add_argument("--dry-run", action="store_true", help="print rendered diffs, write nothing")
    parser.add_argument("--diff", action="store_true", help="print a diff before writing")
    args = parser.parse_args()

    apps = args.apps.split(",") if args.apps else None
    context = resolve(contrast=args.contrast, accent=args.accent)
    targets = writer.load_targets(apps=apps)

    print(f"# foraya: contrast={args.contrast} accent={args.accent} apps={apps or 'all'}")
    writer.apply(targets, context, dry_run=args.dry_run, show_diff=args.diff)


if __name__ == "__main__":
    main()

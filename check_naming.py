#!/usr/bin/env python3

import re
import sys
from pathlib import Path

VALID = re.compile(
    r"^([a-z0-9]+(_[a-z0-9]+)*(\.[a-z0-9]+)*"  # snake_case
    r"|[A-Z0-9]+(_[A-Z0-9]+)*(\.[a-z0-9]+)*"  # ALL_CAPS
    r"|\.[a-z0-9]+(_[a-z0-9]+)*)$"  # dotfile
)
IGNORE = {
    "godot",
    ".git",
    ".godot",
    "build",
    ".venv",
    "__pycache__",
    ".import",
    ".ruff_cache",
    ".ignore",
}
WHITELIST = {"Makefile"}


def main() -> int:
    root = Path(".").resolve()
    errors = []

    for path in root.rglob("*"):
        if any(p in IGNORE for p in path.parts):
            continue
        if path.name not in WHITELIST and not VALID.match(path.name):
            errors.append(str(path.relative_to(root)))

    if errors:
        print(f"Invalid naming ({len(errors)}):")
        for e in sorted(errors):
            print(f"  {e}")
        return 0

    print("All names valid")
    return 0


if __name__ == "__main__":
    sys.exit(main())

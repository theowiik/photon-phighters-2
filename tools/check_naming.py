#!/usr/bin/env python3

import re
import subprocess
import sys
from pathlib import PurePosixPath

VALID = re.compile(
    r"^([a-z0-9]+(_[a-z0-9]+)*(\.[a-z0-9]+)*"  # snake_case
    r"|[A-Z0-9]+(_[A-Z0-9]+)*(\.[a-z0-9]+)*"  # ALL_CAPS
    r"|\.[a-z0-9]+(_[a-z0-9]+)*)$"  # dotfile
)
SOURCE_ART_DIR = "assets"


def repo_paths() -> set[PurePosixPath]:
    output = subprocess.run(
        ["git", "ls-files", "-z", "--cached", "--others", "--exclude-standard"],
        capture_output=True,
        text=True,
        check=True,
    ).stdout
    paths = set()
    for file in output.split("\0"):
        if file:
            path = PurePosixPath(file)
            paths.add(path)
            paths.update(path.parents)
    paths.discard(PurePosixPath("."))
    return paths


def main() -> int:
    errors = sorted(
        str(path)
        for path in repo_paths()
        if path.parts[0] != SOURCE_ART_DIR and not VALID.match(path.name)
    )
    if errors:
        print(f"Invalid naming ({len(errors)}):")
        for error in errors:
            print(f"  {error}")
        return 1

    print("All names valid")
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3

import hashlib
import os
import subprocess
import sys
import tempfile
import tomllib
import urllib.request
import zipfile
from pathlib import Path

ROOT = Path(__file__).parent.parent
GAME_DIR = ROOT / "game"
RELEASES_URL = "https://github.com/godotengine/godot/releases/download"
TEMPLATES = [
    "version.txt",
    "linux_debug.x86_64",
    "linux_release.x86_64",
    "windows_debug_x86_64.exe",
    "windows_debug_x86_64_console.exe",
    "windows_release_x86_64.exe",
    "windows_release_x86_64_console.exe",
]
EXPORTS = {
    "game-linux": "build/linux/project-epic-footsies-2.x86_64",
    "game-windows": "build/windows/project-epic-footsies-2.exe",
}


def godot_data_dir() -> Path:
    if sys.platform == "win32":
        return Path(os.environ["APPDATA"]) / "Godot"
    if sys.platform == "darwin":
        return Path.home() / "Library" / "Application Support" / "Godot"
    xdg_data_home = os.environ.get("XDG_DATA_HOME") or Path.home() / ".local" / "share"
    return Path(xdg_data_home) / "godot"


def expected_sha512(version: str, archive_name: str) -> str:
    with urllib.request.urlopen(
        f"{RELEASES_URL}/{version}/SHA512-SUMS.txt"
    ) as response:
        for line in response.read().decode().splitlines():
            checksum, name = line.split()
            if name == archive_name:
                return checksum
    sys.exit(f"No checksum published for {archive_name}")


def install_export_templates(version: str) -> None:
    template_dir = godot_data_dir() / "export_templates" / version.replace("-", ".")
    if all((template_dir / name).exists() for name in TEMPLATES):
        return

    archive_name = f"Godot_v{version}_export_templates.tpz"
    checksum = expected_sha512(version, archive_name)
    with tempfile.TemporaryDirectory() as tmp:
        archive = Path(tmp) / archive_name
        print(f"Downloading {archive_name} (about 1.2 GiB)...", flush=True)
        urllib.request.urlretrieve(f"{RELEASES_URL}/{version}/{archive_name}", archive)
        with archive.open("rb") as file:
            if hashlib.file_digest(file, "sha512").hexdigest() != checksum:
                sys.exit(f"Checksum mismatch for {archive_name}")

        template_dir.mkdir(parents=True, exist_ok=True)
        with zipfile.ZipFile(archive) as tpz:
            for name in TEMPLATES:
                (template_dir / name).write_bytes(tpz.read(f"templates/{name}"))


def main() -> None:
    version = tomllib.loads((ROOT / "mise.toml").read_text())["tools"]["godot"]
    install_export_templates(version)

    for preset, output in EXPORTS.items():
        output_path = GAME_DIR / output
        output_path.parent.mkdir(parents=True, exist_ok=True)
        subprocess.run(
            [
                "godot",
                "--headless",
                "--path",
                str(GAME_DIR),
                "--export-release",
                preset,
                str(output_path.resolve()),
            ],
            check=True,
        )


if __name__ == "__main__":
    main()

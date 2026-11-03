# project-epic-footsies-2

- [Getting Godot Engine](#getting-godot-engine)
- [Credits](#credits)
  - [Fonts](#fonts)

## Getting Godot Engine

Download Godot 4.7.2: https://godotengine.org/download/archive/4.7.2-stable/

Util command to download Godot for Windows to `godot/` (using Nix).

```bash
nix-shell -p wget unzip bash --run "bash -c '
  rm -rf godot && \
  mkdir godot && \
  wget https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_win64.exe.zip -O godot/godot.zip && \
  unzip -q godot/godot.zip -d godot && \
  rm godot/godot.zip
'"
```

## Credits

### Fonts

https://fonts.google.com/specimen/Cascadia+Mono?categoryFilters=Appearance:%2FMonospace%2FMonospace

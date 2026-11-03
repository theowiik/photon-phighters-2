# AGENTS.md

Photon Phighters 2 (internal name `project-epic-footsies-2`) is a 2.5D local multiplayer
arena shooter built with Godot 4.7 and GDScript. Players fire light bullets from
flashlights to recolor bulbs to their team color. The team with the most bulbs when the
round timer runs out wins, and the loser picks a crystal (power-up).

## How to work in this repo

### Do only what was asked

- Change only what the task needs. Do not refactor, rename, reformat or "clean up" code
  you were not asked to touch, even if it looks wrong.
- If you spot a bug or an improvement outside the task, mention it in your reply instead
  of fixing it.
- Do not delete or rewrite existing comments, docs or tests unless the task requires it.
- Keep diffs small. A reviewer should see why every changed line changed.
- Do not commit, push or open pull requests unless asked.
- When a request is ambiguous, ask instead of guessing at a bigger change.

### Before you write

Read the task and the code it touches. List every place the change must reach: callers,
scenes, resources, the crystal registry, config. That is the scope. Extra features are
not.

### Take the smallest change that fully works

Stop at the first option that works:

1. Does it need to exist? Skip features, options and flexibility nobody asked for, and
   name what you skipped in one line.
1. Is it already in the codebase? Reuse the existing helper or pattern (decorators,
   interfaces, registries, `Constants`) the way the surrounding code does.
1. Does Godot or GDScript already provide it? Use the built-in node, signal or method.
1. Can it be one line a reader understands at a glance? Write one line.
1. Otherwise, write the minimum code that works.

- Be minimal about the solution, never about finishing it. Update every caller, scene
  and resource the change affects.
- No abstractions, wrappers, options, config, boilerplate or "for later" code. Deletion
  beats addition.
- The shortest working diff wins, but a clever one-liner that needs decoding is not
  short. Code should read clearly without comments: descriptive names, short functions,
  early returns, flat control flow.
- Bug fix: find every caller of the function first, then fix the root cause once.
- Code you move or merge keeps its error handling.
- Between options of equal size, pick the one that handles edge cases correctly.
- Do not add defensive checks for cases that cannot happen.
- Match the surrounding style, including line endings (`.gitignore` and
  `check_naming.py` use CRLF).

Never cut: anything the user asked for, error handling that prevents data loss, or input
validation where data enters the game (files, network, user input).

### Verify and report

- Run the relevant checks before saying you are done, and report failures honestly.
- End your reply with what you skipped or did not verify, and any risk the user should
  know about.

## Layout

```
.
├── mise.toml          # Pinned tools and all tasks (run `mise tasks`)
├── pyproject.toml     # Pinned Python tools, locked in uv.lock
├── export_game.py     # Installs export templates and exports builds
├── check_naming.py    # File/directory naming checker
├── assets/            # Source art (.blend, .psd, .xcf); not loaded by Godot
└── game/              # The Godot project (project.godot lives here)
    ├── assets/        # Imported assets (models, fonts, maps)
    ├── objects/       # Reusable scenes (player, bullet, bulb, lasers)
    ├── scenes/        # Top-level scenes (main, hud, crystal_picker)
    └── scripts/       # All GDScript
```

## Commands

Run from the repository root.

- `mise run run`: start the game.
- `mise run format`: format Markdown, Python and GDScript.
- `mise run check`: run all format checks, `gdlint`, the naming check and the GDScript
  validator.
- `mise run build`: export Linux and Windows builds.

mise is the only requirement. It installs the pinned Godot and uv on Windows, macOS and
Linux, and uv installs the Python tools from `uv.lock`. The first `mise run build`
downloads about 1.2 GiB of export templates into Godot's data directory. CI (GitHub
Actions) runs `mise run check` on all three systems and `mise run build` on Linux for
every pull request.

## Architecture

- `scripts/main.gd` is a small state machine (`PLAYING`, `ROUND_END`, `PICKING`). It
  starts rounds through `RoundManager`, shows the crystal picker to the round loser and
  applies the picked crystal.
- `scripts/round_manager.gd` owns the round timer and scores. Scores are counted per
  team color hex from the bulbs in the `bulbs` group.
- `scripts/player.gd` wires together input, movement, shooting, animation and team
  color.
- Player abilities use the decorator pattern:
  - Movement: `MoverInterface` → `BaseMover`, wrapped by subclasses of `MoverDecorator`
    in `scripts/movement/decorators/`.
  - Shooting: `ShooterInterface` → `BaseShooter`, wrapped by subclasses of
    `ShooterDecorator` in `scripts/shooting/decorators/`. Decorators adjust a
    `ShootingContext` and pass it down the chain.
  - `CrystalRegistry` maps crystal names to decorator classes. `Player` stores the names
    and rebuilds the decorator chain whenever a crystal is added.
- Input is abstracted by `InputInterface`, with keyboard/mouse, gamepad, dev and bot
  implementations in `scripts/input/`.
- Group names and tuning constants live in `scripts/utils/constants.gd`. The `Groups`
  autoload (`scripts/registries/groups.gd`) returns typed group members.

### Adding a crystal

1. Create a decorator in `scripts/movement/decorators/` or
   `scripts/shooting/decorators/` that extends `MoverDecorator` or `ShooterDecorator`
   and declares a `class_name`.
1. Register it in the matching dictionary in `scripts/crystal_registry.gd`.

## Conventions

- No inline comments. Prefer clear names. `##` doc comments on members are fine.
- Use static typing for variables, parameters and return types.
- Every reusable script declares a `class_name`.
- File and directory names are `snake_case` (`ALL_CAPS` for files like `README.md`).
  Scene files match their root node (`player.tscn` → `Player`).
- Code must pass `gdformat` and `gdlint`. Use tabs for indentation in GDScript.
- Commit the `.uid` file next to each script, since scenes reference scripts by UID.
- Do not edit `.godot/` or `build/`. They are generated.
- Prefer editing `.tscn` and `project.godot` through the Godot editor. Hand edits are
  fine when small, but keep UIDs and resource IDs intact.

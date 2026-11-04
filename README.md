# project-epic-footsies-2

- [Getting started](#getting-started)
- [Credits](#credits)
  - [Fonts](#fonts)

## Getting started

Install [mise](https://mise.jdx.dev/getting-started.html), then from the repository
root:

```bash
mise trust
mise run run
```

mise installs the pinned Godot and Python tools on Windows, macOS and Linux. Run
`mise tasks` to list everything you can do (`run`, `check`, `format`, `build`).

## Playing

Paint surfaces with your flashlight and steal the other team's bulbs. Every bulb in your
color is a point. Rounds last 30 seconds; first to three round wins takes the match. The
loser chooses one of three new crystals between rounds. A draw replays the round without
awarding a win. Damage knocks players out briefly, then they respawn with a short
shield.

- P1: A/D to move, W or Space to jump, mouse to aim, left click to shoot.
- P2: connect a gamepad before starting the match; left stick to move, A to jump, right
  stick to aim, RT to shoot. Without a gamepad, P2 is a bot.
- Enter, a click or gamepad A starts a match or plays again. Crystal choices use the
  losing player's controls (mouse/arrow keys and Enter, or gamepad D-pad/left stick and
  A).
- F1 toggles the developer console.

Run `mise run test` for the automated match-loop smoke test.

## Credits

### Fonts

https://fonts.google.com/specimen/Cascadia+Mono?categoryFilters=Appearance:%2FMonospace%2FMonospace

# Lost Memoria

Lost Memoria is a Godot 4 puzzle game prototype.

## Concept

Core loop:

1. Play a simple color-matching puzzle stage.
2. Clear the stage to increase still illustration restoration progress.
3. Fully restored stills are unlocked in the collection gallery.

## Current Scope

This repository starts with a minimal Godot structure for:

- Title screen
- Stage select screen
- Puzzle screen
- Collection screen
- Save data manager
- Still unlock progress data

No character skills, gacha, or growth systems are planned for the first prototype.

## Recommended Godot Version

Godot 4.2 or later.

## Folder Structure

```txt
assets/
  puzzle/
  stills/
  ui/
scenes/
  title/
  stage_select/
  puzzle/
  collection/
scripts/
```

## Puzzle Rules Target

- Board: 6 x 6
- Pieces: 4 colors at first
- Clear condition: fill restoration gauge to 100%
- Still unlock: 1 still = 4 stages, 25% progress per cleared stage

## Notes

Generated/imported Godot cache files are ignored by `.gitignore`.

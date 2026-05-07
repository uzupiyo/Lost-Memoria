# Lost Memoria UI Design Tokens

This document defines the shared visual rules for the Lost Memoria UI. Use this as the baseline before updating individual screens.

## 1. Visual Direction

Lost Memoria UI should feel like a quiet archive, a magical mirror, and restored fragments of memory.

Core mood:

- Deep night blue
- Soft cyan glow
- Gold restoration light
- Gentle pink/purple accents
- Dark locked/unknown states

## 2. Core Palette

| Role | Name | Hex | Usage |
| --- | --- | --- | --- |
| Background Base | Deep Archive Navy | `#070B1F` | Main dark background, overlay base |
| Background Panel | Mirror Panel Navy | `#101936` | Cards, panels, HUD containers |
| Panel Edge | Soft Cyan Edge | `#8FEAFF` | Thin borders, active frames |
| Primary Text | Memory White | `#F4F8FF` | Main readable text |
| Secondary Text | Mist Blue | `#BFD6F2` | Sub labels, progress details |
| Gold Accent | Restoration Gold | `#FFD86A` | Clear, complete, achievement, S rank |
| Cyan Accent | Mirror Cyan | `#83F4FF` | A rank, active hints, selected states |
| Pink Accent | Fragment Pink | `#FF9EDB` | Gentle emphasis, Moka accents |
| Purple Accent | Dream Violet | `#B89CFF` | B rank, magical secondary effects |
| Warning | Warm Amber | `#FFAD5C` | Low moves, caution |
| Locked | Locked Gray | `#5C6477` | Locked state, disabled text |
| Dark Overlay | Memory Shadow | `#000000AA` | Locked overlays, modal dim |

## 3. Rank Colors

| Rank | Color | Hex | Tone |
| --- | --- | --- | --- |
| S | Restoration Gold | `#FFD86A` | Premium, perfect, glowing |
| A | Mirror Cyan | `#83F4FF` | Clean, strong |
| B | Dream Violet | `#B89CFF` | Good, magical |
| C | Locked Gray | `#8C93A6` | Cleared but basic |

Rules:

- S rank should be the most visually rewarding.
- PERFECT MEMORY should use S-rank gold plus a soft glow.
- Locked content should never use gold or cyan as the main color.

## 4. Typography Scale

| Token | Size | Usage |
| --- | --- | --- |
| `TITLE_L` | 42 | Screen titles, Clear Rank main text |
| `TITLE_M` | 34 | Character names, major section headings |
| `HEADING` | 28 | Panel headings, status cards |
| `BODY` | 22 | Main UI text |
| `BODY_S` | 18 | Progress details, helper text |
| `BADGE` | 16 | Rank, Complete, Perfect, Locked tags |

Rules:

- Main screen headings should use `TITLE_M` or higher.
- Dense information such as ranks and progress should use `BODY_S` or `BADGE`.
- Avoid mixing more than 3 sizes in one panel.

## 5. Spacing Scale

| Token | Size | Usage |
| --- | --- | --- |
| `SPACE_XS` | 4 | Tight label spacing |
| `SPACE_S` | 8 | Between small labels |
| `SPACE_M` | 16 | Inside panels |
| `SPACE_L` | 24 | Between UI groups |
| `SPACE_XL` | 40 | Screen-level separation |

Rules:

- Cards should use at least `SPACE_M` internal padding.
- Screen edges should generally use `SPACE_XL`.
- Progress/rank lines should not be packed too tightly.

## 6. Shared Panel Pattern

Default panel:

- Fill: `Mirror Panel Navy` with slight transparency
- Border: `Soft Cyan Edge` at low opacity
- Text: `Memory White`
- Secondary text: `Mist Blue`
- Highlight text: `Restoration Gold`

Use for:

- Restoration Status
- Character progress cards
- Stage Select still cards
- Collection info panels
- Puzzle HUD sections

## 7. Shared Badge Pattern

Badges should be short, readable, and color-coded.

Common badges:

- `S`, `A`, `B`, `C`
- `COMPLETE`
- `PERFECT`
- `LOCKED`
- `NEW`
- `ACHIEVEMENT`

Badge rules:

- Use uppercase English for compact system labels.
- Use gold for `PERFECT`, `S`, `ACHIEVEMENT`.
- Use gray for `LOCKED`.
- Use cyan for selected/active/available states.

## 8. Button Rules

### Large Buttons

Use for:

- Start
- Collection
- Main navigation

Visual:

- Wide, clear, strong hover
- Gold or cyan highlight on hover

### Medium Buttons

Use for:

- Back
- Retry
- Hint
- Fullscreen

Visual:

- Less dominant than large buttons
- Role-based color hints are allowed

### Small Buttons

Use for:

- Stage buttons
- Previous/Next
- Small filters

Visual:

- Compact
- Rank/lock state must remain readable

## 9. Screen-Specific Direction

### Title

- Restoration Status should look like a polished archive card.
- Achievement should read like a badge/title, not plain text.
- Character progress line should remain compact.

### Character Select

- Cards should feel collectible.
- Selected character needs a strong frame/glow.
- Progress should be readable but not overpower the portrait.

### Stage Select

- Each Still should be a card.
- Stage buttons should clearly show: cleared, current, locked.
- Mastery should be easy to scan.

### Collection

- Still image is the hero.
- Rank list should become tags or badges over time.
- PERFECT MEMORY should have a premium frame/glow.

### Puzzle HUD

- Top HUD must be readable during play.
- Burst popups should not cover critical board visibility too long.
- SD character panel should feel friendly and character-specific.

## 10. Character Accent Guidance

| Character | Accent | Tone |
| --- | --- | --- |
| Rin | Gold + cyan | Bright gyaru, confident, energetic |
| Moka | Pink + soft cyan | Soft, fluffy, childlike |
| Kaede | Green/cyan + navy | Calm, intelligent, supportive |

## 11. Implementation Order

1. Title status card polish
2. Character Select card polish
3. Stage Select still card polish
4. Collection rank/badge polish
5. Puzzle HUD polish
6. Options / Help / Reset Save UI

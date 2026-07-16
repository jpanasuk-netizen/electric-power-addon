# Electric Power Combo UI

A World of Warcraft addon (Plater hook script) that renders your Paladin's Holy Power as a row of five animated stars floating above your target's nameplate — built with a sleek electric blue and white Aston Martin-inspired color scheme.

## Features
- Real-time Holy Power visualization with 5 animated stars above target nameplate
- Electric cyan / Aston Martin blue lighting (0.25, 0.85, 1.0)
- Pure white cores with pearl white flash on power gain
- Dark navy inactive stars for strong combat readability
- Audio cue when reaching max Holy Power (once per transition)
- Smooth eased scaling, rotation, and alpha animations
- Four visual modes: Normal, Wake of Ashes, Avenging Wrath, Both
- Event-driven Dawnlight charge tracking (no per-frame aura polling)
- 30 FPS update throttle for performance

## Installation
1. Clone this repository to your WoW Addons folder
2. Reload your UI in-game with `/reload`

## Usage
The combo UI appears above your target's nameplate and hides when no target is selected.

## Requirements
- World of Warcraft (The War Within 11.0 or later)

## Author
jpanasuk-netizen

---

## Release Notes

### v2.0 — Electric Sigil Rewrite
- **Electric cyan / white color scheme** — Aston Martin-inspired lighting replacing all gold
- **Pure white cores** (1, 1, 1) with white flash on power gain
- **Dark navy inactive stars** (0.20, 0.35, 0.45) for strong readability in combat
- **Slower, refined motion** — spin speeds halved for a cleaner look
- **Reduced bloom and opacity** — less visual noise, more focus
- All Holy Power logic from v1 preserved: Wake of Ashes, Avenging Wrath modes, bell chime
- Event-driven Dawnlight tracking, spender whitelist + Holy Power-drop fallback

### v1.0 — Initial Release
- 5 Holy Power stars above target nameplate
- Basic electric blue color scheme
- Bell chime at max Holy Power

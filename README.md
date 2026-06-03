# Fruit Game

**2D arena shooter** built in Godot 4.3 — local multiplayer for 2–4 players (or vs bots).

[![Godot](https://img.shields.io/badge/Godot-4.3-478CBF?logo=godot-engine)](https://godotengine.org/)
[![GDScript](https://img.shields.io/badge/GDScript-4.x-478CBF)](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## EN

### Overview

Fruit-themed FFA arena brawler with 6 playable characters, ~45 modifiers, a rot-timer mechanic, and a full anti-snowball system. Built entirely in Godot 4.3 using GDScript and the autoload architecture pattern.

### Core Systems

| System | Description |
|---|---|
| **ModifierSystem** | Losers draw 3 upgrade cards per round; cards are pooled from ~45 modifiers across 5 categories |
| **Rot mechanic** | Per-player countdown (default 120s); player is eliminated when timer expires — prevents stalling |
| **Anti-snowball** | Only losers receive modifier choices; winner gets no upgrade advantage between rounds |
| **Bot AI** | Fully playable vs bots; any slot can be Player / Bot / Disabled |
| **Set structure** | Rounds aggregate into sets (every 5 rounds); running score display |
| **Autoload managers** | `Global` · `ModifierSystem` · `MultiplayerManager` · `AudioManager` · `SettingsManager` |
| **LAN multiplayer** | Experimental ENet-based network play |

### Characters (6)

| Character | Type |
|---|---|
| Strawberry | Ranged |
| Orange | Ranged |
| Grape | Ranged |
| Lemon | Ranged |
| Watermelon | Ranged |
| Pineapple | Melee |

Each character has unique stats (speed, HP, fire rate) and a distinct projectile type.

### Modifier Categories (~45 total)

`Projectile` · `Defense` · `Bounce` · `Passive/Area` · `Legacy`

### Scoring

| Place | Points |
|---|---|
| 1st | 3 |
| 2nd | 2 |
| 3rd | 1 |
| 4th | 0 |

### How to Run

1. Open the project in **Godot 4.3** (or later compatible version)
2. Press **F5**
3. Configure slots in the main menu (Player / Bot / Disabled)
4. Click **Start** — minimum 2 active slots required

### Project Structure

```
Fruit-Game/
├── scenes/
│   ├── characters/     # 6 character scenes
│   ├── bullets/        # per-character projectiles
│   ├── effects/        # explosions, melee, poison
│   ├── maps/           # 6 arena maps
│   └── ui/             # menus, lobby, HUD, modifier picker
├── scripts/
│   ├── ai/             # bot logic
│   ├── characters/     # character controllers
│   ├── core/           # autoload managers
│   ├── effects/
│   ├── map/
│   ├── multiplayer/    # ENet networking
│   └── ui/
└── assets/
    ├── audio/
    └── sprites/
```

---

## PL

### Przegląd

Arena FFA w klimacie owocowym z 6 postaciami, ~45 modyfikatorami, mechaniką gnicia (rot-timer) i pełnym systemem anti-snowball. Zbudowana w Godot 4.3 z użyciem GDScript i wzorca autoload.

### Kluczowe systemy

| System | Opis |
|---|---|
| **ModifierSystem** | Przegrani losują 3 karty ulepszeń per runda z puli ~45 modyfikatorów w 5 kategoriach |
| **Gnicie (Rot)** | Odliczanie per gracz (domyślnie 120s); eliminacja po upływie czasu — zapobiega pasywnej grze |
| **Anti-snowball** | Tylko przegrani otrzymują modyfikatory; zwycięzca nie dostaje przewagi między rundami |
| **Boty** | Każdy slot można ustawić na Gracz / Bot / Wyłączony |
| **Struktura seta** | Co 5 rund podsumowanie wyników |
| **Autoloady** | `Global` · `ModifierSystem` · `MultiplayerManager` · `AudioManager` · `SettingsManager` |
| **LAN** | Eksperymentalny multiplayer przez sieć (ENet) |

### Uruchomienie

1. Otwórz projekt w **Godot 4.3** (lub nowszym kompatybilnym)
2. Naciśnij **F5**
3. Skonfiguruj sloty w menu (Gracz / Bot / Wyłączony)
4. Kliknij **Start** — wymagane minimum 2 aktywne sloty

---

## License / Licencja

MIT — see [LICENSE](LICENSE)

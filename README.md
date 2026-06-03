# Fruit Game

**2D arena shooter** built in Godot 4.3 — local multiplayer for 2–4 players (or vs bots).

[![Godot](https://img.shields.io/badge/Godot-4.3-478CBF?logo=godot-engine)](https://godotengine.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## EN

### Gameplay

Players fight in a free-for-all arena. The last one standing scores points. Losers choose modifiers between rounds (anti-snowball mechanic). Every 5 rounds a set summary is shown.

- **Round** — fight until one player remains
- **Modifiers** — losers draw 3 upgrade cards and pick 1
- **Set** — summary every 5 rounds

### Scoring

| Place | Points |
|---|---|
| 1st | 3 |
| 2nd | 2 |
| 3rd | 1 |
| 4th | 0 |

### Characters (6)

Strawberry, Orange, Pineapple (melee), Grape, Lemon, Watermelon — each with unique stats and projectiles.

### Modifiers (~45)

Categories: Projectile · Defense · Bounce · Passive/Area · Legacy

### Rot Mechanic

Each player has a limited time (default 120s). When the timer runs out, the fruit rots and is eliminated from the round.

### How to Run

1. Open the project in **Godot 4.3** (or later compatible version)
2. Press **F5**
3. In the main menu configure slots (Player / Bot / Disabled)
4. Click **Start** — minimum 2 active slots required

---

## PL

### Rozgrywka

Gracze walczą na arenie w trybie FFA. Ostatni żywy zdobywa punkty. Przegrani wybierają modyfikatory między rundami (mechanika anti-snowball). Co 5 rund następuje podsumowanie seta.

- **Runda** — walka do ostatniego żywego
- **Modyfikatory** — przegrani losują 3 karty ulepszeń i wybierają 1
- **Set** — podsumowanie co 5 rund

### Punktacja

| Miejsce | Punkty |
|---|---|
| 1. | 3 |
| 2. | 2 |
| 3. | 1 |
| 4. | 0 |

### Postacie (6)

Strawberry, Orange, Pineapple (melee), Grape, Lemon, Watermelon — każda z unikalnymi statystykami i pociskami.

### Modyfikatory (~45)

Kategorie: Projectile · Defense · Bounce · Passive/Area · Legacy

### Gnicie (Rot)

Każdy gracz ma ograniczony czas (domyślnie 120s). Po upływie czasu owoc gnije i odpada z rundy.

### Uruchomienie

1. Otwórz projekt w **Godot 4.3** (lub nowszym kompatybilnym)
2. Naciśnij **F5**
3. W menu głównym ustaw sloty (Gracz / Bot / Wyłączony)
4. Kliknij **Start** — wymagane minimum 2 aktywne sloty

---

## Project Structure / Struktura projektu

```
Fruit-Game/
├── scenes/
│   ├── characters/     # 6 characters / 6 postaci
│   ├── bullets/        # per-character projectiles / pociski
│   ├── effects/        # explosions, melee, poison / efekty
│   ├── maps/           # 6 maps / 6 map
│   └── ui/             # menus, HUD, modifiers / menu, HUD, modyfikatory
├── scripts/
│   ├── ai/
│   ├── characters/
│   ├── core/           # Global, ModifierSystem, Audio, Settings
│   ├── effects/
│   ├── map/
│   ├── multiplayer/
│   └── ui/
└── assets/
    ├── audio/
    └── sprites/
```

---

## License / Licencja

MIT — see [LICENSE](LICENSE)

# Fruit Game

**2D arena shooter** w Godot 4.3 — lokalna gra dla 2–4 graczy (lub vs boty).

> **Wersja:** 1.0.0 &nbsp;&nbsp;|&nbsp;&nbsp; **Silnik:** Godot 4.3 &nbsp;&nbsp;|&nbsp;&nbsp; **Licencja:** MIT

---

## Rozgrywka

Gracze walczą na arenie w trybie FFA. Ostatni żywy zdobywa punkty. Przegrani wybierają modyfikatory między rundami (mechanika anti-snowball). Co 5 rund następuje podsumowanie seta.

- **Runda** — walka do ostatniego żywego
- **Modyfikatory** — przegrani losują 3 karty ulepszeń i wybierają 1
- **Set** — co 5 rund podsumowanie wyników

### Punktacja

| Miejsce | Punkty |
|---------|--------|
| 1.      | 3      |
| 2.      | 2      |
| 3.      | 1      |
| 4.      | 0      |

---

## Postacie (6)

Strawberry, Orange, Pineapple (melee), Grape, Lemon, Watermelon.

Każda postać ma unikalne statystyki i pociski.

---

## Modyfikatory

Pula ~45 modyfikatorów podzielona na kategorie:
- Projectile, Defense, Bounce, Passive/Area, Legacy

---

## Gnicie (Rot)

Każdy gracz ma ograniczony czas (domyślnie 120s). Po upływie czasu owoc gnije i odpada z rundy.

---

## Sterowanie

Wsparcie dla 4 graczy na klawiaturze + boty.

---

## Uruchomienie

1. Otwórz projekt w **Godot 4.3** (lub nowszym kompatybilnym)
2. Naciśnij **F5**
3. W menu głównym ustaw sloty (Gracz / Bot / Wyłączony)
4. Kliknij **Start**

Wymagane minimum 2 aktywne sloty.

---

## Struktura projektu

```
Fruit-Game/
├── scenes/
│   ├── characters/     # 6 postaci
│   ├── bullets/        # Pociski per postać
│   ├── effects/        # Eksplozje, melee, trucizna
│   ├── maps/           # 6 map
│   ├── ui/             # Menu, lobby, HUD, modyfikatory
│   ├── global.tscn
│   └── main_game.tscn
├── scripts/
│   ├── ai/
│   ├── characters/
│   ├── core/           # Global, ModifierSystem, Audio, Settings
│   ├── effects/
│   ├── map/
│   ├── multiplayer/
│   └── ui/
├── assets/
│   ├── audio/
│   └── sprites/
├── fonts/              # Tylko używane czcionki + .tres
├── addons/
├── docs/               # Dokumentacja projektowa (GDD)
├── CHANGELOG.md
├── TASKS.md
└── project.godot
```

---

## Uwagi techniczne

- Gra używa autoloadów: `Global`, `ModifierSystem`, `MultiplayerManager`, `AudioManager`, `SettingsManager`
- Wsparcie dla LAN (ENet) w fazie eksperymentalnej
- System gnicia (rot) jest per-gracz

---

## Licencja

MIT — patrz plik [LICENSE](LICENSE)

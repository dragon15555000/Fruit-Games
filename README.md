# Fruit Game

**2D arena shooter** w Godot 4.3 — do 4 graczy lokalnie lub vs boty.

> Wersja: **1.0** | Silnik: Godot 4.3 | Licencja: MIT

---

## Rozgrywka

Gracze walczą na arenie w systemie FFA. Ostatni żywy zdobywa punkty. Przegrani wybierają modyfikatory między rundami (mechanika anti-snowball). Co 5 rund wyświetlane jest podsumowanie setu.

- **Runda** — walka na arenie, ostatni żywy wygrywa
- **Modyfikatory** — przegrani losują 3 karty ulepszenia, wybierają 1
- **Set** — co 5 rund podsumowanie rankingu

### Punktacja

| Miejsce | Punkty |
|---------|--------|
| 1. | 3 |
| 2. | 2 |
| 3. | 1 |
| 4. | 0 |

---

## Postacie

| Postać | HP | Speed | DMG | Fire Rate | Typ |
|--------|-----|-------|-----|-----------|-----|
| Strawberry | 100 | 80 | 25 | 0.8 s | Ranged |
| Orange | 50 | 90 | 50 | 2.5 s | Ranged — mało HP, duży DMG |
| Pineapple | 200 | 60 | 30 | 0.5 s | **Melee** — cios obszarowy |
| Grape | 80 | 100 | 15 | 0.2 s | Ranged — szybkostrzelny |
| Lemon | 90 | 85 | 20 | 0.6 s | Ranged |
| Watermelon | 150 | 65 | 35 | 1.2 s | Ranged — tank |

Pineapple nie strzela — wykonuje cios obszarowy (promień 40 px) z knockbackiem.

---

## Modyfikatory

Pula 45 modyfikatorów podzielona na kategorie. Przegrani wybierają między rundami, boty wybierają losowo.

### Projectile
Podwójny strzał · Pestka snajpera · Fermentacja · Dojrzały strzał · Shotgun pestek · Radioaktywna pestka · Strzał zgnilizny · Magnetyczna pestka · Kolekcjoner pestek · Owocowa passa

### Defense
Gruba skórka · Soczyste wnętrze · Woskowa powłoka · Kolczasta tarcza · Twardy owoc · Antyzgnilizna · Konserwant · Drugi owoc · Zielony jeszcze · Kamienna pestka · Lustrzana skórka

### Bounce
Dodatkowe odbicie · Przyspieszające odbicie · Niszczące odbicie · Magnetyczne odbicie · Wściekłe odbicie

### Passive / Area
Dojrzały sprint · Przyspieszacz gnicia · Gnilna eksplozja · Duplikator modów

### Legacy
Odbijające pociski · Wirujące pociski · Ślad trucizny · Kradzież HP · Eksplodujące · Lepkie pociski · Pancerz · +20% prędkość

---

## Gnicie (Rot)

Każdy gracz ma **120 sekund** do zgniecia. Pasek nad postacią pokazuje czas. Mody wpływają na tempo gnicia.

---

## Sterowanie

| Gracz | Ruch | Skok | Strzał |
|-------|------|------|--------|
| P1 | A / D | Space | LPM |
| P2 | ← / → | ↑ | PPM |
| P3 | J / L | I | Środkowy myszy |
| P4 | Numpad 4/6 | Numpad 8 | Przycisk myszy 9 |
| Bot | — | — | automatycznie |

---

## Tryby gry

Menu główne oferuje **4 sloty**. Każdy slot to: Gracz → Bot → Wyłączony (kliknij żeby cyklować). Wymagane minimum 2 aktywne sloty.

---

## Mapy

Gra losuje mapę każdą rundę spośród 5 unikalnych aren:

| Mapa | Klimat |
|------|--------|
| Fruit Bowl | Letni ogród, trawa, drzewa owocowe |
| Juice Factory | Ciemna fabryka, rury, industrialne platformy |
| Canopy | Nocny las tropikalny, gałęzie, świetliki |
| Blender | Wnętrze blendera, szklane ściany, ostrza |
| Watermelon Caves | Jaskinia z miąższu arbuza, pestki, stalaktyty |

---

## Uruchomienie

1. Otwórz projekt w **Godot 4.3**
2. Naciśnij **F5**
3. W menu ustaw sloty i kliknij Start

---

## Struktura projektu

```
Fruit-Game/
├── scenes/
│   ├── characters/     # 6 postaci (.tscn)
│   ├── bullets/        # Pociski per postać (.tscn)
│   ├── effects/        # Eksplozje, trucizna, cios melee
│   └── ui/             # Menu, wybór postaci, modyfikatory, wyniki, HUD
├── scripts/
│   ├── ai/             # Bot AI controller
│   ├── characters/     # Logika postaci
│   ├── core/           # Global, MainGame, ModifierSystem
│   ├── effects/        # Eksplozje, trucizna
│   ├── map/            # 5 map + map_base
│   └── ui/             # Cały UI flow
├── assets/
└── fonts/
```

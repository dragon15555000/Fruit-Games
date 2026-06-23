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

| Postać | HP | Speed | DMG | Fire Rate | Styl |
|--------|-----|-------|-----|-----------|------|
| Strawberry | 110 | 92 | 23 | 0.62 s | Mobilny duelist, 2-strzałowy nacisk i łatwe ustawianie pozycji |
| Orange | 70 | 88 | 66 | 2.2 s | Snajper / artyleria z mocnym pojedynczym uderzeniem i wybuchem |
| Pineapple | 240 | 58 | 38 | 0.55 s | Brawler melee, lepkie trafienia i walka w zwarciu |
| Grape | 82 | 118 | 11 | 0.12 s | Szybkostrzelny spammer, najlepszy do ciągłej presji |
| Lemon | 88 | 98 | 16 | 0.72 s | Kontroler przestrzeni, pociski z magnetycznym prowadzeniem |
| Watermelon | 310 | 46 | 72 | 1.35 s | Ciężki tank, wolniejszy ale bardzo karzący za błąd |

Każda postać ma też wbudowany charakter:
- Strawberry: `double_shot`
- Orange: `explosive`
- Pineapple: `sticky`
- Grape: `shotgun`
- Lemon: `magnetic_seed` i `fermentation`
- Watermelon: `stone_seed` i `armor`

Pineapple walczy w zwarciu — jego atak obszarowy działa zamiast zwykłego strzału.

## Checklist playtestu

Po zmianach warto sprawdzić:

- Strawberry:
  - czy podwójny strzał daje wyraźną presję
  - czy mobilność jest odczuwalna
- Orange:
  - czy wysoki DMG i eksplozja dają mocny pojedynczy impact
  - czy wolniejsze tempo ognia nadal jest grywalne
- Pineapple:
  - czy melee faktycznie wymusza walkę blisko
  - czy sticky pomaga, ale nie robi z tej postaci pewnego fraga
- Grape:
  - czy szybki spam strzałów jest czytelny
  - czy niski DMG nie jest zbyt karzący
- Lemon:
  - czy magnetyczne prowadzenie daje kontrolę przestrzeni
  - czy nie robi się z tego auto-win na średnim dystansie
- Watermelon:
  - czy tankowatość jest odczuwalna
  - czy wolny ruch nadal pozwala grać, a nie tylko cierpieć

Ogólnie:

- czy żadna postać nie dominuje na każdej mapie
- czy małe mapy nie wzmacniają za bardzo Orange i Watermelon
- czy otwarte mapy nie faworyzują za mocno Grape i Strawberry
- czy zabójstwa są czytelne dzięki fatality i kill feed
- czy muzyka zmienia klimat między spokojem i walką

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

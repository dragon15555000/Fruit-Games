# Fruit Game

Lokalna gra dla 2–4 graczy (lub vs boty) zrobiona w Godot 4.3. Arena FFA, ostatni żywy zbiera punkty.

*Local multiplayer arena brawler for 2–4 players (or vs bots), built in Godot 4.3. FFA — last one standing scores.*

---

## Rozgrywka / Gameplay

Gracze wybierają jedną z 6 postaci (Strawberry, Orange, Pineapple, Grape, Lemon, Watermelon) i walczą na arenie. Pineapple jest melee, reszta strzelają pociskami. Każda postać ma inne statystyki i inny typ pocisku.

Po każdej rundzie przegrani losują 3 karty modyfikatorów i wybierają jedną — zwycięzca nie dostaje nic. To celowy design żeby nie było snowballa. Modyfikatorów jest ok. 45 w 5 kategoriach: Projectile, Defense, Bounce, Passive/Area, Legacy.

Mechanika gnicia (Rot): każdy gracz ma licznik czasu (domyślnie 120s). Jak skończy mu się czas, odpada z rundy — nie można siedzieć w miejscu i czekać. Co 5 rund podsumowanie seta.

*Players pick one of 6 characters and fight on an arena. After each round, losers draw 3 modifier cards and pick one — winner gets nothing (intentional anti-snowball design). Rot mechanic: each player has a 120s timer; when it runs out they're eliminated. Every 5 rounds a set summary.*

---

## Uruchomienie / Running

Godot 4.3, naciśnij F5. W menu głównym ustaw sloty (Gracz / Bot / Wyłączony), minimum 2 aktywne. Eksperymentalny LAN przez ENet.

*Open in Godot 4.3, press F5. Set slots in the main menu (Player / Bot / Disabled), minimum 2 active. Experimental LAN via ENet.*

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

Szczegółowy balans i checklistę testową przeniosłem do:

- [docs/balance.md](file:///home/marcin/projects/Fruit-Games/docs/balance.md)
- [docs/playtest.md](file:///home/marcin/projects/Fruit-Games/docs/playtest.md)

---

## Struktura / Structure

```
scenes/    characters, bullets, effects, maps (6), ui
scripts/   ai, characters, core (autoloads), effects, map, multiplayer, ui
assets/    audio, sprites
```

Autoloady: `Global`, `ModifierSystem`, `MultiplayerManager`, `AudioManager`, `SettingsManager`.

---

MIT License

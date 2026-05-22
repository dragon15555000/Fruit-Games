# Changelog

Format oparty na [Keep a Changelog](https://keepachangelog.com/pl/1.1.0/).

---

## [1.0.0] — 2026-05-22

### Dodane
- **Lemon i Watermelon** — 2 nowe grywalne postacie z unikalnymi pociskami (ziarnko cytryny, pestka arbuza)
- **Lemon bullet / Watermelon bullet** — draw-based pociski per postać
- **HUD: licznik rund** — wyświetla "Runda X/5" w trakcie gry
- **5 unikalnych map** z bogatą grafiką proceduralną: Fruit Bowl, Juice Factory, Canopy, Blender, Watermelon Caves

### Naprawione
- **Progresja gry** — boty teraz automatycznie wybierają modyfikatory; gra nie zawieszała się na ekranie wyboru
- **Ekran modyfikatorów** — HBoxContainer i karty miały rozmiar 32×8 px, teraz 960×300 px / 280×300 px
- **Ekran round_ended** — WinnerLabel i PointsLabel miały minimalne rozmiary, teraz 600/500 px szerokości
- **Ekran set_over** — przycisk Continue miał 8 px szerokości (offset -4..+4), teraz poprawnie wyśrodkowany

---

## [0.4.0] — 2026-04-07

### Dodane
- Menu główne — wybór trybu: gra lokalna / LAN
- System Gracz/Bot/Off — 4 sloty, klikaj żeby cyklować typ
- Bot AI (`bot_controller.gd`) — szuka wroga, strzela, skacze, unika
- Ananas MELEE — cios obszarowy (r=40px) z knockbackiem
- Per-gracz gnicie — `rot_time_remaining` zamiast globalnego Timera
- 3 nowe mody: `antirot`, `rot_shot`, `rot_accelerator`
- 8 legacy modów dodanych do puli losowania
- MultiplayerManager w autoload

### Naprawione
- thick_skin — HP nie kumuluje się między rundami
- Poison stacks — wygasają po 3 sekundach
- Ścieżki — ujednolicono `res://Scenes/` → `res://scenes/`
- Shotgun — 3 dodatkowe pociski zamiast 4
- Head nudge — hc[1] i hc[3] obsługiwane
- Gnicie Timer — usunięto podwójny autostart

---

## [0.3.0] — 2026-04-05

### Dodane
- Multiplayer LAN (ENet, server-authoritative)
- Lobby z listą graczy i slotami

---

## [0.2.0] — 2026-04-03

### Dodane
- System modyfikatorów (30 modów)
- Wybór modyfikatorów między rundami (anti-snowball)
- System rund z punktacją (3/2/1/0)
- Kill feed, owocowe pociski i sprite'y (draw-based)
- Odbijanie pocisków od terenu

---

## [0.1.0] — 2026-04-01

### Dodane
- 4 postacie: Strawberry, Orange, Pineapple, Grape
- Fizyka platformówki: grawitacja, coyote time, jump buffer, head nudge
- Sterowanie dla 4 graczy na jednym ekranie
- Podstawowa struktura projektu w Godot 4.3

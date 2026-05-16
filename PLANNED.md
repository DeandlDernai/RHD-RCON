# RHD-RCON - Feature Backlog & Roadmap

> Geplante Features + UI-Verbesserungen für zukünftige Versionen.
> Diese Features sind nach aktuellen Fixes + Public-Release v1.0.2 geplant.

## UI-Verbesserungen (High Priority)

### Chat-Funktionalitaeten
- **Chat-Text kopierbar**
  - Aktuell: Chat ist ItemsControl ohne Selektion
  - Gewuenscht: Text pro Zeile markierbar + Strg+C zum Kopieren
  - Idee: SelectableTextBlock oder readonly TextBox mit BorderThickness=0

- **Chat-Filterung**
  - Gewuenscht: Filter-Checkboxes für Chat-Typen
  - Typen: Global / Side / Direct / Vehicle / Group / Command / Admin / Console
  - Optionen: "Nur Console", "Nur Commands" etc.

- **Enter=Send bei Broadcast-Message**
  - Aktuell: Nur Send-Button, Enter macht Zeilenumbruch
  - Gewuenscht: Enter sendet direkt (wie in Spieler-PM)
  - Shift+Enter fuer Zeilenumbruch

### Feedback & Status-Meldungen
- **"Refresh geolocation" Rueckmeldung**
  - Aktuell: Befehl laeuft stillschweigend
  - Gewuenscht: Toast/Info-Dialog wie bei "Refresh Steam profile"

### Scheduler UI-Improvements
- **Kontextmenue für Scheduler-Einträge**
  - Messages: Rechtsklick -> Edit / Delete
  - Shutdown: Rechtsklick -> Edit / Delete / Run now
  - Global Tasks: Rechtsklick -> Edit / Delete / Run now

### UI-Branding & Layout
- **Window-Icon (D-Logo) Optimierung**
  - Aktuell: D-Logo zeigt zu groß in Titelleiste
  - Gewuenscht: Kompaktes Layout - nur Name + Version + Buttons (Support/Mode/Info/Settings)
  - Logo bleibt in Taskleisten-Icon + Fenster-Ecke

## Feature-Ideen (Future Roadmap)

### Server-Management
- **Server-Tabs per Drag-and-Drop umsortieren**
  - Reihenfolge in SQLite persistieren

- **Player-Activity Tracking**
  - Brandneue Spieler in Player-DB markieren (first_seen < X Tage)
  - Automatischer Steam-Profil-Check für neue Spieler

### Netzwerk & Diagnose
- **Connection-Quality-Monitoring**
  - Ping zu Server-IP
  - Ping zu neutralem Ziel (8.8.8.8 default, konfigurierbar)
  - Latenz + Packet-Loss bei RCon-Disconnect diagnostizieren

### UX-Improvements
- **Auto-Scroll bei neuen Einträgen**
  - Chat-View, Console-Log, Player-Log-Dialog
  - Smart: Scrollt nur wenn User nah am Ende war, nicht wenn bewusst hochgescrollt

---

## Status

**Release-Version:** v1.0.2  
**Letztes Update:** 2026-05-16  
**Nächste Phase:** Nach öffentlichem Release + User-Feedback geplant

Feedback & Feature-Requests: [GitHub Issues](https://github.com/DeandlDernai/RHD-RCON)

# Roadmap / Planned Features

> Planned features and UI improvements for future versions.
>
> Items here are not commitments - they are ideas the project owner finds
> useful and intends to work on as time permits. Feedback and feature
> requests are welcome via [GitHub Issues](https://github.com/DeandlDernai/RHD-RCON/issues).

## UI improvements (high priority)

### Chat
- **Copyable chat text** - currently the chat is a non-selectable
  `ItemsControl`. Goal: per-line selection + Ctrl+C.
- **Chat filtering** - filter checkboxes per chat type
  (Global / Side / Direct / Vehicle / Group / Command / Admin / Console).
- **Enter = send** in the broadcast input (Shift+Enter for newline). Matches
  the PM dialog behavior.

### Feedback / status messages
- Toast / info dialog when **Refresh geolocation** finishes (currently runs
  silently).

### Scheduler
- Context menu for scheduler entries (Edit / Delete / Run now for global
  tasks and shutdowns).


## Feature ideas (future roadmap)

### Server management
- Show the current online player count next to the server name (in the
  server tab header). Updates whenever the player list refreshes.

### UX
- Smart auto-scroll for chat view, console log and player log dialog
  (only scroll if the user was near the bottom, not when intentionally
  scrolled up).

### IP ban
- **In place:** in-tool IP-ban table. Players whose IP is in the table get
  kicked on the next player refresh (works only while the tool is connected
  to the server).
- **Planned:** additionally write an entry to a dedicated log file in
  [DigitalRuby IPBan](https://github.com/DigitalRuby/IPBan) format on
  every IP ban. IPBan can then enforce the ban at the OS firewall level,
  so the address is blocked even when RHD-RCON is down. Open questions:
  log file path + rotation, which event types to write, whether the entry
  is written immediately on ban-add or only when the player actually tries
  to connect.

### ISP ban (Internet Service Provider)
- Kick (or optionally ban) players based on their internet service
  provider. Useful for cutting off VPN / hosting / proxy networks that
  are commonly abused by ban evaders. Off by default; configurable
  provider list per server.

### Country block
- Auto-kick or auto-ban by country (optional, off by default). Configurable
  allow- or blocklist of ISO country codes, applied on player connect.

### Whitelist management
- UI for the existing whitelist DB table - add / remove GUIDs, optional
  enforce-mode that kicks non-whitelisted players on connect.

### Other
- Player DB / ban list export beyond the current PlayerDB JSON.

## Multi-game support (long term)

RHD-RCON is currently focused on DayZ Mod (Arma 2 OA) servers. The BattlEye
RCon protocol is the same across multiple Bohemia titles, so support for
related games is on the roadmap once the DayZ Mod feature set has
stabilized:

- **DayZ Standalone** - BattlEye RCon, same protocol. Differences live
  mostly in chat parsing, kick/ban admin labels and the server log format.
- **Arma 3** - BattlEye RCon. Same protocol; player list and admin chat
  formats differ. Mainly a parsing / labels question.
- **Arma Reforger** - BattlEye RCon protocol is supported. Open
  question is how to feed useful per-player data (Steam-ID etc.) into
  the tool without impacting server performance.

These are listed here as direction, not as committed milestones - they
will be tackled after the DayZ Mod (Arma 2 OA) workflow is feature
complete.

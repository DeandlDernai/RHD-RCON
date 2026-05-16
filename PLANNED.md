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
- Drag-and-drop reorder of server tabs, with order persisted in SQLite.
- Mark new players in the Player DB (`first_seen < X days`) and trigger an
  automatic Steam profile check for them.

### Network / diagnostics
- Connection-quality monitoring:
  - Ping to the configured server host
  - Ping to a neutral target (8.8.8.8 default, configurable)
  - Helps diagnose latency vs. packet loss when an RCon disconnect happens.

### UX
- Smart auto-scroll for chat view, console log and player log dialog
  (only scroll if the user was near the bottom, not when intentionally
  scrolled up).

### Geolocation
- Highlight country changes for a player (color indicator).
- Auto-kick / auto-ban by country (optional, off by default).

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

### Database cleanup
- Optional, opt-in cleanup logic: remove entries older than X days when
  more than Y entries exist. Off by default - admin enables per table.

| Table | Date column | Cleanup rule |
|---|---|---|
| `player_change_log` | `changed_at` | older than 1 year AND more than 30 per player |
| `player_server_log` | `last_seen` | not seen in over 1 year |
| `ban_sync` | `created_at` | synced entries older than 90 days |

### Global scheduler
- Optional, opt-in cross-server scheduled tasks (one entry runs on
  multiple servers). Off by default - admin enables when needed.

### Country block
- Auto-kick or auto-ban by country (optional, off by default). Configurable
  allow- or blocklist of ISO country codes, applied on player connect.

### Whitelist management
- UI for the existing whitelist DB table - add / remove GUIDs, optional
  enforce-mode that kicks non-whitelisted players on connect.

### Other
- Player DB / ban list export beyond the current PlayerDB JSON.

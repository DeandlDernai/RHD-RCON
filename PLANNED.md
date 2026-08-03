# Roadmap / Planned Features

> Planned features and UI improvements for future versions.
>
> Items here are not commitments - they are ideas the project owner finds
> useful and intends to work on as time permits. Feedback and feature
> requests are welcome via [GitHub Issues](https://github.com/DeandlDernai/RHD-RCON/issues).

## UI improvements

### Scheduler
- Context menu for scheduler entries (Edit / Delete / Run now for global
  tasks and shutdowns).

### Smart auto-scroll
- Chat auto-scroll is in since 1.0.5. Still planned: the same
  follow-the-tail-but-pause-when-scrolled-up behavior for the player log
  dialog (Actions / Server Log / Ban Status tabs).


## Feature ideas (future roadmap)

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
- **Arma Reforger** - **shipped in 1.0.6**: player list, kick, ban,
  unban, ban list, and player IP + country flag from the BattlEye log.
  Still open: Steam-ID resolution and chat need a companion server mod
  (`RHD_ReforgerRconSupport`) that is in development and not published
  yet. The tool side for both is already in 1.0.6.

These are listed here as direction, not as committed milestones - they
will be tackled after the DayZ Mod (Arma 2 OA) workflow is feature
complete.

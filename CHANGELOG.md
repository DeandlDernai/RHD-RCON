# Changelog

All notable changes to RHD-RCON are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project
uses semantic-ish versioning (`major.minor.patch`).

## 1.0.6 - 2026-08-03

### Added

- **Arma Reforger support.** Every server now has a **game type**
  (`Arma 2` / `Arma Reforger`) in the Add/Edit-Server dialog. With
  Reforger selected, RHD-RCON talks to the server the way Reforger
  expects:
  - **Player list** with in-game player ID, backend UUID and name.
  - **Kick, ban, unban and ban list.** Reforger keeps bans in its backend
    (there is no `bans.txt`), so the ban list is read back from the
    server page by page - 25 entries per page, capped at 100 pages
    (2500 bans). You get a warning in the action log if that cap is hit.
  - **IP address and country flag**, read from the BattlEye `console.log`
    of the server (server mode only - the tool needs access to the BE
    log folder). Reforger itself never exposes a player IP over RCon.
  - **Steam-ID resolution** through the new `reforger_loginlog` provider
    and **chat** (broadcast, warning, info, private message) - both
    require a companion server mod that is not public yet, see below.

> [!NOTE]
> **Two Reforger features are still waiting on a server mod.** Reforger
> has no vanilla RCon chat command at all, and it never hands a player's
> Steam-ID to RCon. Both gaps are closed by a companion server mod
> (`RHD_ReforgerRconSupport`) that is **still in development and not
> published yet**. The tool side is ready and ships in 1.0.6 - the two
> features simply have nothing to talk to until the mod is out.
> Everything else (player list, kick, ban, unban, ban list, IP and
> country flag) works against a plain, unmodded Reforger server today.

- **IP retention (GDPR data minimization).** Stored player IPs are
  automatically cleared after a configurable period of inactivity
  (Settings -> General -> "IP retention (days)", default **90**, `0` =
  keep forever). The retention is measured against a player's last-seen
  time, so regulars who keep playing are not affected. Active IP bans are
  never touched - an IP ban stays as long as the ban does.
- The player IP-change history now records only **that** an IP changed,
  not the actual addresses. Existing raw IPs in the change log are
  anonymized once on first start (schema migration v19 -> v20). The
  "this player keeps changing IPs" signal is preserved.

See the updated **Privacy and data** section in the README for the full
picture of what is stored, what is sent to third parties (ip-api.com /
Steam Web API), and who is responsible for handling player data requests.

### Fixed

> [!WARNING]
> **Temporary bans were removed again seconds after being set (Arma 2).**
> The ban sync read BattlEye's "minutes left" column as if it were a Unix
> timestamp, so *every* temporary ban counted as already expired and was
> purged from `bans.txt` on the next sync - including bans you set by
> hand in-game. Only permanent bans survived. This affects 1.0.5 and
> earlier: until you upgrade, use permanent bans only.

- The action log no longer prints misleading `[removed]` / `[restored]`
  lines right after a ban. A post-ban comparison reported changes that
  had never happened on the server.
- The selected player is no longer lost when the player list
  auto-refreshes.
- The player-count badge in the server tab showed only the first digit
  (60 players -> "6").
- Kicking or banning could crash with a NullReferenceException when the
  selection changed while the command was being sent.

### Changed

- Ban purging and player-list merging moved into separate, testable
  components and are now covered by regression tests (412 tests total).

### Known limitations

- **Reforger, very large player lists.** Reforger sends the player list
  as a server message, which - unlike a normal command response - carries
  no "part 1 of n" header. If a server ever splits that response across
  several UDP packets, only the first packet is read. Not observed on our
  servers so far. The ban list is unaffected because it is paginated.

### Upgrading

Schema migrations v18 -> v20 run automatically on first start. A backup
of the pre-migration database is written to `backups/` next to the EXE.

## 1.0.5 - 2026-06-23

### Added

- **Country auto-kick** with a global whitelist (schema v14). Players
  connecting from a blocked country are kicked automatically; whitelisted
  players are exempt.
- **Whitelist as its own tab**, matching on Steam-ID, plus a per-server
  kick message (schema v15).
- **Name filter** - block player names by Unicode range, symbols or
  pattern, with an audit log of every hit (schema v16).
- Action-log entries for country kicks and whitelist add/remove.
- Online player count as an accent pill in the server tab header.

### Changed

- Per-server filter settings now apply to a running session immediately -
  no reconnect needed.
- The Add/Edit-Server dialog is split into five tabs (Connection /
  Behavior / Filters / Steam-ID / Watchdog).
- Remaining UI strings switched to English; the Debug-Log tab was removed
  (debug output goes to the log file).
- `servers.admin_name` removed (schema v17).

### Fixed

- Chat auto-scrolls to the newest message again.
- The shutdown scheduler's "Last run" column updates live instead of only
  after a restart.
- Hint boxes in the Country/Name filter tabs are readable in both light
  and dark theme.

## 1.0.4 - 2026-05-19

> [!WARNING]
> **This release contains breaking changes.** The RCon password is no
> longer stored in the database - you must set an environment variable
> before connecting, otherwise every login will fail. The global
> `Settings -> MySQL` tab is also gone. See the **Breaking changes**
> section below for the migration steps. Old passwords cannot be
> recovered after the schema migration runs.

### Breaking changes

- :warning: **RCon password is no longer stored in `resthirnrcon.db`.** The
  `servers.password` column was removed by schema migration v11 -> v12.
  Existing passwords cannot be recovered after the migration runs.
  The tool now reads the password from an environment variable on every
  connect: the hardcoded prefix `RH_RCON_PASSWORD` plus a per-server
  **suffix** you set in the Edit-Server dialog (empty suffix =
  `RH_RCON_PASSWORD`, suffix `_S2` = `RH_RCON_PASSWORD_S2`, etc.).

  **Migration steps for existing installs:**
  1. Stop the tool.
  2. Set `RH_RCON_PASSWORD` (and optional per-server `_<suffix>`
     variants) at the OS level. On Windows the easiest way is the
     built-in "Edit environment variables for your account" dialog
     (Start -> type "environment" -> open it -> *User variables*
     -> *New*). Use a user variable if only your account runs the
     tool, or a system variable if it runs as a service / under
     another account. Log out / in so a fresh process sees the new
     value.
  3. Start the tool. The schema migration writes a backup of the
     pre-migration DB to `backups/` next to the EXE.
  4. For each server, open the Edit-Server dialog and fill in the
     **RCon env-var suffix** matching the env-var name you set
     (leave empty for `RH_RCON_PASSWORD`).
  5. Hit **Test connect** to verify, then save.

  **Tip - same password on all servers:** if all your servers share
  the same RCon password, set **one** env-var `RH_RCON_PASSWORD` and
  use the **same suffix** (or leave it empty) on every server. You do
  not need a separate env-var per server.

  Backup of the pre-migration DB lives in `backups/` if you need to
  recover the old config (not the passwords themselves - those are
  gone).

- :warning: **Global `Settings -> MySQL` tab removed.** The MySQL provider is now
  configured **per server** in the Add/Edit-Server dialog under
  Steam-ID provider. The migration (v7 -> v8) auto-copies your old
  global MySQL config into every existing server with the `mysql`
  provider and an **empty password suffix**, so `RH_MYSQL_PASSWORD`
  keeps working out of the box. Set a per-server suffix if you want
  different passwords across servers.

### Fixed (behavior bugs)

- **Server tab status indicator** now reflects the real RCon connection state.
  Previously the status dot turned green ("connected") as soon as the session
  object was attached - even if the login never came back. Now the tab reads
  the actual `RConClient.State` (Disconnected / Connecting / Connected /
  Error) on attach and only shows green when the login has succeeded.
- **Auto-connect reconnect loop only starts on app launch.** Adding or
  editing a server with a connection that fails no longer kicks off a silent
  background reconnect loop. The startup auto-connect path still does -
  that is the only place it makes sense (server happens to be down at
  launch). For Add/Edit a failed test connect is now reported to the user
  via the existing error dialog.
- **First-run wizard no longer asks for a Server-mode password.** A leftover
  text box was still asking for one even though the password mechanism was
  removed earlier. Confirmation now goes through the same warning dialog as
  the Settings -> Server-mode switch.

### Added

- **Per-server Steam-ID provider** - each server picks its own
  Steam-ID source. Two providers ship in 1.0.4:
  - **`none`** - no Steam-ID lookup. Pick this for any server without
    an Epoch-style MySQL Hive (Reforger, DayZ Standalone, fresh setups).
  - **`mysql` (Arma 2 Epoch)** - reads `player_login_log` from your
    Epoch DB. Currently the only DB-backed provider.

  The plugin layer is prepared for more providers (Arma 3 Hive, DayZ
  Standalone, Arma Reforger, BattlEye-RCon Steam-ID parser, FileWatcher,
  HTTP bridge), but the concrete implementation for those games is not
  finalised yet - they will drop in without a DB migration when the
  approach per game is settled.
- **Reorder server tabs** - small `<` / `>` buttons in each tab
  header move the tab left or right. Order persists across restarts.
- **Updated IP2Location LITE geolocation data** (dated 2026-05-15). The
  bundled IP-to-country dataset is refreshed on every app update, so
  countries on the player list stay accurate without manual import.

### Documentation

- README + SETUP rewritten for the per-server provider model and the
  new RCon env-var password flow.

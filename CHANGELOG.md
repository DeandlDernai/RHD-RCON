# Changelog

All notable changes to RHD-RCON are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the project
uses semantic-ish versioning (`major.minor.patch`).

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

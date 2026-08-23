# Setup Guide

Admin documentation for installing and configuring RHD-RCON on a DayZ Epoch
server.

This guide assumes you already run a DayZ Epoch server with BattlEye, know
where `BEServer.cfg` lives, and have edited `dayz_server.pbo` before. It
focuses on what RHD-RCON specifically needs.

## Prerequisites

RHD-RCON is a **Windows desktop application**. Specifically:

- **Windows 10 / 11** or **Windows Server with Desktop Experience**
  (Windows Server 2016, 2019, 2022 - the default installation option).
- **Windows Server Core is not supported.** The tool is a GUI application
  (Avalonia / Direct2D) and needs the desktop graphics stack that Server
  Core does not ship. Microsoft no longer supports converting Server Core
  to / from Desktop Experience after install, so if you ended up on Server
  Core you will need a fresh OS install - or run the **Client EXE** instead
  from a normal Windows PC against your game server's RCon port.
- No additional .NET runtime is required - the EXE is self-contained.

## Choosing your download

RHD-RCON ships as **two separate EXEs**. There is no in-app switch - the
role follows from which EXE you download and run. Pick the one that
matches your role:

| EXE | Who is this for | What you get |
|---|---|---|
| **Client** (`RHD-RCON-Client_v1.0.x`) | You manage someone else's server. You have RCon password but no shell access to the server PC. | Live player list, kick/ban via RCon, ban list view, chat, theme. Multi-server ban sync and offline bans work. No scheduler, no process watchdog, no IP-ban enforcement, no player DB writes from live data. |
| **Server** (`RHD-RCON-Server_v1.0.x`) | You **are** the operator of the server PC: you can install/configure things there (restart scripts, scheduled tasks) and reach its own data (MySQL Hive DB and/or BattlEye logs, if you use those features). | Everything the Client EXE has, plus scheduler, server-process watchdog, IP-ban enforcement, persistent player DB writes from live data, MySQL Steam-ID lookups, PlayerDB export for client admins. |

> **Server EXE requirement, spelled out:** it is built to run *on the
> server machine itself* (or at least somewhere with admin rights on it
> and network access to its RCon/MySQL/log files) - it is not a
> general-purpose "more powerful client". If you only have an RCon
> password and no way to touch the server PC's filesystem, scheduled
> tasks or database, the Client EXE is the one you want; the Server EXE's
> extra features simply will not work for you without that access.

The Server EXE unlocks every feature but requires a few one-time setup
steps (env vars, optional MySQL table, optional SQF hook in
`dayz_server.pbo`).

## Quick start (Client EXE)

1. Download `RHD-RCON-Client_v1.0.x.zip` from the
   [Releases page](https://github.com/DeandlDernai/RHD-RCON/releases) -
   contains the EXE plus all docs (README, SETUP, TESTPLAN_CLIENT,
   PLANNED). The bare EXE is also published separately if you only want
   to update.
2. Extract into a folder of your choice. A SQLite database file
   (`resthirnrcon.db`) and a `logs/` folder will be created next to the
   EXE on first run.
3. Run the EXE. On first start a wizard asks for admin name and theme.
4. **Set the RCon password as an environment variable** (since 1.0.4 the
   tool reads it from the OS, never from the DB). Admin PowerShell:
   ```powershell
   [Environment]::SetEnvironmentVariable("RH_RCON_PASSWORD", "your-rcon-password", "Machine")
   ```
   Log out / in (or reboot) so a fresh process sees the variable.
   For multiple servers with different passwords, append a suffix per
   server (e.g. `RH_RCON_PASSWORD_S2` -> in the dialog set suffix `_S2`).
5. Click **+ Add server** in the top-right, enter Name / Host / Port and
   the **env-var suffix** (leave empty if you used the default
   `RH_RCON_PASSWORD`). Hit **Test connect**. Save.
6. Done. Click the new server tab on the left to connect and start managing.

## Quick start (Server EXE)

Download `RHD-RCON-Server_v1.0.x.zip` instead of the Client one - same
steps 2-6 above, plus:

1. Run the EXE **as Administrator** (needed for the restart scripts).
2. Configure the **Steam-ID provider per server** (optional, only if
   you want Steam-ID resolution) in the Add/Edit-Server dialog. Three
   providers ship in 1.0.6:
   - **`none`** (default) - no Steam-ID lookup. Pick this for DayZ
     Standalone or any server that has no Steam-ID source.
   - **`reforger_loginlog`** - for Arma Reforger. Enter the full path to
     the `logins.jsonl` written by the `RHD_ReforgerRconSupport` mod,
     normally
     `<instance>\Profile\profile\RHD_Logins\logins.jsonl`. The tool reads
     the newest line per backend UUID and stores UUID / Steam-ID / name.
     That mod is not published yet, so for now pick `none` on Reforger
     unless you already run it.
   - **`mysql`** - enter Host / Port / Database / User of your Epoch
     (or Arma 3 Hive) DB. The password is read from an environment
     variable: the tool combines the hardcoded prefix
     `RH_MYSQL_PASSWORD` with a per-server **suffix** you set in the
     dialog (empty suffix = `RH_MYSQL_PASSWORD`, suffix `_DE` =
     `RH_MYSQL_PASSWORD_DE`, etc.). No password is ever stored in
     `resthirnrcon.db`.
3. To make the `mysql` provider actually return Steam-IDs: install the
   optional MySQL table + SQF hook on your DayZ server (see
   [Server-side prerequisites](#server-side-prerequisites) below).

**Upgrading from 1.0.3 or earlier:** the global `Settings -> MySQL` tab is
gone. The 1.0.4 schema migration automatically copies your old global
MySQL config (Host/Port/User/Database) into every existing server with
provider `mysql` and an **empty password suffix**, so the tool keeps
reading the same `RH_MYSQL_PASSWORD` env-var you already had set. No
manual changes needed. If you want to give a specific server its own
password, open the server-edit dialog and fill in a suffix (e.g. `_DE`
-> set `RH_MYSQL_PASSWORD_DE` in your OS).

## Server-side prerequisites

For most features RHD-RCON only needs the BattlEye RCon password. A few
optional capabilities need server-side preparation:

### A) Steam-ID resolution (Server EXE, `mysql` provider)

RHD-RCON resolves BattlEye GUIDs to Steam-IDs through a per-server
**Steam-ID provider**. In 1.0.4 the only provider that hits a database
is `mysql`: it reads a `player_login_log` table that your DayZ server
writes on every player login. Without this table the `mysql` provider
returns nothing and the VAC/Game-Ban check via Steam Web API has nothing
to query. Servers configured with provider `none` skip this entirely.

**Required pieces** (on your DayZ server DB, not the RHD-RCON PC):

| Component | What | Where |
|---|---|---|
| MySQL table | `player_login_log` schema | run once on your Epoch database |
| [extDB3](https://github.com/DeandlDernai/extDB) protocol | `[playerLoginLog]` block | `@extDB/sql_custom/shared-conf.ini` |
| SQF hook | `rh_logPlayerLogin.sqf` | `dayz_server/compile/custom/` |
| Compile registration | One line | `dayz_server/init/server_functions.sqf` |
| Login hook call | One line | `dayz_server/compile/server_playerLogin.sqf` |

All integration files (SQL schema, INI block, SQF file, snippets with
exact insertion points + step-by-step README) ship in the
[server-integration/](server-integration/) folder of this repo and are
also packed into the release ZIP.

Verify on the server side after deployment:

```sql
SELECT * FROM player_login_log ORDER BY LoginTime DESC LIMIT 10;
```

Rows should appear on every player login. Once that works, set the
server's Steam-ID provider to `mysql` in the Add/Edit-Server dialog and
RHD-RCON's Steam-ID lookups start populating automatically.

**Multi-server with separate databases:** every server has its own
provider config blob, so you can point server A at DB `epoch_eu` and
server B at DB `epoch_us` from the same RHD-RCON instance. No global
config to clash on.

### B) Scheduled server restarts (Server EXE)

A scheduled restart in RHD-RCON is actually a **scheduled shutdown plus
a separate restart trigger**. The two halves:

**1. Shutdown side (handled by RHD-RCON):**

1. Send warn broadcasts at the configured minutes (e.g. `30,15,5,1`)
2. Send `#lock` + a "server restarting" broadcast 3 minutes before shutdown
3. `Process.Kill` on the configured `ServerProcessName` at shutdown time

**2. Restart side (your script, triggered by RHD-RCON):**

RHD-RCON does not know how to start your specific server (mod params,
Steam ports, config files, mission name etc. are all your setup). You
provide a `.ps1` or `.bat` script that contains the exact start command,
and configure it per-server in the tool:

- **Server-Edit dialog -> Watchdog tab** -> set `ServerProcessName` (e.g.
  `arma2oaserver.exe`), `RestartScriptPath` (full path to your script)
  and enable **Process monitor active**.

With both set, the built-in **server-process watchdog** polls every 20s.
If the process is gone (because the scheduler just killed it, or because
it crashed), it runs your script. A 120s cooldown prevents restart loops.

So you don't need a separate Windows Scheduled Task - the tool itself is
the watchdog, you only supply the start script.

### C) Connect filters (Server EXE)

Two independent connect-time filters were added in 1.0.5. Both are
**off-server-by-default-on** (the global filter is enabled, and every
server has its individual on/off toggle on by default). The kick happens
on the next refresh tick after the player passed BattlEye verification,
so the player briefly shows up in the live list before being kicked.

**Country filter:**

- Global config: Settings -> **Country Filter** -> Mode (`off` /
  `allow` / `block`) + CSV list of ISO country codes (e.g. `DE,FR,GB`).
- Per-server override: Server-Edit dialog -> **Filters** tab -> the
  "Country filter active for this server" checkbox + the per-server
  "Country kick message" (max 120 chars, blank = fall back to the
  global message; if the global is also blank, the filter only logs
  and does not kick).
- **Whitelist bypass:** whitelisted GUIDs / SteamIDs are skipped by
  the country filter. See [Whitelist](#whitelist-server-exe).
- Audit: every kick lands in `player_change_log` as `Country-Kick`
  with detail `Country: XX | Mode: yy | Liste: ...`. Visible in the
  Player Log -> Actions tab.
- **Live reload:** changes in Settings apply to running sessions
  without reconnect.

**Name filter:**

- Global config: Settings -> **Name Filter** -> Allowed character set
  (`Ascii` / `Latin` / `LatinCyrillic` / `Any`), max special-char
  ratio in % (100 = off), forbidden patterns (CSV of case-insensitive
  substrings).
- Per-server override: Server-Edit dialog -> **Filters** tab -> the
  "Name filter active for this server" checkbox + per-server kick
  message (same rules as the country message).
- Three match strategies evaluated in order with early exit:
  **Pattern** -> **Unicode block** -> **Symbol ratio**.
- **Whitelist does NOT bypass the name filter.** Even whitelisted
  admins must have readable names. Deliberate decision.
- Audit: `Name-Kick` with `Reason: cyrillic` / `asian` / `arabic` /
  `hebrew` / `non-latin` / `too-many-symbols` / `pattern '...'`.

### Whitelist (Server EXE)

The whitelist protects individual players from the **country filter**
(not from the name filter). Match is by GUID **OR** SteamID, so an
entry with only one of the two is enough.

Lives in its own left-side tab next to **Player DB**. Each entry has:
GUID (nullable) / SteamID (nullable) / Note / AddedAt.

Four ways to add an entry, all open the same dialog:

| Where | Pre-filled with |
|---|---|
| Whitelist tab -> **Add** | empty |
| Settings -> Country Filter -> **Add whitelist entry...** | empty |
| Players view -> right-click -> **Add to whitelist...** | that player's GUID / SteamID / name |
| Player DB -> right-click -> **Add to whitelist...** | that player's GUID / SteamID / name |

Players view and Player DB both show a **star** column for at-a-glance
identification. Add / remove is audit-logged as `Whitelist-Add` /
`Whitelist-Remove` (only when a GUID is present on the entry, since
the audit log is GUID-keyed).


### D) Arma Reforger (optional)

- **Steam-ID + chat:** these need the `RHD_ReforgerRconSupport` server
  mod, which is **still in development and not published yet**. Once it
  is out, you add its mod ID to `game.mods` in `config.json`, restart,
  and check for `[RHD_Rcon] Login-Logger` in the server log. Until then,
  Reforger servers run without Steam-ID resolution and without chat.
- **Player IP + country flag:** no mod needed, but this needs the Server
  EXE (running with read access to the BattlEye log folder of the server
  instance). The tool picks the newest `logs_*` folder and only tails the
  last 256 KB of `console.log`, so big logs stay cheap.

## Configuration reference

### General tab

Self-explanatory: admin names, debug log toggle, theme.

**Admin names (since 1.0.5)** are global - the per-server `admin_name`
column was removed by schema migration v16 -> v17. Two names live here:

| Setting | Used by |
|---|---|
| **Client admin name** | Manual actions you trigger from the UI: chat broadcasts, PMs, kicks, bans. |
| **Server admin name** (default `RESTHIRN`) | Automated actions: scheduler, daily ban sync, country / name connect-kicks. |

Both names are injected into the active RCon session on connect, so a
change here takes effect after **disconnect + reconnect** of the
affected server.

The **Debug log** checkbox toggles writes to
`logs/debug/RHD-RCON_Debug_YYYY-MM-DD.log`. The standalone "Debug log"
tab from earlier versions has been removed - the file is still written
when the checkbox is on.

The **Ban sync time** *(Server EXE)* sets when the daily background
ban-status sync between RHD-RCON DB and BattlEye `bans.txt` runs.
Default 04:00. If your tool is offline at that time, the sync is missed
for that day - this only matters for the Server EXE, which is typically
running 24/7 on the server PC.

### Server tab (per-server)

Since 1.0.5 the Add/Edit-Server dialog is split into tabs to keep
related settings together:

| Dialog tab | Available in | Contains |
|---|---|---|
| **Connection** | both EXEs | Name, Host, Port, RCon env-var suffix, Tab color |
| **Behavior** | both EXEs | Auto refresh, Chat log path, Auto-connect at startup |
| **Filters** | Server EXE only | Country filter on/off + kick message, Name filter on/off + kick message |
| **Steam-ID** | Server EXE only | Provider (`none` / `mysql`), MySQL Host / Port / Database / User, MySQL password env-var suffix, **Copy provider config from another server** |
| **Watchdog** | Server EXE only | ServerProcessName, RestartScriptPath, Process monitor active toggle |

Fields are self-explanatory. A few things worth knowing:

- **RCon password (since 1.0.4)** is read from an environment variable
  on every connect, never stored in `resthirnrcon.db`. You enter only
  the **env-var suffix** in the dialog: empty -> reads
  `RH_RCON_PASSWORD`, suffix `_S2` -> reads `RH_RCON_PASSWORD_S2`, etc.
  The dialog shows the full computed name live (`Full env-var name:
  RH_RCON_PASSWORD_S2`).
- **Auto-connect** makes 3 attempts with 2s delay on tool start.
- **Tab order** (since 1.0.4) - small `<` / `>` buttons in each tab
  header move the tab left/right. The order is persisted across restarts.
- **Steam-ID provider** (since 1.0.4) - per-server plugin:
  - **`none`** - no lookup. Pick this for DayZ Standalone or any server
    without an Epoch-style MySQL Hive.
  - **`reforger_loginlog`** (since 1.0.6) - for Arma Reforger. Path to
    the `logins.jsonl` written by the `RHD_ReforgerRconSupport` mod. See
    [D) Arma Reforger](#d-arma-reforger-optional).
  - **`mysql`** - reads `player_login_log` from your DB. You enter
    Host/Port/Database/User and a **password env-var suffix**:
    - The tool combines the hardcoded prefix `RH_MYSQL_PASSWORD` with
      your suffix to build the env-var name it reads on each connect.
      Empty suffix -> reads `RH_MYSQL_PASSWORD` (the 1.0.3 default).
      Suffix `_DE` -> reads `RH_MYSQL_PASSWORD_DE`. Set the env-var
      yourself at OS level (Windows: `setx`; Linux/macOS: shell rc /
      systemd EnvironmentFile).
    - The dialog shows the full computed name live (`Voller
      Env-Var-Name: RH_MYSQL_PASSWORD_DE`) so you know exactly which
      variable to set.
    - **No password ever lands in `resthirnrcon.db`** - back up the DB
      file freely.
  - **Copy provider config from another server** - convenience button
    in the dialog. Pick another server from the dropdown and its
    provider + config (Host/Port/User/Database + the password suffix)
    is copied over. Handy when you run several servers against the
    same DB.

### Country Filter tab *(Server EXE)*

| Setting | What it does |
|---|---|
| **Mode** | `off` (filter disabled globally) / `allow` (only listed countries can connect) / `block` (listed countries are kicked). |
| **Country list** | CSV of ISO-3166 alpha-2 country codes (e.g. `DE,FR,GB`). |
| **Global kick message** | Default kick message (max 120 chars). Each server can override it on the **Filters** tab of its Edit dialog. |
| **Add whitelist entry...** | Shortcut to the whitelist-entry dialog (empty). Whitelisted players bypass this filter (match by GUID or SteamID). |

See [C) Connect filters](#c-connect-filters-server-exe) above for the
per-server toggle, audit-log behavior and live-reload semantics.

### Name Filter tab *(Server EXE)*

| Setting | What it does |
|---|---|
| **Allowed character set** | `Ascii` (strict, no umlauts), `Latin` (Latin-1 + Latin-Extended; recommended default), `LatinCyrillic` (also allow Cyrillic), `Any` (off). |
| **Max special chars %** | Maximum allowed ratio of symbol characters in the name. 100 = off. Default 60. |
| **Forbidden patterns** | CSV of case-insensitive substrings. Useful against impersonation (e.g. `admin,moderator,discord.gg`). |
| **Global kick message** | Default message; per-server override on the Filters tab of the Edit dialog. |

> Whitelisted players **still get kicked** by the name filter. The name
> filter is absolute - even admins must have readable names.

### IP Ban tab *(Server EXE)*

| Setting | What it does |
|---|---|
| **Kick message** | What players see when they get hit by an IP ban (max 120 chars). |

**Tip:** do not say "you are IP-banned" - the player will just route through
a VPN. Use something generic like "rule violation".

ArmA 2 + BattlEye has no IP-ban mechanism over RCon (`bans.txt` is
GUID-only), so RHD-RCON enforces the ban itself: an in-tool IP-ban table
is checked on every player refresh, and matching players get kicked with
the configured message. This works only while RHD-RCON is running and
connected to the server - banned players who connect during a tool
downtime stay until the tool re-connects and the next refresh runs.

A planned future extension is an additional log-file export in
[DigitalRuby IPBan](https://github.com/DigitalRuby/IPBan) format so the
ban can also be enforced at the OS level. Not implemented yet - see
[PLANNED.md](PLANNED.md).

### Geolocation tab

- Local DB of IP-range to country mappings.
- **Export / Import** as SQL file - useful for handing off your already-built
  geolocation cache to client admins so they do not have to hit the API.

### MySQL configuration *(Server EXE, per server)*

There is no global MySQL tab in Settings since 1.0.4. MySQL is
configured per server in the Add/Edit-Server dialog under
**Steam-ID provider -> `mysql`** (see [Server tab](#server-tab-per-server)
above for the full field list).

The tool only **reads** `player_login_log` - no write access required.

### Steam tab

| Setting | What it does |
|---|---|
| **Steam Web API key** | Get one for free at [steamcommunity.com/dev/apikey](https://steamcommunity.com/dev/apikey). Used for VAC and Game-Ban lookups. |

Works in both EXEs. Steam Web API has a 100k calls/day quota, plenty for
typical server sizes.

## Environment variables

Since 1.0.4 **no passwords are stored in `resthirnrcon.db`**. The tool
reads them from environment variables on every connect. The variable
name is built from a **fixed prefix** plus a **per-server suffix** you
enter in the Edit-Server dialog. Two prefixes exist:

| Prefix | Used for | Required when |
|---|---|---|
| `RH_RCON_PASSWORD` | BattlEye RCon password | Always (any server you want to connect to) |
| `RH_MYSQL_PASSWORD` | MySQL provider password | Only if a server uses the `mysql` Steam-ID provider (Server EXE) |

The suffix can be empty (then the bare prefix is read). Examples:

| Suffix in server dialog | RCon env-var | MySQL env-var |
|---|---|---|
| *(empty)* | `RH_RCON_PASSWORD` | `RH_MYSQL_PASSWORD` |
| `_DE` | `RH_RCON_PASSWORD_DE` | `RH_MYSQL_PASSWORD_DE` |
| `_S2` | `RH_RCON_PASSWORD_S2` | `RH_MYSQL_PASSWORD_S2` |

The RCon suffix and the MySQL suffix are independent per server - you
do not have to use the same suffix for both. The variable is read on
every connect; nothing is cached.

**Set the env-var yourself in your OS.**

Windows (machine-wide so a logon-on-start setup also sees it):

```powershell
[Environment]::SetEnvironmentVariable("RH_RCON_PASSWORD", "your-rcon-password", "Machine")
[Environment]::SetEnvironmentVariable("RH_MYSQL_PASSWORD", "your-mysql-password", "Machine")
```

Log out / in (or reboot) so a fresh process picks it up.

Linux / macOS - put it in your shell rc, or for a systemd unit use
`EnvironmentFile=` so the env-var lands in the service environment.

**No secrets ever land in `resthirnrcon.db`** - back up the file
freely.

### Upgrading from 1.0.3 -> 1.0.4 (RCon password breaking change)

In 1.0.3 the RCon password lived inside `resthirnrcon.db`. The 1.0.4
schema migration **drops the column** - existing passwords are gone
and cannot be recovered. You need to:

1. Stop the tool.
2. Set `RH_RCON_PASSWORD` (and optional per-server `_<suffix>`
   variants) at the OS level using the PowerShell command above.
3. Start the tool. The migration runs once and writes a backup of the
   pre-migration DB into `backups/` next to the EXE.
4. For each server, open the Edit-Server dialog and fill in the
   **RCon env-var suffix** matching the env-var you set in step 2
   (leave empty to read the bare `RH_RCON_PASSWORD`).
5. Hit **Test connect** to verify, then save.

The MySQL provider was already env-var-based in 1.0.3, so the MySQL
side does not change.

### Upgrading from 1.0.6 or earlier (two EXEs since 1.0.7)

Through 1.0.6 there was one combined EXE with a Client/Server toggle in
Settings (and a mode step in the first-run wizard). Since 1.0.7 that EXE
is replaced by two separate downloads - `RHD-RCON-Client_v1.0.x.exe` and
`RHD-RCON-Server_v1.0.x.exe` - see [Choosing your
download](#choosing-your-download) above. There is no more in-app switch.

1. Stop the old combined EXE.
2. Download whichever new EXE matches how you were already running it -
   Client if you had "Client mode" selected, Server if you had "Server
   mode" selected.
3. Put the new EXE in the same folder as your existing `resthirnrcon.db`
   and `logs/`. The database schema is unchanged by the split, so the
   new EXE picks up your servers, player DB, bans and settings as-is -
   **no migration tool, no export/import needed.**
4. If you use scheduled tasks / auto-logon to launch the old EXE, point
   them at the new one.
5. Delete the old combined EXE once you have confirmed the new one
   connects and shows your existing data.

If you were running one instance in Client mode and a separate instance
in Server mode from two different folders, just replace each folder's
EXE with the matching new one - same rule, no cross-folder changes needed.

## Running the tool

### As a console app

Just double-click the EXE. Closes when you close the window.

### As a Windows service / scheduled task

The tool is a GUI app, not designed to run headless. For "always on" you
have two practical options:

- **Auto-start at logon** via Windows Task Scheduler (trigger: "At log on of
  any user"). Tool runs in the user's session. Good for a dedicated admin PC.
- **Run on the server PC** with an auto-logon Windows user. Same pattern.

A true headless service mode (no GUI) is not implemented.

## Logs to look at when things break

All log files live next to the EXE:

| File | What |
|---|---|
| `logs/app-YYYYMMDD.log` | General INFO/WARN/ERROR. Always on. |
| `logs/debug/RHD-RCON_Debug_YYYY-MM-DD.log` | Raw BattlEye feed (only if Debug log is enabled in settings). |
| `crash.log` | Last unhandled exception. The tool shows a dialog on next start if this file is present. |

## What this guide intentionally doesn't cover

- How to set up a DayZ Epoch server, install BattlEye or configure
  `BEServer.cfg` - the Epoch wiki and BI forums cover this.
- How to install MySQL or [extDB3](https://github.com/DeandlDernai/extDB) -
  upstream docs are better than what I could squeeze in here. The
  linked repo is my fork; the original upstream (Bitbucket) is no
  longer reachable.

If you hit a problem that is specifically about RHD-RCON, open a
[GitHub Issue](https://github.com/DeandlDernai/RHD-RCON/issues) and attach
the relevant logs. PRs against documentation are welcome.

If you want to actually talk, drop by my
[Discord](https://discord.gg/kjGXC7X93S) - the TS3 address for voice
chat is pinned there.

# Setup Guide

Admin documentation for installing and configuring RHD-RCON on a DayZ Epoch
server.

This guide assumes you already run a DayZ Epoch server with BattlEye, know
where `BEServer.cfg` lives, and have edited `dayz_server.pbo` before. It
focuses on what RHD-RCON specifically needs.

## Choosing a mode

RHD-RCON has two operating modes. Pick the one that matches your role:

| Mode | Who is this for | What you get |
|---|---|---|
| **Client mode** | You manage someone else's server. You have RCon password but no shell access to the server PC. | Live player list, kick/ban via RCon, ban list view, chat, theme. Multi-server ban sync and offline bans work. No scheduler, no process watchdog, no IP-ban enforcement, no player DB writes from live data. |
| **Server mode** | You run your own server(s) and can install things on the server PC. | Everything client mode has, plus scheduler, server-process watchdog, IP-ban enforcement, persistent player DB writes from live data, MySQL Steam-ID lookups, PlayerDB export for client admins. |

Server mode unlocks every feature but requires a few one-time setup steps
(env vars, optional MySQL table, optional SQF hook in `dayz_server.pbo`).

## Quick start (client mode)

1. Download `RHD-RCON_v1.0.x.zip` from the
   [Releases page](https://github.com/DeandlDernai/RHD-RCON/releases) -
   contains the EXE plus all docs (README, SETUP, TESTPLAN,
   TESTPLAN_SERVER, PLANNED). The bare EXE is also published separately
   if you only want to update.
2. Extract into a folder of your choice. A SQLite database file
   (`resthirnrcon.db`) and a `logs/` folder will be created next to the
   EXE on first run.
3. Run the EXE. On first start a wizard asks for mode (pick **Client**),
   admin name and theme.
4. Click **+ Add server** in the top-right, enter Name / Host / Port /
   Password, hit **Test connect**. Save.
5. Done. Click the new server tab on the left to connect and start managing.

## Quick start (server mode)

Server mode on top of the client-mode steps:

1. **If you plan to use MySQL Steam-ID resolution**, set the MySQL
   password as a system environment variable (Admin PowerShell):
   ```powershell
   [Environment]::SetEnvironmentVariable("RH_MYSQL_PASSWORD", "your-mysql-password", "Machine")
   ```
   Log out / in (or reboot) so a fresh process sees the variable. Skip
   this step if you do not plan to enable MySQL.

2. Run the EXE **as Administrator** (needed for the restart scripts).
3. First-run wizard: pick **Server**.
4. Configure MySQL (optional, for Steam-ID resolution): **Settings -> MySQL**.
   The password field is intentionally absent - the tool reads it from
   `RH_MYSQL_PASSWORD`.
5. To enable Steam-ID resolution: install the optional MySQL table + SQF hook
   on your server (see [Server-side prerequisites](#server-side-prerequisites)
   below).

## Server-side prerequisites

For most features RHD-RCON only needs the BattlEye RCon password. Two
optional capabilities need server-side preparation:

### A) Steam-ID resolution (server mode)

RHD-RCON resolves BattlEye GUIDs to Steam-IDs by reading a `player_login_log`
table that your DayZ server writes on every player login. Without this table,
Steam-ID lookups stay empty and the VAC/Game-Ban check via Steam Web API has
nothing to query.

**Required pieces** (on your DayZ server DB , not the RHD-RCON PC):

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

Rows should appear on every player login. Once that works, RHD-RCON's
Steam-ID lookups in server mode start populating automatically.

### B) Scheduled server restarts (server mode)

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

- **Server tab -> Process monitoring** -> set `ServerProcessName` (e.g.
  `arma2oaserver.exe`) and `RestartScriptPath` (full path to your script).

With both set, the built-in **server-process watchdog** polls every 20s.
If the process is gone (because the scheduler just killed it, or because
it crashed), it runs your script. A 120s cooldown prevents restart loops.

So you don't need a separate Windows Scheduled Task - the tool itself is
the watchdog, you only supply the start script.


## Configuration reference

### General tab

Self-explanatory: admin name, debug log path, theme.

The **Ban sync time** *(server mode)* sets when the daily background
ban-status sync between RHD-RCON DB and BattlEye `bans.txt` runs.
Default 04:00. If your tool is offline at that time, the sync is missed
for that day - this only matters in server mode, where the tool is
typically running 24/7 on the server PC.

### Server tab (per-server)

Fields are self-explanatory in the Add/Edit-Server dialog. Two things
worth knowing:

- **Password** is stored encrypted in SQLite.
- **Auto-connect** makes 3 attempts with 2s delay on tool start.

### IP Ban tab *(server mode)*

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

### MySQL tab *(server mode only)*

| Setting | What it does |
|---|---|
| **Host / Port / Database / User** | Connection to the DayZ Epoch MySQL database. |
| Password | Read from env var `RH_MYSQL_PASSWORD`. No field in the UI. |

The tool only **reads** `player_login_log` - no write access required.

### Steam tab

| Setting | What it does |
|---|---|
| **Steam Web API key** | Get one for free at [steamcommunity.com/dev/apikey](https://steamcommunity.com/dev/apikey). Used for VAC and Game-Ban lookups. |

Works in both modes. Steam Web API has a 100k calls/day quota, plenty for
typical server sizes.

## Environment variables (server mode)

Only one variable, and only if you use MySQL Steam-ID resolution:

- `RH_MYSQL_PASSWORD` - MySQL password. Read from env on every connect,
  never stored anywhere by the tool.

The MySQL password is intentionally **not** stored in `resthirnrcon.db`
or any config file. Backup `resthirnrcon.db` freely - no secrets in it.

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

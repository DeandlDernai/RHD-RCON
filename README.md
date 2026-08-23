# RHD-RCON

A BattlEye RCon tool for **DayZ Epoch** and **Arma Reforger** server
admins, with a plugin architecture for other BattlEye-based games
(Arma 3, DayZ Standalone, Arma 4) via per-server Steam-ID providers.

Live player monitoring, ban management with multi-server sync, scheduled
messages, scheduled shutdowns, server-process watchdog (auto-restart on
crash) and a cross-server player database - as two purpose-built Windows
EXEs, no install.

## Client vs. Server - which one do I need?

Since 1.0.7 RHD-RCON ships as **two separate EXEs** instead of one app
with a mode switch. Pick the download that matches your role:

- **`RHD-RCON-Client`** - you manage someone else's server. All you need
  is the RCon password; no access to the server PC itself required.
- **`RHD-RCON-Server`** - you **are** the operator of the server PC. This
  EXE is built to run *on that machine* (or somewhere with admin rights on
  it and network access to its RCon/MySQL/log files) - it needs to be
  able to configure things there (restart scripts, scheduled tasks) and
  to reach the server's own data (the MySQL Hive DB if you use the
  `mysql` Steam-ID provider, or the BattlEye console log for Reforger IP
  lookups). **It is not a "more powerful client" you can run from any PC**
  - the extra features it unlocks (scheduler, watchdog, IP-ban
  enforcement, connect filters, live player-DB writes) all depend on that
  server-side access.

If you are unsure which one applies to you: if you only ever type an RCon
password into a config file and never touch the server's own filesystem
or database, you want the Client EXE.

## Status

**Early access.** First public release series (v1.0.x). Runs in production
on my own servers, but expect rough edges. Bug reports and feature requests
via [GitHub Issues](https://github.com/DeandlDernai/RHD-RCON/issues) are
welcome.

I would really appreciate it if you could walk through the test plan
on your setup and let me know what works, what does not, and what
feels off. Two short plans depending on how you use the tool:

- **[TESTPLAN_CLIENT.md](TESTPLAN_CLIENT.md)** - for the Client EXE, if
  you manage someone else's server via RCon. ~15-20 minutes.
- **[TESTPLAN_SERVER.md](TESTPLAN_SERVER.md)** - for the Server EXE, if
  you run RHD-RCON on your own server PC. Covers the server-only features
  (scheduler, watchdog, IP ban, MySQL Steam-ID resolution) on top of the
  client plan. ~10-15 minutes extra.

Both plans (and SETUP.md / PLANNED.md) are also shipped inside the
release ZIP, so you have them offline next to the EXE. Feedback from
other admins is the fastest way to make this tool less rough at the
edges.

## Who is this for?

DayZ Epoch admins who want more than a plain RCon shell. You should be
comfortable with:

- Editing `BEServer.cfg` and `dayz_server.pbo`
- Running things on a Windows server (the tool is Windows-only)
- Optional MySQL access if you want Steam-ID resolution (configured
  per server, so different servers can use different databases or none
  at all)

If you only need the occasional broadcast, a basic RCon tool is simpler.
RHD-RCON shines when you run multiple servers, want a shared ban list, or
care about who connected when.

## Arma Reforger

Since 1.0.6 a server can be set to game type **Arma Reforger** in the
Add/Edit-Server dialog.

| Feature | Status |
|---|---|
| Player list, kick, ban, unban, ban list | works today |
| Player IP + country flag (Server EXE) | works today |
| Steam-ID resolution | needs the companion mod - **work in progress** |
| Chat: broadcast / warning / info / PM | needs the companion mod - **work in progress** |

Reforger has no vanilla RCon chat command, and it never exposes a
player's Steam-ID over RCon. Both are closed by a companion server mod
(`RHD_ReforgerRconSupport`) that adds the chat commands and writes a
login log (`logins.jsonl`) mapping backend UUID -> Steam-ID. That mod is
**still in development and not published yet** - the tool side is
finished and already in 1.0.6, so those two features light up as soon as
the mod is out. This page will link it once it is public.

## What you need to set it up

The two EXEs need different things ready before you start. Full
walkthrough in [SETUP.md](SETUP.md).

**Client EXE** (you manage someone else's server via RCon):

| What | Where from |
|---|---|
| **RCon Host / Port** | The server admin (your `BEServer.cfg` `RConPort`) |
| **RCon Password (env-var)** | The server admin (your `BEServer.cfg` `RConPassword`). Stored as an environment variable on **your PC**, never in `resthirnrcon.db`. The tool reads `RH_RCON_PASSWORD` plus a per-server **suffix** you set in the dialog (empty suffix = `RH_RCON_PASSWORD`, suffix `_S2` = `RH_RCON_PASSWORD_S2`, etc.) |
| **A PlayerDB export from a server admin** (optional, for VAC / Game-Ban badges) | The Client EXE has no Settings -> Steam tab (no Steam Web API key field) - it only *shows* SteamIDs and VAC/Game-Ban badges for players a Server EXE already resolved and exported. See [TESTPLAN_CLIENT.md](TESTPLAN_CLIENT.md), section 4.4 |

**Server EXE** (you run RHD-RCON on your own server PC - see
["Client vs. Server"](#client-vs-server---which-one-do-i-need) above for
why this one needs server-side access). Everything from the Client EXE,
plus:

| What | Where from |
|---|---|
| **Admin rights** on the server PC | Needed so the watchdog can launch the restart script (only if you use the watchdog feature) |
| **Steam Web API key** (optional, for VAC / Game-Ban lookups) | [steamcommunity.com/dev/apikey](https://steamcommunity.com/dev/apikey) - entered under Settings -> Steam, a tab that only exists in the Server EXE |
| **MySQL credentials** (optional, for Steam-ID resolution) | Configured **per server** in the Add/Edit-Server dialog under "Steam-ID provider": Host / Port / Database / User. Password is read from an environment variable - the tool uses the prefix `RH_MYSQL_PASSWORD` and appends a per-server **suffix** you choose (e.g. suffix `_DE` -> env-var `RH_MYSQL_PASSWORD_DE`). Empty suffix = `RH_MYSQL_PASSWORD` (1.0.3 default). No secrets land in the DB |
| **`player_login_log` table + SQF hook** (optional, only with MySQL provider) | See [server-integration/](server-integration/) - SQL schema, extDB3 block, SQF hook + step-by-step README. Also shipped in the release ZIP |

## Features

- **Player management** - live list with country flag, Steam-ID,
  online-player-count badge, right-click for kick/ban/PM/comment/whitelist.
  Reorderable, color-coded server tabs.
- **Ban management** - BattlEye GUID bans, multi-server ban sync, offline
  queue (bans get applied to servers that come back online later).
- **Player database** - cross-server, name- and IP-change history, action
  log per player, JSON export (Server EXE) / import (both EXEs) so a
  Client admin can see SteamIDs and Steam bans a Server EXE already
  resolved.
- **Connect filters** (Server EXE only) - country allow/blocklist and a
  name filter (allowed Unicode block, symbol ratio, forbidden patterns),
  each with a configurable per-server kick message. A whitelist (match by
  GUID or SteamID) exempts individual players from the country filter.
  See SETUP.md ["Connect filters"](SETUP.md#c-connect-filters-server-exe)
  for what this is for and what it is not for.
- **Scheduler** (Server EXE only) - scheduled chat broadcasts and daily
  server restarts (warn broadcasts + clean process kill).
- **Server-process watchdog** (Server EXE only) - restarts the game
  server process if it dies, with a cooldown against restart loops.
- **IP ban list** (Server EXE only) - in-tool IP-ban enforcement, since
  BattlEye/ArmA 2 has no IP-ban mechanism of its own.
- **Chat view** - selectable text, per-log-type filters, smart
  auto-scroll, Enter-to-send in broadcast and PM.
- **Per-server Steam-ID provider** - each server picks its own source
  (`none`, `mysql` for Epoch/Arma 3 Hive DBs, `reforger_loginlog` for
  Arma Reforger); more providers land without a database migration.
- **RCon password and MySQL password never touch `resthirnrcon.db`** -
  both are read from OS environment variables on every connect. See
  [Environment variables](SETUP.md#environment-variables) in SETUP.md.

Full field-by-field configuration reference is in [SETUP.md](SETUP.md);
version-by-version history is in [CHANGELOG.md](CHANGELOG.md).

## Download

Get the latest build from the
[Releases page](https://github.com/DeandlDernai/RHD-RCON/releases). See
["Client vs. Server"](#client-vs-server---which-one-do-i-need) above if
you are not sure which one you need.

Each release ships **four assets** - a ZIP and a bare EXE for each of the
two roles:

- `RHD-RCON-Client_v1.0.x.zip` - EXE + all docs (`README.md`, `SETUP.md`,
  `TESTPLAN_CLIENT.md`, `PLANNED.md`, `CHANGELOG.md`) + `.sha256`.
  Recommended - you get everything offline next to the EXE.
- `RHD-RCON-Client_v1.0.x.exe` - the bare Client EXE if you just want a
  quick update.
- `RHD-RCON-Server_v1.0.x.zip` - same as the Client ZIP plus
  `TESTPLAN_SERVER.md` and the `server-integration/` folder (SQL/extDB3/
  SQF for MySQL Steam-ID resolution).
- `RHD-RCON-Server_v1.0.x.exe` - the bare Server EXE if you just want a
  quick update.

**Verify the download** (recommended):

```powershell
Get-FileHash RHD-RCON-Client_v1.0.x.exe -Algorithm SHA256
```

Compare the result to the **contents** of the matching `.sha256` file
(e.g. `RHD-RCON-Client_v1.0.x.exe.sha256` - open that file, it is plain
text with the expected hash). Do not confuse this with the hash GitHub
shows next to the `.sha256` file itself in the release list - that is
the checksum of the text file, not its contents.

## Setup

Full walkthrough in **[SETUP.md](SETUP.md)** (server-side prerequisites,
choosing Client vs. Server, env vars, MySQL, Steam, IP ban).

After setup, [TESTPLAN_CLIENT.md](TESTPLAN_CLIENT.md) (and
[TESTPLAN_SERVER.md](TESTPLAN_SERVER.md) if you run the Server EXE) takes
you through every feature step by step.

## Privacy and data

- All player data lives locally in `resthirnrcon.db` next to the EXE. No
  cloud, no telemetry, no auto-update phone-home.
- **What personal data is stored:** player IP address, BattlEye GUID,
  in-game name (and name/IP-change markers), country code, and - if you
  enable Steam lookups - the Steam-ID and cached Steam profile. GUID and
  name are pseudonymous identifiers needed for abuse prevention (ban-evasion
  detection, bans, connect filters).
- **IP retention (configurable):** stored player IPs are automatically
  cleared after **90 days of inactivity** (Settings -> General, `0` =
  keep forever). Active IP bans are never affected - an IP ban stays as
  long as the ban does. The IP-change history only records *that* an IP
  changed, not the actual addresses.
- **Transfer to third parties:** geolocation lookups send the player **IP**
  to [ip-api.com](https://ip-api.com); Steam lookups send the **Steam-ID**
  to the official Steam Web API. Both only happen for players connecting to
  servers you manage, and results are cached locally.
- **You are the data controller.** This tool is run on your own machine and
  stores data only there - the author never receives any of it. Handling
  access or deletion requests (GDPR Art. 15/17) for your players is your
  responsibility as the server operator. You can clear individual entries
  by editing `resthirnrcon.db` directly, and player IPs age out automatically
  via the retention setting above.
- **No passwords are stored in `resthirnrcon.db`.** The RCon password and
  the MySQL password (if you use the MySQL provider) are both read from
  environment variables on every connect. Back up `resthirnrcon.db` freely.
- Steam-ID lookups (Server EXE, when the MySQL provider is enabled on
  a server) go to your own MySQL database. Requires one-time server-side
  setup (MySQL table + SQF hook in `dayz_server.pbo`) - see
  [SETUP.md](SETUP.md#a-steam-id-resolution-server-exe-mysql-provider) for details.
- Steam profile lookups (VAC/Game-Ban) call the official Steam Web API with
  your own API key. Get a free key at
  [steamcommunity.com/dev/apikey](https://steamcommunity.com/dev/apikey),
  then enter it under Settings -> Steam **in the Server EXE** (see
  [SETUP.md](SETUP.md#steam-tab-server-exe)) - the Client EXE has no
  Steam tab and never calls the Steam Web API itself; it only displays
  Steam data a Server EXE already resolved and exported.
- Geolocation lookups use [ip-api.com](https://ip-api.com) (free tier, 45
  requests/minute). Results are cached locally.
- **Update check:** on every start the tool fetches a small `links.json`
  from this GitHub repo to compare your version against the latest. If
  newer, a one-time dialog points you to the Releases page. On a version
  mismatch the external API calls (Steam Web API + ip-api.com) are quietly
  disabled until you update, to avoid sending requests that might break
  after an API change. RCon, scheduler, ban management and everything
  local keep working - the local geolocation cache is still used too.

## Source code and license

The source code is **not public** and there are no plans to open it.
Only the compiled Windows EXE is distributed via GitHub Releases under
"all rights reserved" terms - the binary may be downloaded, run and
redistributed in its original form, but no derivative works.

The server-side integration files in `server-integration/` are a
different matter: they are meant to be installed on your own DayZ server
and are free to copy, modify and adapt.

Full terms in [LICENSE](LICENSE).

## About this project

This is a one-person side project: concept, feature scope, testing on
live servers, debugging and all decisions are mine. Coding is done with
AI assistance (Claude) - which is increasingly normal, but worth saying
out loud so bug reporters know not every corner has had years of human
review behind it.

## Credits / Third-party assets

- App icon: [Microsoft Fluent UI Emoji](https://github.com/microsoft/fluentui-emoji)
  ("Wrench" 3D, MIT License, Copyright (c) Microsoft Corporation).
- Geolocation seed data: [IP2Location LITE](https://lite.ip2location.com),
  CC-BY-SA 4.0. The bundled IP-to-country database is derived from
  IP2Location LITE.
- Live geolocation lookups: [ip-api.com](https://ip-api.com) free tier.

---

<div align="center">

If this tool is useful to you, I would be happy about a coffee.

**[ko-fi.com/deandlresthirn](https://ko-fi.com/deandlresthirn)**

<sub>voluntary, no strings attached</sub>

</div>

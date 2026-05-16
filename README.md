# RHD-RCON

A BattlEye RCon tool for **DayZ Epoch** server admins.

Live player monitoring, ban management with multi-server sync, scheduled
messages, scheduled shutdowns, server-process watchdog (auto-restart on
crash) and a cross-server player database - all in a single Windows EXE,
no install.

## Status

**Early access.** First public release series (v1.0.x). Runs in production
on my own servers, but expect rough edges. Bug reports and feature requests
via [GitHub Issues](https://github.com/DeandlDernai/RHD-RCON/issues) are
welcome.

I would really appreciate it if you could walk through the test plan
on your setup and let me know what works, what does not, and what
feels off. Two short plans depending on how you use the tool:

- **[TESTPLAN.md](TESTPLAN.md)** - if you manage someone else's server
  via RCon (client mode). ~15-20 minutes.
- **[TESTPLAN_SERVER.md](TESTPLAN_SERVER.md)** - if you run RHD-RCON
  on your own server PC. Covers the server-only features (scheduler,
  watchdog, IP ban, MySQL Steam-ID resolution) on top of the client
  plan. ~10-15 minutes extra.

Both plans (and SETUP.md / PLANNED.md) are also shipped inside the
release ZIP, so you have them offline next to the EXE. Feedback from
other admins is the fastest way to make this tool less rough at the
edges.

## Who is this for?

DayZ Epoch admins who want more than a plain RCon shell. You should be
comfortable with:

- Editing `BEServer.cfg` and `dayz_server.pbo`
- Running things on a Windows server (the tool is Windows-only)
- Optional MySQL access if you want Steam-ID resolution

If you only need the occasional broadcast, a basic RCon tool is simpler.
RHD-RCON shines when you run multiple servers, want a shared ban list, or
care about who connected when.

## What you need to set it up

Different modes need different things ready before you start. Full
walkthrough in [SETUP.md](SETUP.md).

**Client mode** (you manage someone else's server via RCon):

| What | Where from |
|---|---|
| **RCon Host / Port / Password** | The server admin (your `BEServer.cfg` `RConPassword`) |
| **Steam Web API key** (optional, for VAC / Game-Ban lookups) | [steamcommunity.com/dev/apikey](https://steamcommunity.com/dev/apikey) |

**Server mode** (you run RHD-RCON on your own server PC). Everything
from client mode, plus:

| What | Where from |
|---|---|
| **Admin rights** on the server PC | Needed so the watchdog can launch the restart script (only if you use the watchdog feature) |
| **MySQL credentials** (optional, for Steam-ID resolution) | Your Epoch DB: Host / Port / Database / User. Password goes into env var `RH_MYSQL_PASSWORD`, never stored by the tool |
| **`player_login_log` table + SQF hook** (optional, only with MySQL) | See [server-integration/](server-integration/) - SQL schema, extDB3 block, SQF hook + step-by-step README. Also shipped in the release ZIP |

## Features

- **Player management** - live list with country flag, Steam-ID, right-click
  for kick/ban/PM/comment
- **Ban management** - BattlEye GUID bans, multi-server ban sync, offline
  queue (bans get applied to servers that come back online later)
- **Player database** - cross-server, name- and IP-change history, action
  log per player
- **Scheduler** (server mode only) - scheduled chat broadcasts, daily server
  restarts with warn broadcasts + clean process kill
- **Server-process watchdog** (server mode only) - polls the configured
  game-server process every 20s and runs your restart script if it has
  died (with cooldown to prevent restart loops)
- **IP ban list** (server mode only) - in-tool IP-ban table, players with
  banned IPs get kicked on the next refresh (the kick message is
  configurable - keep it generic to hide that it is an IP ban)
- **Two modes:**
  - **Client mode:** GUI for managing someone else's server. Has its own
    local SQLite (server configs, settings, local geo cache, imported
    player data, ban-sync queue). Multi-server ban sync and offline bans
    work in client mode too - any server you are connected to (or that
    comes back online later) gets the queued ban. What client mode does
    *not* do: scheduler, server-process watchdog, IP-ban enforcement,
    player DB writes from live data (only via import from a server admin),
    MySQL Steam-ID resolution.
  - **Server mode:** everything above plus scheduler, server-process
    watchdog, IP-ban enforcement, full player DB writes from live data,
    MySQL Steam-ID resolution.

## Download

Get the latest build from the
[Releases page](https://github.com/DeandlDernai/RHD-RCON/releases).

Each release ships two assets:

- `RHD-RCON_v1.0.x.zip` - EXE + all docs (`README.md`, `SETUP.md`,
  `TESTPLAN.md`, `TESTPLAN_SERVER.md`, `PLANNED.md`) + `server-integration/`
  folder + `.sha256`. Recommended - you get everything offline next to
  the EXE.
- `RHD-RCON_v1.0.x.exe` - the bare EXE if you just want a quick update.

**Verify the download** (recommended):

```powershell
Get-FileHash RHD-RCON_v1.0.x.exe -Algorithm SHA256
```

Compare the result to the **contents** of the `RHD-RCON_v1.0.x.exe.sha256`
file (open that file - it is plain text with the expected hash). Do not
confuse this with the hash GitHub shows next to the `.sha256` file
itself in the release list - that is the checksum of the text file, not
its contents.

## Setup

Full walkthrough in **[SETUP.md](SETUP.md)** (server-side prerequisites,
modes, env vars, MySQL, Steam, IP ban).

After setup, [TESTPLAN.md](TESTPLAN.md) takes you through every feature
step by step.

## Privacy and data

- All player data lives locally in `resthirnrcon.db` next to the EXE. No
  cloud, no telemetry, no auto-update phone-home.
- Steam-ID lookups (server mode) go to your own MySQL database. Requires
  one-time server-side setup (MySQL table + SQF hook in `dayz_server.pbo`) -
  see [SETUP.md](SETUP.md#a-steam-id-resolution-server-mode) for details.
- Steam profile lookups (VAC/Game-Ban) call the official Steam Web API with
  your own API key. Get a free key at
  [steamcommunity.com/dev/apikey](https://steamcommunity.com/dev/apikey),
  then enter it under Settings -> Steam (see
  [SETUP.md](SETUP.md#steam-tab)).
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

The source code is currently **not public**. Only the compiled Windows EXE
is distributed via GitHub Releases under "all rights reserved" terms - the
binary may be downloaded, run and redistributed in its original form,
but no derivative works. The server-side integration files in
`server-integration/` are free to copy and adapt as needed.

Full terms in [LICENSE](LICENSE).

Once the codebase reaches a quality level I am comfortable sharing
publicly, the source will be opened under a permissive license.

## About this project

This is a one-person side project: concept, feature scope, testing on
live servers, debugging and all decisions are mine. Coding is done with
AI assistance (Claude) - which is increasingly normal, but worth saying
out loud so bug reporters know not every corner has had years of human
review behind it.

---

<div align="center">

If this tool is useful to you, I would be happy about a coffee.

**[ko-fi.com/deandlresthirn](https://ko-fi.com/deandlresthirn)**

<sub>voluntary, no strings attached</sub>

</div>

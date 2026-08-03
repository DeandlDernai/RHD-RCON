# RHD-RCON

A BattlEye RCon tool for **DayZ Epoch** and **Arma Reforger** server
admins, with a plugin architecture for other BattlEye-based games
(Arma 3, DayZ Standalone, Arma 4) via per-server Steam-ID providers.

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
| Player IP + country flag (server mode) | works today |
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

Different modes need different things ready before you start. Full
walkthrough in [SETUP.md](SETUP.md).

**Client mode** (you manage someone else's server via RCon):

| What | Where from |
|---|---|
| **RCon Host / Port** | The server admin (your `BEServer.cfg` `RConPort`) |
| **RCon Password (env-var, since 1.0.4)** | The server admin (your `BEServer.cfg` `RConPassword`). Stored as an environment variable on **your PC**, never in `resthirnrcon.db`. The tool reads `RH_RCON_PASSWORD` plus a per-server **suffix** you set in the dialog (empty suffix = `RH_RCON_PASSWORD`, suffix `_S2` = `RH_RCON_PASSWORD_S2`, etc.) |
| **Steam Web API key** (optional, for VAC / Game-Ban lookups) | [steamcommunity.com/dev/apikey](https://steamcommunity.com/dev/apikey) |

**Server mode** (you run RHD-RCON on your own server PC). Everything
from client mode, plus:

| What | Where from |
|---|---|
| **Admin rights** on the server PC | Needed so the watchdog can launch the restart script (only if you use the watchdog feature) |
| **MySQL credentials** (optional, for Steam-ID resolution) | Configured **per server** in the Add/Edit-Server dialog under "Steam-ID provider": Host / Port / Database / User. Password is read from an environment variable - the tool uses the prefix `RH_MYSQL_PASSWORD` and appends a per-server **suffix** you choose (e.g. suffix `_DE` -> env-var `RH_MYSQL_PASSWORD_DE`). Empty suffix = `RH_MYSQL_PASSWORD` (1.0.3 default). No secrets land in the DB |
| **`player_login_log` table + SQF hook** (optional, only with MySQL provider) | See [server-integration/](server-integration/) - SQL schema, extDB3 block, SQF hook + step-by-step README. Also shipped in the release ZIP |

## Features

- **Player management** - live list with country flag, Steam-ID, right-click
  for kick/ban/PM/comment. Whitelist-star column shows protected players
  at a glance.
- **Ban management** - BattlEye GUID bans, multi-server ban sync, offline
  queue (bans get applied to servers that come back online later)
- **Player database** - cross-server, name- and IP-change history, action
  log per player. Audit entries for connect-filter kicks (Country-Kick /
  Name-Kick) and whitelist add/remove show up in the player action log.
- **Connect filters** (server mode only, since 1.0.5):
  - **Country filter** - allow- or blocklist of ISO country codes, kicks
    on connect with a configurable per-server message.
  - **Name filter** - allowed Unicode block (Ascii / Latin /
    LatinCyrillic / Any), max special-char ratio, and a forbidden
    substring pattern list (e.g. `admin,discord.gg`). Kicks unlesbare
    or impersonating names on connect.
  - **Whitelist** - dedicated tab on the left with its own grid (GUID
    and/or SteamID, free-form note, AddedAt timestamp). Match is
    GUID-OR-SteamID, so partial info is enough. Four ways to add an
    entry: the whitelist tab itself, Settings -> Country Filter,
    right-click in the Players view, right-click in the Player DB.
    Whitelist is enforced **for the country filter only** - the name
    filter is absolute (even admins must have readable names).
- **Scheduler** (server mode only) - scheduled chat broadcasts, daily server
  restarts with warn broadcasts + clean process kill. Live `Last run`
  timestamp updates without leaving the tab.
- **Server-process watchdog** (server mode only) - polls the configured
  game-server process every 20s and runs your restart script if it has
  died (with cooldown to prevent restart loops)
- **IP ban list** (server mode only) - in-tool IP-ban table, players with
  banned IPs get kicked on the next refresh (the kick message is
  configurable - keep it generic to hide that it is an IP ban)
- **Chat view** - selectable text (Ctrl+C to copy), filter checkboxes per
  log type (Global / Side / Direct / Vehicle / Group / Command / Admin),
  smart auto-scroll that follows new messages when you are at the bottom
  and stays put when you scrolled up to read history, Enter = Send in
  the broadcast input and the PM dialog (Shift+Enter for newline).
- **Server tab header** - online-player-count badge in the accent color
  next to the tab name; short-lived `+1` / `-2` delta marker after
  changes makes connects and disconnects easy to spot across tabs.
- **Two modes:**
  - **Client mode:** GUI for managing someone else's server. Has its own
    local SQLite (server configs, settings, local geo cache, imported
    player data, ban-sync queue). Multi-server ban sync and offline bans
    work in client mode too - any server you are connected to (or that
    comes back online later) gets the queued ban. What client mode does
    *not* do: scheduler, server-process watchdog, IP-ban enforcement,
    country / name connect-filters, whitelist tab, player DB writes
    from live data (only via import from a server admin), MySQL
    Steam-ID resolution.
  - **Server mode:** everything above plus scheduler, server-process
    watchdog, IP-ban enforcement, country / name connect-filters,
    whitelist tab, full player DB writes from live data, per-server
    Steam-ID resolution (MySQL provider in 1.0.4; more providers
    planned for other games).

- **Per-server Steam-ID provider** (since 1.0.4) - each server picks
  its own Steam-ID source. Two providers ship in 1.0.4:
  - **`none`** - no Steam-ID lookup. Default for servers that have no
    DB (Reforger, DayZ Standalone, fresh setups).
  - **`mysql`** - reads `player_login_log` from your Epoch/Arma 3 Hive
    DB. Each server has its own DB connection and its own password,
    so you can run multiple servers against different databases from
    one tool instance.
  Future providers (BattlEye-RCon Steam-ID parser, FileWatcher for
  Reforger/Standalone, HTTP bridge) are plugin-style additions - no
  database migration needed when they land.

- **Reorder server tabs** (since 1.0.4) - small `<` / `>` buttons in
  each tab header move the tab left/right. The order is persisted, so
  your favourite server can stay first across restarts.

- **RCon password from env-var** (since 1.0.4, **breaking change**) -
  the RCon password is no longer stored in `resthirnrcon.db`. Each
  server defines an env-var suffix (empty = `RH_RCON_PASSWORD`,
  `_S2` = `RH_RCON_PASSWORD_S2`, etc.). The tool reads the variable
  on every connect. Upgrade path: set the env-var(s) on your OS and
  enter the matching suffix in the Edit-Server dialog. See the
  [CHANGELOG](CHANGELOG.md) for the migration steps.

- **Country / Name auto-kick + Whitelist** (since 1.0.5, server mode only) -
  kick players on connect by country code or name pattern with a
  configurable per-server message. A separate whitelist tab protects
  individual players from the country filter (match by GUID or
  SteamID). Setup pointers in [SETUP.md](SETUP.md#c-connect-filters-server-mode);
  test steps in [TESTPLAN_SERVER.md](TESTPLAN_SERVER.md).

- **Server-Edit dialog with tabs** (since 1.0.5) - the Add/Edit-Server
  dialog is now split into **Connection**, **Behavior**, **Filters**
  (server mode), **Steam-ID** (server mode) and **Watchdog** (server
  mode). Easier to find a single setting and easier to skim what each
  server is configured for.

- **Chat improvements** (since 1.0.5) - selectable text + Ctrl+C, filter
  checkboxes per log type, smart auto-scroll (follows the live stream
  at the bottom, holds position when you scrolled up), Enter sends in
  both the broadcast input and the PM dialog (Shift+Enter for newline).

- **Online player count badge** (since 1.0.5) - each connected server
  tab shows a small accent-colored pill with the live player count,
  plus a short-lived `+1` / `-2` delta after changes.

- **Global admin names** (since 1.0.5, schema V17) - the per-server
  `admin_name` column is gone. Two global names live under Settings ->
  General: the **Client admin name** for manual actions (chat / PM /
  kick / ban) and the **Server admin name** (default `RESTHIRN`) for
  automated actions (scheduler, ban sync, country/name kicks). Changes
  take effect after a server disconnect + reconnect.

## Download

Get the latest build from the
[Releases page](https://github.com/DeandlDernai/RHD-RCON/releases).

Each release ships two assets:

- `RHD-RCON_v1.0.x.zip` - EXE + all docs (`README.md`, `SETUP.md`,
  `TESTPLAN.md`, `TESTPLAN_SERVER.md`, `PLANNED.md`, `CHANGELOG.md`) +
  `server-integration/` folder + `.sha256`. Recommended - you get
  everything offline next to the EXE.
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
- **What personal data is stored:** player IP address, BattlEye GUID,
  in-game name (and name/IP-change markers), country code, and - if you
  enable Steam lookups - the Steam-ID and cached Steam profile. GUID and
  name are pseudonymous identifiers needed for abuse prevention (ban-evasion
  detection, bans, connect filters).
- **IP retention (configurable, ships with 1.0.6):** stored player IPs are
  automatically cleared after **90 days of inactivity** (configurable under
  Settings -> General, `0` = keep forever). Active IP bans are never
  affected - an IP ban stays as long as the ban does. The IP-change history
  only records *that* an IP changed, not the actual addresses. (This note is
  published ahead of the 1.0.6 binary so the data-handling is transparent up
  front.)
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
- **No passwords are stored in `resthirnrcon.db`** (since 1.0.4). The
  RCon password and the MySQL password (if you use the MySQL provider)
  are both read from environment variables on every connect. The tool
  builds the variable name from a fixed prefix (`RH_RCON_PASSWORD` /
  `RH_MYSQL_PASSWORD`) plus a per-server **suffix** you set in the
  Edit-Server dialog. Back up `resthirnrcon.db` freely.
- Steam-ID lookups (server mode, when the MySQL provider is enabled on
  a server) go to your own MySQL database. Requires one-time server-side
  setup (MySQL table + SQF hook in `dayz_server.pbo`) - see
  [SETUP.md](SETUP.md#a-steam-id-resolution-server-mode) for details.
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

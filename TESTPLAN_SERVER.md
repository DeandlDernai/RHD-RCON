# Test Plan - Server EXE

Workflow walkthrough for **Server-EXE admins** (RHD-RCON runs on the
same Windows machine as your DayZ Epoch server, with the server process,
restart scripts and optionally MySQL available locally). See README
["Client vs. Server"](README.md#client-vs-server---which-one-do-i-need)
if you are not sure this is the right download for you.

> **Prerequisite:** run through [TESTPLAN_CLIENT.md](TESTPLAN_CLIENT.md)
> first - it covers everything that also exists in the Client EXE (player
> list, kick, ban, ban list, ban sync, player DB, scheduled chat messages,
> commands). This plan only covers the **Server-EXE-only** features on
> top.

## How to use this plan

Each test step has three checkboxes. Tick exactly one:

- `[x]` - **works** as described
- `[-]` - **does not work** / unexpected behavior
- `[?]` - **question / unclear** - write your question on the line below

When you report back (GitHub Issue or Discord), please reference the
section number (e.g. "3.2 step 4 was [-]: ...") so I know exactly which
step you mean. For `[-]` a short note plus a snippet from
`logs/app-YYYYMMDD.log` helps a lot.

## Prerequisites

- TESTPLAN_CLIENT.md completed (you can connect, kick, ban, see players)
- `RHD-RCON-Server_v1.0.x.exe` downloaded (the Server EXE is a separate
  binary from the Client EXE, not a mode you switch to inside one app)
- RHD-RCON running **as Administrator** on the server PC (needed so the
  watchdog can start your restart script)
- You are the operator of this server PC: you can create/edit restart
  scripts, set up scheduled tasks, and (if you use the `mysql` Steam-ID
  provider or Reforger) reach the server's own database/log files. See
  README ["Client vs. Server"](README.md#client-vs-server---which-one-do-i-need)
  for the full requirement.

---

## 1. First start (Server EXE)

1. Double-click `RHD-RCON-Server_v1.0.x.exe`. First-run wizard: Admin
   name, theme. There is no mode picker - starting this EXE **is** the
   server role.
   `[x]` `[-]` `[?]`
   > Question:
2. Main window shows the Server-EXE-only tabs (**Country Filter**, **Name
   Filter**, **IP Ban**, server-side scheduler entries, ...) directly.
   The Add/Edit-Server dialog has additional tabs (**Filters**,
   **Steam-ID**, **Watchdog**) that do not exist at all in the Client EXE.
   `[x]` `[-]` `[?]`
   > Question:

---

## 2. Player DB live writes

In the Server EXE the Player DB is populated automatically from the live
RCon feed (Verified GUID events on your servers).

### 2.1 Connect with active players

1. Connect to a server that has at least one player online.
   `[x]` `[-]` `[?]`
   > Question:
2. Open **Player DB** tab on the left. New players appear within a few
   seconds with Name / GUID / IP / first-seen.
   `[x]` `[-]` `[?]`
   > Question:

### 2.2 Name and IP change history

1. Have a player reconnect with a different name (or different IP).
   `[x]` `[-]` `[?]`
   > Question:
2. Right-click the player -> **Player Log...** -> **Actions**. Name /
   IP change is logged with timestamp.
   `[x]` `[-]` `[?]`
   > Question:

---

## 3. MySQL Steam-ID resolution

Requires the optional server-side integration (MySQL table
`player_login_log`, extDB3 protocol, SQF hook). See
[SETUP.md - Steam-ID resolution](SETUP.md#a-steam-id-resolution-server-exe-mysql-provider).

> Since 1.0.4 there is **no global MySQL tab in Settings**. The MySQL
> provider is configured per server in the Add/Edit-Server dialog on the
> **Steam-ID** tab.

### 3.1 MySQL provider per server

1. Server-Edit dialog -> **Steam-ID** tab -> set Provider to **mysql**,
   enter Host / Port / Database / User and the **password env-var
   suffix** (empty = `RH_MYSQL_PASSWORD`, `_DE` = `RH_MYSQL_PASSWORD_DE`,
   etc.). The full env-var name is shown live below the suffix field.
   `[x]` `[-]` `[?]`
   > Question:
2. **Test connection** -> green check. (Password is read from the env-var
   on every connect; no field in the UI.)
   `[x]` `[-]` `[?]`
   > Question:

### 3.2 Verify on the server side

Run on your Epoch database:

```sql
SELECT * FROM player_login_log ORDER BY LoginTime DESC LIMIT 10;
```

1. Rows appear on every player login (PlayerUid + Name + IP + LoginTime).
   `[x]` `[-]` `[?]`
   > Question:

### 3.3 Steam-ID in the Player DB

1. After a player logged in (with the SQF hook active), Player DB shows
   a Steam-ID for that player within ~5-30s.
   `[x]` `[-]` `[?]`
   > Question:

### 3.4 Steam profile lookup

1. Settings -> **Steam** -> enter your Steam Web API key.
   `[x]` `[-]` `[?]`
   > Question:
2. Player DB -> right-click player with Steam-ID -> **Refresh Steam
   profile**. VAC / Game-Ban status updates.
   `[x]` `[-]` `[?]`
   > Question:

---

## 4. PlayerDB Export (for client admins)

### 4.1 Export

1. Player DB tab -> **Export...** -> pick a target file (JSON).
   `[x]` `[-]` `[?]`
   > Question:
2. File contains players + Steam profiles (open in a text editor to
   sanity-check).
   `[x]` `[-]` `[?]`
   > Question:
3. Hand the JSON to your client admins. They import it via Player DB
   tab -> **Import...** in their own RHD-RCON.
   `[x]` `[-]` `[?]`
   > Question:

---

## 5. IP Ban

ArmA 2 + BattlEye does not support IP bans over RCon. RHD-RCON enforces
them itself: an in-tool IP-ban table, checked on every player refresh.

### 5.1 Kick message

1. Settings -> **IP Ban** -> set Kick message (max 120 chars). Keep it
   generic ("rule violation"), do not say "IP-banned".
   `[x]` `[-]` `[?]`
   > Question:

### 5.2 Add an IP ban

1. Player DB tab -> right-click a player with a known IP -> **IP-ban**.
   Enter an optional comment.
   `[x]` `[-]` `[?]`
   > Question:
2. IP appears in the IP-Ban tab.
   `[x]` `[-]` `[?]`
   > Question:

### 5.3 Enforcement

1. Have that player reconnect. On the next refresh tick (5-10s) they
   are kicked with the configured message.
   `[x]` `[-]` `[?]`
   > Question:
2. IP-Ban tab still shows the entry (it is not auto-removed on kick).
   `[x]` `[-]` `[?]`
   > Question:

### 5.4 Remove IP ban

1. Player DB -> right-click -> **Remove IP ban**. Player can connect
   again on the next attempt.
   `[x]` `[-]` `[?]`
   > Question:

---

## 6. Country filter (since 1.0.5)

Connect-time filter by ISO country code (allow- or blocklist). Settings
are global; the per-server **on/off** switch and **kick message** live
in the Server-Edit dialog. The **Whitelist** (section 8) bypasses this
filter on a per-player basis.

### 6.1 Configure the filter

1. Settings -> **Country Filter** -> set Mode to **block**, add a
   country code you can test with (e.g. `DE`) to the country list,
   and set a kick message. Save.
   `[x]` `[-]` `[?]`
   > Question:
2. Server-Edit dialog -> **Filters** tab -> the "Country filter active
   for this server" checkbox is on by default and the per-server
   "Country kick message" defaults to empty (falls back to the global
   message).
   `[x]` `[-]` `[?]`
   > Question:

### 6.2 Verify a kick

1. A player connecting from a matching country (here: `DE`) is kicked
   on the next refresh tick with the configured message.
   `[x]` `[-]` `[?]`
   > Question:
2. **Player DB** -> right-click the player -> **Player Log...** ->
   **Actions** shows a `Country-Kick` entry with detail
   `Country: <code> | Mode: <off/allow/block> | Liste: ...`.
   `[x]` `[-]` `[?]`
   > Question:

### 6.3 Per-server override

1. Open one server's Edit dialog -> **Filters** tab -> uncheck the
   "Country filter active for this server" box and save.
   `[x]` `[-]` `[?]`
   > Question:
2. On that server, the same player can now connect. Other servers (with
   the toggle still on) continue to kick.
   `[x]` `[-]` `[?]`
   > Question:

### 6.4 Live wirksamkeit

1. Change the country list / mode / kick message in Settings and save -
   the change applies to any running session **without reconnect**.
   `[x]` `[-]` `[?]`
   > Question:

---

## 7. Name filter (since 1.0.5)

Connect-time filter on the player name. Three strategies, evaluated in
order with early exit:

1. **Pattern blacklist** (CSV, case-insensitive substring match) - e.g.
   `admin,discord.gg`.
2. **Allowed character set** (Ascii / Latin / LatinCyrillic / Any) -
   first non-allowed char kicks with reason `cyrillic` / `asian` /
   `arabic` / `hebrew` / `non-latin`.
3. **Symbol-spam ratio** - max percentage of special chars in the name
   (100% = off).

> **Important:** the whitelist does **not** bypass the name filter.
> Even whitelisted players (including admins) must have readable names.

### 7.1 Configure the filter

1. Settings -> **Name Filter** -> set Allowed character set to **Latin**,
   add `admin` to the forbidden patterns list, set a kick message. Save.
   `[x]` `[-]` `[?]`
   > Question:
2. Server-Edit dialog -> **Filters** tab -> "Name filter active for this
   server" is on by default and "Name kick message" defaults to empty.
   `[x]` `[-]` `[?]`
   > Question:

### 7.2 Cyrillic / non-Latin kick

1. A test player with a cyrillic name (e.g. `Витя`) connects -> gets
   kicked on the next refresh tick.
   `[x]` `[-]` `[?]`
   > Question:
2. Player Log -> **Actions** shows a `Name-Kick` entry with detail
   `Reason: cyrillic` (or `asian`, `arabic`, `hebrew`, `non-latin` for
   other scripts).
   `[x]` `[-]` `[?]`
   > Question:

### 7.3 Pattern kick

1. A player named `Admin Bob` connects -> kicked with reason
   `pattern 'admin'`.
   `[x]` `[-]` `[?]`
   > Question:
2. Whitelisted (see section 8) version of the same player **still gets
   kicked** - the name filter is absolute.
   `[x]` `[-]` `[?]`
   > Question:

---

## 8. Whitelist (since 1.0.5)

Whitelisted players bypass the **country filter** (not the name filter).
Match is by GUID **OR** SteamID, so partial info is enough.

### 8.1 The Whitelist tab

1. Left tab **Whitelist** (next to **Player DB**). Grid shows
   GUID / SteamID / Note / AddedAt.
   `[x]` `[-]` `[?]`
   > Question:

### 8.2 Add an entry - four ways

1. **Whitelist tab -> Add** -> empty dialog, fill in GUID and/or
   SteamID + a note. Save -> appears in the grid.
   `[x]` `[-]` `[?]`
   > Question:
2. **Settings -> Country Filter -> "Add whitelist entry..."** -> opens
   the same empty dialog.
   `[x]` `[-]` `[?]`
   > Question:
3. **Players view -> right-click a player -> "Add to whitelist..."** ->
   dialog opens pre-filled with that player's GUID / SteamID / name.
   `[x]` `[-]` `[?]`
   > Question:
4. **Player DB -> right-click a player -> "Add to whitelist..."** ->
   same pre-filled dialog.
   `[x]` `[-]` `[?]`
   > Question:

### 8.3 Whitelist indicator

1. Players view and Player DB both show a **star** column. Whitelisted
   players have a filled star.
   `[x]` `[-]` `[?]`
   > Question:

### 8.4 Bypass + Audit log

1. Add a whitelist entry for a player whose country would normally kick
   them. The player connects and **stays** (no country kick).
   `[x]` `[-]` `[?]`
   > Question:
2. Player Log -> **Actions** shows `Whitelist-Add` (and `Whitelist-Remove`
   after removal) entries with note + admin name (only logged if a
   GUID is present on the entry).
   `[x]` `[-]` `[?]`
   > Question:

---

## 9. Scheduled server restarts

A scheduled restart = scheduled shutdown (RHD-RCON does this) + restart
trigger (your `.ps1` / `.bat` does this via the watchdog). See
[SETUP.md - Scheduled server restarts](SETUP.md#b-scheduled-server-restarts-server-exe).

### 9.1 Configure process + restart script

1. Server-Edit dialog -> **Watchdog** tab -> set **ServerProcessName**
   (e.g. `arma2oaserver.exe`), **RestartScriptPath** (full path to your
   start `.ps1` or `.bat`) and enable **Process monitor active**.
   `[x]` `[-]` `[?]`
   > Question:
2. **Test script** button starts the script once. ArmA server comes up.
   `[x]` `[-]` `[?]`
   > Question:

### 9.2 Watchdog (process crash)

1. With the server running, kill the ArmA process manually (Task Manager
   -> End Task).
   `[x]` `[-]` `[?]`
   > Question:
2. Within ~20s (next watchdog tick) the restart script runs and the
   server comes back up.
   `[x]` `[-]` `[?]`
   > Question:
3. Kill the process again within 120s -> watchdog does **not** restart
   (cooldown). After 120s the next kill triggers a restart again.
   `[x]` `[-]` `[?]`
   > Question:

### 9.3 Scheduled shutdown

1. Server tab -> **Scheduler** -> add a **Shutdown** entry with warn
   minutes (e.g. `30,15,5,1`) and a daily time a few minutes from now.
   `[x]` `[-]` `[?]`
   > Question:
2. Warn broadcasts appear in chat at the configured minutes.
   `[x]` `[-]` `[?]`
   > Question:
3. 3 minutes before shutdown: server locks (`#lock`) and broadcasts
   "server restarting".
   `[x]` `[-]` `[?]`
   > Question:
4. At shutdown time: ArmA process is killed (`Process.Kill`), watchdog
   sees the gap on the next tick and runs the restart script.
   `[x]` `[-]` `[?]`
   > Question:
5. The Scheduler grid `Last run` column updates live with the new
   timestamp (format `yyyy-MM-dd HH:mm:ss`) **without** switching away
   and back to the tab.
   `[x]` `[-]` `[?]`
   > Question:

---

## 10. Daily ban-status sync

The tool runs a background sync between RHD-RCON DB and BattlEye
`bans.txt` once a day. Default 04:00.

1. Settings -> **General** -> check the **Ban sync time**. Default
   04:00 is usually fine for a server PC that runs 24/7.
   `[x]` `[-]` `[?]`
   > Question:
2. After the configured time has passed, `logs/app-YYYYMMDD.log` shows
   a sync line ("Ban sync: ...").
   `[x]` `[-]` `[?]`
   > Question:

---

## 11. Logs to look at if something goes wrong

- App log: `logs/app-YYYYMMDD.log` next to the EXE - always on.
- Debug log: `logs/debug/RHD-RCON_Debug_YYYY-MM-DD.log` - only if enabled.
- Crash log: `crash.log` next to the EXE - on unhandled exceptions.
- Restart script output: whatever your script logs (PowerShell
  `Start-Transcript` is handy).

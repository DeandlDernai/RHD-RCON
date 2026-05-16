# Test Plan - Server Mode

Workflow walkthrough for **server-mode admins** (RHD-RCON runs on the
same Windows machine as your DayZ Epoch server, with the server process,
restart scripts and optionally MySQL available locally).

> **Prerequisite:** run through [TESTPLAN.md](TESTPLAN.md) first - it
> covers everything that also exists in client mode (player list, kick,
> ban, ban list, ban sync, player DB, scheduled chat messages, commands).
> This plan only covers the **server-mode-only** features on top.

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

- TESTPLAN.md completed (you can connect, kick, ban, see players)
- RHD-RCON running **as Administrator** on the server PC (needed so the
  watchdog can start your restart script)
- Server-mode active (first-run wizard set to **Server**, or switched
  later in Settings)

---

## 1. Switching to server mode

If you started in client mode, switch first.

### 1.1 Mode switch

1. Settings -> **General** -> set mode to **Server**. Restart the tool
   if prompted.
   `[x]` `[-]` `[?]`
   > Question:
2. After restart: Settings now shows the server-mode tabs (**MySQL**,
   **IP Ban**, server-side scheduler entries, ...).
   `[x]` `[-]` `[?]`
   > Question:

---

## 2. Player DB live writes

In server mode the Player DB is populated automatically from the live
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
[SETUP.md - Steam-ID resolution](SETUP.md#a-steam-id-resolution-server-mode).

### 3.1 MySQL connection

1. Settings -> **MySQL** -> enter Host / Port / Database / User.
   Password is read from `RH_MYSQL_PASSWORD` env var, no field in the UI.
   `[x]` `[-]` `[?]`
   > Question:
2. **Test connection** -> green check.
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

## 6. Scheduled server restarts

A scheduled restart = scheduled shutdown (RHD-RCON does this) + restart
trigger (your `.ps1` / `.bat` does this via the watchdog). See
[SETUP.md - Scheduled server restarts](SETUP.md#b-scheduled-server-restarts-server-mode).

### 6.1 Configure process + restart script

1. Server tab -> **Process monitoring** -> set **ServerProcessName**
   (e.g. `arma2oaserver.exe`) and **RestartScriptPath** (full path to
   your start `.ps1` or `.bat`).
   `[x]` `[-]` `[?]`
   > Question:
2. **Test script** button starts the script once. ArmA server comes up.
   `[x]` `[-]` `[?]`
   > Question:

### 6.2 Watchdog (process crash)

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

### 6.3 Scheduled shutdown

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

---

## 7. Daily ban-status sync

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

## 8. Logs to look at if something goes wrong

- App log: `logs/app-YYYYMMDD.log` next to the EXE - always on.
- Debug log: `logs/debug/RHD-RCON_Debug_YYYY-MM-DD.log` - only if enabled.
- Crash log: `crash.log` next to the EXE - on unhandled exceptions.
- Restart script output: whatever your script logs (PowerShell
  `Start-Transcript` is handy).

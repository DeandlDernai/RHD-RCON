# Test Plan - Client EXE

Workflow walkthrough for **Client-EXE admins** (you connect to someone
else's server via RCon). Go through the sections in order on a fresh
install. Should take about 15-20 minutes.

> Running the **Server EXE** on your own server PC? Use this plan first,
> then continue with [TESTPLAN_SERVER.md](TESTPLAN_SERVER.md) for the
> server-only features (scheduler, watchdog, IP ban, MySQL Steam-ID
> resolution).

## How to use this plan

Each test step has three checkboxes. Tick exactly one:

- `[x]` - **works** as described
- `[-]` - **does not work** / unexpected behavior
- `[?]` - **question / unclear** - write your question on the line below

When you report back (GitHub Issue or Discord), please reference the
section number (e.g. "2.3 step 4 was [-]: ...") so I know exactly which
step you mean. For `[-]` a short note plus a snippet from
`logs/app-YYYYMMDD.log` helps a lot.

## Prerequisites

- `RHD-RCON-Client_v1.0.x.exe` (~62 MB, single-file, no installer)
- A BattlEye RCon endpoint (Host / Port / Password) reachable from your PC

---

## 1. First start

### 1.1 Wizard

1. Double-click `RHD-RCON-Client_v1.0.x.exe`.
   `[x]` `[-]` `[?]`
   > Question:
2. **First-run wizard** appears. Enter an Admin name, pick a theme
   (Dark/Light).
   `[x]` `[-]` `[?]`
   > Question:
3. Close the wizard - main window appears.
   `[x]` `[-]` `[?]`
   > Question:

### 1.2 Add a server

1. Top right: **+ Add server**.
   `[x]` `[-]` `[?]`
   > Question:
2. Fill in Name, Host, Port, Password and optionally Tab color.
   `[x]` `[-]` `[?]`
   > Question:
3. **Test connect** - shows a green check.
   `[x]` `[-]` `[?]`
   > Question:
4. **Save** - new server tab appears on the left.
   `[x]` `[-]` `[?]`
   > Question:

### 1.3 Connect

1. Click the new server tab on the left (or click **Connect** in the
   header if Auto-Connect is off).
   `[x]` `[-]` `[?]`
   > Question:
2. Status dot turns green, player list loads.
   `[x]` `[-]` `[?]`
   > Question:

---

## 2. Player management

### 2.1 View players

1. Select a server tab on the left -> **Overview** tab. Table shows all
   currently connected players.
   `[x]` `[-]` `[?]`
   > Question:
2. Auto-refresh keeps the list current every few seconds.
   `[x]` `[-]` `[?]`
   > Question:

### 2.2 Kick a player

1. Right-click a player -> **Kick**.
   `[x]` `[-]` `[?]`
   > Question:
2. Enter a reason (max 120 chars) or leave empty, confirm - player is
   kicked.
   `[x]` `[-]` `[?]`
   > Question:

### 2.3 Ban a player

1. Right-click -> **Ban...**.
   `[x]` `[-]` `[?]`
   > Question:
2. Set Duration in minutes (0 = permanent) and a Reason.
   `[x]` `[-]` `[?]`
   > Question:
3. Optional: tick **Sync to all servers** to apply the ban to all
   connected servers.
   `[x]` `[-]` `[?]`
   > Question:
4. Click **Ban** - server status dot briefly turns blue (ban sync
   running) and back to green.
   `[x]` `[-]` `[?]`
   > Question:

### 2.4 Private message

1. Right-click -> **PM...**. ComboBox lists all online players.
   `[x]` `[-]` `[?]`
   > Question:
2. Type message + Send. Dialog stays open for follow-up messages.
   `[x]` `[-]` `[?]`
   > Question:

---

## 3. Ban list management

### 3.1 Bans tab

1. Server tab -> **Bans** (inner tab). Shows the BE ban list with
   Number / GUID / Reason / Time.
   `[x]` `[-]` `[?]`
   > Question:

### 3.2 Unban

1. Select an entry -> **Unban**. Ban is removed from BE and from the
   local DB.
   `[x]` `[-]` `[?]`
   > Question:

### 3.3 Sync ban status

1. **Single server:** right-click the server tab on the left -> **Sync
   ban status (this server)**. Status dot turns blue, then green.
   `[x]` `[-]` `[?]`
   > Question:
2. **All connected servers:** Player DB tab on the left -> toolbar button
   **Sync ban status (all servers)**. Info dialog at the end lists which
   servers got synced and which were offline.
   `[x]` `[-]` `[?]`
   > Question:

### 3.4 Multi-server unban

1. Player DB tab -> right-click on a player -> **Unban...**. Dropdown to
   pick a server, or **Apply to all connected servers** to unban on every
   connected server at once.
   `[x]` `[-]` `[?]`
   > Question:

---

## 4. Player DB

### 4.1 Search the DB

1. Left tab **Player DB**. Search field: matches Name / GUID / IP /
   Comment. **Load All** shows every stored player.
   `[x]` `[-]` `[?]`
   > Question:

### 4.2 Player details

1. Right-click an entry -> **Player Log...** opens tabs: **Actions**,
   **Server Log**, **Ban Status**.
   `[x]` `[-]` `[?]`
   > Question:

### 4.3 Add a comment

1. Right-click -> **Comment...**. Multi-line allowed (stored as one line
   with ` | ` separator).
   `[x]` `[-]` `[?]`
   > Question:

### 4.4 Import a PlayerDB JSON (from a server admin)

In the Client EXE the Player DB starts empty. SteamIDs and cross-server
ban data come from a JSON export your server admin sends you.

1. Player DB tab -> **Import...**. Pick the JSON file from the server.
   `[x]` `[-]` `[?]`
   > Question:
2. Player DB is merged: local comments stay, SteamIDs + Steam bans get
   pulled in.
   `[x]` `[-]` `[?]`
   > Question:
3. Optional: add your own **Steam Web API key** in Settings -> Steam to
   do your own Steam profile refreshes.
   `[x]` `[-]` `[?]`
   > Question:

---

## 5. Scheduled chat messages

1. Server tab -> **Scheduler** tab.
   `[x]` `[-]` `[?]`
   > Question:
2. **Add** -> message text (e.g. rule reminder), repeat mode (interval
   or daily times).
   `[x]` `[-]` `[?]`
   > Question:
3. Message is sent as `say -1 <message>` at the configured time.
   `[x]` `[-]` `[?]`
   > Question:

### 5.1 Chat view - smart auto-scroll (since 1.0.5)

1. Server tab -> **Chat** tab. With auto-refresh on and a new chat line
   arriving, the view scrolls to keep the newest line visible.
   `[x]` `[-]` `[?]`
   > Question:
2. Scroll up by ~100px to read older lines. When the next chat line
   arrives, the scroll position stays put (no jump to the bottom).
   `[x]` `[-]` `[?]`
   > Question:
3. Scroll back to the bottom. Auto-scroll resumes automatically when
   the next line arrives.
   `[x]` `[-]` `[?]`
   > Question:

### 5.2 Chat view - select text + filters

1. Click into a chat line and drag to select text. Ctrl+C copies it to
   the clipboard.
   `[x]` `[-]` `[?]`
   > Question:
2. Above the chat list, the per-type filter checkboxes (Global / Side /
   Direct / Vehicle / Group / Command / Admin) hide / show their lines
   live without reconnecting.
   `[x]` `[-]` `[?]`
   > Question:
3. In the broadcast input, **Enter** sends, **Shift+Enter** adds a
   newline. Same in the PM dialog.
   `[x]` `[-]` `[?]`
   > Question:

---

## 6. Running commands

1. Server tab -> **Commands** tab. Buttons available: **Lock / Unlock**,
   **Load Scripts**, **Load Bans**, **Shutdown**.
   `[x]` `[-]` `[?]`
   > Question:
2. **Custom Command** field accepts a free-form RCon command + Execute.
   `[x]` `[-]` `[?]`
   > Question:
3. Same commands also reachable via **right-click on the server tab on
   the left**.
   `[x]` `[-]` `[?]`
   > Question:

Notes: `loadScripts` does not reliably reload `scripts.txt` in ArmA 2 OA
(a server restart is needed for filter changes). `loadBans` reliably
reloads `bans.txt`. **Shutdown** in the Client EXE sends RCon `#shutdown` -
the ArmA process may not always exit cleanly, this is an ArmA limitation.

---

## 7. Settings overview

Settings are reached via the gear icon top-right. See [SETUP.md](SETUP.md)
for the full configuration reference. Quick pointers for the Client EXE:

- **General** - **Client admin name** (used for manual chat / PM / kick /
  ban), **Server admin name** (used for automated actions - visible here
  too, but has no effect since the Client EXE has no scheduler, watchdog
  or connect filters to run it), **Debug log** checkbox toggles file-only
  debug logging, theme.
- **Geolocation** - export / import the IP->country cache.
- **Steam** - your Steam Web API key (optional, for VAC / Game-Ban
  lookups on imported players).

Tabs that only exist in the Server EXE (Country Filter, Name Filter, IP
Ban, Watchdog) simply are not part of the Client EXE - there is nothing
to hide or reveal, they were never built in.

> Note: the standalone "Debug log" tab from earlier versions has been
> removed. Debug data is still written to
> `logs/debug/RHD-RCON_Debug_YYYY-MM-DD.log` when the **Debug log**
> checkbox is on. See [9. Troubleshooting](#9-troubleshooting) for the
> log paths.

---

## 8. Multi-server tips

- Multiple server tabs at the same time work fine.
- Status dots per tab on the left:
  - **Green** = connected
  - **Grey** = disconnected
  - **Blue** = ban sync running (non-blocking, other tabs stay usable)
- Each connected tab shows an **online-player-count pill** in the accent
  color next to the tab name. After a player connects or disconnects, a
  short-lived `+1` / `-2` marker appears for a few seconds so you can
  spot activity at a glance across many tabs.

---

## 9. Troubleshooting

### Connect fails with "Login Timeout"

- Check Host / Port / Password.
- The tool internally retries the login packet up to 3 times (UDP can
  drop packets). If all 3 fail, the server is genuinely unreachable.

### Player does not show up in the list

- BE takes ~1-3s after connect to assign a GUID (`Verified GUID` event).
- The tool refreshes 500ms and 3000ms after the Verified event - usually
  the player is there by then.
- Otherwise: the auto-refresh tick (5-10s) catches it.

### Reading the logs

- App log: `logs/app-YYYYMMDD.log` next to the EXE - always on.
- Debug log: `logs/debug/RHD-RCON_Debug_YYYY-MM-DD.log` - only if enabled.
- Crash log: `crash.log` next to the EXE - on unhandled exceptions.

### "BE Master" console noise

The BattlEye master / cloud status pings used to flood the chat and
console views in earlier versions. Since 1.0.5 these lines are filtered
out at parse time, so chat stays readable. If you still see them, please
report the exact text in a GitHub issue - it means a new variant has
shown up.

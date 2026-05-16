# Server-side integration for RHD-RCON

This folder contains everything you need to enable **Steam-ID resolution**
in RHD-RCON server mode. With these pieces deployed, your DayZ Epoch
server writes one row per player login into a MySQL table, and RHD-RCON
reads that table to map BattlEye GUIDs to Steam-IDs (PlayerUID).

Without this integration, RHD-RCON still works fine - Steam-ID columns
stay empty and VAC / Game-Ban lookups via the Steam Web API have nothing
to query.

## What's in this folder

| File | Purpose |
|---|---|
| `player_login_log_schema.sql` | MySQL table + optional auto-cleanup event |
| `shared-conf.ini.snippet` | extDB3 protocol block - append to your `shared-conf.ini` |
| `rh_logPlayerLogin.sqf` | SQF hook that writes the login row |
| `server_functions.sqf.snippet` | One-line compile registration |
| `server_playerLogin.sqf.snippet` | One-line call site |

## Prerequisites

- DayZ Epoch server (1.0.7.x) with
  **[extDB3](https://github.com/DeandlDernai/extDB)** running and the
  shared database configured. extDB3 is the SQF<->MySQL bridge used
  here. The linked repo is my own fork - the original upstream
  (Bitbucket) is no longer reachable, so this fork is the one
  practical source today. If you do not have extDB3 set up yet,
  install it from there.
- MySQL access with permission to create a table in your Epoch database.
- Ability to repack `dayz_server.pbo` (you do this already if you run an
  Epoch server).

## Step 1 - create the MySQL table

On the MySQL server that holds your Epoch schema:

```bash
mysql -u root -p <your_database> < player_login_log_schema.sql
```

Or paste the SQL from the file directly into a MySQL client. The optional
cleanup event at the bottom requires the MySQL event scheduler to be
enabled globally - run once if you want it:

```sql
SET GLOBAL event_scheduler = ON;
```

Verify the table exists:

```sql
SHOW CREATE TABLE player_login_log;
```

## Step 2 - register the extDB3 protocol

Open your `@extDB/sql_custom/shared-conf.ini` and append the contents of
`shared-conf.ini.snippet` to the end of the file. The `[Default]` block
at the top of the file stays untouched.

Restart your server (or reload extDB3) so the new protocol block is
picked up.

## Step 3 - drop the SQF hook into dayz_server

1. Copy `rh_logPlayerLogin.sqf` into `dayz_server\compile\custom\`.
   (Create the `custom\` folder if you do not have it yet.)
2. Open `dayz_server\init\server_functions.sqf` and add the line from
   `server_functions.sqf.snippet` next to the other compile registrations
   (roughly around line 100 in stock Epoch, wherever the other custom
   `rh_*` lines live).
3. Open `dayz_server\compile\server_playerLogin.sqf` and add the line
   from `server_playerLogin.sqf.snippet` right after the
   `dayz_recordLogin` call (roughly around line 193 in stock Epoch).
4. Repack `dayz_server.pbo` and deploy it.

## Step 4 - verify

After a player logs in, your server RPT should show:

```
[LOGIN_LOG] PlayerName (UID:76561198... / CID:12345) login logged.
```

And in MySQL:

```sql
SELECT * FROM player_login_log ORDER BY LoginTime DESC LIMIT 10;
```

If rows appear here, RHD-RCON can resolve Steam-IDs. Continue with
**Settings -> MySQL** in the tool itself (see
[SETUP.md](../SETUP.md#a-steam-id-resolution-server-mode) for the env
var + connection setup).

## Troubleshooting

**`[LOGIN_LOG]` does not appear in the RPT.**
The SQF hook is not being called. Check:
- `dayz_server.pbo` was actually re-packed and deployed.
- `server_functions.sqf` contains the `rh_logPlayerLogin = compile ...`
  line and it points at the file you just dropped in.
- `server_playerLogin.sqf` contains the `call rh_logPlayerLogin;` line
  in the login flow.

**`[LOGIN_LOG]` appears but no row in the table.**
- extDB3 did not load the new INI block - restart the server fully.
- The DB ID in the SQF (`[1, "sharedWrite", ...]`) does not match your
  `extdb3-conf.ini` layout. Open the SQF and change the `1` to whatever
  ID your shared DB uses.
- The `[playerLoginLog]` block has a typo - re-check against the snippet.
- Check `@extDB\logs\` for extDB3 errors right after the next login.

**`[LOGIN_LOG ERROR] invalid parameters`.**
`_playerName` or `_playerUID` is empty. Make sure the call site is placed
AFTER the player record is built (i.e. AFTER the line that sets
`_playerName` / `_playerID` / `_charID`).

**RHD-RCON still shows empty Steam-IDs.**
- The tool retries the MySQL lookup 10 times in 60-second intervals
  (total ~10 minutes) before giving up. After "give up" the Steam-ID is
  retried only on the player's next login.
- Right-click a player -> **Refresh Steam profile** forces a fresh
  lookup.
- Players who never logged in since you deployed the hook have no row,
  so they cannot be auto-resolved. They need to join once.

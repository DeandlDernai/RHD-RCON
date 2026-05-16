/*
	DayZ Epoch - Server: log player login into MySQL

	Writes Name, SteamUID, CharacterID and login timestamp into the
	`player_login_log` table via extDB3 (protocol [playerLoginLog]).

	Used by RHD-RCON (server mode) to resolve BattlEye GUID -> Steam-ID.

	Called from server_playerLogin.sqf after a successful login.

	Parameters:
	_this select 0: STRING - player name
	_this select 1: STRING - PlayerUID (getPlayerUID)
	_this select 2: STRING - character ID

	Call site (server_playerLogin.sqf, after the player record is built):
	[_playerName, _playerID, str _charID] call rh_logPlayerLogin;

	NOTE: This file uses `EXTDB_fnc_APICall` with DB ID `1`. If your
	extdb3-conf.ini exposes the shared DB under a different ID, adjust the
	`1` below accordingly.
*/

local _playerName = _this select 0;
local _playerUID  = _this select 1;
local _charID     = _this select 2;

if (_playerName == "" || _playerUID == "") exitWith {
	diag_log format["[LOGIN_LOG ERROR] invalid parameters: Name=%1 UID=%2", _playerName, _playerUID];
};

local _query = format["playerLoginLog:%1:%2:%3", _playerName, _playerUID, _charID];
local _null = [1, "sharedWrite", _query] call EXTDB_fnc_APICall;

diag_log format["[LOGIN_LOG] %1 (UID:%2 / CID:%3) login logged.", _playerName, _playerUID, _charID];

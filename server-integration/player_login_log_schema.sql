-- ============================================================================
-- DayZ Epoch - player_login_log
-- Used by RHD-RCON (server mode) to resolve BattlEye GUID -> Steam-ID.
-- One row is written on every successful player login (server_playerLogin.sqf).
-- Auto-cleanup: rows older than 30 days are deleted daily by the event below.
-- ============================================================================

CREATE TABLE IF NOT EXISTS `player_login_log` (
  `id`          INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `PlayerName`  VARCHAR(64)   NOT NULL DEFAULT '',
  `PlayerUID`   VARCHAR(32)   NOT NULL DEFAULT '',
  `CharacterID` VARCHAR(32)   NOT NULL DEFAULT '',
  `LoginTime`   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_playeruid` (`PlayerUID`),
  INDEX `idx_logintime` (`LoginTime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- ============================================================================
-- Optional: auto-cleanup via MySQL event scheduler. Requires the event
-- scheduler to be enabled globally (once on the MySQL server):
--   SET GLOBAL event_scheduler = ON;
-- Skip this block if you do not want auto-cleanup - a few thousand rows do
-- not hurt performance.
--
-- Run the DROP EVENT statement separately from the CREATE EVENT statement
-- if your SQL client does not split multi-statement scripts cleanly.
-- ============================================================================

DROP EVENT IF EXISTS `evt_player_login_log_cleanup`;

CREATE EVENT `evt_player_login_log_cleanup`
ON SCHEDULE EVERY 1 DAY
STARTS (CURRENT_DATE + INTERVAL 1 DAY + INTERVAL 3 HOUR)
ON COMPLETION NOT PRESERVE
ENABLE
COMMENT 'Deletes player_login_log rows older than 30 days'
DO BEGIN
    DELETE FROM `player_login_log`
    WHERE `LoginTime` < DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 30 DAY);
END

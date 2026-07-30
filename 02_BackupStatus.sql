/* 02_BackupStatus.sql | Author: Ganesh Chittalwar
   Purpose: Last Full/Diff/Log backup per online database with simple age flags.
   Adjust SLA thresholds before client use.
*/
SET NOCOUNT ON;

WITH B AS
(
    SELECT database_name,
           MAX(CASE WHEN type='D' THEN backup_finish_date END) AS LastFullBackup,
           MAX(CASE WHEN type='I' THEN backup_finish_date END) AS LastDiffBackup,
           MAX(CASE WHEN type='L' THEN backup_finish_date END) AS LastLogBackup
    FROM msdb.dbo.backupset
    WHERE is_copy_only = 0
    GROUP BY database_name
)
SELECT
    d.name AS DatabaseName,
    d.recovery_model_desc,
    b.LastFullBackup,
    DATEDIFF(HOUR,b.LastFullBackup,GETDATE()) AS FullBackupAgeHours,
    b.LastDiffBackup,
    b.LastLogBackup,
    CASE
      WHEN b.LastFullBackup IS NULL THEN 'CRITICAL - No full backup history'
      WHEN DATEDIFF(HOUR,b.LastFullBackup,GETDATE()) > 24 THEN 'WARNING - Full backup > 24h'
      ELSE 'OK'
    END AS FullBackupStatus,
    CASE
      WHEN d.recovery_model_desc = 'FULL' AND b.LastLogBackup IS NULL THEN 'CHECK - No log backup history'
      WHEN d.recovery_model_desc = 'FULL' AND DATEDIFF(MINUTE,b.LastLogBackup,GETDATE()) > 60 THEN 'WARNING - Log backup > 60m'
      WHEN d.recovery_model_desc <> 'FULL' THEN 'N/A'
      ELSE 'OK'
    END AS LogBackupStatus
FROM sys.databases d
LEFT JOIN B b ON b.database_name=d.name
WHERE d.database_id > 4 AND d.state_desc='ONLINE'
ORDER BY d.name;

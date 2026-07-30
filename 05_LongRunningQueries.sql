/* 05_LongRunningQueries.sql | Active requests running >= 30 seconds */
SET NOCOUNT ON;
DECLARE @ThresholdSeconds int = 30;

SELECT
    r.session_id,
    DB_NAME(r.database_id) AS DatabaseName,
    s.login_name,s.host_name,s.program_name,
    r.status,r.command,
    CAST(r.total_elapsed_time/1000.0 AS decimal(18,1)) AS ElapsedSeconds,
    r.cpu_time AS CpuMs,
    r.logical_reads,r.reads,r.writes,
    r.wait_type,r.wait_time,r.blocking_session_id,
    t.text AS BatchText,
    SUBSTRING(t.text,(r.statement_start_offset/2)+1,
      ((CASE r.statement_end_offset WHEN -1 THEN DATALENGTH(t.text) ELSE r.statement_end_offset END-r.statement_start_offset)/2)+1) AS CurrentStatement
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions s ON s.session_id=r.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.session_id <> @@SPID
  AND r.total_elapsed_time >= @ThresholdSeconds*1000
ORDER BY r.total_elapsed_time DESC;

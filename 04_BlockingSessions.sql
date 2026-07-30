/* 04_BlockingSessions.sql | Current blocking requests */
SET NOCOUNT ON;

SELECT
    r.session_id AS BlockedSession,
    r.blocking_session_id AS BlockingSession,
    DB_NAME(r.database_id) AS DatabaseName,
    r.status,
    r.command,
    r.wait_type,
    r.wait_time AS WaitTimeMs,
    r.wait_resource,
    r.cpu_time AS CpuMs,
    r.total_elapsed_time AS ElapsedMs,
    s.login_name,
    s.host_name,
    s.program_name,
    SUBSTRING(t.text,(r.statement_start_offset/2)+1,
      ((CASE r.statement_end_offset WHEN -1 THEN DATALENGTH(t.text) ELSE r.statement_end_offset END-r.statement_start_offset)/2)+1) AS CurrentStatement
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions s ON r.session_id=s.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE r.blocking_session_id <> 0
ORDER BY r.wait_time DESC;

-- Root blockers participating in blocking
SELECT DISTINCT
    s.session_id AS RootBlockingSession,
    s.login_name,s.host_name,s.program_name,s.status,
    txt.text AS LastSubmittedSQL
FROM sys.dm_exec_sessions s
LEFT JOIN sys.dm_exec_connections c ON c.session_id=s.session_id
OUTER APPLY sys.dm_exec_sql_text(c.most_recent_sql_handle) txt
WHERE s.session_id IN
(SELECT blocking_session_id FROM sys.dm_exec_requests WHERE blocking_session_id <> 0)
AND NOT EXISTS
(SELECT 1 FROM sys.dm_exec_requests r2 WHERE r2.session_id=s.session_id AND r2.blocking_session_id<>0);

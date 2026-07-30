/* 08_WaitStatistics.sql | Top cumulative waits since SQL Server startup.
   Baseline/delta analysis is preferred for real tuning.
*/
SET NOCOUNT ON;

WITH W AS
(
 SELECT wait_type,waiting_tasks_count,wait_time_ms,signal_wait_time_ms,
        wait_time_ms-signal_wait_time_ms AS resource_wait_time_ms
 FROM sys.dm_os_wait_stats
 WHERE wait_type NOT IN
 ('SLEEP_TASK','SLEEP_SYSTEMTASK','SQLTRACE_BUFFER_FLUSH','WAITFOR','LAZYWRITER_SLEEP','XE_TIMER_EVENT','XE_DISPATCHER_WAIT','BROKER_TO_FLUSH','BROKER_TASK_STOP','CLR_AUTO_EVENT','CLR_MANUAL_EVENT','DISPATCHER_QUEUE_SEMAPHORE','FT_IFTS_SCHEDULER_IDLE_WAIT','HADR_FILESTREAM_IOMGR_IOCOMPLETION','LOGMGR_QUEUE','REQUEST_FOR_DEADLOCK_SEARCH','SP_SERVER_DIAGNOSTICS_SLEEP','SQLTRACE_INCREMENTAL_FLUSH_SLEEP')
 AND wait_time_ms > 0
), T AS (SELECT SUM(wait_time_ms) total_wait_ms FROM W)
SELECT TOP (25)
    W.wait_type,W.waiting_tasks_count,W.wait_time_ms,W.resource_wait_time_ms,W.signal_wait_time_ms,
    CAST(100.0*W.wait_time_ms/NULLIF(T.total_wait_ms,0) AS decimal(9,2)) AS WaitPct
FROM W CROSS JOIN T
ORDER BY W.wait_time_ms DESC;

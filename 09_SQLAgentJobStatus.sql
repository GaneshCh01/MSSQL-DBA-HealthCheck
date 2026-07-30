/* 09_SQLAgentJobStatus.sql | Latest SQL Agent outcome + currently executing jobs */
SET NOCOUNT ON;

WITH LastOutcome AS
(
 SELECT j.job_id,j.name,
        h.run_status,h.run_date,h.run_time,h.run_duration,h.message,
        ROW_NUMBER() OVER(PARTITION BY j.job_id ORDER BY h.instance_id DESC) rn
 FROM msdb.dbo.sysjobs j
 LEFT JOIN msdb.dbo.sysjobhistory h ON h.job_id=j.job_id AND h.step_id=0
)
SELECT name AS JobName,
       CASE run_status WHEN 0 THEN 'FAILED' WHEN 1 THEN 'SUCCEEDED' WHEN 2 THEN 'RETRY' WHEN 3 THEN 'CANCELED' WHEN 4 THEN 'IN PROGRESS' ELSE 'NO HISTORY' END AS LastOutcome,
       msdb.dbo.agent_datetime(run_date,run_time) AS LastRunDateTime,
       run_duration AS RunDuration_HHMMSS,
       message
FROM LastOutcome
WHERE rn=1 OR rn IS NULL
ORDER BY CASE WHEN run_status=0 THEN 0 ELSE 1 END,name;

SELECT j.name AS RunningJob,
       ja.start_execution_date,
       DATEDIFF(MINUTE,ja.start_execution_date,GETDATE()) AS RunningMinutes
FROM msdb.dbo.sysjobactivity ja
JOIN msdb.dbo.sysjobs j ON j.job_id=ja.job_id
WHERE ja.start_execution_date IS NOT NULL AND ja.stop_execution_date IS NULL
  AND ja.session_id=(SELECT MAX(session_id) FROM msdb.dbo.syssessions)
ORDER BY ja.start_execution_date;

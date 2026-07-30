/* 01_ServerHealthCheck.sql | Author: Ganesh Chittalwar
   Purpose: Fast instance + database configuration/availability overview.
   Permission: VIEW SERVER STATE recommended.
*/
SET NOCOUNT ON;

SELECT
    @@SERVERNAME AS ServerName,
    CAST(SERVERPROPERTY('MachineName') AS nvarchar(128)) AS MachineName,
    CAST(SERVERPROPERTY('InstanceName') AS nvarchar(128)) AS InstanceName,
    CAST(SERVERPROPERTY('Edition') AS nvarchar(128)) AS Edition,
    CAST(SERVERPROPERTY('ProductVersion') AS nvarchar(128)) AS ProductVersion,
    CAST(SERVERPROPERTY('ProductLevel') AS nvarchar(128)) AS ProductLevel,
    CAST(SERVERPROPERTY('IsClustered') AS int) AS IsClustered,
    sqlserver_start_time,
    DATEDIFF(HOUR, sqlserver_start_time, GETDATE()) AS UptimeHours
FROM sys.dm_os_sys_info;

SELECT
    name AS DatabaseName,
    state_desc,
    recovery_model_desc,
    user_access_desc,
    compatibility_level,
    page_verify_option_desc,
    is_auto_close_on,
    is_auto_shrink_on,
    SUSER_SNAME(owner_sid) AS DatabaseOwner
FROM sys.databases
ORDER BY database_id;

SELECT
    name,
    value_in_use,
    description
FROM sys.configurations
WHERE name IN
('max server memory (MB)','min server memory (MB)','max degree of parallelism','cost threshold for parallelism','backup compression default','optimize for ad hoc workloads')
ORDER BY name;

<#
.SYNOPSIS
  MSSQL DBA portfolio health-check runner.
.DESCRIPTION
  Runs selected read-only T-SQL checks with Invoke-Sqlcmd and writes a text report.
  Requires the SqlServer PowerShell module.
.EXAMPLE
  .\SQLHealthCheck.ps1 -ServerInstance "localhost" -OutputFolder "C:\DBAReports"
#>
param(
    [Parameter(Mandatory=$true)][string]$ServerInstance,
    [string]$OutputFolder = ".\Reports",
    [System.Management.Automation.PSCredential]$Credential
)

$ErrorActionPreference = 'Stop'
if (-not (Get-Module -ListAvailable -Name SqlServer)) {
    throw "SqlServer module not found. Install it in an approved environment, then retry."
}
Import-Module SqlServer

New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$outFile = Join-Path $OutputFolder "SQLHealthCheck_$stamp.txt"

$checks = [ordered]@{
 'Instance Summary' = @"
SELECT @@SERVERNAME ServerName, SERVERPROPERTY('Edition') Edition,
SERVERPROPERTY('ProductVersion') ProductVersion, sqlserver_start_time,
DATEDIFF(HOUR,sqlserver_start_time,GETDATE()) UptimeHours FROM sys.dm_os_sys_info;
"@
 'Database Status' = @"
SELECT name,state_desc,recovery_model_desc,compatibility_level,page_verify_option_desc
FROM sys.databases ORDER BY database_id;
"@
 'Backup Status' = @"
WITH B AS (SELECT database_name,MAX(CASE WHEN type='D' THEN backup_finish_date END) LastFull,
MAX(CASE WHEN type='L' THEN backup_finish_date END) LastLog FROM msdb.dbo.backupset GROUP BY database_name)
SELECT d.name DatabaseName,d.recovery_model_desc,b.LastFull,b.LastLog
FROM sys.databases d LEFT JOIN B b ON b.database_name=d.name WHERE d.database_id>4 ORDER BY d.name;
"@
 'Blocking' = @"
SELECT session_id,blocking_session_id,DB_NAME(database_id) DatabaseName,status,wait_type,wait_time,wait_resource
FROM sys.dm_exec_requests WHERE blocking_session_id<>0 ORDER BY wait_time DESC;
"@
 'Failed Agent Jobs - Latest Outcome' = @"
WITH x AS (SELECT j.name,h.run_status,h.run_date,h.run_time,h.message,
ROW_NUMBER() OVER(PARTITION BY j.job_id ORDER BY h.instance_id DESC) rn
FROM msdb.dbo.sysjobs j LEFT JOIN msdb.dbo.sysjobhistory h ON h.job_id=j.job_id AND h.step_id=0)
SELECT name,run_status,msdb.dbo.agent_datetime(run_date,run_time) LastRun,message FROM x WHERE rn=1 AND run_status=0;
"@
}

"MSSQL DBA HEALTH CHECK`r`nServer: $ServerInstance`r`nGenerated: $(Get-Date)`r`n" | Out-File $outFile -Encoding utf8

foreach ($item in $checks.GetEnumerator()) {
    "`r`n================ $($item.Key) ================`r`n" | Out-File $outFile -Append -Encoding utf8
    try {
        $params = @{ ServerInstance=$ServerInstance; Query=$item.Value; TrustServerCertificate=$true; ErrorAction='Stop' }
        if ($Credential) { $params.Credential=$Credential }
        $result = Invoke-Sqlcmd @params
        if ($null -eq $result) { "No rows returned." | Out-File $outFile -Append -Encoding utf8 }
        else { $result | Format-Table -AutoSize | Out-String -Width 300 | Out-File $outFile -Append -Encoding utf8 }
    }
    catch {
        "ERROR: $($_.Exception.Message)" | Out-File $outFile -Append -Encoding utf8
    }
}

Write-Host "Health-check report created: $outFile"

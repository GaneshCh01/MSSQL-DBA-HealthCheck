# MSSQL DBA Automated Health Check & Monitoring Portfolio

**Author:** Ganesh Chittalwar  
**GitHub:** ganeshch01  
**Level:** Basic to Advanced | Production portfolio project

## Project Objective
A reusable SQL Server DBA health-check toolkit for daily operations, incident triage, performance review, backup compliance, capacity monitoring, and freelance client assessments.

## What this project checks
- SQL Server instance configuration and uptime
- Database state, recovery model, compatibility and owner
- Full/Differential/Log backup status and SLA flags
- Database/data/log file size and free space
- Blocking sessions and active requests
- Long-running requests and current SQL text
- Index fragmentation candidates
- Missing-index recommendations from DMVs
- Wait statistics for performance triage
- SQL Agent failed/running job status
- File growth settings and risky percentage/autogrowth configurations

## Folder Structure
MSSQL-DBA-HealthCheck/
├── README.md
├── SQL-Scripts/
│   ├── 01_ServerHealthCheck.sql
│   ├── 02_BackupStatus.sql
│   ├── 03_DatabaseSize.sql
│   ├── 04_BlockingSessions.sql
│   ├── 05_LongRunningQueries.sql
│   ├── 06_IndexFragmentation.sql
│   ├── 07_MissingIndexes.sql
│   ├── 08_WaitStatistics.sql
│   ├── 09_SQLAgentJobStatus.sql
│   └── 10_DatabaseGrowth.sql
├── PowerShell/
│   └── SQLHealthCheck.ps1
├── Reports/
├── Screenshots/
└── Documentation/
    ├── Architecture.md
    ├── Troubleshooting-Scenarios.md
    └── Client-Deployment-Guide.md

## Requirements
- SQL Server 2016+ recommended (most T-SQL also works on older supported versions)
- SQL Server Management Studio (SSMS)
- VIEW SERVER STATE for server-wide DMVs
- msdb read access for backup/job history
- PowerShell 5.1+ for automation script

## Quick Start
1. Clone/download this repository.
2. Open SSMS and connect to a non-production/test SQL Server first.
3. Run scripts in `SQL-Scripts` individually.
4. Review thresholds and adapt them to the client's SLA/workload.
5. Run `PowerShell/SQLHealthCheck.ps1` to export a consolidated text report.
6. Add sanitized screenshots to `Screenshots` before publishing the portfolio.

## Suggested Daily DBA Workflow
1. Server/database availability
2. Backup SLA status
3. SQL Agent failures
4. Blocking and long-running requests
5. File/disk capacity and growth
6. Wait statistics and performance indicators
7. Index analysis during maintenance review (not blindly every day)

## Important Production Notes
- DMV data is often cumulative since service start; establish a baseline before acting.
- Missing-index DMVs are suggestions, not automatic CREATE INDEX commands.
- Fragmentation alone is not sufficient reason to rebuild an index; consider size, workload, page count, log impact and maintenance window.
- Do not change server configuration based only on this toolkit. Validate findings against workload, SLA and change-management procedures.
- Always sanitize server names, database names, usernames, IPs and client information before uploading screenshots/reports publicly.

## Portfolio Demo Scenario
Use a SQL Server Developer Edition lab. Create a test database, generate sample workload, take backups, create a failed Agent job (lab only), open a blocking transaction, and capture sanitized before/after evidence. Explain each finding and remediation in your portfolio.

## Freelance Services Demonstrated
- SQL Server health assessment
- Backup/recovery review
- Performance troubleshooting
- Blocking investigation
- SQL Agent monitoring
- Index/database maintenance assessment
- Capacity and autogrowth review
- PowerShell-based DBA automation

## Disclaimer
This repository is a portfolio/lab toolkit. Test and review scripts before running in production. Production changes should follow backup, security, SLA and change-control requirements.

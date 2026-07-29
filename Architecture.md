# Architecture

## Flow
DBA / Scheduled PowerShell -> SQL Server -> DMVs + msdb metadata -> Health Report -> DBA Review -> Approved remediation/change.

## Data Sources
- `sys.databases`, `sys.master_files`, `sys.configurations`
- `sys.dm_os_sys_info`, `sys.dm_os_wait_stats`
- `sys.dm_exec_requests`, `sys.dm_exec_sessions`, `sys.dm_exec_sql_text`
- Missing-index and index physical-stat DMVs
- `msdb.dbo.backupset`
- SQL Agent job/history tables in msdb

## Design Principles
1. Collection first; remediation only after review.
2. Read-only diagnostics wherever possible.
3. Thresholds are examples and must match client SLA/workload.
4. Use least privilege and protect credentials.
5. Baseline cumulative DMVs instead of interpreting one snapshot in isolation.
6. Sanitize all evidence used in a public portfolio.

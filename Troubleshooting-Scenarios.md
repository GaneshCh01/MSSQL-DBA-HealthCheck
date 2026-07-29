# Troubleshooting Scenarios

## 1. Full Backup Older Than SLA
**Detection:** `02_BackupStatus.sql` flags full backup > 24 hours.  
**Investigation:** Check SQL Agent job history, backup destination space, permissions, error log, backup duration and recent changes.  
**Action:** Fix root cause, take approved backup, validate with RESTORE VERIFYONLY where appropriate, and document RPO exposure.

## 2. Blocking Incident
**Detection:** `04_BlockingSessions.sql` identifies blocked and root-blocking sessions.  
**Investigation:** Identify transaction owner, SQL text, wait resource, duration, application/user, open transaction and business impact.  
**Action:** Do not KILL blindly. Coordinate with application/business owner, resolve transaction/query/index design, then capture RCA.

## 3. Long-Running Query
**Detection:** `05_LongRunningQueries.sql`.  
**Investigation:** Check execution plan, waits, reads, CPU, blocking, parameter values, statistics, indexes and Query Store history.  
**Action:** Tune based on evidence; compare before/after duration and resource consumption.

## 4. High PAGEIOLATCH Waits
**Investigation:** Confirm data-file I/O latency, buffer-cache pressure, large scans, bad plans and storage behavior. A wait name alone does not prove slow disks.  
**Action:** Tune query/index/workload first where appropriate; validate storage latency and memory configuration.

## 5. Risky File Autogrowth
**Detection:** `10_DatabaseGrowth.sql` flags disabled, percentage or very small growth.  
**Investigation:** Review historical growth, free disk, expected workload and maintenance events.  
**Action:** Pre-size files and choose sensible fixed growth after change approval.

## 6. Failed SQL Agent Job
**Detection:** `09_SQLAgentJobStatus.sql`.  
**Investigation:** Open job history and step output, identify owner/proxy/permission, disk, network, SQL or application error.  
**Action:** Correct root cause, rerun only when safe, validate downstream dependencies, document incident.

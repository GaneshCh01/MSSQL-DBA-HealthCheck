# Client Deployment Guide

## Phase 1 - Discovery
- Confirm SQL Server versions/editions, instance count, critical databases and business hours.
- Agree backup RPO/RTO and monitoring thresholds.
- Confirm authentication, least-privilege access and change process.

## Phase 2 - Safe Assessment
- Run scripts individually during an agreed window.
- Avoid heavy index scans on very large/busy databases without planning.
- Save outputs in a protected client location.

## Phase 3 - Findings
Classify findings as Critical / High / Medium / Informational. For every finding document evidence, business risk, recommendation, owner and proposed maintenance window.

## Phase 4 - Remediation
No automatic destructive changes are included. Changes such as KILL, index rebuild, file resizing, configuration changes, job edits, restore/failover or security modifications require explicit approval and rollback planning.

## Phase 5 - Portfolio Evidence
Never publish client-identifying data. Replace server/database/login/host/IP names with lab values. Use your own Developer Edition lab for screenshots whenever possible.

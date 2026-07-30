/* 06_IndexFragmentation.sql | Run in target USER database.
   LIMITED mode; filters small indexes. Recommendations are review-only.
*/
SET NOCOUNT ON;
DECLARE @MinPages int=1000;

SELECT
    DB_NAME() AS DatabaseName,
    OBJECT_SCHEMA_NAME(ips.object_id) AS SchemaName,
    OBJECT_NAME(ips.object_id) AS TableName,
    i.name AS IndexName,
    ips.index_type_desc,
    ips.page_count,
    CAST(ips.avg_fragmentation_in_percent AS decimal(9,2)) AS FragmentationPct,
    CASE
      WHEN ips.page_count < @MinPages THEN 'IGNORE-SMALL'
      WHEN ips.avg_fragmentation_in_percent >= 30 THEN 'REVIEW REBUILD'
      WHEN ips.avg_fragmentation_in_percent >= 10 THEN 'REVIEW REORGANIZE'
      ELSE 'NO ACTION'
    END AS ReviewGuidance
FROM sys.dm_db_index_physical_stats(DB_ID(),NULL,NULL,NULL,'LIMITED') ips
JOIN sys.indexes i ON i.object_id=ips.object_id AND i.index_id=ips.index_id
WHERE ips.index_id > 0
  AND ips.alloc_unit_type_desc='IN_ROW_DATA'
  AND ips.page_count >= @MinPages
ORDER BY ips.avg_fragmentation_in_percent DESC,ips.page_count DESC;

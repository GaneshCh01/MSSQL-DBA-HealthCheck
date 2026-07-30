/* 07_MissingIndexes.sql | DMV recommendations since service restart.
   DO NOT create indexes blindly; consolidate overlaps and test writes/storage.
*/
SET NOCOUNT ON;

SELECT TOP (50)
    DB_NAME(mid.database_id) AS DatabaseName,
    OBJECT_SCHEMA_NAME(mid.object_id,mid.database_id) AS SchemaName,
    OBJECT_NAME(mid.object_id,mid.database_id) AS TableName,
    CAST(migs.avg_total_user_cost*migs.avg_user_impact*(migs.user_seeks+migs.user_scans) AS decimal(18,2)) AS ImprovementScore,
    migs.user_seeks,migs.user_scans,
    CAST(migs.avg_user_impact AS decimal(9,2)) AS AvgImpactPct,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns,
    migs.last_user_seek
FROM sys.dm_db_missing_index_group_stats migs
JOIN sys.dm_db_missing_index_groups mig ON migs.group_handle=mig.index_group_handle
JOIN sys.dm_db_missing_index_details mid ON mig.index_handle=mid.index_handle
WHERE mid.database_id > 4
ORDER BY ImprovementScore DESC;

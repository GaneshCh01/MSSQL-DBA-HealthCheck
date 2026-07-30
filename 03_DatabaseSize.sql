/* 03_DatabaseSize.sql | Database/file capacity overview */
SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#FileSpace') IS NOT NULL DROP TABLE #FileSpace;
CREATE TABLE #FileSpace
(DatabaseName sysname, LogicalName sysname, FileType nvarchar(60), PhysicalName nvarchar(260), SizeMB decimal(18,2), UsedMB decimal(18,2), FreeMB decimal(18,2), FreePct decimal(9,2));

EXEC sys.sp_MSforeachdb N'
IF DB_ID(''?'') > 4 AND DATABASEPROPERTYEX(''?'',''Status'')=''ONLINE''
BEGIN
USE [?];
INSERT #FileSpace
SELECT DB_NAME(), name, type_desc, physical_name,
       size/128.0,
       CASE WHEN type=0 THEN FILEPROPERTY(name,''SpaceUsed'')/128.0 ELSE NULL END,
       CASE WHEN type=0 THEN (size-FILEPROPERTY(name,''SpaceUsed''))/128.0 ELSE NULL END,
       CASE WHEN type=0 AND size>0 THEN ((size-FILEPROPERTY(name,''SpaceUsed''))*100.0/size) ELSE NULL END
FROM sys.database_files;
END';

SELECT * FROM #FileSpace ORDER BY DatabaseName, FileType, LogicalName;

SELECT DB_NAME(database_id) AS DatabaseName, type_desc,
       CAST(SUM(size)*8.0/1024 AS decimal(18,2)) AS TotalAllocatedMB
FROM sys.master_files
WHERE database_id > 4
GROUP BY database_id,type_desc
ORDER BY DatabaseName,type_desc;

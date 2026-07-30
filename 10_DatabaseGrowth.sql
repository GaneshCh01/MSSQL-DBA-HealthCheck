/* 10_DatabaseGrowth.sql | Review file sizes and autogrowth settings */
SET NOCOUNT ON;

SELECT
    DB_NAME(database_id) AS DatabaseName,
    name AS LogicalFileName,
    type_desc,
    physical_name,
    CAST(size*8.0/1024 AS decimal(18,2)) AS CurrentSizeMB,
    CASE WHEN max_size=-1 THEN 'UNLIMITED' ELSE CAST(CAST(max_size*8.0/1024 AS decimal(18,2)) AS varchar(30)) END AS MaxSizeMB,
    is_percent_growth,
    CASE WHEN is_percent_growth=1 THEN CAST(growth AS varchar(20))+'%'
         ELSE CAST(CAST(growth*8.0/1024 AS decimal(18,2)) AS varchar(30))+' MB' END AS GrowthSetting,
    CASE
      WHEN growth=0 THEN 'CRITICAL - Autogrowth disabled'
      WHEN is_percent_growth=1 THEN 'REVIEW - Percentage growth'
      WHEN growth*8.0/1024 < 64 THEN 'REVIEW - Small fixed growth'
      ELSE 'OK/REVIEW WITH WORKLOAD'
    END AS GrowthReview
FROM sys.master_files
WHERE database_id > 4
ORDER BY DatabaseName,type_desc,LogicalFileName;

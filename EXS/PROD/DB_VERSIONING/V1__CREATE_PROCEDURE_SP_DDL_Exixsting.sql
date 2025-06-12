
create procedure [ver].[SP_DDL_Exixsting](@databasename VARCHAR(50))
as
BEGIN

	SELECT *
	FROM
	(
	  SELECT ROW_NUMBER() OVER (ORDER BY [ID]) AS nofile,
			 'V'+CAST(ROW_NUMBER() OVER (ORDER BY [ID]) AS VARCHAR(MAX))+'__'+EventType+'_'+TableName+'.sql' AS [filename],
			 ID,
			 DBName,
			 ScriptVw,
			 GETDATE() CreatedDate,
			 0 IsExport,
			 NULL ExportDate,
			 IsGenerate
	  FROM [DB_VERSIONING].[ver].[Temp_Cycle] a
	  WHERE DBName = @databasename
	)a
	WHERE IsGenerate=0 -- ini nanti cari IsGenerate=0 (yang masih 0, biar dapat urutan terakhir)

END

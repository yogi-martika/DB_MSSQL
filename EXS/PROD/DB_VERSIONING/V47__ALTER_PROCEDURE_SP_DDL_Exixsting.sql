

ALTER procedure [ver].[SP_DDL_Exixsting](@databasename VARCHAR(50))
as
BEGIN

	INSERT INTO [DB_VERSIONING].[ver].[Table_DDL_Exixsting]
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
			 1 IsGenerate
	  FROM [DB_VERSIONING].[ver].[Temp_Cycle] a
	  WHERE DBName = @databasename
	)a
	WHERE IsGenerate=0 -- ini nanti cari IsGenerate=0 (yang masih 0, biar dapat urutan terakhir)

	UPDATE a SET a.IsGenerate=1
	FROM [DB_VERSIONING].[ver].[Temp_Cycle] a
	INNER JOIN [DB_VERSIONING].[ver].[Table_DDL_Exixsting] b ON a.ID=b.ID
	WHERE a.IsGenerate=0

END





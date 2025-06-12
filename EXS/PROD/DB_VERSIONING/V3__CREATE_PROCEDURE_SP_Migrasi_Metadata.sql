
-- EXEC [ver].[SP_Migrasi_Metadata]
create procedure [ver].[SP_Migrasi_Metadata]
as
BEGIN

	DECLARE @dbname VARCHAR(50),@row int

	SELECT ROW_NUMBER() OVER (ORDER BY [DBName]) AS nomor,DBName
	INTO #Loop
	FROM
	(
		SELECT DBName
		FROM [DB_VERSIONING].[ver].[Temp_Cycle]
		GROUP BY DBName
	)a

	SELECT @row=COUNT(*) FROM #Loop

	WHILE @row > 0
	BEGIN
		
		SELECT @dbname=DBName FROM #Loop WHERE nomor=@row

		IF EXISTS (SELECT DBName FROM [DB_VERSIONING].[ver].[db_status] WHERE IsNew=1 AND WasDeploy=0 AND DBName = @dbname)
		BEGIN
			-- DB baru yang belom dideploy
			EXEC [ver].[SP_DDL_New]@dbname
		END
		ELSE
		BEGIN
			EXEC [ver].[SP_DDL_Exixsting]@dbname
		END

		SET @row=@row-1

	END

	DROP TABLE #Loop

END

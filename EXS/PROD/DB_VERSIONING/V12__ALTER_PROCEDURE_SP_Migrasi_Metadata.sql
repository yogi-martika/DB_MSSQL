
-- EXEC [ver].[SP_Migrasi_Metadata]
ALTER procedure [ver].[SP_Migrasi_Metadata]
as
BEGIN

	DECLARE @dbname VARCHAR(50),@row int

		SELECT ID,EventType,DBName,SchName,TableName,ScriptVw
		INTO #Droplist
		FROM [DB_VERSIONING].[ver].[Temp_Cycle]
		WHERE EventType='DROP_TABLE'

	IF EXISTS (SELECT TOP 1 ID FROM #Droplist)
	BEGIN
		EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'AFISDBMail',
		@recipients = 'yogi.martika@inhealth.co.id',
		@subject = 'Drop Table Trigger Capture',
		@body = 'Hi, Yogi<br>Terdapat DROP_TABLE pada list metadata DB Development, tolong cek dahulu.',
		@body_format = 'HTML',
		@query = 'SELECT ID,EventType,DBName,SchName,TableName,ScriptVw FROM [DB_VERSIONING].[ver].[Temp_Cycle] WHERE EventType=''DROP_TABLE''',
		@attach_query_result_as_file = 1,
		@query_attachment_filename = 'Droplist.txt',
		@query_result_separator = '|',
		@query_result_no_padding = 1;

		SELECT 'Terdapat perintah DROP_TABLE, sedang direview DBA tunggu kabarnya.'[OUTPUT]
	END
	ELSE
	BEGIN
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

	DROP TABLE #Droplist
END

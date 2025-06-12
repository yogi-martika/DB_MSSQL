
ALTER procedure [ver].[SP_DDL_New](@databasename VARCHAR(50))
as
BEGIN
	
	INSERT INTO [DB_VERSIONING].[ver].[Table_DDL_New]
	SELECT *
	FROM
	(
	  SELECT ROW_NUMBER() OVER (ORDER BY [ID]) AS nofile,
				'V'+CAST(ROW_NUMBER() OVER (ORDER BY [ID]) AS VARCHAR(MAX))+'__'+EventType+'_'+TableName+'.sql' AS [filename],
				ID,
				DBName,
				ScriptVw,
				CASE WHEN EventType='CREATE_DATABASE' THEN 'BACKUP DATABASE ['+DBName+'] TO DISK=//10.10.10.177/FolderBackupCICD/'+DBName+'_backup_4Flyway.bak;' ELSE NULL END BackupScript,
				CASE WHEN EventType='CREATE_DATABASE' THEN 'RESTORE DATABASE ['+DBName+'] FROM DISK=//10.10.10.177/FolderBackupCICD/'+DBName+'_backup_4Flyway.bak WITH RECOVERY;'ELSE NULL END RestoreScript,
				GETDATE() CreatedDate,
				0 IsExport,
				NULL ExportDate,
				IsGenerate
	  FROM [DB_VERSIONING].[ver].[Temp_Cycle] a
	  WHERE DBName = @databasename --'APP_BARU2' 
	)a
	WHERE IsGenerate = 0

END




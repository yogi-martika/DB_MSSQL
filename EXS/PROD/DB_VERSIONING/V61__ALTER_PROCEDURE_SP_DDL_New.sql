

ALTER procedure [ver].[SP_DDL_New](@databasename VARCHAR(50))
as
BEGIN
	
	INSERT INTO [DB_VERSIONING].[ver].[Table_DDL_New]
	SELECT nofile,[filename],ID,DBName,ScriptVw,BackupScript,RestoreScript,CreatedDate,IsExport,ExportDate,1 IsGenerate
	FROM
	(
	  SELECT ROW_NUMBER() OVER (ORDER BY [ID]) AS nofile,
				CASE WHEN EventType='CREATE_DATABASE' THEN EventType ELSE 'V'+CAST(ROW_NUMBER() OVER (ORDER BY [ID]) AS VARCHAR(MAX))+'__'+EventType+'_'+TableName+'.sql' END AS [filename],
				ID,
				DBName,
				ScriptVw,
				CASE WHEN EventType='CREATE_DATABASE' THEN 'BACKUP DATABASE ['+ DBName +'] TO DISK=''\\10.10.10.177\FolderBackupCICD\'+ DBName +'_backup_4Flyway.bak'' WITH NOFORMAT, SKIP, COMPRESSION,  STATS = 10;' ELSE NULL END BackupScript,
				CASE WHEN EventType='CREATE_DATABASE' THEN 'RESTORE DATABASE ['+ DBName +'] FROM  DISK =''\\10.10.10.177\FolderBackupCICD\'+ DBName +'_backup_4Flyway.bak'' WITH MOVE '''+ DBName +''' TO ''F:\MDFDB\'+ DBName +'.mdf'',  MOVE '''+ DBName +'_log'' TO ''G:\LDFDB\'+ DBName +'_log.ldf'',  RECOVERY;' ELSE NULL END RestoreScript,
				GETDATE() CreatedDate,
				0 IsExport,
				NULL ExportDate,
				IsGenerate
	  FROM [DB_VERSIONING].[ver].[Temp_Cycle] a
	  WHERE DBName = @databasename --'APP_BARU2' 
	)a
	WHERE IsGenerate = 0


	UPDATE a SET a.IsGenerate=1
	FROM [DB_VERSIONING].[ver].[Temp_Cycle] a
	INNER JOIN [DB_VERSIONING].[ver].[Table_DDL_New] b ON a.ID=b.ID
	WHERE a.IsGenerate=0

END




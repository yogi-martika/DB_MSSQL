ALTER TABLE dbo.yogi_tes2 ADD CONSTRAINT
	FK_yogi_tes2_yogi_tes1 FOREIGN KEY
	(
	Id_2
	) REFERENCES dbo.yogi_tes1
	(
	id_parent
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION

CREATE PROCEDURE sp_InsertRelationTcIcdInclusion
    @master_tc_id UNIQUEIDENTIFIER,
    @kode_diagnosa VARCHAR(10),
    @request_by VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO AKTUW2..relation_tc_icd_inclusion 
    (
        id,
        master_tc_id,
        kode_diagnosa,
        created_at,
        created_by
    )
    VALUES
    (
        NEWID(),
        @master_tc_id,
        @kode_diagnosa,
        GETDATE(),
        @request_by
    );
END

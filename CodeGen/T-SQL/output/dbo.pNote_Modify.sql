create procedure [dbo].pNote_Modify
(
		@NoteId bigint,
		@ReferenceTypeId smallint,
		@ReferenceEntityId bigint,
		@Body nvarchar(2000),
		@CreatedByUserId int,
		@CreatedDate datetime,
		@IsRemoved bit
) AS
BEGIN
	UPDATE
		[dbo].Note
	SET
		ReferenceTypeId = @ReferenceTypeId,
		ReferenceEntityId = @ReferenceEntityId,
		Body = @Body,
		CreatedByUserId = @CreatedByUserId,
		CreatedDate = @CreatedDate,
		IsRemoved = @IsRemoved
	WHERE
		[dbo].Note.NoteId = @NoteId;
END
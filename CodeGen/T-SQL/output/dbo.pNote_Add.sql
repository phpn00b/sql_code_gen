create procedure [dbo].pNote_Add
(
		@NoteId bigint OUTPUT,
		@ReferenceTypeId smallint,
		@ReferenceEntityId bigint,
		@Body nvarchar(2000),
		@CreatedByUserId int,
		@CreatedDate datetime,
		@IsRemoved bit
) AS
BEGIN
	INSERT INTO [dbo].Note
	(
		ReferenceTypeId,
		ReferenceEntityId,
		Body,
		CreatedByUserId,
		CreatedDate,
		IsRemoved
	)
	VALUES
	(
		@ReferenceTypeId,
		@ReferenceEntityId,
		@Body,
		@CreatedByUserId,
		@CreatedDate,
		@IsRemoved
	);
	SET @NoteId = SCOPE_IDENTITY();
END
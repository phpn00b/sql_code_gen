create procedure [dbo].pNote_Remove
(
		@NoteId bigint
) AS
BEGIN
	DELETE FROM
		[dbo].Note
	WHERE
		[dbo].Note.NoteId = @NoteId;
END
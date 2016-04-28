create procedure [dbo].pNote_Fetch
(
		@NoteId bigint
) AS
BEGIN
	DECLARE @SearchResults dbo.IntSortedList;

	IF @NoteId = 0
		INSERT INTO
			@SearchResults
		SELECT
			t.NoteId,
			ROW_NUMBER() OVER(ORDER BY t.NoteId ASC)
		FROM
			[dbo].Note t;
	ELSE
		INSERT INTO
			@SearchResults
		SELECT
			@NoteId,
			0;

	EXEC [dbo].pNote_Search @SearchResults;
END
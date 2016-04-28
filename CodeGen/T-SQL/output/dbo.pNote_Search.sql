create procedure [dbo].pNote_Search
(
	@SearchResults dbo.IntSortedList READONLY
) AS
BEGIN
	SELECT
		t.NoteId,
		t.ReferenceTypeId,
		t.ReferenceEntityId,
		t.Body,
		t.CreatedByUserId,
		t.CreatedDate,
		t.IsRemoved
	FROM
		@SearchResults r
		INNER JOIN [dbo].Note t
			ON r.ItemId = t.NoteId
	ORDER BY
		r.Sequence ASC;
END
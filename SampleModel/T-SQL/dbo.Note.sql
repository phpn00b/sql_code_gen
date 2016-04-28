create table dbo.Note
(
	NoteId bigint not null identity (1, 1),
	ReferenceTypeId smallint not null,
	ReferenceEntityId bigint not null,
	Body nvarchar(4000) not null,
	CreatedByUserId int not null,
	CreatedDate datetime not null,
	IsRemoved bit not null,
	PRIMARY KEY(NoteId)
);

go
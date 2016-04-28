declare 
	@sprocname varchar(50),
	@schema varchar(50),
	@mode varchar(50),
	@name varchar(50),
	@dataType varchar(50),
	@maxlength1 varchar(50),
	@maxlength2 varchar(50),
	@parameters varchar(max),
	@callingConvention varchar(max),
	@csDataType varchar(50),
	@dbDataType varchar(50),
	@nullable varchar(3),
	@needsPipe bit,
	@inputs varchar(max),
	@insertColumns varchar(max),
	@insertValues varchar(max),
	@update varchar(max),
	@select VARCHAR(MAX),
	@charLength int,
	@numPrecision int,
	@numScale int;
	
-- ========================================================= Change @sprocname & @schema below =========================================================
set @sprocname = 'Note';
set @schema = 'dbo';
-- ================================= No need to touch anything below this line unless you wish to customize the output =================================
set @parameters = '';
set @insertValues = '';
set @insertColumns = '';
set @select = '';
set @callingConvention = '';
set @update ='';
declare @i int= 0;
declare @idColumn VARCHAR(50);
declare @idColumnParam VARCHAR(100);
declare @count int =(  select 
			COUNT(*)
	from 
		INFORMATION_SCHEMA.COLUMNS p
	where
		p.TABLE_NAME = @sprocname 
		and p.TABLE_SCHEMA= @schema)
declare cur cursor
    for 
    select 
		
		p.COLUMN_NAME,
		p.DATA_TYPE,
		p.CHARACTER_MAXIMUM_LENGTH,
		p.CHARACTER_OCTET_LENGTH,
		p.IS_NULLABLE,
		p.CHARACTER_OCTET_LENGTH,
		p.NUMERIC_PRECISION,
		p.NUMERIC_SCALE
	from 
		INFORMATION_SCHEMA.COLUMNS p
	where
		p.TABLE_NAME = @sprocname 
		and p.TABLE_SCHEMA= @schema
open cur
set @schema = '[' + @schema + ']';
fetch next from cur into @name,@dataType,@maxlength1,@maxlength2,@nullable,@charLength,@numPrecision,@numScale
while @@fetch_status = 0
begin
	set @csDataType = case @dataType 
		when 'int' then 'int' 
		when 'nvarchar' then 'string'
		when 'datetime' then 'DateTime'
		when 'uniqueidentifier' then 'Guid'
		when 'bigint' then 'long'
		when 'varchar' then 'string'
		when 'tinyint' then 'bool'
		when 'decimal' then 'decimal'
		when 'bit' then 'bool'
		when 'date' then 'DateTime'
		when 'money' then 'decimal'
		when 'smallint' then 'short' end;
		
	set @dbDataType = case @dataType 
		when 'int' then 'int' 
		when 'nvarchar' then 'string'
		when 'varchar' then 'string'
		when 'datetime' then 'DateTime'
		when 'uniqueidentifier' then 'Guid'
		when 'bigint' then 'long'
		when 'tinyint' then 'byte'
		when 'bit' then 'bool'
		when 'decimal' then 'Decimal'
		when 'smallint' then 'short' end;
	SET @dataType = CASE @dataType
		WHEN 'nvarchar' THEN @dataType + '(' + CONVERT(VARCHAR, @charLength) + ')'
		WHEN 'varchar' THEN @dataType + '(' + CONVERT(VARCHAR, @charLength) + ')'
		WHEN 'decimal' THEN @dataType + '(' + CONVERT(VARCHAR, @numPrecision) + ', ' + CONVERT(VARCHAR, @numScale) + ')'
		ELSE @dataType
	END;

--	print @csDataType
	set @parameters= @parameters+  CHAR(9) + CHAR(9) +'@'+@name+ ' ' + @dataType+ case @i when @count-1 THEN '' WHEN 0 THEN ' OUTPUT,' ELSE ',' END+CHAR(13)+CHAR(10);
	if @i =0 
		BEGIN
			SET @idColumnParam = @parameters;
			set @idColumn = @name;
		END
	ELSE
		BEGIN
			set @insertValues = @insertValues+ CHAR(9) + CHAR(9) +'@'+@name+ case @i when @count-1 THEN '' ELSE ','END +CHAR(13)+CHAR(10);
			set @insertColumns = @insertColumns + CHAR(9) + CHAR(9) + @name + case @i when @count-1 THEN '' ELSE ','END +CHAR(13)+CHAR(10);
			set @update = @update +CHAR(9) +CHAR(9) + @name + ' = @' + @name + case @i when @count-1 THEN '' ELSE ','END +CHAR(13)+CHAR(10);
		END
	SET @select = @select + CHAR(9) + CHAR(9) + 't.' + @name + case @i when @count-1 THEN '' ELSE ','END +CHAR(13)+CHAR(10);
		--new Column("PassphraseSalt", DbType.String, 50, ColumnProperty.NotNull),
	
	
	fetch next from cur into @name,@dataType,@maxlength1,@maxlength2,@nullable,@charLength,@numPrecision,@numScale
	set @i +=1;
end
close cur
deallocate cur
--/*
-- create the add procedure
print 'create procedure ' + @schema + '.p' + @sprocname + '_Add'+ CHAR(13)+CHAR(10)
print '('+CHAR(13)+CHAR(10);
print @parameters;
print ') AS'+CHAR(13)+CHAR(10);
print 'BEGIN'+CHAR(13)+CHAR(10);
print  CHAR(9) +'INSERT INTO ' + @schema+'.'+ @sprocname
print  CHAR(9) +'('+CHAR(13)+CHAR(10);
print @insertColumns;
print  CHAR(9) +')'+CHAR(13)+CHAR(10);
print  CHAR(9) +'VALUES'+CHAR(13)+CHAR(10);
print  CHAR(9) +'('+CHAR(13)+CHAR(10);
print @insertValues;
print  CHAR(9) +');'+CHAR(13)+CHAR(10);
print  CHAR(9) +'SET @' + @idColumn +' = SCOPE_IDENTITY();'+CHAR(13)+CHAR(10)
print 'END'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10);

-- create the modify procedure
print 'create procedure ' + @schema + '.p' + @sprocname + '_Modify' + CHAR(13)+CHAR(10)
print '('+CHAR(13)+CHAR(10);
print REPLACE(@parameters, ' OUTPUT', '');
print ') AS'+CHAR(13)+CHAR(10);
print 'BEGIN'+CHAR(13)+CHAR(10);
print CHAR(9) +'UPDATE'+CHAR(13)+CHAR(10);
print CHAR(9) +CHAR(9) +   @schema+'.'+ @sprocname
print CHAR(9) +'SET'+CHAR(13)+CHAR(10);
print @update
print CHAR(9) + 'WHERE'
print CHAR(9) + CHAR(9) +  @schema+'.'+ @sprocname + '.' + @idColumn + ' = @' + @idColumn +';';
print 'END'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)

-- create the remove procedure
print 'create procedure ' + @schema + '.p' + @sprocname + '_Remove' + CHAR(13)+CHAR(10)
print '('+CHAR(13)+CHAR(10);
print REPLACE(@idColumnParam, ' OUTPUT,', '');
print ') AS'+CHAR(13)+CHAR(10);
print 'BEGIN'+CHAR(13)+CHAR(10);
print CHAR(9) +'DELETE FROM'+CHAR(13)+CHAR(10);
print CHAR(9) +CHAR(9) +   @schema+'.'+ @sprocname
print CHAR(9) +'WHERE'+CHAR(13)+CHAR(10);
print CHAR(9) + CHAR(9) +  @schema+'.'+ @sprocname + '.' + @idColumn + ' = @' + @idColumn +';';
print 'END'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)

-- create the fetch procedure
print 'create procedure ' + @schema + '.p' + @sprocname + '_Fetch' + CHAR(13)+CHAR(10)
print '('+CHAR(13)+CHAR(10);
print REPLACE(@idColumnParam, ' OUTPUT,', '');
print ') AS'+CHAR(13)+CHAR(10);
print 'BEGIN'+CHAR(13)+CHAR(10);
print CHAR(9) + 'DECLARE @SearchResults dbo.IntSortedList;'+ CHAR(13) + CHAR(10)+ CHAR(13) + CHAR(10);
print CHAR(9) + 'IF @' + @idColumn + ' = 0' + CHAR(13) + CHAR(10);

print CHAR(9) + CHAR(9) + 'INSERT INTO'
print CHAR(9) + CHAR(9) + CHAR(9) + '@SearchResults'
print CHAR(9) + CHAR(9) + 'SELECT'
print CHAR(9) + CHAR(9) + CHAR(9) + 't.' + @idColumn + ','
print CHAR(9) + CHAR(9) + CHAR(9) + 'ROW_NUMBER() OVER(ORDER BY t.' + @idColumn +' ASC)'
print CHAR(9) + CHAR(9) + 'FROM'
print CHAR(9) + CHAR(9) + CHAR(9) + @schema+'.'+ @sprocname + ' t;';
print CHAR(9) + 'ELSE' + CHAR(13) + CHAR(10);
print CHAR(9) + CHAR(9) + 'INSERT INTO'
print CHAR(9) + CHAR(9) + CHAR(9) + '@SearchResults'
print CHAR(9) + CHAR(9) + 'SELECT'
print CHAR(9) + CHAR(9) + CHAR(9) + '@' + @idColumn + ','
print CHAR(9) + CHAR(9) + CHAR(9) + '0;'+ CHAR(13) + CHAR(10)+ CHAR(13) + CHAR(10);
print CHAR(9) + 'EXEC ' + @schema + '.p' + @sprocname + '_Search @SearchResults;';
print 'END'+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)+CHAR(13)+CHAR(10)
--*/
-- create the search procedure
print 'create procedure ' + @schema + '.p' + @sprocname + '_Search' + CHAR(13)+CHAR(10)
print '('+CHAR(13)+CHAR(10);
print CHAR(9) + '@SearchResults dbo.IntSortedList READONLY'
print ') AS'+CHAR(13)+CHAR(10);
print 'BEGIN'+CHAR(13)+CHAR(10);
print CHAR(9) +'SELECT'+CHAR(13)+CHAR(10);
print @select;
print CHAR(9) + 'FROM';
print CHAR(9) + CHAR(9) + '@SearchResults r';
print CHAR(9) + CHAR(9) + 'INNER JOIN ' + + @schema + '.' + @sprocname + ' t';
print CHAR(9) + CHAR(9) + CHAR(9) +'ON r.ItemId = t.' + @idColumn
print CHAR(9) + 'ORDER BY'
print CHAR(9) +CHAR(9) + 'r.Sequence ASC'
print 'END'
--print @callingConvention
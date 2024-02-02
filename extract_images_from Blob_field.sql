
--RUN SSMS as ADMin on SQL machine, create the dump folder, give full permissions to USER for said folder
DECLARE @outPutPath VARCHAR(50) = 'C:\image_dump', 
	@i BIGINT,
	@init INT,
    @rowcount INT,
	@data VARBINARY(max),
	@fPath VARCHAR(max),
	@folderPath VARCHAR(max)

--Get Data into temp Table variable so that we can iterate over it
DECLARE @Doctable TABLE (
	id INT identity(1, 1),
	[FileName] VARCHAR(100),
	[Doc_Content] VARBINARY(max)
	)

INSERT INTO @Doctable (
	[FileName],
	[Doc_Content]
	)
SELECT 
	Replace(Replace([Some_Text_field_identifying_the_row], '/', '_fwdslash_'), '\', '_backslash_'),
	[Image]
FROM [dbo].[TableWithImagesInVarBinaryMAXcolumn] a
WHERE DATALENGTH(a.IMAGE) > 1 --len(image) > 0
	AND a.IsDeleted = 0
ORDER BY a.SomeOtherColumn

--SELECT * FROM @table
SELECT @i = COUNT(1), @rowcount = COUNT(1)
FROM @Doctable

--SELECT * FROM @Doctable where ID between 8130 and  8142
PRINT 'img count: ' + cast(@i AS VARCHAR(10))


WHILE @i >= 1
BEGIN
	SELECT @data = [Doc_Content],
			@fPath = @outPutPath + '\Pid[' + RTRIM(cast([SomeOtherColumn] AS CHAR(3))) + ']__rownum[' + LTRIM(RTRIM(cast(@rowcount - @i + 1 AS CHAR(5)))) + ']__[' + [FileName] + '].jpg',
			@folderPath = '\' + [FileName]
	FROM @Doctable
	WHERE id = @i

	DECLARE @hr INT;

	EXECUTE @hr = sp_OACreate 'ADODB.Stream', @init OUTPUT;-- An instance created

	IF @hr <> 0
	BEGIN
		 RAISERROR ('Error %d creating object.', 16, 1, @hr )
		 RETURN
	END

	EXECUTE @hr = sp_OASetProperty @init, 'Type', 1;

	IF @hr <> 0
	BEGIN
		 RAISERROR ( 'Error %d opening file.', 16, 1, @hr )
		 RETURN
	END

	EXECUTE @hr = sp_OAMethod @init, 'Open';-- Calling a method

	IF @hr <> 0
	BEGIN
		 RAISERROR ( 'Error %d writing line.', 16, 1, @hr )
		 RETURN
	END

	EXECUTE @hr = sp_OAMethod @init, 'Write', NULL, @data;-- Calling a method

	IF @hr <> 0
	BEGIN
		 RAISERROR ( 'Error %d closing file.', 16, 1, @hr )
		 RETURN
	END

	EXECUTE @hr = sp_OAMethod @init, 'SaveToFile', NULL, @fPath, 2;-- Calling a method

	IF @hr <> 0
	BEGIN
		 PRINT 'errpath: ' + @fpath
		 RAISERROR ( 'Error %d closing file.', 16, 1, @hr )
		 RETURN
	END

	EXECUTE @hr = sp_OAMethod @init, 'Close';-- Calling a method

	IF @hr <> 0
	BEGIN
		 RAISERROR ( 'Error %d closing file.', 16, 1, @hr )
		 RETURN
	END

	EXECUTE @hr = sp_OADestroy @init

	PRINT @hr
	
	PRINT 'Document Generated at - ' + @fPath

	--Reset the variables for next use
	SELECT @data = NULL, 
	@init = NULL, 
	@fPath = NULL, 
	@folderPath = NULL
	SET @i -= 1

	PRINT 'row nr: ' + cast(14174 - @i AS VARCHAR(10)) + '  i nr: ' + cast(@i AS VARCHAR(10))
END
 --Get Data into temp Table variable so that we can iterate over it
 --Document Generated at - C:\image_dump\229__chair123.jpg

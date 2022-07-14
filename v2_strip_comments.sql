USE Lineage;


--EXEC dbo.sql_sample_procedure 


DROP TABLE IF EXISTS dbo.SQL_query_table;

CREATE TABLE dbo.SQL_query_table (
     id INT IDENTITY(1,1) NOT NULL
    ,query_txt NVARCHAR(4000)
)

INSERT INTO dbo.SQL_query_table
EXEC sp_helptext  
	@objname = 'sql_sample_procedure'



--SELECT * FROM dbo.SQL_query_table


DECLARE @sp_text varchar(8000) = ''
DECLARE @sp_text_row varchar(8000)
DECLARE @sp_no_comment varchar(8000) = ''
DECLARE @c char(1)
DECLARE @comment_count INT = 0


SELECT @sp_text = @sp_text + CASE 
								WHEN LEN(@sp_text) > 0 THEN '\n' 
								ELSE '' END + query_txt
FROM dbo.SQL_query_table

--PRINT @sp_text

DECLARE @i INT  = 1
DECLARE @rowcount INT = (SELECT LEN(@sp_text))
--PRINT @rowcount

WHILE (@i <= @rowcount) 
	BEGIN
		 IF SUBSTRING(@sp_text,@i,2) = '/*'
			BEGIN
				-- SELECT (SUBSTRING(@sp_text,@i,2)) -- Uncomment or Delete
				SELECT @comment_count = @comment_count + 1
			END
		 ELSE IF SUBSTRING(@sp_text,@i,2) = '*/'  
			BEGIN
				SELECT @comment_count = @comment_count - 1  
				-- SELECT @comment_count -- Uncomment or Delete
			END
		 ELSE IF @comment_count = 0
			SELECT @sp_no_comment = @sp_no_comment + SUBSTRING(@sp_text,@i,1)

		 IF SUBSTRING(@sp_text,@i,2) = '*/' 
		  SELECT @i = @i + 2
		 ELSE
		  SELECT @i = @i + 1
	END


WHILE (@i <= @rowcount) 
	BEGIN
		 IF SUBSTRING(@sp_text,@i,4) = '/*/*'
			BEGIN
				SELECT @comment_count = @comment_count + 2
			END
		 ELSE IF SUBSTRING(@sp_text,@i,4) = '*/*/'  
			BEGIN
				SELECT @comment_count = @comment_count - 2 
			END
		 ELSE IF @comment_count = 0
			SELECT @sp_no_comment = @sp_no_comment + SUBSTRING(@sp_text,@i,1)

		 IF SUBSTRING(@sp_text,@i,4) = '*/*/' 
		  SELECT @i = @i + 2
		 ELSE
		  SELECT @i = @i + 1
	END

DROP TABLE IF EXISTS  #tbl_sp_no_comments
CREATE TABLE #tbl_sp_no_comments (
			 rn int identity(1,1)
			,sp_text varchar(8000)
			)


WHILE (LEN(@sp_no_comment) > 0)
	BEGIN
		INSERT INTO  #tbl_sp_no_comments (sp_text)
		SELECT SUBSTRING( @sp_no_comment, 0, CHARINDEX('\n', @sp_no_comment))
		SELECT @sp_no_comment = SUBSTRING(@sp_no_comment, CHARINDEX('\n',@sp_no_comment) + 2, LEN(@sp_no_comment))
	END

--SELECT * FROM #tbl_sp_no_comments


DROP TABLE IF EXISTS  #tbl_sp_no_comments_fin
CREATE TABLE #tbl_sp_no_comments_fin (rn_orig int identity(1,1), rn INT, sp_text_fin varchar(8000))


DECLARE @nofRows INT =  (SELECT COUNT(*) FROM #tbl_sp_no_comments)
PRINT @nofRows
DECLARE @ii INT = 1

WHILE (@nofRows >= @ii)
BEGIN

	DECLARE @LastLB INT = 0
	DECLARE @Com INT = 0 
	SET @Com = (SELECT CHARINDEX('--', sp_text,@com) FROM #tbl_sp_no_comments WHERE rn = @ii)

	SET @LastLB = (SELECT CHARINDEX(CHAR(10), sp_text, @LastLB) FROM #tbl_sp_no_comments WHERE rn = @ii)


	
	INSERT INTO #tbl_sp_no_comments_fin (rn, sp_text_fin)

	SELECT 
		rn
		--,sp_text
		--,@Com AS StartCom
		--,@LastLB AS endCom
		,CASE WHEN @Com = 0 THEN sp_text
			  WHEN @Com <> 0 THEN SUBSTRING(sp_text, 0, @Com) END as new_sp_text
	FROM #tbl_sp_no_comments
	WHERE 
		rn = @ii


	SET @ii = @ii + 1

END

--DROP TABLE IF EXISTS  #tbl_sp_no_comments

SELECT sp_text_fin  FROM #tbl_sp_no_comments_fin
WHERE	
	DATALENGTH(sp_text_fin) > 0 AND LEN(sp_text_fin) > 0

USE QL;
GO

/*
Author: Tomaz Kastrun
Date: 2021
URL: github.com/tomaztk
Description:
	Stripping comments from your T-SQL Query

Usage:
	EXEC dbo.sp_strip_comments @procedureName = 'sql_text'

ChangeLog:
	- 

*/


DROP PROCEDURE IF EXISTS dbo.sql_sample_procedure;
GO

CREATE PROCEDURE dbo.sql_sample_procedure 
AS
BEGIN
		-- Query

		/* This is our Query */

		---- Adding some comments

		SELECT 
		s.Name
		,s.Surname
		-- ,s.Surname
		,d.DepartmentName -- Comment there
		-- Comment here
		-- /*,d.DepartmentID*/
		/* This is a comment */ -- works
		---------------------
		/* this is a inline comment
		in two lines  */
		/* /* this is a double comment */*/ -- works
		,'test' AS test
		/* /* comment */*/ --nope
		FROM Students AS s
		JOIN Departments AS D
		ON d.DepartmentId = s.DepartmentId

END;
GO

EXEC dbo.sql_sample_procedure;


-- #### PRoceedure

DROP TABLE IF EXISTS dbo.SQL_query_table;

CREATE TABLE dbo.SQL_query_table (
     id INT IDENTITY(1,1) NOT NULL
    ,query_txt NVARCHAR(4000)
)

INSERT INTO dbo.SQL_query_table
EXEC sp_helptext  
	@objname = 'sql_sample_procedure'



SELECT * FROM dbo.SQL_query_table
-- ==


DECLARE @sp_text varchar(8000) = ''
DECLARE @sp_text_row varchar(8000)
DECLARE @sp_no_comment varchar(8000) = ''
DECLARE @c char(1)
DECLARE @comment_count INT = 0


SELECT @sp_text = @sp_text + CASE 
								WHEN LEN(@sp_text) > 0 THEN '\n' 
								ELSE '' END + query_txt
FROM dbo.SQL_query_table

PRINT @sp_text

DECLARE @i INT  = 1
DECLARE @rowcount INT = (SELECT LEN(@sp_text))
PRINT @rowcount

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
		 IF SUBSTRING(@sp_text,@i,2) = '/*/*'
			BEGIN
				-- SELECT (SUBSTRING(@sp_text,@i,2)) -- Uncomment or Delete
				SELECT @comment_count = @comment_count + 1
			END
		 ELSE IF SUBSTRING(@sp_text,@i,2) = '*/*/'  
			BEGIN
				SELECT @comment_count = @comment_count - 1  
				-- SELECT @comment_count -- Uncomment or Delete
			END
		 ELSE IF @comment_count = 0
			SELECT @sp_no_comment = @sp_no_comment + SUBSTRING(@sp_text,@i,1)

		 IF SUBSTRING(@sp_text,@i,2) = '*/*/' 
		  SELECT @i = @i + 2
		 ELSE
		  SELECT @i = @i + 1
	END

----------------
-- Define CR/LF
----------------


DROP TABLE IF EXISTS  #tbl_sp_no_comments
CREATE TABLE #tbl_sp_no_comments (rn int identity(1,1), sp_text varchar(8000))

WHILE (LEN(@sp_no_comment) > 0)
	BEGIN
		INSERT INTO  #tbl_sp_no_comments (sp_text)
		SELECT SUBSTRING( @sp_no_comment, 0, CHARINDEX('\n', @sp_no_comment))
		SELECT @sp_no_comment = SUBSTRING(@sp_no_comment, CHARINDEX('\n',@sp_no_comment) + 2, LEN(@sp_no_comment))
	END

SELECT * FROM #tbl_sp_no_comments


----------------
-- from -- to CR/LF
----------------

DROP TABLE IF EXISTS  #tbl_sp_no_comments_fin
CREATE TABLE #tbl_sp_no_comments_fin (rn int identity(1,1), sp_text_fin varchar(8000))


DECLARE @nofRows INT =  (SELECT COUNT(*) FROM #tbl_sp_no_comments)
DECLARE @LastLB INT = 0
DECLARE @Com INT = 0 

SET @Com = (SELECT CHARINDEX('--', sp_text,@com) FROM #tbl_sp_no_comments)
PRINT @com

SET @LastLB = (SELECT CHARINDEX(CHAR(10), sp_text, @LastLB) FROM #tbl_sp_no_comments)
WHILE @LastLB>=1
BEGIN
	INSERT INTO #tbl_sp_no_comments_fin VALUES (@Com)
    SET @nofRows=@nofRows+1
    SET @LastLB= (SELECT CHARINDEX(CHAR(10) ,txt,  @LastLB+1) FROM dbo.SQL)
	SET @Com = (SELECT CHARINDEX('--',txt, @LastLB) FROM dbo.SQL)
END

----------------
-- Running code in ADS
-- Running code in Azure SQL Server/Database
-- CR/LF does not break correctly
----------------


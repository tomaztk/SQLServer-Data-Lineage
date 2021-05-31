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
		/*/* comment */*/ --nope
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
								WHEN LEN(@sp_text) > 0 THEN '\n' ELSE '' END + query_txt
FROM dbo.SQL_query_table

PRINT @sp_text

DECLARE @i INT  = 1
DECLARE @rowcount INT = (SELECT LEN(@sp_text))


WHILE (@i <= @rowcount) 
	BEGIN
		 IF SUBSTRING(@sp_text,@i,2) = '/*'
			BEGIN
				SELECT (SUBSTRING(@sp_text,@i,2))
				SELECT @comment_count = @comment_count + 1
			END
		 ELSE IF SUBSTRING(@sp_text,@i,2) = '*/'  
			SELECT @comment_count = @comment_count - 1  
		 ELSE IF @comment_count = 0
			SELECT @sp_no_comment = @sp_no_comment + SUBSTRING(@sp_text,@i,1)

		 IF SUBSTRING(@sp_text,@i,2) = '*/' 
		  SELECT @i = @i + 2
		 ELSE
		  SELECT @i = @i + 1
	END


DROP TABLE IF EXISTS  #tbl_sp_no_comments
CREATE TABLE #tbl_sp_no_comments (sp_text varchar(8000))

WHILE (LEN(@sp_no_comment) > 0)
	BEGIN
		INSERT INTO  #tbl_sp_no_comments
		SELECT SUBSTRING( @sp_no_comment, 0, CHARINDEX('\n', @sp_no_comment))
		SELECT @sp_no_comment = SUBSTRING(@sp_no_comment, CHARINDEX('\n',@sp_no_comment) + 2, LEN(@sp_no_comment))
	END

SELECT
	*
FROM #tbl_sp_no_comments
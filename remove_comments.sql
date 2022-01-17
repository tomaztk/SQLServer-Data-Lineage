USE QL;
GO

GO

CREATE OR ALTER PROCEDURE dbo.remove_comments

/*

Author: Tomaz Kastrun
Date: July 2021

GitHub: github.com/tomaztk
Blogpost: https://tomaztsql.wordpress.com/2021/07/13/remove-comments-from-your-t-sql-code/

Description:
	Removing all comments from your T-SQL Query for a given procedure
	for better code visibility and readability



Usage:
	EXEC dbo.remove_comments
		@procedure_name = N'sql_sample_procedure'


*/

(
	@Procedure_name VARCHAR(300)
)
AS

BEGIN

DROP TABLE IF EXISTS dbo.SQL_query_table;

CREATE TABLE dbo.SQL_query_table (
     id INT IDENTITY(1,1) NOT NULL
    ,query_txt NVARCHAR(4000)
)

INSERT INTO dbo.SQL_query_table
EXEC sp_helptext  
	@objname = @Procedure_name



DECLARE @proc_text varchar(MAX) = ''
DECLARE @proc_text_row varchar(MAX)
DECLARE @proc_no_comment varchar(MAX) = ''
DECLARE @comment_count INT = 0


SELECT @proc_text = @proc_text + CASE 
								WHEN LEN(@proc_text) > 0 THEN '\n' 
								ELSE '' END + query_txt
FROM dbo.SQL_query_table


DECLARE @i INT  = 1
DECLARE @rowcount INT = (SELECT LEN(@proc_text))

WHILE (@i <= @rowcount) 
	BEGIN
		 IF SUBSTRING(@proc_text,@i,2) = '/*'
			BEGIN
				SELECT @comment_count = @comment_count + 1
			END
		 ELSE IF SUBSTRING(@proc_text,@i,2) = '*/'  
			BEGIN
				SELECT @comment_count = @comment_count - 1  
			END
		 ELSE IF @comment_count = 0
			SELECT @proc_no_comment = @proc_no_comment + SUBSTRING(@proc_text,@i,1)

		 IF SUBSTRING(@proc_text,@i,2) = '*/' 
		  SELECT @i = @i + 2
		 ELSE
		  SELECT @i = @i + 1
	END


WHILE (@i <= @rowcount) 
	BEGIN
		 IF SUBSTRING(@proc_text,@i,4) = '/*/*'
			BEGIN
				SELECT @comment_count = @comment_count + 2
			END
		 ELSE IF SUBSTRING(@proc_text,@i,4) = '*/*/'  
			BEGIN
				SELECT @comment_count = @comment_count - 2 
			END
		 ELSE IF @comment_count = 0
			SELECT @proc_no_comment = @proc_no_comment + SUBSTRING(@proc_text,@i,1)

		 IF SUBSTRING(@proc_text,@i,4) = '*/*/' 
		  SELECT @i = @i + 2
		 ELSE
		  SELECT @i = @i + 1
	END

DROP TABLE IF EXISTS  #tbl_sp_no_comments
CREATE TABLE #tbl_sp_no_comments (
			 rn INT IDENTITY(1,1)
			,sp_text VARCHAR(8000)
			)


WHILE (LEN(@proc_no_comment) > 0)
	BEGIN

		INSERT INTO  #tbl_sp_no_comments (sp_text)
		SELECT SUBSTRING( @proc_no_comment, 0, CHARINDEX('\n', @proc_no_comment))
		
		SELECT @proc_no_comment = SUBSTRING(@proc_no_comment, CHARINDEX('\n',@proc_no_comment) + 2, LEN(@proc_no_comment))
	END


DROP TABLE IF EXISTS  #tbl_sp_no_comments_fin
CREATE TABLE #tbl_sp_no_comments_fin 
			(rn_orig INT IDENTITY(1,1)
			,rn INT
			,sp_text_fin VARCHAR(8000))


DECLARE @nofRows INT =  (SELECT COUNT(*) FROM #tbl_sp_no_comments)
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
		,CASE WHEN @Com = 0 THEN sp_text
			  WHEN @Com <> 0 THEN SUBSTRING(sp_text, 0, @Com) END as new_sp_text
	FROM #tbl_sp_no_comments
	WHERE 
		rn = @ii
	SET @ii = @ii + 1

END


SELECT 
	 rn
	,sp_text_fin  
FROM #tbl_sp_no_comments_fin
WHERE	
	DATALENGTH(sp_text_fin) > 0 
AND LEN(sp_text_fin) > 0


END;

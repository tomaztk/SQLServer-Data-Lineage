USE lineage;
GO


/* ******************************
*
* 1. Remove unnecessary characters
*
******************************** */

CREATE OR ALTER FUNCTION dbo.fn_removelistChars
/*
Author: Tomaz Kastrun
Created: 06.JUN.2022

Desc: Function for removing list of unwanted characters

Usage:
	SELECT dbo.fn_removelistChars('Tol~99""''''j\e.j/e[,t&eks]t,ki')

*/
(
	@txt AS VARCHAR(max)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @list VARCHAR(200) = '%[^a-zA-Z0-9+@#\/%=_?!:.''-]%'
    WHILE PATINDEX(@list,@txt) > 0
		SET @txt = REPLACE(@txt,SUBSTRING(@txt,PATINDEX(@list,@txt),1),'')
RETURN @txt

END;
GO   



CREATE OR ALTER PROCEDURE dbo.TSQL_data_lineage 
/*
Author: Tomaz Kastrun
Date: August 2022

GitHub: github.com/tomaztk
Blogpost: 

Description:
	Removing all comments from your T-SQL Query for a given procedure for better code visibility and readability - separate function 
    Remove all unused characters.
    Create data lineage for inputed T-SQL query

Usage:
	EXEC dbo.TSQL_data_lineage 
		@InputQuery = N'  SELECT * FROM master.dbo.spt_values '

*/
(
	@InputQuery NVARCHAR(MAX) 
)
AS
BEGIN

/* ******************************
*
* 2. Remove comments characters
*
******************************** */


DROP TABLE IF EXISTS dbo.SQL_query_table

CREATE TABLE dbo.SQL_query_table (
    id INT IDENTITY(1,1) NOT NULL
    ,query_txt NVARCHAR(4000)
)

    -- Breaks the procedure into lines with linebreak
    -- INSERT INTO dbo.SQL_query_table
    -- EXEC sp_helptext  
    --     @objname =  @InputQuery

        -- Breaks the query into lines with linebreak
            DECLARE @MAX_nof_break INT = (select len(@InputQuery) - len(replace(@InputQuery, CHAR(10), '')))
            DECLARE @start_nof_break INT = 1
            declare @iq2 NVARCHAR(max) = @InputQuery

            declare @max_len int = (SELECT len(@InputQuery))
            declare @start_pos int = 0
            declare @br_pos int = 0



            while (@MAX_nof_break >= @start_nof_break)
            BEGIN

                SET @br_pos = (SELECT charindex( char(10), @iq2) )
                INSERT INTO dbo.SQL_query_table(query_txt)
                    SELECT  substring(@InputQuery,@start_pos, @br_pos )
                
                SET @start_pos = @start_pos + @br_pos  
                SET @iq2 = SUBSTRING(@InputQuery, @start_pos, @max_len)
                SET @start_nof_break = @start_nof_break + 1
            END


    --- STart removing comments
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

DROP TABLE IF EXISTS  dbo.Query_results_no_comment

SELECT 
    rn
    ,sp_text_fin  
INTO dbo.Query_results_no_comment
FROM #tbl_sp_no_comments_fin
WHERE	
    DATALENGTH(sp_text_fin) > 0 
AND LEN(sp_text_fin) > 0


/* ******************************
*
* 3. Create data lineage 
*
******************************** */



DECLARE @orig_q VARCHAR(MAX) 
SELECT @orig_q = COALESCE(@orig_q + ', ', '') + sp_text_fin
FROM dbo.Query_results_no_comment
order by rn asc

DROP TABLE IF EXISTS dbo.LN_Query


DECLARE @stmt2 NVARCHAR(MAX)
SET @stmt2 = REPLACE(REPLACE(@orig_q, CHAR(13), ' '), CHAR(10), ' ')


SELECT 
     TRIM(REPLACE(value, ' ','')) as val
    ,dbo.fn_removelistChars(value) as val_f
    ,row_number() over (ORDER BY (SELECT 1)) as rn
INTO dbo.LN_Query
from string_split(REPLACE(@stmt2, CHAR(13), ' '), ' ' )
WHERE
    REPLACE(value, ' ','') <> ' ' 
OR REPLACE(value, ' ','') <> ' '



DECLARE @table TABLE (command_ VARCHAR(200), location_ VARCHAR(200), order_ INT)
DECLARE @command_i VARCHAR(200) = ''
DECLARE @next_step BIT = 0 -- FALSE (1 = TRUE)
DECLARE @previous VARCHAR(200) = ''
DECLARE @order INT = 1
DECLARE @previous_cmd VARCHAR(200) = ''
DECLARE @previous_step BIT = 0 -- FALSE

DECLARE @ttok VARCHAR(100) = ''


DECLARE @i_row INT = 1
DECLARE @max_row INT = (SELECT MAX(rn) FROM dbo.LN_Query)

DECLARE @row_commands_1 NVARCHAR(1000) = 'select,delete,insert,drop,create,select,truncate,exec,execute'
DECLARE @row_commands_2 NVARCHAR(1000) = 'select,not,if,exists,select'
DECLARE @row_commands_3 NVARCHAR(1000) = 'from,join,into,table,exists,sys.dm_exec_sql_text,sys.dm_exec_cursors,exec,execute'


WHILE (@max_row >= @i_row)
BEGIN
		DECLARE @command VARCHAR(1000) = (SELECT val FROM dbo.LN_Query WHERE rn = @i_row)

			IF @command IN (SELECT REPLACE(TRIM(LOWER(value)), ' ','') FROM STRING_SPLIT(@row_commands_1, ','))
			BEGIN
				IF LOWER(@command) = 'select'
					BEGIN
						SET @command = 'select'
					END
				SET @command_i = @command
			END
			IF (@next_step = 1)
			BEGIN
					IF @command NOT IN (SELECT REPLACE(TRIM(LOWER(value)), ' ',' ') FROM STRING_SPLIT(@row_commands_2,','))
					BEGIN
						IF (LOWER(@previous) = 'into')
							SET @command_i = 'select into'
						IF (@command NOT LIKE '%#%' OR @command NOT LIKE '%#%')
						
								SET @ttok = ' ' + @command + ' as ('
								 IF (@ttok NOT IN (SELECT @stmt2))
									INSERT INTO @table (command_, location_, order_)
									SELECT 
										 @command_i
										,@command
										,@order

						SET @command_i = @command_i
					END
					SET @next_step = 0
					IF @command  IN ('sys.dm_exec_sql_text','sys.dm_exec_cursors')
					BEGIN SET @next_step = 1  END
			END
			IF (@command IN (SELECT REPLACE(TRIM(LOWER(value)), ' ','') FROM STRING_SPLIT(@row_commands_3,',')))
			BEGIN
				SET @next_step = 1
			END

			SET @previous_cmd  = @command_i
			SET @previous = @command							

			SET @i_row = @i_row + 1
END

DROP TABLE IF EXISTS dbo.final_result
-- Final results
SELECT *
,row_number() over (order by (select 1)) as rn 
INTO dbo.final_result
FROM @table


SELECT 
  [command_] AS Clause_name
 ,[location_] AS Object_Name
 ,rn AS order_DL
 FROM dbo.final_result


END;
GO


/* **************************
*
* -- TEST functionalities
*
************************* */

DECLARE @test_query VARCHAR(MAX) = '

-- This is a sample query to test data lineage
SELECT 
    s.[BusinessEntityID]
    ,p.[Title]
    ,p.[FirstName]
    ,p.[MiddleName]
   -- ,p.[LastName]
    ,p.[Suffix]
    ,e.[JobTitle] as JobName
    ,p.[EmailPromotion]
    ,s.[SalesQuota]
    ,s.[SalesYTD]
    ,s.[SalesLastYear]
	,( SELECT GETDATE() ) AS DateNow
	,( select count(*)  FROM [AdventureWorks2014].sales.[SalesPerson] ) as totalSales

/*

Adding some comments!

*/

FROM [AdventureWorks2014].sales.[SalesPerson] s
    LEFT JOIN [AdventureWorks2014].[HumanResources].[Employee] e 
    ON e.[BusinessEntityID] = s.[BusinessEntityID]
	INNER JOIN [AdventureWorks2014].[Person].[Person] AS p
	ON p.[BusinessEntityID] = s.[BusinessEntityID]

'


EXEC dbo.TSQL_data_lineage 
  @InputQuery = @test_query


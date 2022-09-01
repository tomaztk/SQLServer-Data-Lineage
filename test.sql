USE Lineage;
GO


CREATE OR ALTER FUNCTION dbo.fn_removelistChars
/*
Desc: Function for removing list of unwanted characters
Created: 06.JUN.2022
Author: TK
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


CREATE OR ALTER PROCEDURE dbo.sp_removeComments
AS
BEGIN
-- comments
END;
GO


declare @stmt VARCHAR(8000) = '

SELECT 
    s.[BusinessEntityID]
    ,p.[Title]
    ,p.[FirstName]
    ,p.[MiddleName]
    ,p.[LastName]
    ,p.[Suffix]
    ,e.[JobTitle] as imeSluzbe
    ,p.[EmailPromotion]
    ,s.[SalesQuota]
    ,s.[SalesYTD]
    ,s.[SalesLastYear]
	,( SELECT GETDATE() ) AS DateNow
	,( select count(*)  FROM [AdventureWorks2014].sales.[SalesPerson] ) as totalSales

FROM [AdventureWorks2014].sales.[SalesPerson] s
    LEFT JOIN [AdventureWorks2014].[HumanResources].[Employee] e 
    ON e.[BusinessEntityID] = s.[BusinessEntityID]
	INNER JOIN [AdventureWorks2014].[Person].[Person] AS p
	ON p.[BusinessEntityID] = s.[BusinessEntityID]

'





DROP TABLE IF EXISTS TK_TEST2

DECLARE @stmt2 NVARCHAR(4000)
SET @stmt2 = REPLACE(REPLACE(@stmt, CHAR(13), ' '), CHAR(10), ' ')


select 
TRIM(REPLACE(value, ' ','')) as val
,dbo.fn_removelistChars(value) as val_f
,row_number() over (ORDER BY (SELECT 1)) as rn
INTO TK_TEST2
from string_split(REPLACE(@stmt2, CHAR(13), ' '), ' ' )
WHERE
    REPLACE(value, ' ','') <> ' ' 
OR REPLACE(value, ' ','') <> ' '




SELECT 
*
,case when val like '%(%' then 1 else 0 end as predok
,case when val like '%)%' then 1 else 0 end as zak
,case when val like '%select%' then 1 else 0 end as select_
,case when val like '%FROM%' then 1 else 0 end as from_
,case when val like '%join%' then 1 else 0 end as join_
,case when val like '%where%' then 1 else 0 end as where_
FROM TK_TEST2






-- @token = @tokenen
-- @token_i = @tokenen_i

DECLARE @table TABLE (tik varchar(100), tok varchar(100), order_ INT)
DECLARE @token_i VARCHAR(100) = ''
DECLARE @get_next BIT = 0 -- FALSE (1 = TRUE)
DECLARE @previous VARCHAR(100) = ''
DECLARE @order INT = 1
DECLARE @previous_tik VARCHAR(100) = ''
DECLARE @previous_get BIT = 0 -- FALSE

DECLARE @ttok VARCHAR(100) = ''


DECLARE @i_row INT = 1
DECLARE @max_row INT = (SELECT MAX(rn) FROM TK_TEST2)
DECLARE @row_commands_1 NVARCHAR(1000) = 'select,delete,insert,drop,create,select,truncate,exec,execute'
DECLARE @row_commands_2 NVARCHAR(1000) = 'select,not,if,exists,select'
DECLARE @row_commands_3 NVARCHAR(1000) = 'from,join,into,table,exists,sys.dm_exec_sql,exec,execute'



WHILE (@max_row >= @i_row)
BEGIN
		DECLARE @token VARCHAR(1000) = (SELECT val FROM TK_TEST2 WHERE rn = @i_row)

			IF @token IN (SELECT REPLACE(TRIM(LOWER(value)), ' ','') FROM STRING_SPLIT(@row_commands_1, ','))
			BEGIN
				IF LOWER(@token) = 'select'
					BEGIN
						SET @token = 'select'
					END
				SET @token_i = @token
			END
			IF (@get_next = 1)
			BEGIN
					IF @token NOT IN (SELECT REPLACE(TRIM(LOWER(value)), ' ',' ') FROM STRING_SPLIT(@row_commands_2,','))
					BEGIN
						IF (LOWER(@previous) = 'into')
							SET @token_i = 'select into'
						IF (@token NOT LIKE '%#%' OR @token NOT LIKE '%#%')
						
								SET @ttok = ' ' + @token + ' as ('
								--IF (@ttok NOT IN (SELECT @token))
								 IF (@ttok NOT IN (SELECT @stmt2))
									INSERT INTO @table (tik, tok, order_)
									SELECT @token_i, @token, @order

						SET @token_i = @token_i
					END
					SET @get_next = 0
					IF @token = 'sys.dm_exec_sql_text'
					BEGIN
						SET @get_next = 1 
					END
			END
			IF (@token IN (SELECT REPLACE(TRIM(LOWER(value)), ' ','') FROM STRING_SPLIT(@row_commands_3,',')))
			BEGIN
				SET @get_next = 1
			END

			SET @previous_tik  = @token_i
			SET @previous = @token							

			SET @i_row = @i_row + 1
END

-- Final results
SELECT *, row_number() over (order by (select 1)) as rn FROM @table






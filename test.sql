use AdventureWorks2014;

declare @stmt nvarchar(4000) = '

SELECT 
    s.[BusinessEntityID]
    ,p.[Title]
    ,p.[FirstName]
    ,p.[MiddleName]
    ,p.[LastName]
    ,p.[Suffix]
    ,e.[JobTitle]
    ,p.[EmailPromotion]
    ,s.[SalesQuota]
    ,s.[SalesYTD]
    ,s.[SalesLastYear]
	,( SELECT GETDATE()) AS DateNow
	,(select count(*)  FROM [AdventureWorks2014].sales.[SalesPerson]) as totalSales

FROM [AdventureWorks2014].sales.[SalesPerson] s
    INNER JOIN [AdventureWorks2014].[HumanResources].[Employee] e 
    ON e.[BusinessEntityID] = s.[BusinessEntityID]
	INNER JOIN [AdventureWorks2014].[Person].[Person] p
	ON p.[BusinessEntityID] = s.[BusinessEntityID]
'



DECLARE @stmt AS NVARCHAR(2000)

SET @stmt ='SELECT
 d1.name
,d1.database_id
,(select GETDATE()) as dd
,X.compatibility_level 

from sys.databases as d1
join (select * from sys.databases) as x
on x.name = d1.name'



-- exec sp_executesql @stmt


/*
query info
*/

declare @q_len int = DATALENGTH(@stmt)
declare @i int = 1

declare @Results TABLE (SearchWord VARCHAR(100),
    i int,
    j int,
    sqlobject nvarchar(100))


declare @res_words nvarchar(1000) = 'from,join,where,exists,with,apply,select'

DECLARE @reserved_words_tables TABLE (id int identity(1,1),
    word varchar(100))
INSERT INTO @reserved_words_tables
    (word)
SELECT [VALUE]
FROM string_split(@res_words, ',')

DECLARE @result_table TABLE (rword varchar(100),
    position int,
    rwordlen int,
    tableName varchar(1000))


while @i <= (select max(id)
from @reserved_words_tables)
begin
    DECLARE @int_word nvarchar(100) = (select word
    from @reserved_words_tables
    where id = @i)
    declare @ii int = 1
    while @ii < @q_len
	begin
        if substring(@stmt,@ii,LEN(@int_word)) = @int_word
		begin
            INSERT into  @result_table
            SELECT
                @int_word
					  , @ii
					  , LEN(@int_word)

					    , REPLACE(REPLACE(SUBSTRING(
				       TRIM(SUBSTRING(@stmt, @ii+LEN(@int_word), @q_len))
						,1
						,PATINDEX('% %', TRIM(SUBSTRING(@stmt, @ii+LEN(@int_word), @q_len)))), ')',''),'(','') as tableName
        END
        SET @ii += 1
    END

    SET @i = @i + 1

END

DROP TABLE IF EXISTS dbo.TK_test;

select
    row_number() over (ORDER BY position ASC) as RN
, * 
, 0 AS LVL
into TK_test
from @result_table
order by position asc
-- last from that can be before join or select or exists



IF (SELECT rword
from TK_TEST
where rn = 1 ) = 'SELECT'
BEGIN
    -- select first
    UPDATE TK_TEST
        SET lvl = 1
    WHERE 
        RN = 1
END
ELSE BEGIN
    -- SELECT NOT first
    DECLARE @res_words2_order NVARCHAR(1000) = 'select,delete,insert,drop,create,truncate,exec,execute'
    SELECT 'No'
END


SELECT *
FROM TK_TEST
order by rn asc



---- test
DROP TABLE IF EXISTS TK_TEST2
declare @st nvarchar(200) = '

select  a, b, c from  dbo.tabela join  dbo.tabla as ta 
on tabela.a = tabla.b  
where a > b and c = 201;'


DECLARE @st2 NVARCHAR(200)
SET @st2 = REPLACE(REPLACE(@st, CHAR(13), ''), CHAR(10), '')


select 
TRIM(REPLACE(value, ' ','')) as val
,row_number() over (ORDER BY (SELECT 1)) as rn
INTO TK_TEST2
from string_split(REPLACE(@st, CHAR(13), ' '), ' ' )
WHERE
    REPLACE(value, ' ','') <> ' ' 
OR REPLACE(value, ' ','') <> ' '


SELECT * FROM TK_TEST2

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
								 IF (@ttok NOT IN (SELECT @st2))
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

SELECT * FROM @table

/*

DECLARE @prev_word VARCHAR(1000), @int_word VARCHAR(1000)
DEclare @row_commands nvarchar(1000) = 'select,delete,insert,drop,create,select,truncate,exec,execute'
declare @result table (wordd varchar(100), intt varchar(100), i_row varchar(100))

WHILE @max_row >= @i_row
BEGIN
    DECLARE @row VARCHAR(1000) = (SELECT val FROM TK_TEST2 WHERE rn = @i_row)
    IF lower(@row) in (SELECT replace(trim(lower(value)), ' ','') from string_split(@row_commands, ','))
         IF @row = 'select'
         BEGIN
            SET @int_word = 'SELECT'
           SELECT @int_word
           END
        ELSE
            SET @row = @prev_word
            IF LOWER(@int_word) NOT IN (SELECT replace(trim(lower(value)), ' ','') from string_split(@row_commands, ','))
            BEGIN
                IF LOWER(@prev_word) = 'INTO'
                SET @int_word = 'SELECT INTO'
                    IF LOWER (@prev_word) NOT LIKE '%#%' OR LOWER(@prev_word)  NOT LIKE '%@%'
                    SET @prev_word = ' ' + @prev_word + ' as ('

		    IF @int NOT IN (SELECT replace(trim(lower(value)), ' ','') from string_split(@row_commands, ','))
			     INSERT INTO @result
			     SELECT 
			     	@word, @int, @i_row
				
				SET @i_row += 1
				SET @int = REPLACE(@int,  ' ', '')
            END
        
    ELSE
    BEGIN
        SELECT 'no'
    END
    SET @i_row = @i_row + 1
END

*/

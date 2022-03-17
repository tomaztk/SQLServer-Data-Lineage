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


-- exec sp_executesql @stmt


/*
query info
*/

declare @q_len int = DATALEngth(@stmt)
declare @i int = 1

declare @Results TABLE (SearchWord VARCHAR(100), i int, j int, sqlobject nvarchar(100))


declare @res_words nvarchar(1000) = 'from,join,where,exists,with,apply,select'

DECLARE @reserved_words_tables TABLE (id int identity(1,1), word varchar(100))
INSERT INTO @reserved_words_tables (word)
SELECT [VALUE] FROM string_split(@res_words, ',')

DECLARE @result_table TABLE (rword varchar(100), position int, rwordlen int, tableName varchar(1000))


while @i <= (select max(id) from @reserved_words_tables)
begin
	DECLARE @int_word nvarchar(100) = (select word from @reserved_words_tables where id = @i)
	declare @ii int = 1
	while @ii < @q_len
	begin
		if substring(@stmt,@ii,LEN(@int_word)) = @int_word
		begin
					INsert into  @result_table
					 SELECT 
					 @int_word
					  ,@ii
					  ,LEN(@int_word)

					    ,REPLACE(REPLACE(SUBSTRING(
				       TRIM(SUBSTRING(@stmt, @ii+LEN(@int_word), @q_len))
						,1
						,PATINDEX('% %', TRIM(SUBSTRING(@stmt, @ii+LEN(@int_word), @q_len)))), ')',''),'(','') as tableName
			END
			SET @ii += 1		
		END
		
	 SET @i = @i + 1 

END


select *from @result_table
order by position asc
-- last from that can be before join or select or exists
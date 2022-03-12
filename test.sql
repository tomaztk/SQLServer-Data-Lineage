use [AdventureWorks2014];

DECLARE @sqlStatement3 AS VARCHAR(2000)
SET @sqlStatement3 ='
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
FROM [AdventureWorks2014].sales.[SalesPerson] s
    INNER JOIN [AdventureWorks2014].[HumanResources].[Employee] e 
    ON e.[BusinessEntityID] = s.[BusinessEntityID]
	INNER JOIN [AdventureWorks2014].[Person].[Person] p
	ON p.[BusinessEntityID] = s.[BusinessEntityID]
'


DECLARE @maxl INT = (SELECT DATALENGTH(@sqlStatement3))

DECLARE @reserved_words_tables TABLE (id int identity(1,1), word varchar(100))

INSERT INTO @reserved_words_tables (word)
 	     SELECT 'from' 
UNION ALL SELECT 'join' 
UNION ALL SELECT 'with' 
UNION ALL SELECT 'where'
UNION ALL SELECT 'exists'


DECLARE @jj INT = 1
DECLARE @rwt INT = (SELECT COUNT(*) FROM @reserved_words_tables)

DECLARE @Results TABLE (SearchWord VARCHAR(100), j INT, s_len INT, SQLObject VARCHAR(100), lvl INT)

WHILE @jj <= @rwt
BEGIN
		DECLARE @lvl INT = 0
		DECLARE @j INT = 1
		DECLARE @search_res_word VARCHAR(100)
	    SET @search_res_word  = (SELECT word from @reserved_words_tables where id=@jj)
	    DECLARE @s_len int = DATALENGTH(@search_res_word)
		print @search_res_word

		WHILE @j < LEN(@sqlStatement3)
		BEGIN

			IF  (SUBSTRING(@sqlStatement3,@j,@s_len) = @search_res_word)
			
		
				BEGIN
				INSERT INTO @Results(SearchWord,j,s_len,SQLObject, lvl)
 
					 SELECT 
					 @search_res_word
					  ,@j
					  ,@s_len
					 
					  ,REPLACE(REPLACE(SUBSTRING(
				       TRIM(SUBSTRING(@sqlStatement3, @j+@s_len, @maxl))
						,1
						,PATINDEX('% %', TRIM(SUBSTRING(@sqlStatement3, @j+@s_len, @maxl)))), ')',''),'(','')
						 as tableName
						 ,@lvl

				END
			
			SET @j += 1		
		END
		
	 SET @jj = @jj + 1 

END

SELECT * FROM @Results
	WHERE	SQLObject IS NOT NULL AND SQLObject <> ''





/***************************************************************************

-- Searching for T-SQL reserved words

****************************************************************************/


DECLARE @reserved_words TABLE (id int identity(1,1), word varchar(100))

INSERT INTO @reserved_words (word)
	     SELECT 'select ' 
union all select 'from ' 
union all select 'join ' 
union all select 'where ' 
union all select 'GROUP BY ' 


DECLARE @sqlStatement AS VARCHAR(200)
SET @sqlStatement ='
SELECT  
 t.[name]
,t.object_id
,t.schema_id
,( select
    8 * SUM(a.used_pages) 
FROM sys.indexes AS i
    JOIN sys.partitions AS p ON p.OBJECT_ID = i.OBJECT_ID AND p.index_id = i.index_id
    JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
WHERE
    i.object_id = t.object_id) AS ''Indexsize(KB)''

FROM sys.tables AS t
JOIN ( select * from sys.columns) AS O
ON t.object_id=o.object_Id
WHERE
	t.name like ''s%''
'

DECLARE @search_results TABLE (
		 id int identity(1,1)
		,Res_word varchar(100)
		,pos_start INT
		,pos_end INT)


DECLARE @ii INT = 1
DECLARE @nof_words INT  = (SELECT COUNT(DISTINCT word) FROM @reserved_words)


WHILE @ii <= @nof_words
BEGIN
	
	  DECLARE @i INT = 1
	  DECLARE @search_res_word AS VARCHAR(100)  
	  SET @search_res_word = (SELECT word from @reserved_words where id=@ii)
	  DECLARE @word_len int = LEN(@search_res_word)
		
	  WHILE @i < LEN(@sqlStatement)
		BEGIN

		  IF  (SUBSTRING(@sqlStatement,@i,@word_len) = @search_res_word)
		      BEGIN
			   INSERT INTO @search_results (res_word, pos_start, pos_end)
			   SELECT @search_res_word, @i, @i+LEN(@search_res_word)
		      END
		   SET @i = @i + 1		END


	SET @ii = @ii + 1 
END


select * from @search_results


DECLARE @lin_table TABLE (
		 id int identity(1,1)
		 ,[level] INT
		,[schema] varchar(100)
		,[table] VARCHAR(100)
		)


/***************************************************************************

-- Searching for T-SQL reserved words: FROM, JOIN, WITH 
-- to create a list of tables

****************************************************************************/



DECLARE @sqlStatement2 AS VARCHAR(2000)
SET @sqlStatement2 ='
SELECT  
 t.[name]
,t.object_id
,t.schema_id
,( select
    8 * SUM(a.used_pages) 
FROM sys.indexes AS i 
 JOIN sys.partitions AS p ON p.OBJECT_ID = i.OBJECT_ID AND p.index_id = i.index_id 
 JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
WHERE
    i.object_id = t.object_id) AS ''Indexsize(KB)''

FROM sys.tables AS t
JOIN ( select * from sys.columns join dbo.tables on columns.object_id = tables.object_id) AS O
ON t.object_id=o.object_Id
WHERE
	t.name like ''s%''
'


DECLARE @maxl INT = (SELECT DATALENGTH(@SqlStatement2))

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

		WHILE @j < LEN(@sqlStatement2)
		BEGIN

			IF  (SUBSTRING(@sqlStatement2,@j,@s_len) = @search_res_word)
			
		
				BEGIN
				INSERT INTO @Results(SearchWord,j,s_len,SQLObject, lvl)
 
					 SELECT 
					 @search_res_word
					  ,@j
					  ,@s_len
					 
					  ,REPLACE(REPLACE(SUBSTRING(
				       TRIM(SUBSTRING(@sqlStatement2, @j+@s_len, @maxl))
						,1
						,PATINDEX('% %', TRIM(SUBSTRING(@sqlStatement2, @j+@s_len, @maxl)))), ')',''),'(','')
						 as tableName
						 ,@lvl

				END
			
			SET @j += 1		
		END
		
	 SET @jj = @jj + 1 

END

SELECT * FROM @Results
	WHERE	SQLObject IS NOT NULL AND SQLObject <> ''





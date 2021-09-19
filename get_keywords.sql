

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
****************************************************************************/
-- name of the tables / objects
-- after from statement, if not followed by (
-- or FROM ( select .. from)



DECLARE @j INT = 1
DECLARE @search_FROM AS VARCHAR(100)  
SET @search_res_word = 'from '
DECLARE @s_len int = DATALENGTH(@search_res_word)
		
WHILE @j < LEN(@sqlStatement)
BEGIN

	IF  (SUBSTRING(@sqlStatement,@j,@s_len) = @search_res_word)
		BEGIN
		
		SELECT 
			@search_res_word
		   ,@j
		   ,@s_len
		   ,SUBSTRING(@sqlStatement, 
		                 @j+@s_len, 
						 charindex(' ', @Search_res_word)+@s_len+1
						)
		END
	SET @j = @j + 1		
END

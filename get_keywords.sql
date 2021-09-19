

DECLARE @reserved_words TABLE (id int identity(1,1), word varchar(100))

INSERT INTO @reserved_words (word)
	     SELECT 'select' 
union all select 'from' 
union all select 'join' 
union all select 'where' 
union all select 'GROUP BY' 


DECLARE @sqlStatement AS VARCHAR(200)
SET @sqlStatement ='
SELECT  
 [name]
,object_id
,schema_id
FROM sys.tables AS t
JOIN (select * from sys.objects where type = ''IT'') AS O
ON t.object_id = o.object_Id
WHERE
	t.name like ''test%''
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

-- name of the tables / objects
-- after from statement, if not followed by (


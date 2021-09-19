

DECLARE @reserved_words TABLE (id int identity(1,1), word varchar(100))

INSERT INTO @reserved_words (word)
	     SELECT 'select' 
union all select 'from' 
union all select 'join' 
union all select 'where' 
union all select 'GROUP BY' 


DECLARE @sqlStatement AS VARCHAR(200)
SET @sqlStatement ='
SELECT top 10 
 [name]
,object_id
,schema_id
from sys.tables
join (select * from sys.objects)
'

DECLARE @search_results TABLE (
		 id int identity(1,1)
		,word varchar(100)
		,pos INT
		,posEND INT)


DECLARE @ii INT = 1
DECLARE @nof_words INT  = (SELECT COUNT(DISTINCT word) FROM @reserved_words)


WHILE @ii <= @nof_words
BEGIN
	
	  DECLARE @i INT = 1
	  DECLARE @Search_String AS VARCHAR(100)  
	  SET @Search_String = (SELECT word from @reserved_words where id=@ii)
	  PRINT @search_string
	  DECLARE @stringLen int = LEN(@Search_String)
		
	  WHILE @i < LEN(@sqlStatement)
		BEGIN

		  IF  (SUBSTRING(@sqlStatement,@i,@stringLen) = @Search_String)
		      BEGIN
			   insert into @search_results (word, pos, posEND)
			   select @Search_String, @i, @i+LEN(@Search_String)
		      END
		   SET @i = @i + 1		END


	SET @ii = @ii + 1 
END


select * from @search_results

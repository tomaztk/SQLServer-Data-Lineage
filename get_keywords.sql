DECLARE @String AS VARCHAR(200)

DECLARE @search_words TABLE (id int identity(1,1), word varchar(100))
INSERT INTO @search_words
SELECT 'the' union all select 'from' union all select 'join' union all select 'where'

--select * from @search_words

SET @String ='The sql server is the best from the universe where you join the best of the best'

DECLARE @search_results TABLE (id int identity(1,1), word varchar(100), pos INT)

declare @i int = 1
--declare @Result varchar(100) = ''
DECLARE @ii INT = 1
DECLARE @nof_words INT = (Select COUNT (distinct word) from @search_results)

select @nof_words

while @ii <= @nof_words
BEGIN
	
	   DECLARE @Search_String AS VARCHAR(100)
	   set @Search_String = (SELECT word from @search_results where id=@ii)
		
		declare @stringLen int = LEN(@Search_String)
		print @search_string
		WHILE @i < LEN(@String)
		BEGIN

		  if SUBSTRING(@String,@i,@stringLen) = @Search_String
		   begin
			insert into @search_results (word, pos)
			select @Search_String, @i
		   end
		  SET @i = @i + 1
		END

		SET @ii = @ii + 1 
END

select * from @search_results

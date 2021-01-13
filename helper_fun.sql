USE QL;
GO

DECLARE @sql VARCHAR(500) = '
-- Query
/* This is our Query */

---- Adding some comments

SELECT 
s.Name
,s.Surname
,d.DepartmentName
-- Comment here
-- /*,d.DepartmentID*/
/* This is a comment */ -- works
---------------------
/* this is a inline comment
in two lines  */
/* /* this is a double comment */*/ -- works
,''test'' AS test
/*/* comment */*/ --nope
FROM Students AS s
JOIN Departments AS D
ON d.DepartmentId = s.DepartmentId'

DECLARE @comment VARCHAR(500)
DECLARE @endPosition INT
DECLARE @startPosition INT
DECLARE @commentLen INT
DECLARE @substrlen INT
DECLARE @len INT

PRINT @sql


-- works fine with single comments block - OK 
-- works fine with double (inline) comment block - NOK
-- works fine with multi-line comment blocks - OK

WHILE ( (CHARINDEX('/*',@sql) <> 0) OR (CHARINDEX('/*/*', @sql) <> 0) )
BEGIN
    SET @endPosition = CHARINDEX('*/',@sql)
    SET @substrlen=LEN(SUBSTRING(@sql,1,@endPosition-1))
    SET @startPosition = @substrlen - CHARINDEX('*/',REVERSE(SUBSTRING(@sql,1,@endPosition-1)))+1
    SET @commentLen = @endPosition - @startPosition
    SET @comment = SUBSTRING(@sql,@startPosition-1,@commentLen+3 )
    SET @sql = REPLACE(@sql,@comment,CHAR(13))
END

PRINT @sql


DECLARE @sql VARCHAR(500) = '-- Query
SELECT top 10 
 [name]
,object_id
--,principal_id
--,schema_did
,schema_id
from sys.tables'

DECLARE @comment VARCHAR(500)
DECLARE @endPosition INT
DECLARE @startPosition INT
DECLARE @commentLen INT
DECLARE @substrlen INT
DECLARE @len INT
DECLARE @StartPos INT

SELECT CHARINDEX(CHAR(10),@sql)
,CHARINDEX('--',@sql)
,Len(@sql)

/*
WHILE  (CHARINDEX('--',@sql) <> 0)
BEGIN
    SET @startPos = CHARINDEX('--', @sql)
	SET @endPosition = CHARINDEX(CHAR(10),@sql)
    SET @commentLen = @endPosition - @startPos
	SET @SQL = SUBSTRING(@SQL,@endPosition-1,LEN(@SQL))
END

PRINT @sql

*/
-- ******************************************************
-- number of rows in query
-- with position of comments and Line Breaks
-- ******************************************************

USE QL;


DROP TABLE IF EXISTS dbo.TableQeury;

CREATE TABLE dbo.TableQeury (
ID INT Identity(1,1)
,rowID INT 
,Comm_positton INT
,LB_position INT)

DECLARE @sql VARCHAR(500) = '-- Query
SELECT top 10 
 [name]
,object_id
--,principal_id
--,schema_did
,schema_id
from sys.tables'

DROP TABLE IF EXISTS dbo.SQL
CREATE TABLE dbo.SQL (
    ID INT IDENTITY(1,1)
    ,TXT NVARCHAR(MAX)
)
 
INSERT INTO dbo.[SQL]
SELECT @SQL

-- At the end...always add CR\LB
UPDATE dbo.[SQL]
SET txt = txt +  CHAR(10)

--PRINT @SQL
SELECT * FROM dbo.SQL

DECLARE @nofRows INT = 1
DECLARE @LastLB INT = 0
DECLARE @Com INT = 0 

SET @Com = (SELECT CHARINDEX('--', txt,@com) FROM dbo.SQL)
PRINT @com

SET @LastLB = (SELECT CHARINDEX(CHAR(10), txt, @LastLB) FROM dbo.SQL)
WHILE @LastLB>=1
BEGIN
	INSERT INTO dbo.TableQeury VALUES (@nofrows, @Com,  @lastLB)
    SET @nofRows=@nofRows+1
    SET @LastLB= (SELECT CHARINDEX(CHAR(10) ,txt,  @LastLB+1) FROM dbo.SQL)
	SET @Com = (SELECT CHARINDEX('--',txt, @LastLB) FROM dbo.SQL)
END


SELECT * FROM dbo.TableQeury


/*----


DECLARE @nofRows INT = 1
DECLARE @LastLB INT = 0
DECLARE @Com INT = 0 

--SET @Com = CHARINDEX('--', @sql,@com)
SET @Com = PATINDEX('%--%', @SQL)
DECLARE @POS INT = 0

SET @LastLB = CHARINDEX(CHAR(10), @sql, @LastLB)
WHILE @LastLB>=1
BEGIN
	INSERT INTO dbo.TableQeury 
	SELECT @nofrows, @Com,  @lastLB
    SET @nofRows =+ 1
    SET @LastLB = CHARINDEX(CHAR(10) ,@sql,  @LastLB+1)
	SET @POS = @LASTLB-1
	--SET @Com = CHARINDEX('--',@sql, @lastlb-(@nofRows*2))
	SET @Com = PATINDEX('%--%',SUBSTRING(@SQL,@LastLB+1, LEN(@SQL)))
	print @com
	-- IF @Com > @LastLB-2  SET @com = @lastLB
END


SELECT * FROM dbo.TableQeury

------ */

##################################


DECLARE  @comm TABLE (pos INT)
DECLARE @pos INT
DECLARE @oldpos INT = 0
SELECT @pos = CHARINDEX('--',@sql) 
DECLARE @REP VARCHAR(MAX) = ''

WHILE @pos > 0 AND @oldpos <> @pos
BEGIN
   INSERT INTO @comm VALUES(@pos)
   SELECT @oldpos=@pos
   SELECT @pos=CHARINDEX('--',Substring(@sql,@pos + 2,len(@sql))) + @pos
   SET @sql = REPLACE(@sql, @rep, '')
   print(@sql)
   SET @REP = SUBSTRING(@SQL, @oldpos, CHARINDEX(CHAR(10), @sql))
   --print (charindex(char(10),@sql))

END

SELECT * FROM @comm
PRINT @SQL

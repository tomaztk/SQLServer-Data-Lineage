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

-- Get number of rows
declare @q_nofrows varchar(4000) = (SELECT TXT from dbo.sql)
print @q_nofrows

select len(@q_nofrows) - len(replace(@q_nofrows, CHAR(10),''))


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




----------------
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
   --PRINT (charindex(char(10),@sql))

END

SELECT * FROM @comm
PRINT @SQL

/*
sp_execute_external_script
@language = N'R'
,@script = N''
,@input_data_1 = 'SELECT * FROM @comm'
*/

-- new v. 17.01.2021

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
--SELECT * FROM dbo.SQL

DECLARE @nofRows INT = 1
DECLARE @LastLB INT = 0
DECLARE @Com INT = 0 

SET @Com = (SELECT CHARINDEX('--', txt,@com) FROM dbo.SQL)
PRINT @com

SET @LastLB = (SELECT CHARINDEX(CHAR(10), txt, @LastLB) FROM dbo.SQL)
print @lastLB
WHILE @LastLB>=1
BEGIN
	INSERT INTO dbo.TableQeury VALUES (@nofrows, @Com,  @lastLB)
    SET @nofRows=@nofRows+1
    SET @LastLB= (SELECT CHARINDEX(CHAR(10) ,txt,  @LastLB+1) FROM dbo.SQL)
    if (@Com > @LastLB+1)
            BEGIN
            SET @com = @LastLB+1
            END
    ELSE 
                BEGIN
                SET @Com = (SELECT CHARINDEX('--',txt, @LastLB) FROM dbo.SQL)
                END
END

DROP TABLE IF EXISTS dbo.QueryByRow

CREATE TABLE dbo.QueryByRow
(ID INT IDENTITy(1,1)
,Row_ID INT
,Start_L INT
,End_L INT
,query_by_row VARCHAR(MAX)
)

INSERT INTO dbo.QueryByRow
-- Rows Start and Rows End
SELECT 
t1.ID as Row_ID
,ISNULL(t2.LB_position,0)+1 as Start_L
,t1.LB_position AS END_L
,SUBSTRING(@sql, ISNULL(t2.LB_position,0), t1.LB_position-ISNULL(t2.LB_position,0)  ) as query_by_row
--,t1.Comm_positton
FROM dbo.TableQeury AS t1
left join dbo.TableQeury as t2
ON t1.id = T2.id+1


-- Get number of rows in Query
DECLARE @q_nofrows VARCHAR(4000) = (SELECT TXT from dbo.sql)
SELECT LEN(@q_nofrows) - LEN(REPLACE(@q_nofrows, CHAR(10),'')) -- nof_rows

SELECT * FROM dbo.QueryByRow

--- Adding  multiline/block comments out

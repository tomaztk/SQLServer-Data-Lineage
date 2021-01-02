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


-- works fine with single comments block
-- works fine with double (inline) comment block
-- works fine with multi-line comment blocks

WHILE (CHARINDEX('/*',@sql)<>0)
BEGIN
    SET @endPosition = charindex('*/',@sql)
    SET @substrlen=len(substring(@sql,1,@endPosition-1))
    SET @startPosition = @substrlen - charINDEX('*/',reverse(substring(@sql,1,@endPosition-1)))+1
    SET @commentLen = @endPosition - @startPosition
    SET @comment = substring(@sql,@startPosition-1,@commentLen+3 )
    SET @sql = REPLACE(@sql,@comment,CHAR(13))
END

PRINT @sql

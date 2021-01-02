USE QL;
GO

DECLARE @sql VARCHAR(400) = '
-- Query
/* This is our Query */

---- Adding some comments

SELECT 
s.Name
,s.Surname
,d.DepartmentName
-- Comment here
-- /*,d.DepartmentID*/
FROM Students AS s
JOIN Departments AS D
ON d.DepartmentId = s.DepartmentId'

DECLARE @comment VARCHAR(400)
DECLARE @endPosition INT
DECLARE @startPosition INT
DECLARE @commentLen INT
DECLARE @substrlen INT
DECLARE @len INT

PRINT @sql

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

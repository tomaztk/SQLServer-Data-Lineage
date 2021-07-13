SELECT @@VERSION

USE master;
GO

CREATE DATABASE QL;
GO

USE QL;
GO

DROP TABLE IF EXISTS dbo.Departments;
CREATE TABLE dbo.Departments
(
 DepartmentId   INT IDENTITY(1,1) NOT NULL
,DepartmentName VARCHAR(20)
)

INSERT INTO dbo.Departments VALUES ('SQL Server') 
INSERT INTO dbo.Departments VALUES ('Power BI') 
INSERT INTO dbo.Departments VALUES ('DBA 101') 
INSERT INTO dbo.Departments VALUES ('Azure SQL Database') 
INSERT INTO dbo.Departments VALUES ('Machine Learning')


DROP TABLE IF EXISTS dbo.Students
CREATE TABLE dbo.Students
(
 StudentId INT IDENTITY(1,1)
,[Name] VARCHAR(20) NOT NULL 
,Surname VARCHAR(40) NOT NULL
,DateOfBirth DATE NOT NULL
,DepartmentId INT NOT NULL
) 

INSERT INTO dbo.Students VALUES( 'Markus', 'Miller', '1980-05-31', 1)
INSERT INTO dbo.Students VALUES( 'Mike', 'Patton', '1968-02-02', 1)
INSERT INTO dbo.Students VALUES( 'Stone', 'Gossard', '1962-07-29', 2)
INSERT INTO dbo.Students VALUES( 'Geoffrey', 'Wilson', '1977-01-21', 3)
INSERT INTO dbo.Students VALUES( 'Mike', 'McCready', '1968-10-10', 4)
INSERT INTO dbo.Students VALUES( 'John', 'Smith', '1975-01-01',4)
INSERT INTO dbo.Students VALUES( 'Abigale', 'Wail', '1955-01-01',3)




CREATE OR ALTER PROCEDURE [dbo].[sql_sample_procedure] 
AS
BEGIN
		-- Query

	    /********************* 
		    This is our Query
      With author, date and place
		   *******************/

		---- Adding some comments

		SELECT 
		s.Name
		,s.Surname
		-- ,s.Surname
		,d.DepartmentName -- Comment there
		-- Comment here
		-- /*,d.DepartmentID*/
		/* This is a comment */ -- works
		---------------------
		/* this is a inline comment
		in two lines  */
		/* /* this is a double comment */*/ -- works
		,'test' AS test
		/* /* comment */*/ --nope
		FROM Students AS s
		JOIN Departments AS D
		ON d.DepartmentId = s.DepartmentId

END;
GO

# Data Lineage for Microsoft SQL Server T-SQL Queries

Data Lineage Transact SQL (T-SQL) for [Microsoft SQL Server](https://www.microsoft.com/en-us/sql-server) enables you to find the data origins and data destinations in your query. It gives you the visibility over query data columns and ability to track the changes over time.


# Features

* Remove any kind of comments from your T-SQL code
* Remove any special characters from your T-SQL code
* Generate data lineage from your T-SQL Code
* Learn interesting facts about your data and get better analytics



# Removing comments from your T-SQL code
Clean your code of in-line and multiple lines of _--comments_ or _slash star_ comments from better visibility and greater readability.

<a href="https://tomaztsql.files.wordpress.com/2021/07/2021-07-13-05_24_06-window.png"><img width="50%" src="https://tomaztsql.files.wordpress.com/2021/07/2021-07-13-05_24_06-window.png"/>
</a>
  
Run **Remove_comments.sql**  to create  a procedure. 
Strip and remove all comments from your T-SQL query by using _dbo.remove_comments_ procedure 

``` sql
--  Run procedure dbo.remove_comments

EXEC dbo.remove_comments
   @procedure_name = N'dbo.MySample_procedure'

```


# Start with Data Lineage on T-SQL

Run **TSQL_data_lineage.sql**  file to create  a lineage procedure. This script includes the removal of comments and special characters and creates the data lineage.


```sql
-- Get your query:
declare @test_query VARCHAR(8000) = '

SELECT 
    s.[BusinessEntityID]
    ,p.[Title]
    ,p.[FirstName]
    ,p.[MiddleName]
    ,p.[LastName]
    ,p.[Suffix]
    ,e.[JobTitle] as imeSluzbe
    ,p.[EmailPromotion]
    ,s.[SalesQuota]
    ,s.[SalesYTD]
    ,s.[SalesLastYear]
	,( SELECT GETDATE() ) AS DateNow
	,( select count(*)  FROM [AdventureWorks2014].sales.[SalesPerson] ) as totalSales

FROM [AdventureWorks2014].sales.[SalesPerson] s
    LEFT JOIN [AdventureWorks2014].[HumanResources].[Employee] e 
    ON e.[BusinessEntityID] = s.[BusinessEntityID]
	INNER JOIN [AdventureWorks2014].[Person].[Person] AS p
	ON p.[BusinessEntityID] = s.[BusinessEntityID]

'

-- And run the procedure with single input parameter
EXEC dbo.TSQL_data_lineage 
  @InputQuery = @test_query
```

# Requirements

The script works with any of the following versions:

* Microsoft SQL Server database (works on all editions and versions 2016+) 
* Azure SQL Database 
* Azure SQL Server 
* Azure SQL MI 



Get started
===========
The easiest way to get started is with fork or clone the repository.


## Cloning the repository
You can follow the steps below to clone the repository.
```
git clone https://github.com/tomaztk/SQLServer-Data-Lineage.git
```

## Read more on blog posts

Remove comments from your T-SQL code ([Blog post](https://tomaztsql.wordpress.com/2021/07/13/remove-comments-from-your-t-sql-code/))


## Collaboration and contributors
Ideas, code collaboration or any other contributions of any kind is highly appreciated! 
Fork the repository, add your code.


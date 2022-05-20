# SQLServer Data  Lineage for T-SQL Queries

Data Lineage Transact SQL (T-SQL) for [Microsoft SQL Server](https://www.microsoft.com/en-us/sql-server) enables you to find the data origins and data destinations in your query. It gives you the visibility over query data columns and ability to track the changes over time.

## Cloning the repository
You can follow the steps below to clone the repository.
```
git clone https://github.com/tomaztk/SQLServer-Data-Lineage.git
```

# Removing comments from your code
Clean your code of in-line and multiple lines of _--comments_ or _slash star_ comments from better visibility and greater readability.

<a href="https://tomaztsql.files.wordpress.com/2021/07/2021-07-13-05_24_06-window.png"><img width="50%" src="https://tomaztsql.files.wordpress.com/2021/07/2021-07-13-05_24_06-window.png"/>
</a>
  

1. Run the support files

Run **helper_fun.sql** helper file, that will create a sample data tables and example procedure.
In addition, run a **remove_comments.sql** file to create a procedure with stripping and removing  all the comments from your T-SQL query.

2. Removing comments from T-SQL Query

Strip and remove all comments from your T-SQL query by using _dbo.remove_comments_ procedure.

``` sql
# Run procedure dbo.remove_comments

EXEC dbo.remove_comments
   @procedure_name = N'sql_sample_procedure'

```


# Quickstart for Data Lineage on T-SQL

1.  Clone the repository
2.  Have your T-SQL query ready
3.  Load the DataLineage table function with your query


``` sql
# Run
DECLARE @t_sql_query NVARCHAR(MAX)
SET @t_sql_query = N'-- Query
SELECT top 10 
 [name]
,object_id
--,principal_id
--,schema_did
,schema_id
from sys.tables'


SELECT dbo.fn_datalineage(@t_sql_query)
```

## Follow and more on blog posts

Remove comments from your T-SQL code ([Blog post](https://tomaztsql.wordpress.com/2021/07/13/remove-comments-from-your-t-sql-code/))

## Contribute

## Write mathematical formulas in Markdown using `$` prefix

Write the following formula `$\sqrt{3x-1}+(1+x)^2$` and it will be rendered as:

$\sqrt{3x-1}+(1+x)^2$

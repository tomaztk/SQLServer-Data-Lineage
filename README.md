# SQLServer Data  Lineage for T-SQL Queries

Data Lineage Transact SQL (T-SQL) for [Microsoft SQL Server](https://www.microsoft.com/en-us/sql-server) enables you to find the data origins and data destinations in your query. It gives you the visibility over query data columns and ability to track the changes over time.

## Cloning the repository
You can follow the steps below to clone the repository.
```
git clone -n https://github.com/tomaztk/SQLServer-Data-Lineage.git
```

# Removing comments from your code
Clean your code of in-line and multiple lines of _--comments_ or _slash star_ comments from better visibility and greater readability.


1. Run the helper_fun.sql
Run helper_fun.sql helper file, that will create a sample data tables and example procedure.

1.  Stripping comments from T-SQL Query

Strip and remove all comments from your T-SQL query by using this procedure.

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


## Getting the results


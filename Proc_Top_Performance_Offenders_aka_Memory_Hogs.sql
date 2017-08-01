 /*
 Memory Hogs
 Author: Marcus Hartman

 This script will identify and sort the Stored Procedures which cost the most resources. Please comment/uncomment the ORDER BY for what resource you want to review.
 */
 
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
 
 SELECT db_name(eST.[dbid]) AS [database]
    , OBJECT_SCHEMA_NAME(ePS.object_id, ePS.database_id) AS [schema]
    , OBJECT_NAME(ePS.object_id, ePS.database_id) AS [procedure_name]
    , ePS.execution_count

    -- CPU TIME (in minutes)
    , ePS.min_worker_time/60000000 AS [min_cpu(minute)]
    , ePS.max_worker_time/60000000 AS [max_cpu(minute)]
    , (ePS.total_worker_time/COALESCE(ePS.execution_count, 1))/60000000 AS [avg_cpu(minute)]
    , ePS.last_elapsed_time/60000000 AS [last_cpu(minute)]
    , ePS.total_worker_time/60000000 AS [total_cpu(minute)]

    -- ELAPSED TIME (in minutes)
    , ePS.min_elapsed_time/60000000 AS [min_duration(minute)]
    , ePS.max_elapsed_time/60000000 AS [max_duration(minute)]
    , (ePS.total_elapsed_time/COALESCE(ePS.execution_count, 1))/60000000 AS [avg_duration(minute)]
    , ePS.last_elapsed_time/60000000 AS [last_duration(minute)]
    , ePS.total_elapsed_time/60000000 AS [total_duration(minute)]  

    -- LOGICAL READS (thousands)
    , ePS.min_logical_reads/1000 AS [min_logical_reads K]
    , ePS.max_logical_reads/1000 AS [max_logical_reads K]
    , (ePS.total_logical_reads/COALESCE(ePS.execution_count, 1))/1000 AS [avg_logical_reads K]
    , ePS.last_logical_reads/1000 AS [last_logical_reads K]
    , ePS.total_logical_reads/1000 [total_logical_reads K]

    -- PHYSICAL READS (thousands)
    , ePS.min_physical_reads/1000 AS [min_physical_reads K]
    , ePS.max_physical_reads/1000 AS [max_physical_reads K]
    , (ePS.total_physical_reads/COALESCE(ePS.execution_count, 1))/1000 AS [avg_physical_reads K]
    , ePS.last_physical_reads/1000 AS [last_physical_reads K]
    , ePS.total_physical_reads/1000 AS [total_physical_reads K]

    -- LOGICAL WRITES (thousands)
    , ePS.min_logical_writes/1000 AS [min_writes K]
    , ePS.max_logical_writes/1000 AS [max_writes K]
    , (ePS.total_logical_writes/COALESCE(ePS.execution_count, 1))/1000 AS [avg_writes K]
    , ePS.last_logical_writes/1000 AS [last_writes K]
    , ePS.total_logical_writes/1000 AS [total_writes K]

    -- CACHE & EXEC TIMES
    , ePS.last_execution_time
    , P.create_date
    , DATEDIFF(HOUR, P.create_date, GetDate()) AS 'hours_since_create'
    , ePS.execution_count/DATEDIFF(HOUR, P.create_date, GetDate()) AS [calls/hour]

    
    --STATEMENTS AND QUERY TEXT DETAILS
    , eST.text AS [stored_procedure_text]
    , eQP.query_plan
    , ePS.plan_handle
FROM sys.dm_exec_procedure_stats AS ePS  
    INNER JOIN sys.procedures AS P ON ePS.object_id = P.object_id
    CROSS APPLY sys.dm_exec_sql_text(ePS.sql_handle) AS eST  
    CROSS APPLY sys.dm_exec_query_plan (ePS.plan_handle) AS eQP 


-- ORDER BY ePS.total_worker_time/COALESCE(ePS.execution_count, 1) DESC -- [avg_cpu]
-- ORDER BY ePS.total_elapsed_time/COALESCE(ePS.execution_count, 1) DESC -- [avg_duration]
 ORDER BY ePS.total_logical_reads/COALESCE(ePS.execution_count, 1) DESC    -- [avg_logical_reads]
-- ORDER BY ePS.total_physical_reads/COALESCE(ePS.execution_count, 1) DESC --[avg_physical_reads]
-- ORDER BY ePS.total_logical_writes/COALESCE(ePS.execution_count, 1) DESC -- [avg_writes]
-- ORDER BY ePS.execution_count DESC --[Executions]

-- Get the execution history for your SSRS reports
SELECT TOP 100 
cat.name, rptlog.*   
FROM [dbo].[ExecutionLogStorage] as rptlog 
inner join .[dbo].[Catalog] cat on rptlog.ReportID = cat.ItemID
order by TimeStart desc

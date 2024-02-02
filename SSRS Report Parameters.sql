
-- Get the details of Parameters used in your SSRS reports

SELECT 
        Cat.ItemID, cat.[Path], cat.Name
        , p.* , cat.*
    FROM dbo.Catalog cat with (nolock)
        JOIN (
                SELECT ReportID = ItemID 
                                ,ParameterName = params.value('(Name/text())[1]', 'varchar(100)')
                                ,Prompt = params.value('(Prompt/text())[1]', 'nvarchar(100)') 
                                ,DataType = params.value('(Type/text())[1]', 'varchar(100)')
                               ,Defaults = params.value('(DefaultValues/Value/text())[1]', 'varchar(100)')
                FROM (
                                SELECT C.ItemID, C.Name,CONVERT(XML,C.Parameter) AS ParameterXML
                                FROM  dbo.Catalog C with (nolock)
                                WHERE  C.Content is not null
                                AND  C.Type  = 2
                                ) a
                cross apply ParameterXML.nodes('//Parameters/Parameter') q (params)
        ) p 
            on cat.ItemID = p.ReportID

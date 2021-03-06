CREATE PROCEDURE stp_TwoColumnPivotWithTableOutput
@PivotColumn VARCHAR(250),
@CalcColumn VARCHAR(250),
@SourceTable VARCHAR(250),
@Function VARCHAR(10)
AS
BEGIN

	DECLARE @c NVARCHAR(4000), @create NVARCHAR(MAX), @sql NVARCHAR(MAX)

	DECLARE @s TABLE(
		S NVARCHAR(MAX)
	)
	
	INSERT INTO @s
	EXECUTE stp_OutputColumns @PivotColumn, @SourceTable
	
	SELECT @c = S FROM @s
	SET @create = 'CREATE TABLE Pivot' + @SourceTable + '(' + REPLACE(@c,',',' INT,') + ' VARCHAR(100))'
	EXEC sp_executesql @create

	SET @sql = N'INSERT INTO Pivot' + @SourceTable + '(' + @c + ')
				SELECT ' + @c + ' FROM (SELECT t.' + @PivotColumn + ', t.' + @CalcColumn + ' FROM ' + @SourceTable + ' t) p
				PIVOT (' + @Function + '(' + @CalcColumn + ') FOR ' + @PivotColumn + ' IN (' + @c + ')) AS pv;
				
				SELECT *
				FROM Pivot' + @SourceTable + '
				
				-- This can be added, if needed
				--DROP TABLE Pivot' + @SourceTable
				
	EXEC sp_executesql @sql
	
END

IF OBJECT_ID('PivotRequest') IS NOT NULL
BEGIN
	DROP TABLE PivotRequest
END

EXECUTE stp_TwoColumnPivotWithTableOutput 'Request','RequestCount','Request','SUM'
	
DROP TABLE PivotRequest

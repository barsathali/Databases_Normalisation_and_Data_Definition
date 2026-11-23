DROP PROCEDURE IF EXISTS dbo.usp_OldOrderFollowUps_Cursor;
GO
CREATE PROCEDURE dbo.usp_OldOrderFollowUps_Cursor AS
BEGIN
 SET NOCOUNT ON; DECLARE @Id int;
 DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT OrderId FROM dbo.SalesOrder o
 WHERE OrderStatus='Pending' AND OrderDate<DATEADD(day,-3,CONVERT(date,GETDATE()))
 AND NOT EXISTS(SELECT 1 FROM dbo.OrderFollowUp f WHERE f.OrderId=o.OrderId);
 OPEN c; FETCH NEXT FROM c INTO @Id;
 WHILE @@FETCH_STATUS=0 BEGIN INSERT dbo.OrderFollowUp(OrderId,Note) VALUES(@Id,'Pending over 3 days — follow up'); FETCH NEXT FROM c INTO @Id; END;
 CLOSE c; DEALLOCATE c;
END;
GO
EXEC dbo.usp_OldOrderFollowUps_Cursor; SELECT 'Cursor' Method,COUNT(*) RowsInserted FROM dbo.OrderFollowUp;
DELETE dbo.OrderFollowUp;
DECLARE @T datetime2=SYSDATETIME();
INSERT dbo.OrderFollowUp(OrderId,Note)
SELECT o.OrderId,'Pending over 3 days — follow up' FROM dbo.SalesOrder o
WHERE o.OrderStatus='Pending' AND o.OrderDate<DATEADD(day,-3,CONVERT(date,GETDATE()))
AND NOT EXISTS(SELECT 1 FROM dbo.OrderFollowUp f WHERE f.OrderId=o.OrderId);
SELECT DATEDIFF(millisecond,@T,SYSDATETIME()) SetBasedMs,COUNT(*) RowsInserted FROM dbo.OrderFollowUp;

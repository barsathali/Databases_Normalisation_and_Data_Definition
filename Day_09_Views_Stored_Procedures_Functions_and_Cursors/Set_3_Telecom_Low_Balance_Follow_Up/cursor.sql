DROP PROCEDURE IF EXISTS dbo.usp_LowBalanceNotifications_Cursor;
GO
CREATE PROCEDURE dbo.usp_LowBalanceNotifications_Cursor AS
BEGIN
 SET NOCOUNT ON; DECLARE @Id int;
 DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT SubscriberId FROM dbo.Subscriber WHERE SubscriberType='Prepaid' AND IsActive=1 AND Balance<50;
 OPEN c; FETCH NEXT FROM c INTO @Id;
 WHILE @@FETCH_STATUS=0 BEGIN INSERT dbo.NotificationLog(SubscriberId,MessageText) VALUES(@Id,'Prepaid balance is below 50. Please recharge.'); FETCH NEXT FROM c INTO @Id; END;
 CLOSE c; DEALLOCATE c;
END;
GO
TRUNCATE TABLE dbo.NotificationLog; DECLARE @C datetime2=SYSDATETIME(); EXEC dbo.usp_LowBalanceNotifications_Cursor;
DECLARE @CursorMs int=DATEDIFF(millisecond,@C,SYSDATETIME()); SELECT @CursorMs CursorMs,COUNT(*) CursorRows FROM dbo.NotificationLog;
TRUNCATE TABLE dbo.NotificationLog; DECLARE @S datetime2=SYSDATETIME();
INSERT dbo.NotificationLog(SubscriberId,MessageText) SELECT SubscriberId,'Prepaid balance is below 50. Please recharge.' FROM dbo.Subscriber WHERE SubscriberType='Prepaid' AND IsActive=1 AND Balance<50;
DECLARE @SetMs int=DATEDIFF(millisecond,@S,SYSDATETIME()); SELECT @SetMs SetBasedMs,COUNT(*) SetBasedRows FROM dbo.NotificationLog;
SELECT * FROM dbo.NotificationLog;

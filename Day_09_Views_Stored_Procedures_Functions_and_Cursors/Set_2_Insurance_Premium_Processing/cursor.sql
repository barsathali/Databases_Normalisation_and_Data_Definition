DROP PROCEDURE IF EXISTS dbo.usp_LapsePolicies_Cursor;
GO
CREATE PROCEDURE dbo.usp_LapsePolicies_Cursor AS
BEGIN
 SET NOCOUNT ON; DECLARE @Id int;
 DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT PolicyId FROM dbo.Policy WHERE RenewalDate<CONVERT(date,GETDATE()) AND PolicyStatus='Active';
 OPEN c; FETCH NEXT FROM c INTO @Id;
 WHILE @@FETCH_STATUS=0 BEGIN UPDATE dbo.Policy SET PolicyStatus='Lapsed' WHERE PolicyId=@Id; INSERT dbo.PolicyAudit(PolicyId,ActionName) VALUES(@Id,'Lapsed by cursor'); FETCH NEXT FROM c INTO @Id; END;
 CLOSE c; DEALLOCATE c;
END;
GO
UPDATE dbo.Policy SET RenewalDate=DATEADD(day,-2,GETDATE()),PolicyStatus='Active' WHERE PolicyId=2003;
EXEC dbo.usp_LapsePolicies_Cursor; SELECT * FROM dbo.PolicyAudit WHERE ActionName='Lapsed by cursor';
DELETE dbo.PolicyAudit WHERE ActionName='Lapsed by cursor'; UPDATE dbo.Policy SET PolicyStatus='Active' WHERE PolicyId=2003;
DECLARE @T datetime2=SYSDATETIME(); DECLARE @Changed TABLE(PolicyId int);
UPDATE dbo.Policy SET PolicyStatus='Lapsed' OUTPUT inserted.PolicyId INTO @Changed WHERE RenewalDate<CONVERT(date,GETDATE()) AND PolicyStatus='Active';
INSERT dbo.PolicyAudit(PolicyId,ActionName) SELECT PolicyId,'Lapsed set-based' FROM @Changed;
SELECT DATEDIFF(millisecond,@T,SYSDATETIME()) SetBasedMs; SELECT * FROM dbo.PolicyAudit WHERE ActionName='Lapsed set-based';

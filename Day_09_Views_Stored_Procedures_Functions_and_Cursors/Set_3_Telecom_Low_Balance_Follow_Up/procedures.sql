DROP FUNCTION IF EXISTS dbo.fn_ValidityDaysLeft;
DROP FUNCTION IF EXISTS dbo.fn_LastFiveRecharges;
DROP PROCEDURE IF EXISTS dbo.usp_Recharge;
GO
CREATE FUNCTION dbo.fn_ValidityDaysLeft(@SubscriberId int) RETURNS int
AS BEGIN DECLARE @D int; SELECT @D=DATEDIFF(day,CONVERT(date,GETDATE()),ValidUntil) FROM dbo.Subscriber WHERE SubscriberId=@SubscriberId AND SubscriberType='Prepaid'; RETURN COALESCE(@D,0); END;
GO
CREATE FUNCTION dbo.fn_LastFiveRecharges(@SubscriberId int) RETURNS TABLE AS RETURN
(SELECT TOP(5) RechargeId,SubscriberId,PlanId,RechargeAmount,RechargeDate,ValidUntil FROM dbo.RechargeHistory WHERE SubscriberId=@SubscriberId ORDER BY RechargeDate DESC,RechargeId DESC);
GO
CREATE PROCEDURE dbo.usp_Recharge @SubscriberId int,@PlanId int,@Amount decimal(10,2),@NewBalance decimal(10,2) OUTPUT AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON; SET @NewBalance=NULL;
 BEGIN TRY BEGIN TRAN;
 DECLARE @Price decimal(10,2),@Days int,@PlanActive bit,@SubActive bit,@Type varchar(10);
 SELECT @Price=RechargeAmount,@Days=ValidityDays,@PlanActive=IsActive FROM dbo.SubscriberPlan WHERE PlanId=@PlanId;
 IF @Price IS NULL THROW 53001,'Plan not found.',1;
 IF @PlanActive=0 THROW 53002,'Plan is inactive.',1;
 IF @Amount<=0 OR @Amount<>@Price THROW 53003,'Amount must be positive and equal plan price.',1;
 SELECT @SubActive=IsActive,@Type=SubscriberType FROM dbo.Subscriber WITH(UPDLOCK,HOLDLOCK) WHERE SubscriberId=@SubscriberId;
 IF @SubActive IS NULL THROW 53004,'Subscriber not found.',1;
 IF @SubActive=0 THROW 53005,'Subscriber is inactive.',1;
 IF @Type<>'Prepaid' THROW 53006,'Only prepaid subscribers can recharge.',1;
 UPDATE dbo.Subscriber SET Balance=Balance+@Amount,PlanId=@PlanId,ValidUntil=DATEADD(day,@Days,CONVERT(date,GETDATE())) WHERE SubscriberId=@SubscriberId;
 SELECT @NewBalance=Balance FROM dbo.Subscriber WHERE SubscriberId=@SubscriberId;
 INSERT dbo.RechargeHistory(SubscriberId,PlanId,RechargeAmount,ValidUntil) SELECT @SubscriberId,@PlanId,@Amount,ValidUntil FROM dbo.Subscriber WHERE SubscriberId=@SubscriberId;
 COMMIT; END TRY BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; SET @NewBalance=NULL; THROW; END CATCH
END;
GO
DECLARE @B decimal(10,2); EXEC dbo.usp_Recharge 101,1,99,@B OUTPUT; SELECT @B OutputNewBalance,dbo.fn_ValidityDaysLeft(101) ValidityDaysLeft;
SELECT * FROM dbo.fn_LastFiveRecharges(101);
BEGIN TRY EXEC dbo.usp_Recharge 101,1,50,@B OUTPUT; END TRY BEGIN CATCH SELECT ERROR_MESSAGE() ExpectedAmountValidationError; END CATCH;

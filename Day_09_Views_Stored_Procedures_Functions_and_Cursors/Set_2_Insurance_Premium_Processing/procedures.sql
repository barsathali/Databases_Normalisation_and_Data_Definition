DROP FUNCTION IF EXISTS dbo.fn_PremiumWithNoClaimDiscount;
DROP FUNCTION IF EXISTS dbo.fn_AgentRenewalQuotes;
DROP PROCEDURE IF EXISTS dbo.usp_RenewPolicy;
GO
CREATE FUNCTION dbo.fn_PremiumWithNoClaimDiscount(@Base decimal(12,2),@NoClaim bit) RETURNS decimal(12,2)
AS BEGIN RETURN CONVERT(decimal(12,2),CASE WHEN @NoClaim=1 THEN @Base*.90 ELSE @Base END); END;
GO
CREATE FUNCTION dbo.fn_AgentRenewalQuotes(@CustomerId int) RETURNS TABLE AS RETURN
(SELECT p.PolicyId,p.CustomerId,c.CustomerName,p.RenewalDate,p.AnnualPremium,
 dbo.fn_PremiumWithNoClaimDiscount(p.AnnualPremium,p.LastClaimFree) RenewalQuote
 FROM dbo.Policy p JOIN dbo.Customer c ON c.CustomerId=p.CustomerId
 WHERE p.CustomerId=@CustomerId AND p.RenewalDate<=DATEADD(day,30,CONVERT(date,GETDATE())));
GO
CREATE PROCEDURE dbo.usp_RenewPolicy @PolicyId int,@NewPremium decimal(12,2) OUTPUT AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON; SET @NewPremium=NULL;
 BEGIN TRY BEGIN TRAN;
 DECLARE @Status varchar(20),@Base decimal(12,2),@NoClaim bit,@Old decimal(12,2);
 SELECT @Status=PolicyStatus,@Base=AnnualPremium,@NoClaim=LastClaimFree,@Old=AnnualPremium FROM dbo.Policy WITH(UPDLOCK,HOLDLOCK) WHERE PolicyId=@PolicyId;
 IF @Status IS NULL THROW 52001,'Policy not found.',1;
 IF @Status<>'Active' THROW 52002,'Only active policies can renew.',1;
 IF EXISTS(SELECT 1 FROM dbo.Claim WHERE PolicyId=@PolicyId AND ClaimStatus='Pending') THROW 52003,'Pending claim blocks renewal.',1;
 SET @NewPremium=dbo.fn_PremiumWithNoClaimDiscount(@Base,@NoClaim);
 UPDATE dbo.Policy SET AnnualPremium=@NewPremium,RenewalDate=DATEADD(year,1,RenewalDate) WHERE PolicyId=@PolicyId;
 INSERT dbo.PolicyAudit(PolicyId,ActionName,OldPremium,NewPremium) VALUES(@PolicyId,'Renewal',@Old,@NewPremium);
 COMMIT; END TRY BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; SET @NewPremium=NULL; THROW; END CATCH
END;
GO
DECLARE @P decimal(12,2); EXEC dbo.usp_RenewPolicy 2001,@P OUTPUT; SELECT @P OutputPremium;
SELECT * FROM dbo.fn_AgentRenewalQuotes(2); SELECT * FROM dbo.PolicyAudit;
BEGIN TRY EXEC dbo.usp_RenewPolicy 2002,@P OUTPUT; END TRY BEGIN CATCH SELECT ERROR_MESSAGE() ExpectedPendingClaimError; END CATCH;

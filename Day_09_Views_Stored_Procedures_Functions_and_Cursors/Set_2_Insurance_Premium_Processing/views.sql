DROP VIEW IF EXISTS dbo.vw_policy_due;
DROP TABLE IF EXISTS dbo.PolicyAudit,dbo.Claim,dbo.Policy,dbo.Customer;
GO
CREATE TABLE dbo.Customer(CustomerId int PRIMARY KEY,CustomerName nvarchar(80),Email nvarchar(120),Phone varchar(30),NationalId varchar(30),DOB date);
CREATE TABLE dbo.Policy(PolicyId int PRIMARY KEY,CustomerId int REFERENCES dbo.Customer,PolicyType varchar(30),AnnualPremium decimal(12,2),RenewalDate date,PolicyStatus varchar(20),LastClaimFree bit);
CREATE TABLE dbo.Claim(ClaimId int PRIMARY KEY,PolicyId int REFERENCES dbo.Policy,ClaimStatus varchar(20),ClaimAmount decimal(12,2));
CREATE TABLE dbo.PolicyAudit(AuditId int IDENTITY PRIMARY KEY,PolicyId int,ActionName varchar(40),OldPremium decimal(12,2),NewPremium decimal(12,2),ActionAt datetime2 DEFAULT SYSDATETIME());
INSERT dbo.Customer VALUES(1,'Ananya','ananya@example.test','900000001','SECRET-1','1990-04-10'),(2,'Bharat','bharat@example.test','900000002','SECRET-2','1985-08-22'),(3,'Charu','charu@example.test','900000003','SECRET-3','1992-01-15');
INSERT dbo.Policy VALUES(2001,1,'Health',12000,DATEADD(day,15,GETDATE()),'Active',1),(2002,2,'Motor',9000,DATEADD(day,30,GETDATE()),'Active',0),(2003,3,'Health',15000,DATEADD(day,10,GETDATE()),'Lapsed',1);
INSERT dbo.Claim VALUES(3001,2002,'Pending',2500),(3002,2001,'Approved',1000);
GO
CREATE VIEW dbo.vw_policy_due AS
SELECT p.PolicyId,c.CustomerId,c.CustomerName,c.Email,p.PolicyType,p.RenewalDate,p.AnnualPremium,p.PolicyStatus
FROM dbo.Policy p JOIN dbo.Customer c ON c.CustomerId=p.CustomerId
WHERE p.RenewalDate>=CONVERT(date,GETDATE()) AND p.RenewalDate<DATEADD(day,31,CONVERT(date,GETDATE()));
GO
SELECT * FROM dbo.vw_policy_due;

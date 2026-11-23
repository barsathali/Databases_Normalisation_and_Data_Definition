DROP VIEW IF EXISTS dbo.vw_prepaid_subscribers,dbo.vw_recharge_summary,dbo.vw_prepaid_only;
DROP TABLE IF EXISTS dbo.NotificationLog,dbo.RechargeHistory,dbo.SubscriberPlan,dbo.Subscriber;
GO
CREATE TABLE dbo.Subscriber(SubscriberId int PRIMARY KEY,SubscriberName nvarchar(80),SubscriberType varchar(10) CHECK(SubscriberType IN('Prepaid','Postpaid')),Balance decimal(10,2) CHECK(Balance>=0),PlanId int,ValidUntil date,IsActive bit);
CREATE TABLE dbo.SubscriberPlan(PlanId int PRIMARY KEY,PlanName varchar(50),RechargeAmount decimal(10,2),ValidityDays int,IsActive bit);
CREATE TABLE dbo.RechargeHistory(RechargeId int IDENTITY PRIMARY KEY,SubscriberId int REFERENCES dbo.Subscriber,PlanId int REFERENCES dbo.SubscriberPlan,RechargeAmount decimal(10,2),RechargeDate datetime2 DEFAULT SYSDATETIME(),ValidUntil date);
CREATE TABLE dbo.NotificationLog(NotificationId int IDENTITY PRIMARY KEY,SubscriberId int,MessageText nvarchar(200),CreatedAt datetime2 DEFAULT SYSDATETIME(),IsRead bit DEFAULT 0);
INSERT dbo.SubscriberPlan VALUES(1,'Basic 28 days',99,28,1),(2,'Value 56 days',199,56,1),(3,'Data 84 days',299,84,1);
INSERT dbo.Subscriber VALUES(101,'Meera','Prepaid',25,1,DATEADD(day,8,GETDATE()),1),(102,'Naveen','Prepaid',120,2,DATEADD(day,30,GETDATE()),1),(103,'Oviya','Postpaid',10,1,DATEADD(day,12,GETDATE()),1),(104,'Pranav','Prepaid',42,1,DATEADD(day,3,GETDATE()),1);
INSERT dbo.RechargeHistory(SubscriberId,PlanId,RechargeAmount,ValidUntil) VALUES(101,1,99,DATEADD(day,8,GETDATE())),(101,2,199,DATEADD(day,30,GETDATE())),(102,2,199,DATEADD(day,30,GETDATE())),(104,1,99,DATEADD(day,3,GETDATE()));
GO
CREATE VIEW dbo.vw_prepaid_subscribers AS SELECT SubscriberId,SubscriberName,Balance,PlanId,ValidUntil,IsActive FROM dbo.Subscriber WHERE SubscriberType='Prepaid';
GO
CREATE VIEW dbo.vw_recharge_summary AS SELECT SubscriberId,COUNT_BIG(*) RechargeCount,SUM(RechargeAmount) TotalRecharged,MAX(RechargeDate) LastRechargeAt FROM dbo.RechargeHistory GROUP BY SubscriberId;
GO
CREATE VIEW dbo.vw_prepaid_only AS SELECT SubscriberId,SubscriberName,Balance,PlanId,ValidUntil FROM dbo.Subscriber WHERE SubscriberType='Prepaid';
GO
SELECT * FROM dbo.vw_prepaid_subscribers; SELECT * FROM dbo.vw_recharge_summary; SELECT * FROM dbo.vw_prepaid_only;

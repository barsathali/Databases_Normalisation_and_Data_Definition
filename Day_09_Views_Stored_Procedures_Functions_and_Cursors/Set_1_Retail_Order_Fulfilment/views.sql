DROP VIEW IF EXISTS dbo.vw_order_summary,dbo.vw_low_stock,dbo.vw_active_order_entry;
DROP TABLE IF EXISTS dbo.OrderFollowUp,dbo.OrderLine,dbo.SalesOrder,dbo.Product,dbo.Supplier;
GO
CREATE TABLE dbo.Supplier(SupplierId int PRIMARY KEY,SupplierName nvarchar(80),ContactEmail nvarchar(120));
CREATE TABLE dbo.Product(ProductId int PRIMARY KEY,ProductName nvarchar(80),SupplierId int REFERENCES dbo.Supplier,CostPrice decimal(10,2),SellingPrice decimal(10,2),StockQty int CHECK(StockQty>=0),ReorderLevel int);
CREATE TABLE dbo.SalesOrder(OrderId int IDENTITY(1001,1) PRIMARY KEY,CustomerId int,OrderDate date DEFAULT CONVERT(date,GETDATE()),OrderStatus varchar(20));
CREATE TABLE dbo.OrderLine(OrderLineId int IDENTITY PRIMARY KEY,OrderId int REFERENCES dbo.SalesOrder,ProductId int REFERENCES dbo.Product,Quantity int CHECK(Quantity>0),UnitPrice decimal(10,2));
CREATE TABLE dbo.OrderFollowUp(FollowUpId int IDENTITY PRIMARY KEY,OrderId int REFERENCES dbo.SalesOrder,CreatedAt datetime2 DEFAULT SYSDATETIME(),Note nvarchar(200));
INSERT dbo.Supplier VALUES(1,'Northstar','north@example.test'),(2,'Metro','metro@example.test');
INSERT dbo.Product VALUES(1,'Mouse',1,250,450,30,10),(2,'Keyboard',2,500,850,5,8),(3,'USB Hub',1,180,350,3,5);
INSERT dbo.SalesOrder(CustomerId,OrderDate,OrderStatus) VALUES(501,DATEADD(day,-5,GETDATE()),'Pending'),(502,DATEADD(day,-4,GETDATE()),'Pending'),(503,DATEADD(day,-1,GETDATE()),'Pending'),(504,DATEADD(day,-6,GETDATE()),'Shipped');
INSERT dbo.OrderLine(OrderId,ProductId,Quantity,UnitPrice) VALUES(1001,1,2,450),(1002,2,1,850),(1003,3,2,350),(1004,1,1,450);
GO
CREATE VIEW dbo.vw_order_summary AS
SELECT o.OrderId,o.CustomerId,o.OrderDate,o.OrderStatus,SUM(l.Quantity*l.UnitPrice) OrderTotal,COUNT_BIG(*) LineCount
FROM dbo.SalesOrder o JOIN dbo.OrderLine l ON l.OrderId=o.OrderId GROUP BY o.OrderId,o.CustomerId,o.OrderDate,o.OrderStatus;
GO
CREATE VIEW dbo.vw_low_stock AS SELECT ProductId,ProductName,StockQty,ReorderLevel FROM dbo.Product WHERE StockQty<=ReorderLevel;
GO
CREATE VIEW dbo.vw_active_order_entry AS SELECT OrderId,CustomerId,OrderDate,OrderStatus FROM dbo.SalesOrder WHERE OrderStatus='Pending' WITH CHECK OPTION;
GO
SELECT * FROM dbo.vw_order_summary; SELECT * FROM dbo.vw_low_stock;
BEGIN TRY UPDATE dbo.vw_active_order_entry SET OrderStatus='Shipped' WHERE OrderId=1003; END TRY BEGIN CATCH SELECT ERROR_MESSAGE() ExpectedCheckOptionRejection; END CATCH;
UPDATE dbo.vw_active_order_entry SET CustomerId=599 WHERE OrderId=1003;

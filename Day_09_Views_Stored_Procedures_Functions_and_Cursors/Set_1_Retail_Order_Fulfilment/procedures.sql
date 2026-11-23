DROP FUNCTION IF EXISTS dbo.fn_OrderTotalWithTax;
DROP FUNCTION IF EXISTS dbo.fn_CustomerOrders;
DROP PROCEDURE IF EXISTS dbo.usp_PlaceOrder;
GO
CREATE FUNCTION dbo.fn_OrderTotalWithTax(@OrderId int) RETURNS decimal(12,2)
AS BEGIN DECLARE @T decimal(12,2); SELECT @T=SUM(Quantity*UnitPrice) FROM dbo.OrderLine WHERE OrderId=@OrderId; RETURN CONVERT(decimal(12,2),COALESCE(@T,0)*1.18); END;
GO
CREATE FUNCTION dbo.fn_CustomerOrders(@CustomerId int) RETURNS TABLE AS RETURN
(SELECT o.OrderId,o.OrderDate,o.OrderStatus,SUM(l.Quantity*l.UnitPrice) Subtotal,CONVERT(decimal(12,2),SUM(l.Quantity*l.UnitPrice)*1.18) TotalWithTax
 FROM dbo.SalesOrder o JOIN dbo.OrderLine l ON l.OrderId=o.OrderId WHERE o.CustomerId=@CustomerId GROUP BY o.OrderId,o.OrderDate,o.OrderStatus);
GO
CREATE PROCEDURE dbo.usp_PlaceOrder @CustomerId int,@ProductId int,@Quantity int,@OrderNumber int OUTPUT
AS BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON; SET @OrderNumber=NULL;
 IF @Quantity<=0 THROW 51001,'Quantity must be positive.',1;
 BEGIN TRY BEGIN TRAN;
 DECLARE @Stock int,@Price decimal(10,2);
 SELECT @Stock=StockQty,@Price=SellingPrice FROM dbo.Product WITH(UPDLOCK,HOLDLOCK) WHERE ProductId=@ProductId;
 IF @Stock IS NULL THROW 51002,'Product not found.',1;
 IF @Stock<@Quantity THROW 51003,'Insufficient stock.',1;
 UPDATE dbo.Product SET StockQty=StockQty-@Quantity WHERE ProductId=@ProductId;
 INSERT dbo.SalesOrder(CustomerId,OrderStatus) VALUES(@CustomerId,'Pending');
 SET @OrderNumber=SCOPE_IDENTITY();
 INSERT dbo.OrderLine(OrderId,ProductId,Quantity,UnitPrice) VALUES(@OrderNumber,@ProductId,@Quantity,@Price);
 COMMIT; END TRY BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; SET @OrderNumber=NULL; THROW; END CATCH
END;
GO
DECLARE @N int; EXEC dbo.usp_PlaceOrder 505,1,2,@N OUTPUT;
SELECT @N OrderNumber,dbo.fn_OrderTotalWithTax(@N) ScalarTotal; SELECT * FROM dbo.fn_CustomerOrders(505);
BEGIN TRY EXEC dbo.usp_PlaceOrder 506,3,999,@N OUTPUT; END TRY BEGIN CATCH SELECT ERROR_MESSAGE() ExpectedStockError; END CATCH;

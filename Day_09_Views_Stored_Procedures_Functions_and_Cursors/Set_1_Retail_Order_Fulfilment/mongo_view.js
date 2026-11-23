use day9_retail;
db.orders.drop();
db.orders.insertMany([{_id:1001,status:"Pending",total:900},{_id:1002,status:"Pending",total:850},{_id:1003,status:"Shipped",total:700},{_id:1004,status:"Cancelled",total:300}]);
db.order_status_counts.drop();
db.createView("order_status_counts","orders",[{$group:{_id:"$status",orderCount:{$sum:1},orderValue:{$sum:"$total"}}},{$project:{_id:0,status:"$_id",orderCount:1,orderValue:1}},{$sort:{status:1}}]);
db.order_status_counts.find().forEach(printjson);

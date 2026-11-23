use day9_telecom;
db.notification_log.drop();
db.notification_log.insertMany([{subscriberId:101,message:"Low balance",isRead:false},{subscriberId:101,message:"Recharge done",isRead:true},{subscriberId:104,message:"Low balance",isRead:false},{subscriberId:104,message:"Validity reminder",isRead:false},{subscriberId:102,message:"Plan renewed",isRead:true}]);
db.unread_notification_counts.drop();
db.createView("unread_notification_counts","notification_log",[{$match:{isRead:false}},{$group:{_id:"$subscriberId",unreadCount:{$sum:1}}},{$project:{_id:0,subscriberId:"$_id",unreadCount:1}},{$sort:{subscriberId:1}}]);
db.unread_notification_counts.find().forEach(printjson);

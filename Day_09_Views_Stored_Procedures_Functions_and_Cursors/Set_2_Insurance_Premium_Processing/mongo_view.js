use day9_insurance;
db.customer_communications.drop();
db.customer_communications.insertMany([{customerId:1,channel:"Email",subject:"Claim status",status:"Unresolved"},{customerId:2,channel:"Phone",subject:"Premium query",status:"Resolved"},{customerId:3,channel:"Email",subject:"Renewal issue",status:"Unresolved"}]);
db.unresolved_complaints.drop();
db.createView("unresolved_complaints","customer_communications",[{$match:{status:"Unresolved"}},{$project:{_id:0,customerId:1,channel:1,subject:1}}]);
db.unresolved_complaints.find().forEach(printjson);

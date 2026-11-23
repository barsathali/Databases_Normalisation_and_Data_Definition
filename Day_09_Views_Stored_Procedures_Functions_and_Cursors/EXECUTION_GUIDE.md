# Execution guide
1. Start Docker Desktop and confirm SQL Server container `my_sql_server` and MongoDB container `mongo_test` are running (`docker ps`).
2. In your SQL Server connection, create the practice DB once: `IF DB_ID('Day09Practice') IS NULL CREATE DATABASE Day09Practice;` Then select it.
3. For each set, run `views.sql`, `procedures.sql`, then `cursor.sql`, one file at a time.
4. From this project root, run the MongoDB scripts using your running container:

```bash
docker exec -i mongo_test mongosh < Set_1_Retail_Order_Fulfilment/mongo_view.js
docker exec -i mongo_test mongosh < Set_2_Insurance_Premium_Processing/mongo_view.js
docker exec -i mongo_test mongosh < Set_3_Telecom_Low_Balance_Follow_Up/mongo_view.js
```

5. Capture actual SQL result grids/messages and MongoDB view output for evidence. The scripts' sample data is synthetic. MongoDB scripts use views only and run on standalone MongoDB.

If your container names differ, run `docker ps` and substitute the exact names.

# Day 9 — Views, Stored Procedures, Functions and Cursors
This pack follows the uploaded assignment's three scenarios and required deliverables: Retail Order Fulfilment, Insurance Premium Processing and Telecom Low-Balance Follow-up. Each set contains views.sql, procedures.sql, cursor.sql, mongo_view.js and a cursor-versus-set-based comparison note.

## SQL Server run order
Use a dedicated practice database named Day09Practice. In SSMS/Azure Data Studio, connect to SQL Server, select Day09Practice, then run each set's files separately in this order: views.sql → procedures.sql → cursor.sql. The scripts drop/rebuild their sample objects; never run them in production.

## MongoDB
Run each mongo_view.js with mongosh. The scripts create sample source collections and read-only views using db.createView().

Assignment specifies SQL Server 2025 and MongoDB 8.0. SQL uses common T-SQL and is also compatible with SQL Server 2022. Workflow is fully represented in code; capture genuine query outputs after execution if screenshots are required.

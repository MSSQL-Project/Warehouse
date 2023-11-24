# Warehouse
Hi there. It's my MSSQL Project 

Database Overview:

The database is named "Warehouse."
Tables:

Persons:

Contains information about employees.
Columns: [Id] (primary key), [Company], [Name], [Surname], [Cellphone].
Contracts:

Contains information about contracts.
Columns: [Id] (primary key), [Number], [Begin], [End], [Quantity], [Price].
Cultures:

Contains information about cultures.
Columns: [Id] (primary key), [Culture], [Price], [Quantity].
Warehouses:

Contains information about warehouses.
Columns: [Id] (primary key), [Warehouse], [Free], [Occupied], [Available].
F_Contracts:

Contains information about relationships between contracts, persons, and cultures.
Columns: [Id] (primary key), [ContractId] (foreign key), [PersonId] (foreign key), [CultureId] (foreign key).
F_Warehouse:

Contains information about relationships between warehouses and cultures.
Columns: [Id] (primary key), [Warehouse_id] (foreign key), [Cultureid] (foreign key).
F_Orders:

Contains information about orders.
Columns: [Id] (primary key), [IdContracts] (foreign key), [IdWarehouse] (foreign key), [Shipment], [Quantity], [Price].
Constraints and Data Integrity Rules:

In the Contracts table, the contract start date ([Begin]) must be at least the current date.
In the Contracts table, the quantity ([Quantity]) must be greater than 0.
In the Cultures table, the culture ([Culture]) must be unique and non-empty.
In the Warehouses table, the default available quantity ([Available]) is 900,000.
In the F_Contracts table, the composite key [ContractId, PersonId, CultureId] is unique.
Foreign keys are used to ensure data integrity.
Stored Procedures:

InsertIntoPerson: Procedure to insert a new record into the Persons table.
InsertIntoContract: Procedure to insert a new record into the Contracts table.
InsertIntoCulture: Procedure to insert a new record into the Cultures table.
InsertIntoWarehouse: Procedure to insert a new record into the Warehouses table.
InsertIntoF_Contracts: Procedure to insert a new record into the F_Contracts table.
Triggers:

InsertWarehouseTrigger: Trigger to update the Free column in the Warehouses table after inserting a new record.
UpdateWarehouseTriggerRow: Trigger to check the consistency of the Occupied and Available columns in the Warehouses table after an update.
Transactions:

Use transactions to ensure the atomicity of script execution.
Security Procedures:

Grant appropriate access rights to database objects for different users.

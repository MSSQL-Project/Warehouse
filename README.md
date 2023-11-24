# Warehouse Database

## Overview
The Warehouse Database, named "Warehouse," manages information related to persons, contracts, cultures, warehouses, and orders.

## Tables

### Persons
- Employee information including ID, Company, Name, Surname, and Cellphone.

### Contracts
- Contract details with ID, Number, Start Date, End Date, Quantity, and Price.

### Cultures
- Information about cultures, including ID, Culture Name, Price, and Quantity.

### Warehouses
- Details about warehouses, including ID, Warehouse Name, Free space, Occupied space, and Available space.

### F_Contracts
- Relationships between contracts, persons, and cultures, identified by ID, Contract ID, Person ID, and Culture ID.

### F_Warehouse
- Relationships between warehouses and cultures, with ID, Warehouse ID, and Culture ID.

### F_Orders
- Orders information, including ID, Contract ID, Warehouse ID, Shipment Date, Quantity, and Price.

## Constraints and Data Integrity Rules

- Contracts must have a start date ([Begin]) at least equal to the current date.
- Quantity in Contracts must be greater than 0.
- Cultures must have unique and non-empty names.
- Warehouses default available space to 900,000.
- F_Contracts enforces a unique combination of Contract ID, Person ID, and Culture ID.

## Stored Procedures

### InsertIntoPerson
- Inserts a new employee record into the Persons table.

### InsertIntoContract
- Inserts a new contract record into the Contracts table.

### InsertIntoCulture
- Inserts a new culture record into the Cultures table.

### InsertIntoWarehouse
- Inserts a new warehouse record into the Warehouses table.

### InsertIntoF_Contracts
- Inserts a new relationship record into the F_Contracts table.

## Triggers

### InsertWarehouseTrigger
- Updates the Free column in the Warehouses table after inserting a new record.

### UpdateWarehouseTriggerRow
- Checks the consistency of Occupied and Available columns in the Warehouses table after an update.

## Transactions

- Utilizes transactions to ensure the atomicity of script execution.

## Security Procedures

- Grants appropriate access rights to database objects for different users.

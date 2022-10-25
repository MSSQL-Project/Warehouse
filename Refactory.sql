IF NOT EXISTS(SELECT * FROM sys.databases WHERE name='Warehouse')
BEGIN
	 PRINT N'[--] Database isn`t exist. She will create!'
	 CREATE DATABASE Warehouse
END
GO

USE Warehouse
GO

BEGIN TRANSACTION;
IF object_id('Persons') IS NULL
BEGIN
    CREATE TABLE Persons
	(
	  [Id] INT IDENTITY(1,1) PRIMARY KEY,
	  [Company] NVARCHAR(MAX) NOT NULL,
	  [Name] NVARCHAR(MAX) NOT NULL,
	  [Surname] NVARCHAR(MAX) NOT NULL,
	  [Cellphone] NVARCHAR(MAX) NOT NULL,
	)
	 PRINT N'[++] Create table as ''Person''successfull'
 END

IF object_id('Contracts') IS NULL
BEGIN
	CREATE TABLE Contracts
	(
	 [Id] INT IDENTITY(1,1) PRIMARY KEY,
	 [Number] NVARCHAR(50) NOT NULL UNIQUE,
	 [Begin] DATE NOT NULL CHECK([Begin] >= getdate()),
	 [End]  DATE NOT NULL CHECK([end] >=getdate()),
	 [Quantity] INT DEFAULT 0 NOT NULL CHECK([Quantity] >0),
	 [Price] MONEY DEFAULT  0  NOT NULL
	)
	 PRINT N'[++] Create table as ''Contracts'' successfull'
 END
 GO

IF object_id('Cultures') IS NULL
BEGIN
    CREATE TABLE Cultures
	(
	  [Id] INT IDENTITY(1,1) PRIMARY KEY,
	  [Culture] NVARCHAR(50) NOT NULL CHECK([culture] <> '') UNIQUE,
	  [Price] MONEY DEFAULT 0.00 NOT NULL,
	  [Quantity] INT DEFAULT 0 NOT NULL
	)
	 PRINT N'[++] Create table as ''Cultures'' successfull'
 END
GO

IF object_id('Warehouses') IS NULL
BEGIN
	 CREATE TABLE Warehouses
	 (
	  [Id] INT IDENTITY(1,1) PRIMARY KEY,
	  [Warehouse] NVARCHAR(30) CHECK([Warehouse] <> ''),
	  [Free] INT DEFAULT 0 NOT NULL,
	  [Occupied] INT DEFAULT 0 NOT NULL,
	  [Available] INT DEFAULT 900000 NOT NULL,
	)
	 PRINT N'[++] Create table as ''Warehouses'' successfull'
 END
GO

IF object_id('F_Contracts') IS NULL
BEGIN
	 CREATE TABLE F_Contracts
	 (
	   [Id] INT IDENTITY(1,1),
	   [ContractId] INT  REFERENCES Contracts ON DELETE CASCADE,
	   [PersonId]   INT  REFERENCES Persons ON DELETE CASCADE,
	   [CultureId]  INT  REFERENCES Cultures ON DELETE CASCADE,
	   PRIMARY KEY(ContractId,PersonId,CultureId) 
	)
	 PRINT N'[++] Create table as ''F_Contracts'' successfull'
 END
GO

IF object_id('F_Warehouse') IS NULL
BEGIN
	CREATE TABLE F_Warehouse
	(
	  [Id] INT IDENTITY(1,1) PRIMARY KEY,
	  [Warehouse_id] INT NOT NULL FOREIGN KEY REFERENCES Warehouses(id) ON DELETE CASCADE,
	  [Cultureid] INT FOREIGN KEY REFERENCES Cultures ON DELETE CASCADE
	)
	 PRINT N'[++] Create table as ''F_Warehouse'' successfull'
END
GO

IF object_id('F_Orders') IS NULL
BEGIN
    CREATE TABLE F_Orders
    (
	  [Id] INT IDENTITY(1,1) PRIMARY KEY,
	  [IdContracts] INT FOREIGN KEY REFERENCES Contracts  ON DELETE CASCADE NOT NULL,
	  [IdWarehouse] INT FOREIGN KEY REFERENCES Warehouses ON DELETE CASCADE NOT NULL,
	  [Shipment] DATE CHECK (Shipment >= getdate()),
	  [Quantity] INT NOT NULL,
	  [Price] MONEY NOT NULL
	)
	 PRINT N'[++] Create table as ''F_Orders'' successfull'
 END
GO

IF NOT EXISTS(SELECT * FROM sys.objects WHERE type='P' AND OBJECT_ID = OBJECT_ID('dbo.InsertIntoPerson'))
BEGIN
	EXEC('CREATE PROCEDURE InsertIntoPerson(@CompanyName NVARCHAR(MAX),@Name NVARCHAR(MAX), @Surname NVARCHAR(MAX), @Cellphone NVARCHAR(Max))
		 AS BEGIN 
		      INSERT INTO Persons(Company,Name,Surname,Cellphone) VALUES(@CompanyName, @Name, @Surname, @Cellphone)
		 END')
    PRINT N'[++] Create store procedure as `InsertIntoPerson` complete successfull' 
  END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.InsertIntoContract'))
BEGIN
    EXEC('CREATE PROCEDURE InsertIntoContract(@ContractName NVARCHAR(MAX), @begin DATE, @expirent DATE, @quantity INT ,@price INT) 
		  AS BEGIN 
			  INSERT INTO Contracts(Number, [Begin], [End], Quantity, Price) VALUES (@ContractName,@begin,@expirent,@quantity,(SELECT @quantity*@price)); 
		  END')
    PRINT N'[++] Create store procedure as `InsertIntoContract` complete successfull' 
  END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type ='P' AND OBJECT_ID = OBJECT_ID('dbo.InsertIntoCulture'))
BEGIN
	EXEC('CREATE PROCEDURE InsertIntoCulture(@CultureName NVARCHAR(MAX) , @Price MONEY, @Quantity INT)
		  AS BEGIN
			   INSERT INTO Cultures(Culture,Price,Quantity) VALUES(@CultureName, @Price, @Quantity);
		  END')
	PRINT N'[++] Create store procedure as `InsertIntoCulture` complete successfull'
  END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.InsertIntoWarehouse'))
BEGIN
	EXEC('CREATE PROCEDURE InsertIntoWarehouse(@Location NVARCHAR(MAX), @Free INT, @Available INT, @Capacity INT)
		  AS BEGIN
				INSERT INTO Warehouses(Warehouse,Free,Occupied,Available) VALUES(@Location, @Free,@Available,@Capacity);
		  END')
    PRINT N'[++] Create store procedure as `InsertIntoWarehouse` complete successfull'
 END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND OBJECT_ID = OBJECT_ID('dbo.InsertIntoWarehouse'))
BEGIN
	EXEC('CREATE PROCEDURE InsertIntoF_Contracts(@contractname NVARCHAR(MAX), @culturename NVARCHAR(MAX), @currentPerson NVARCHAR(MAX))
		  AS BEGIN
				 DECLARE @id_1 INT , @id_2 INT ,@id_3 INT
					 SELECT @id_1=id  FROM Contracts  WHERE number= @contractname 
					 SELECT @id_2=id  FROM Persons    WHERE [name]= @currentPerson 
					 SELECT @id_3=id  FROM Culture    WHERE culture= @culturename 
				 INSERT INTO F_Contracts(ContractId, PersonId, CultureId) VALUES (@id_1,@id_2,@id_3);
				 SAVE TRANSACTION InsertIntoWarehouseTransaction 
				 IF @@error <> 0 
				 BEGIN 
					  ROLLBACK TRANSACTION InsertIntoWarehouseTransaction 
				 END
		  END')
    PRINT N'[++] Create store procedure as `InsertIntoF_Contracts` complete successfull'
 END 
GO

---

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type='TR' AND [Name] = 'InsertWarehouseTrigger')
BEGIN
	EXEC('CREATE TRIGGER [dbo].[InsertWarehouseTrigger]
		  ON [dbo].[Warehouses] AFTER INSERT
	      AS BEGIN
				UPDATE Warehouses SET Free = Warehouses.Available WHERE Warehouse=(SELECT Warehouse FROM inserted)
				SAVE TRANSACTION InsertWarehouseTransaction
				IF @@ERROR <> 0
				BEGIN
					ROLLBACK TRANSACTION InsertWarehouseTransaction
				END
		  END')
   PRINT N'[++] Create trigger as `InsertWarehouseTrigger` complete successfull'
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE type='TR' AND [Name] = 'UpdateWarehouseTriggerRow')
BEGIN
	 EXEC('CREATE TRIGGER [dbo].[UpdateWarehouseTriggerRow]
		   ON [dbo].[Warehouses] AFTER UPDATE
		   AS BEGIN
			       DECLARE @occupie INT
			       DECLARE @available INT
				       SELECT @occupie=(SELECT Occupied FROM Warehouses WHERE Warehouse=(SELECT Warehouse FROM inserted))
			           SELECT @available=(SELECT Available FROM Warehouses WHERE Warehouse=(SELECT Warehouse FROM inserted))
				   IF (SELECT @occupie) <> (SELECT @available)
				   BEGIN 
						ROLLBACK TRANSACTION 
				   END
		   END')
	  PRINT N'[++] Create trigger as `UpdateWarehouseTriggerRow` complete successfull'
END

IF @@ERROR<>0
BEGIN
	PRINT N'[--] Rollback All Transaction'
	ROLLBACK TRANSACTION
END
ELSE
	BEGIN
	  PRINT N'[++] Accept All Transaction'
	  COMMIT TRANSACTION
END
 

 ---
SELECT * FROM sys.objects WHERE type='P'
GO

SELECT * FROM sys.objects WHERE type='TR' AND [Name] = 'InsertWarehouseTrigger'
GO

SELECT * FROM Warehouses
GO

SELECT * FROM sys.objects WHERE type='TR' 
GO

INSERT INTO Warehouses(Warehouse)VALUES('6')
GO

INSERT INTO Warehouses(Warehouse) VALUES('5')
GO

USE master
GO
DROP DATABASE Warehouse
GO
USE master ;  
GO  
CREATE DATABASE [NYCTaxiDB]
ON   
( NAME = Sales_dat,  
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\NYCTaxiDB.mdf',  
    SIZE = 10,  
    MAXSIZE = UNLIMITED,  
    FILEGROWTH = 5 )  
LOG ON  
( NAME = Sales_log,  
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\NYCTaxiDB.ldf',  
    SIZE = 5MB,  
    MAXSIZE = UNLIMITED,  
    FILEGROWTH = 5MB ) ;  
GO  

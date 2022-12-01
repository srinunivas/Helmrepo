-- Create new user
CREATE LOGIN $(DB_USERNAME) WITH
PASSWORD = N'$(DB_PASSWORD)',
CHECK_POLICY = OFF,
CHECK_EXPIRATION = OFF;
GO

-- Create new database
CREATE DATABASE $(DB_NAME)
CONTAINMENT = NONE
COLLATE $(MSSQL_COLLATION)
GO

-- Set user as the owner of the database
ALTER AUTHORIZATION ON DATABASE::$(DB_NAME) TO $(DB_USERNAME)
GO

-- Enable remote access
EXEC sp_configure 'remote access', 0;
GO  
RECONFIGURE;  
GO

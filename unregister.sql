USE CrypteronSqlClrDemo
GO

-- drop all added functions and assemblies
DROP FUNCTION [dbo].[CrypteronEncrypt] 
GO

DROP FUNCTION [dbo].[CrypteronDecrypt]
GO

DROP FUNCTION [dbo].[CrypteronSetAppSecret]
GO 

DROP ASSEMBLY [CrypteronSqlClrDemo];
GO

DROP ASSEMBLY [CipherObject];
GO

DROP ASSEMBLY [CipherCore];
GO

DROP ASSEMBLY [System.Runtime.Caching];
GO

DROP ASSEMBLY [System.Net.Http];
GO

DROP ASSEMBLY [System.Runtime.Serialization];
GO

-- disable CLR functionality
EXEC sp_configure 'clr enabled', 0
GO
RECONFIGURE
GO
EXEC sp_configure 'clr enabled'
GO

-- disable trustworthy
USE master;
GO

ALTER DATABASE CrypteronSqlClrDemo SET TRUSTWORTHY OFF; 
GO
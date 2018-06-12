-- tell SQL server we trust this particular database
use master;
GO

ALTER DATABASE CrypteronSqlClrDemo SET TRUSTWORTHY ON;  
GO

-- this is our demo database
USE CrypteronSqlClrDemo
GO

-- enable CLR functionality
EXEC sp_configure 'clr enabled', 1
GO

RECONFIGURE
GO
-- verify CLR functionality
EXEC sp_configure 'clr enabled'
GO

-- Register additional .NET DLLs not included by SQL Server by default
CREATE ASSEMBLY [System.Runtime.Caching] AUTHORIZATION dbo
FROM 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\System.Runtime.Caching.dll'
WITH PERMISSION_SET = UNSAFE
GO

CREATE ASSEMBLY [System.Net.Http] AUTHORIZATION dbo
FROM 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\System.Net.Http.dll'
WITH PERMISSION_SET = UNSAFE
GO

CREATE ASSEMBLY [System.Runtime.Serialization] AUTHORIZATION dbo
FROM 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\System.Runtime.Serialization.dll'
WITH PERMISSION_SET = UNSAFE
GO

-- Add our C# code - this path should be as seen by/on SQL Server itself
DECLARE @AssemblyPath nvarchar(1024)
Set @AssemblyPath = N'D:\projects\crypteron\github\crypteron-sql-clr-demo\CrypteronSqlClrDemo\bin\Debug'

PRINT N'Creating [CrypteronSqlClrDemo]...';
CREATE ASSEMBLY [CrypteronSqlClrDemo] 
FROM @AssemblyPath + 'CrypteronSqlClrDemo.dll'
WITH PERMISSION_SET = UNSAFE; 
GO  

-- Expose C# methods as SQL Functions to be used by SSRS or SQL SPs etc
PRINT N'Creating [dbo].[CrypteronEncrypt]...';
GO
CREATE FUNCTION [dbo].[CrypteronEncrypt](@plainText NVARCHAR (MAX) NULL)
RETURNS NVARCHAR (MAX)
AS EXTERNAL NAME [CrypteronSqlClrDemo].[SqlClrCipherObject.SqlClrUserDefinedFunctions].[CrypteronEncrypt]
GO

PRINT N'Creating [dbo].[CrypteronDecrypt]...';
GO
CREATE FUNCTION [dbo].[CrypteronDecrypt](@cipherText NVARCHAR (MAX) NULL)
RETURNS NVARCHAR (MAX)
AS EXTERNAL NAME [CrypteronSqlClrDemo].[SqlClrCipherObject.SqlClrUserDefinedFunctions].[CrypteronDecrypt]
GO

PRINT N'Creating [dbo].[CrypteronSetAppSecret]...';
GO
CREATE FUNCTION [dbo].[CrypteronSetAppSecret](@appSecret NVARCHAR (MAX) NULL)
RETURNS NVARCHAR (MAX)
AS EXTERNAL NAME [CrypteronSqlClrDemo].[SqlClrCipherObject.SqlClrUserDefinedFunctions].[CrypteronSetAppSecret]
GO

# Encryption and Decryption in SQL Server

This project demonstrates how you can perform encryption and decryption within SQL Server with proper key management techniques. Keys are automatically managed by Crypteron and by not stored them together with SQL Server or your application or with your cloud provider, you have much better security. This way if you a web-application using Crypteron CipherDB or Crypteron CipherObject to protect it's database, your other business applications (like SSRS or SQL Stored Procs) can still work with that database using Crypteron powered SQL CLR functions or SQL CLR SPs. We demonstrate SQL CLR functions here but extending to SQL CLR SPs is straigh forward.

## Final usage

Once you've deployed something like this demo to your crypteron protected SQL Server Database, you can use it very powerfully in multiple ways. 

Purely as a test example, let's assume the `Users` table has social security number _encrypted_ in column `SecureSearch_SSN` and a credit card number _encrypted_ in column `Secure_CreditCardNumber`. If we wish to perform wildcard searches over encrypted data i.e. find credit card numbers that have `1234` _anywhere_ in them, we can have a SQL Stored Procedure or query like:

    -- Use your own Crypteron AppSecret obtained from https://my.cryteron.com
    SELECT [dbo].[CrypteronSetAppSecret](N'YourAppSecretFrom_https://my.cryteron.com_GoesHere')
    GO

    -- Use the Crypteron user-defined function as necessary
    SELECT
    [OrderId]
    ,[dbo].[CrypteronDecrypt]([SecureSearch_SSN]) as SocialSecurityNumber
    ,[Timestamp]
    ,[CustomerName]
    ,[dbo].[CrypteronDecrypt](Secure_CreditCardNumber) as CreditCardNumber
    FROM Users 
    WHERE ([dbo].[CrypteronDecrypt](Secure_CreditCardNumber)) LIKE '%1234%'
    GO

### Advanced usage: data pipelines

What's even more interesting is that if you skip decryption in the `SELECT` part, i.e.

    SELECT * FROM Users
    WHERE ([dbo].[CrypteronDecrypt](Secure_CreditCardNumber)) LIKE '%1234%'
    GO

the returned results are secure and encrypted. So you can now build secure data pipelines across various pieces of your enterprise and/or cloud infrastructure. Example: you can send these processed-but-still-encrypted results to untrusted storage (e.g. log to cloud storage) waiting for additional processing by another Crypteron-powered web-application/SQL SP/background worker.

## To run the demo

1. Clone this repo
2. Open the .sln solution file in Visual Studio
3. Double click the `CrypteronSqlClrDemo.publish.xml` file and follow the wizard to generate/deploy to a database. We've defaulted to a localdb instance but you can adjust as needed.
4. Once deployed, you can test it out by issuing something as seen in `runtest.sql` like

```
USE [CrypteronSqlClrDemo]
GO

-- Use your own Crypteron AppSecret obtained from https://my.cryteron.com
SELECT [dbo].[CrypteronSetAppSecret](N'YourAppSecretFrom_https://my.cryteron.com_GoesHere')
GO

-- Encrypt some sensitive data, key management happens automatically
SELECT [dbo].[CrypteronEncrypt](N'Credit Card: 1234 5678 9012 3456')
GO

-- Decrypt it back, key management happens automatically
SELECT [dbo].[CrypteronDecrypt](N'TheEncryptedTextYouGotFromTheAboveCallGoesHere')
GO
```

## High level architecture

1. We write C# wrappers methods in `CrypteronDemo\SqlClrUserDefinedFunctions.cs` to encrypt and decrypt individual fields by using Crypteron's CipherObject. The complexity around key management, data tamper protection, cryptography etc is handled within CipherObject, shielding the programmers from that burden. There is also a method to initialization the Crypteron AppSecret (a glorified API key) which you must call before your first encrypt or decrypt call.

2. SQL Server is then configured to allow C# / CLR execution.

3. The resulting .dll and dependency .dlls are uploaded to SQL Server

4. The C# methods in our .dll are registered/exposed as SQL User Defined Functions (UDF). We end up with `[dbo].[CrypteronSetAppSecret]`, `[dbo].[CrypteronEncrypt]` and `[dbo].[CrypteronDecrypt]`. Since each of them take in a single value and return a single value (i.e. scalar), they are called Scalar-valued functions. Viewed from SSMS, these will be found at `<Database>/Programmability/Functions/Scalar-valued Functions/`

5. Those SQL UDFs are now used just like regular ones inside SPs or with SSRS

The Crypteron specific portion of this demo are quite straight forward but configuring SQL Server for CLR execution can be tricky. For this reason, we're using a Visual Studio (VS) SQL project to have VS auto-generate the necessary deployment scripts. Advanced users can build their `.dll` separately and then deploy using SQL scripts; please refer to `register.sql` and `unregister.sql` and adapt them to your use-cases.

## Tips and Troubleshooting

### We are here to help!

Do read this section but if you're stuck, contact us at support@crypteron.com for help

### Adding support for byte[]

The demo shows how to encrypt/decrypt strings but you can easily extend this to support byte arrays since CipherObject supports both strings and byte arrays. We recommend another user-defined function that specifically uses byte arrays as input and output - mirroring what's happening in the string example.

### Adding .NET Framework DLLs to VS SQL projects

SQL Server's CLR only includes a small subset of the .NET Framework by default but we need a few more DLLs. We add these additional assemblies from `C:\Windows\Microsoft.NET\Framework64\v4.0.30319\`. To add via SQL refer to `register.sql` here. To add using Visual Studio, 

* Go to solution explorer -> right clicking references -> add reference -> browse (do _NOT_ pick assemblies) -> browse -> `C:\Windows\Microsoft.NET\Framework64\v4.0.30319\` and select the following DLLs

```
    System.Net.Http.dll
    System.Runtime.Caching.dll
    System.Runtime.Serialization.dll
    System.ServiceModel.Internals.dll
    SMDiagnostics.dll
```

* After added to the VS SQL project, go to solution explorer -> references -> right click the just added references -> properties and set `Model aware=True` and `Permission set=Unsafe` for each of the above. `Model aware=True` adds the dll to the deployment SQL script and hence adds the DLL to SQL Server while `Permission set=Unsafe` is needed since those DLLs call native/unsafe code.

### Add the correct .NET Framework DLLs

When adding .NET framework assemblies to SQL Server, you need to add the _Framework_ DLLs from `C:\Windows\Microsoft.NET\Framework64\v4.0.30319\` and NOT the _Reference_ DLLs from `C:\Program Files (x86)\Reference Assemblies\Microsoft\Framework\.NETFramework\v4.5\`.

### Program AppSecret again

Inactivity or memory pressure situations can cause SQL Server to dispose the CLR execution environment (recycle AppDomain). After such conditions, you may need to set the Crypteron AppSecret once again.

### Crypteron DLLs in VS SQL Projects

Unlike Visual Studio C# projects, Visual Studio _SQL projects_ don't currently work with NuGet packages. So you have to manually download the Crypteron packages from https://www.nuget.org/packages/CipherObject/ and https://www.nuget.org/packages/CipherCore/. After downloading both, rename each file to end in `.zip`. Open the .zip files to find the respective .dlls at the `\lib\net45\` location. Now you can copy these .dlls locally into your project and add as a reference in Visual Studio. This demo VS SQL project is already setup so this guidance is only for your own VS SQL projects.

### Set DB as Trustworthy in VS SQL project

You may have to enable `Trustworthy` for your database. In VS SQL project -> project properties -> project settings -> database settings -> Miscellaneous -> [X] Trustworthy -> OK. In raw SQL it's `ALTER DATABASE yourDatabase SET TRUSTWORTHY ON;`

### Miscellaneous VS SQL Project quirks

* Unfortunately, sometimes Visual Studio adds additional XML markup inside your `.sqlproj` file that's not reflected in the GUI. If you find yourself wondering why publishing your changes is failing, try looking inside your own `.sqlproj` file and compare it to the `.sqlproj` file found in this demo project.

* Occassionally, Visual Studio may be unable to directly run the SQL script on the server (when you click publish). We recommend the `generate script` option and then using that instead.

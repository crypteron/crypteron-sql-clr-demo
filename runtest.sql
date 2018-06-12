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

using Microsoft.SqlServer.Server;

namespace SqlClrCipherObject
{
    public class SqlClrUserDefinedFunctions
    {
        /// <summary>
        /// Crypteron CipherObject works with objects and their properties, not 
        /// standalone values, so define an object to facilitate that
        /// </summary>
        private class CipherObjectDataHolder
        {
            // string or byte[] per your use case
            public string Secure_Data { get; set; }
        }

        /// <summary>
        /// Scalar-Values SQL CLR functions return a single value (e.g. a string)
        /// https://docs.microsoft.com/en-us/sql/relational-databases/clr-integration-database-objects-user-defined-functions/clr-scalar-valued-functions?view=sql-server-2017
        /// </summary>
        /// <param name="clearText"></param>
        /// <returns></returns>
        [SqlFunction(DataAccess = DataAccessKind.None)]
        public static string CrypteronEncrypt(string clearText)
        {
            var cipherObj = new CipherObjectDataHolder { Secure_Data = clearText };
            Crypteron.CipherObject.Protector.Seal(cipherObj);
            return cipherObj.Secure_Data;
        }

        [SqlFunction(DataAccess = DataAccessKind.None)]
        public static string CrypteronDecrypt(string cipherText)
        {
            var cipherObj = new CipherObjectDataHolder { Secure_Data = cipherText };
            Crypteron.CipherObject.Protector.Unseal(cipherObj);
            return cipherObj.Secure_Data;
        }

        [SqlFunction(DataAccess = DataAccessKind.None)]
        public static string CrypteronSetAppSecret(string appSecret)
        {
            // you need to program your Crypteron AppSecret. Get it from
            // https://my.crypteron.com
            Crypteron.CrypteronConfig.Config.MyCrypteronAccount.AppSecret = appSecret;
            return Crypteron.CrypteronConfig.Config.MyCrypteronAccount.AppSecret;
        }
    }
}

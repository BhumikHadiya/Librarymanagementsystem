using System;
using System.Security.Cryptography;

/// <summary>
/// Hashes passwords with PBKDF2 (SHA-256) and a random salt.
/// Stored format:  PBKDF2$iterations$base64Salt$base64Hash
/// The plain-text password is never stored anywhere.
/// </summary>
public static class PasswordHasher
{
    private const int SaltSize = 16;      // 128-bit salt
    private const int HashSize = 32;      // 256-bit hash
    private const int Iterations = 10000;

    public static string HashPassword(string password)
    {
        byte[] salt = new byte[SaltSize];
        using (RandomNumberGenerator rng = RandomNumberGenerator.Create())
        {
            rng.GetBytes(salt);
        }

        byte[] hash = Pbkdf2(password, salt, Iterations);
        return "PBKDF2$" + Iterations + "$" + Convert.ToBase64String(salt) + "$" + Convert.ToBase64String(hash);
    }

    public static bool VerifyPassword(string password, string storedHash)
    {
        if (string.IsNullOrEmpty(password) || string.IsNullOrEmpty(storedHash))
            return false;

        string[] parts = storedHash.Split('$');
        if (parts.Length != 4 || parts[0] != "PBKDF2")
            return false;

        int iterations;
        if (!int.TryParse(parts[1], out iterations) || iterations <= 0)
            return false;

        try
        {
            byte[] salt = Convert.FromBase64String(parts[2]);
            byte[] expected = Convert.FromBase64String(parts[3]);
            byte[] actual = Pbkdf2(password, salt, iterations, expected.Length);
            return SlowEquals(expected, actual);
        }
        catch (FormatException)
        {
            return false;
        }
    }

    private static byte[] Pbkdf2(string password, byte[] salt, int iterations, int length = HashSize)
    {
        using (Rfc2898DeriveBytes pbkdf2 = new Rfc2898DeriveBytes(password, salt, iterations, HashAlgorithmName.SHA256))
        {
            return pbkdf2.GetBytes(length);
        }
    }

    // Compares every byte so the time taken does not reveal where the first difference is
    private static bool SlowEquals(byte[] a, byte[] b)
    {
        int diff = a.Length ^ b.Length;
        for (int i = 0; i < a.Length && i < b.Length; i++)
            diff |= a[i] ^ b[i];
        return diff == 0;
    }
}

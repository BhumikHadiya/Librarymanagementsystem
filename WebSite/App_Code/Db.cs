using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

/// <summary>
/// Small helper for talking to SQL Server.
/// Every method takes SqlParameter objects, so values are never
/// concatenated into SQL text (this prevents SQL injection).
/// </summary>
public static class Db
{
    public static string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["LibraryDB"].ConnectionString; }
    }

    public static SqlConnection GetConnection()
    {
        return new SqlConnection(ConnectionString);
    }

    /// <summary>Creates a parameter; null becomes DBNull.Value.</summary>
    public static SqlParameter P(string name, object value)
    {
        return new SqlParameter(name, value ?? DBNull.Value);
    }

    /// <summary>Runs a SELECT and returns the rows as a DataTable.</summary>
    public static DataTable GetDataTable(string sql, params SqlParameter[] parameters)
    {
        using (SqlConnection conn = GetConnection())
        using (SqlCommand cmd = new SqlCommand(sql, conn))
        {
            cmd.Parameters.AddRange(parameters);
            using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
            {
                DataTable table = new DataTable();
                adapter.Fill(table);
                return table;
            }
        }
    }

    /// <summary>Runs a query and returns the first column of the first row.</summary>
    public static object ExecuteScalar(string sql, params SqlParameter[] parameters)
    {
        using (SqlConnection conn = GetConnection())
        using (SqlCommand cmd = new SqlCommand(sql, conn))
        {
            cmd.Parameters.AddRange(parameters);
            conn.Open();
            return cmd.ExecuteScalar();
        }
    }

    /// <summary>Runs INSERT / UPDATE / DELETE and returns the number of affected rows.</summary>
    public static int ExecuteNonQuery(string sql, params SqlParameter[] parameters)
    {
        using (SqlConnection conn = GetConnection())
        using (SqlCommand cmd = new SqlCommand(sql, conn))
        {
            cmd.Parameters.AddRange(parameters);
            conn.Open();
            return cmd.ExecuteNonQuery();
        }
    }

    /// <summary>True when SQL Server rejected a duplicate value (UNIQUE constraint).</summary>
    public static bool IsDuplicateKeyError(SqlException ex)
    {
        return ex.Number == 2627 || ex.Number == 2601;
    }

    /// <summary>True when SQL Server rejected a delete because other rows still refer to it.</summary>
    public static bool IsForeignKeyError(SqlException ex)
    {
        return ex.Number == 547;
    }
}

using System;
using System.Data;
using System.Data.SqlClient;

/// <summary>
/// Business rules for issuing and returning books.
/// Each operation runs inside a database transaction so the book
/// quantity and the issue record are always updated together.
/// </summary>
public static class LibraryService
{
    /// <summary>Fine = days late x fine per day (0 when returned on or before the due date).</summary>
    public static decimal CalculateFine(DateTime dueDate, DateTime returnDate)
    {
        int daysLate = (returnDate.Date - dueDate.Date).Days;
        return daysLate > 0 ? daysLate * AppConfig.FinePerDay : 0m;
    }

    /// <summary>Number of books the student currently has (not yet returned).</summary>
    public static int GetActiveIssueCount(int studentId)
    {
        object result = Db.ExecuteScalar(
            "SELECT COUNT(*) FROM BookIssues WHERE StudentID = @StudentID AND IssueStatus = 'Issued'",
            Db.P("@StudentID", studentId));
        return Convert.ToInt32(result);
    }

    /// <summary>
    /// Issues a book to a student. Returns true on success; otherwise
    /// returns false and puts the reason in errorMessage.
    /// </summary>
    public static bool IssueBook(int studentId, int bookId, DateTime issueDate, DateTime dueDate,
                                 int adminId, out string errorMessage)
    {
        errorMessage = null;

        if (dueDate.Date < issueDate.Date)
        {
            errorMessage = "Due date cannot be before the issue date.";
            return false;
        }

        using (SqlConnection conn = Db.GetConnection())
        {
            conn.Open();
            SqlTransaction tx = conn.BeginTransaction();
            try
            {
                // 1. Student must exist and be active. UPDLOCK makes two issues
                //    for the same student wait for each other (correct counting).
                object active = Scalar(conn, tx,
                    "SELECT IsActive FROM Students WITH (UPDLOCK, ROWLOCK) WHERE StudentID = @StudentID",
                    Db.P("@StudentID", studentId));
                if (active == null)
                {
                    tx.Rollback();
                    errorMessage = "Selected student was not found.";
                    return false;
                }
                if (!Convert.ToBoolean(active))
                {
                    tx.Rollback();
                    errorMessage = "This student account is inactive and cannot borrow books.";
                    return false;
                }

                // 2. Borrowing limit
                int current = Convert.ToInt32(Scalar(conn, tx,
                    "SELECT COUNT(*) FROM BookIssues WHERE StudentID = @StudentID AND IssueStatus = 'Issued'",
                    Db.P("@StudentID", studentId)));
                if (current >= AppConfig.MaxBooksPerStudent)
                {
                    tx.Rollback();
                    errorMessage = "Borrowing limit reached: this student already has " + current +
                                   " book(s). Maximum allowed is " + AppConfig.MaxBooksPerStudent + ".";
                    return false;
                }

                // 3. Same title cannot be issued twice to the same student at the same time
                int sameBook = Convert.ToInt32(Scalar(conn, tx,
                    "SELECT COUNT(*) FROM BookIssues WHERE StudentID = @StudentID AND BookID = @BookID AND IssueStatus = 'Issued'",
                    Db.P("@StudentID", studentId), Db.P("@BookID", bookId)));
                if (sameBook > 0)
                {
                    tx.Rollback();
                    errorMessage = "This student already has a copy of this book.";
                    return false;
                }

                // 4. Take one copy off the shelf - only succeeds if a copy is available
                int updated = NonQuery(conn, tx,
                    "UPDATE Books SET AvailableQuantity = AvailableQuantity - 1 " +
                    "WHERE BookID = @BookID AND AvailableQuantity > 0",
                    Db.P("@BookID", bookId));
                if (updated == 0)
                {
                    tx.Rollback();
                    errorMessage = "This book is not available right now (all copies are issued).";
                    return false;
                }

                // 5. Record the issue
                NonQuery(conn, tx,
                    "INSERT INTO BookIssues (BookID, StudentID, IssueDate, DueDate, IssueStatus, IssuedBy) " +
                    "VALUES (@BookID, @StudentID, @IssueDate, @DueDate, 'Issued', @IssuedBy)",
                    Db.P("@BookID", bookId),
                    Db.P("@StudentID", studentId),
                    Db.P("@IssueDate", issueDate.Date),
                    Db.P("@DueDate", dueDate.Date),
                    Db.P("@IssuedBy", adminId));

                tx.Commit();
                return true;
            }
            catch
            {
                tx.Rollback();
                throw;
            }
        }
    }

    /// <summary>
    /// Returns a book. Calculates the fine, closes the issue record and
    /// puts the copy back on the shelf, all in one transaction.
    /// </summary>
    public static bool ReturnBook(int issueId, DateTime returnDate, int adminId,
                                  out decimal fine, out string errorMessage)
    {
        fine = 0m;
        errorMessage = null;

        using (SqlConnection conn = Db.GetConnection())
        {
            conn.Open();
            SqlTransaction tx = conn.BeginTransaction();
            try
            {
                DataTable issue = Table(conn, tx,
                    "SELECT BookID, IssueDate, DueDate, IssueStatus FROM BookIssues WITH (UPDLOCK, ROWLOCK) " +
                    "WHERE IssueID = @IssueID",
                    Db.P("@IssueID", issueId));

                if (issue.Rows.Count == 0)
                {
                    tx.Rollback();
                    errorMessage = "Issue record was not found.";
                    return false;
                }

                DataRow row = issue.Rows[0];
                if ((string)row["IssueStatus"] != "Issued")
                {
                    tx.Rollback();
                    errorMessage = "This book has already been returned.";
                    return false;
                }

                DateTime issueDate = (DateTime)row["IssueDate"];
                if (returnDate.Date < issueDate.Date)
                {
                    tx.Rollback();
                    errorMessage = "Return date cannot be before the issue date (" + issueDate.ToString("dd MMM yyyy") + ").";
                    return false;
                }

                fine = CalculateFine((DateTime)row["DueDate"], returnDate);

                NonQuery(conn, tx,
                    "UPDATE BookIssues SET ReturnDate = @ReturnDate, FineAmount = @Fine, " +
                    "IssueStatus = 'Returned', ReturnedTo = @ReturnedTo " +
                    "WHERE IssueID = @IssueID AND IssueStatus = 'Issued'",
                    Db.P("@ReturnDate", returnDate.Date),
                    Db.P("@Fine", fine),
                    Db.P("@ReturnedTo", adminId),
                    Db.P("@IssueID", issueId));

                NonQuery(conn, tx,
                    "UPDATE Books SET AvailableQuantity = AvailableQuantity + 1 " +
                    "WHERE BookID = @BookID AND AvailableQuantity < TotalQuantity",
                    Db.P("@BookID", (int)row["BookID"]));

                tx.Commit();
                return true;
            }
            catch
            {
                tx.Rollback();
                throw;
            }
        }
    }

    // ----- small helpers that run a command inside the current transaction -----

    private static SqlCommand Command(SqlConnection conn, SqlTransaction tx, string sql, SqlParameter[] parameters)
    {
        SqlCommand cmd = new SqlCommand(sql, conn, tx);
        cmd.Parameters.AddRange(parameters);
        return cmd;
    }

    private static object Scalar(SqlConnection conn, SqlTransaction tx, string sql, params SqlParameter[] parameters)
    {
        using (SqlCommand cmd = Command(conn, tx, sql, parameters))
        {
            object result = cmd.ExecuteScalar();
            return result == DBNull.Value ? null : result;
        }
    }

    private static int NonQuery(SqlConnection conn, SqlTransaction tx, string sql, params SqlParameter[] parameters)
    {
        using (SqlCommand cmd = Command(conn, tx, sql, parameters))
        {
            return cmd.ExecuteNonQuery();
        }
    }

    private static DataTable Table(SqlConnection conn, SqlTransaction tx, string sql, params SqlParameter[] parameters)
    {
        using (SqlCommand cmd = Command(conn, tx, sql, parameters))
        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
        {
            DataTable table = new DataTable();
            adapter.Fill(table);
            return table;
        }
    }
}

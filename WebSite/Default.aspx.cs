using System;
using System.Data;
using System.Web.UI.WebControls;

public partial class DashboardPage : AdminPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadSummary();
            LoadRecentIssues();
            LoadOverdue();
        }
    }

    private void LoadSummary()
    {
        DataTable t = Db.GetDataTable(@"
            SELECT
                (SELECT COUNT(*) FROM Books)                                   AS TotalTitles,
                (SELECT ISNULL(SUM(TotalQuantity), 0) FROM Books)              AS TotalCopies,
                (SELECT COUNT(*) FROM Students)                                AS TotalStudents,
                (SELECT COUNT(*) FROM BookIssues WHERE IssueStatus = 'Issued') AS CurrentlyIssued,
                (SELECT COUNT(*) FROM BookIssues WHERE IssueStatus = 'Issued'
                                                   AND DueDate < CAST(GETDATE() AS DATE)) AS Overdue");

        DataRow row = t.Rows[0];
        litTotalBooks.Text = row["TotalCopies"].ToString();
        litTotalTitles.Text = row["TotalTitles"].ToString();
        litStudents.Text = row["TotalStudents"].ToString();
        litIssued.Text = row["CurrentlyIssued"].ToString();
        litOverdue.Text = row["Overdue"].ToString();
    }

    private void LoadRecentIssues()
    {
        gvRecent.DataSource = Db.GetDataTable(@"
            SELECT TOP 8 i.IssueID, b.Title, s.FullName AS StudentName,
                   i.IssueDate, i.DueDate, i.IssueStatus
            FROM BookIssues i
            INNER JOIN Books b    ON b.BookID = i.BookID
            INNER JOIN Students s ON s.StudentID = i.StudentID
            ORDER BY i.IssueDate DESC, i.IssueID DESC");
        gvRecent.DataBind();
    }

    private void LoadOverdue()
    {
        gvOverdue.DataSource = Db.GetDataTable(@"
            SELECT TOP 8 b.Title, s.FullName AS StudentName,
                   DATEDIFF(DAY, i.DueDate, CAST(GETDATE() AS DATE)) AS DaysOverdue
            FROM BookIssues i
            INNER JOIN Books b    ON b.BookID = i.BookID
            INNER JOIN Students s ON s.StudentID = i.StudentID
            WHERE i.IssueStatus = 'Issued' AND i.DueDate < CAST(GETDATE() AS DATE)
            ORDER BY i.DueDate");
        gvOverdue.DataBind();
    }

    protected void gvRecent_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow)
            return;

        DataRowView data = (DataRowView)e.Row.DataItem;
        Literal lit = (Literal)e.Row.FindControl("litStatus");
        lit.Text = UiHelper.StatusBadge((string)data["IssueStatus"], (DateTime)data["DueDate"]);
    }
}

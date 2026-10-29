using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web;
using System.Web.UI.WebControls;

public partial class ReportsPage : AdminPage
{
    private const string DateFormat = "yyyy-MM-dd";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadStudents();

            // Links from other pages: Reports.aspx?type=Overdue or Reports.aspx?studentId=5
            string type = Request.QueryString["type"];
            if (type != null && ddlType.Items.FindByValue(type) != null)
                ddlType.SelectedValue = type;

            string studentId = QueryInt("studentId").ToString();
            if (ddlStudent.Items.FindByValue(studentId) != null)
                ddlStudent.SelectedValue = studentId;

            BindReport();
        }
    }

    private void LoadStudents()
    {
        ddlStudent.DataSource = Db.GetDataTable(
            "SELECT StudentID, StudentCode + ' - ' + FullName AS Display FROM Students ORDER BY StudentCode");
        ddlStudent.DataTextField = "Display";
        ddlStudent.DataValueField = "StudentID";
        ddlStudent.DataBind();
        ddlStudent.Items.Insert(0, new ListItem("All students", "0"));
    }

    private void BindReport()
    {
        DateTime from, to;
        bool hasFrom = DateTime.TryParseExact(txtFrom.Text, DateFormat, CultureInfo.InvariantCulture, DateTimeStyles.None, out from);
        bool hasTo = DateTime.TryParseExact(txtTo.Text, DateFormat, CultureInfo.InvariantCulture, DateTimeStyles.None, out to);

        if (hasFrom && hasTo && from > to)
        {
            ShowMessage("'From' date must be before 'To' date.", "danger");
            return;
        }

        DataTable data = Db.GetDataTable(@"
            SELECT i.IssueID, s.StudentCode, s.FullName AS StudentName, b.Title, b.ISBN,
                   i.IssueDate, i.DueDate, i.ReturnDate, i.FineAmount, i.IssueStatus
            FROM BookIssues i
            INNER JOIN Books b    ON b.BookID = i.BookID
            INNER JOIN Students s ON s.StudentID = i.StudentID
            WHERE (@StudentID = 0 OR i.StudentID = @StudentID)
              AND (@From IS NULL OR i.IssueDate >= @From)
              AND (@To   IS NULL OR i.IssueDate <= @To)
              AND (   @Type = 'All'
                   OR (@Type = 'Issued'   AND i.IssueStatus = 'Issued')
                   OR (@Type = 'Returned' AND i.IssueStatus = 'Returned')
                   OR (@Type = 'Overdue'  AND i.IssueStatus = 'Issued' AND i.DueDate < CAST(GETDATE() AS DATE))
                   OR (@Type = 'Fined'    AND i.IssueStatus = 'Returned' AND i.FineAmount > 0))
            ORDER BY i.IssueDate DESC, i.IssueID DESC",
            Db.P("@StudentID", int.Parse(ddlStudent.SelectedValue)),
            new SqlParameter("@From", SqlDbType.Date) { Value = hasFrom ? (object)from : DBNull.Value },
            new SqlParameter("@To", SqlDbType.Date) { Value = hasTo ? (object)to : DBNull.Value },
            Db.P("@Type", ddlType.SelectedValue));

        gvReport.DataSource = data;
        gvReport.DataBind();

        // Summary numbers
        int stillOut = 0, overdue = 0;
        decimal fines = 0m;
        foreach (DataRow row in data.Rows)
        {
            if ((string)row["IssueStatus"] == "Issued")
            {
                stillOut++;
                if ((DateTime)row["DueDate"] < DateTime.Today)
                    overdue++;
            }
            fines += (decimal)row["FineAmount"];
        }
        litTotal.Text = data.Rows.Count.ToString();
        litOut.Text = stillOut.ToString();
        litOverdue.Text = overdue.ToString();
        litFines.Text = HttpUtility.HtmlEncode(AppConfig.Money(fines));

        string title = ddlType.SelectedItem.Text;
        if (ddlStudent.SelectedValue != "0")
            title += " - " + ddlStudent.SelectedItem.Text;
        if (hasFrom || hasTo)
            title += " (" + (hasFrom ? from.ToString("dd MMM yyyy") : "start") + " to " +
                     (hasTo ? to.ToString("dd MMM yyyy") : "today") + ")";
        litReportTitle.Text = HttpUtility.HtmlEncode(title);
    }

    protected void gvReport_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow)
            return;

        DataRowView data = (DataRowView)e.Row.DataItem;
        decimal fine = (decimal)data["FineAmount"];
        ((Literal)e.Row.FindControl("litFine")).Text = fine > 0 ? HttpUtility.HtmlEncode(AppConfig.Money(fine)) : "-";
        ((Literal)e.Row.FindControl("litStatus")).Text =
            UiHelper.StatusBadge((string)data["IssueStatus"], (DateTime)data["DueDate"]);
    }

    protected void btnRun_Click(object sender, EventArgs e)
    {
        BindReport();
    }

    protected void btnReset_Click(object sender, EventArgs e)
    {
        ddlType.SelectedValue = "All";
        ddlStudent.SelectedValue = "0";
        txtFrom.Text = "";
        txtTo.Text = "";
        BindReport();
    }
}

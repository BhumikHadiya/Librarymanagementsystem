using System;
using System.Data;
using System.Globalization;
using System.Web;
using System.Web.UI.WebControls;

public partial class ReturnBookPage : AdminPage
{
    private const string DateFormat = "yyyy-MM-dd";

    protected void Page_Load(object sender, EventArgs e)
    {
        litFineRule.Text = "Fine rule: " + AppConfig.Money(AppConfig.FinePerDay) + " per day after the due date.";

        if (!IsPostBack)
            BindIssued();
    }

    private void BindIssued()
    {
        string search = txtSearch.Text.Trim();
        gvIssued.DataSource = Db.GetDataTable(@"
            SELECT i.IssueID, s.StudentCode, s.FullName AS StudentName, b.Title, b.ISBN,
                   i.IssueDate, i.DueDate,
                   DATEDIFF(DAY, i.DueDate, CAST(GETDATE() AS DATE)) AS DaysLate
            FROM BookIssues i
            INNER JOIN Books b    ON b.BookID = i.BookID
            INNER JOIN Students s ON s.StudentID = i.StudentID
            WHERE i.IssueStatus = 'Issued'
              AND (@Search = '' OR s.StudentCode LIKE @Like OR s.FullName LIKE @Like
                                OR b.Title LIKE @Like OR b.ISBN LIKE @Like)
              AND (@OverdueOnly = 0 OR i.DueDate < CAST(GETDATE() AS DATE))
            ORDER BY i.DueDate",
            Db.P("@Search", search),
            Db.P("@Like", "%" + search + "%"),
            Db.P("@OverdueOnly", chkOverdueOnly.Checked));
        gvIssued.DataBind();
    }

    protected void gvIssued_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow)
            return;

        int daysLate = (int)((DataRowView)e.Row.DataItem)["DaysLate"];
        ((Literal)e.Row.FindControl("litStatus")).Text = daysLate > 0
            ? "<span class=\"badge bg-danger\">" + daysLate + " day(s) late</span> " +
              HttpUtility.HtmlEncode(AppConfig.Money(daysLate * AppConfig.FinePerDay))
            : "<span class=\"badge bg-warning text-dark\">On time</span>";
    }

    protected void gvIssued_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvIssued.PageIndex = e.NewPageIndex;
        BindIssued();
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        gvIssued.PageIndex = 0;
        BindIssued();
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        txtSearch.Text = "";
        chkOverdueOnly.Checked = false;
        gvIssued.PageIndex = 0;
        BindIssued();
    }

    protected void gvIssued_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName != "SelectIssue")
            return;

        int issueId = Convert.ToInt32(e.CommandArgument);
        DataTable t = Db.GetDataTable(@"
            SELECT b.Title, b.ISBN, s.StudentCode, s.FullName, i.IssueDate, i.DueDate
            FROM BookIssues i
            INNER JOIN Books b    ON b.BookID = i.BookID
            INNER JOIN Students s ON s.StudentID = i.StudentID
            WHERE i.IssueID = @ID AND i.IssueStatus = 'Issued'",
            Db.P("@ID", issueId));

        if (t.Rows.Count == 0)
        {
            ShowMessage("This book has already been returned.", "warning");
            BindIssued();
            return;
        }

        DataRow row = t.Rows[0];
        hfIssueId.Value = issueId.ToString();
        litBook.Text = HttpUtility.HtmlEncode(row["Title"] + " (" + row["ISBN"] + ")");
        litStudent.Text = HttpUtility.HtmlEncode(row["StudentCode"] + " - " + row["FullName"]);
        litIssued.Text = ((DateTime)row["IssueDate"]).ToString("dd MMM yyyy");
        litDue.Text = ((DateTime)row["DueDate"]).ToString("dd MMM yyyy");
        ViewState["DueDate"] = (DateTime)row["DueDate"];
        txtReturnDate.Text = DateTime.Today.ToString(DateFormat);
        UpdateFinePreview();
        pnlReturn.Visible = true;
    }

    protected void txtReturnDate_TextChanged(object sender, EventArgs e)
    {
        UpdateFinePreview();
    }

    private void UpdateFinePreview()
    {
        DateTime returnDate;
        if (ViewState["DueDate"] == null || !TryGetReturnDate(out returnDate))
        {
            litFine.Text = "-";
            return;
        }
        decimal fine = LibraryService.CalculateFine((DateTime)ViewState["DueDate"], returnDate);
        litFine.Text = HttpUtility.HtmlEncode(AppConfig.Money(fine));
    }

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid)
            return;

        DateTime returnDate;
        if (!TryGetReturnDate(out returnDate))
        {
            ShowMessage("Please enter a valid return date.", "danger");
            return;
        }
        if (returnDate > DateTime.Today)
        {
            ShowMessage("Return date cannot be in the future.", "danger");
            return;
        }

        decimal fine;
        string error;
        if (LibraryService.ReturnBook(int.Parse(hfIssueId.Value), returnDate, AdminId, out fine, out error))
        {
            ShowMessage(fine > 0
                ? "Book returned. Late fine of " + AppConfig.Money(fine) + " must be collected."
                : "Book returned on time. No fine.", "success");
            pnlReturn.Visible = false;
            ViewState.Remove("DueDate");
        }
        else
        {
            ShowMessage(error, "danger");
        }
        BindIssued();
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        pnlReturn.Visible = false;
        ViewState.Remove("DueDate");
    }

    private bool TryGetReturnDate(out DateTime returnDate)
    {
        return DateTime.TryParseExact(txtReturnDate.Text, DateFormat, CultureInfo.InvariantCulture,
                                      DateTimeStyles.None, out returnDate);
    }
}

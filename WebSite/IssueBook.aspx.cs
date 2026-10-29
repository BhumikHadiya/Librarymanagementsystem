using System;
using System.Data;
using System.Globalization;
using System.Web;
using System.Web.UI.WebControls;

public partial class IssueBookPage : AdminPage
{
    private const string DateFormat = "yyyy-MM-dd"; // format used by <input type="date">

    protected void Page_Load(object sender, EventArgs e)
    {
        litLoanDays.Text = AppConfig.LoanPeriodDays.ToString();

        if (!IsPostBack)
        {
            LoadStudents();
            LoadBooks();
            ResetDates();
        }
    }

    private void LoadStudents()
    {
        ddlStudent.DataSource = Db.GetDataTable(@"
            SELECT StudentID, StudentCode + ' - ' + FullName AS Display
            FROM Students WHERE IsActive = 1 ORDER BY StudentCode");
        ddlStudent.DataTextField = "Display";
        ddlStudent.DataValueField = "StudentID";
        ddlStudent.DataBind();
        ddlStudent.Items.Insert(0, new ListItem("-- Select student --", "0"));
    }

    private void LoadBooks()
    {
        ddlBook.Items.Clear();
        ddlBook.DataSource = Db.GetDataTable(@"
            SELECT BookID,
                   Title + ' - ' + Author + ' (' + CAST(AvailableQuantity AS VARCHAR(10)) + ' available)' AS Display
            FROM Books WHERE AvailableQuantity > 0 ORDER BY Title");
        ddlBook.DataTextField = "Display";
        ddlBook.DataValueField = "BookID";
        ddlBook.DataBind();
        ddlBook.Items.Insert(0, new ListItem("-- Select book --", "0"));
    }

    private void ResetDates()
    {
        txtIssueDate.Text = DateTime.Today.ToString(DateFormat);
        txtDueDate.Text = DateTime.Today.AddDays(AppConfig.LoanPeriodDays).ToString(DateFormat);
    }

    protected void ddlStudent_SelectedIndexChanged(object sender, EventArgs e)
    {
        ShowStudentDetails();
    }

    private void ShowStudentDetails()
    {
        int studentId = int.Parse(ddlStudent.SelectedValue);
        pnlStudent.Visible = studentId > 0;
        pnlNoStudent.Visible = studentId == 0;
        if (studentId == 0)
            return;

        DataTable s = Db.GetDataTable(
            "SELECT StudentCode, FullName, Department, YearOfStudy FROM Students WHERE StudentID = @ID",
            Db.P("@ID", studentId));
        if (s.Rows.Count == 0)
            return;

        DataRow row = s.Rows[0];
        litStudentName.Text = HttpUtility.HtmlEncode(row["FullName"]);
        litStudentInfo.Text = HttpUtility.HtmlEncode(row["StudentCode"] + " | " + row["Department"] +
                                                     " | Year " + row["YearOfStudy"]);

        DataTable current = Db.GetDataTable(@"
            SELECT b.Title, i.DueDate FROM BookIssues i
            INNER JOIN Books b ON b.BookID = i.BookID
            WHERE i.StudentID = @ID AND i.IssueStatus = 'Issued'
            ORDER BY i.DueDate",
            Db.P("@ID", studentId));
        gvCurrent.DataSource = current;
        gvCurrent.DataBind();

        int max = AppConfig.MaxBooksPerStudent;
        litBorrowed.Text = current.Rows.Count + " of " + max;
        litLimitWarning.Text = current.Rows.Count >= max
            ? "<div class=\"alert alert-warning py-2\">Borrowing limit reached. A book must be returned first.</div>"
            : "";
    }

    protected void btnIssue_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid)
            return;

        DateTime issueDate, dueDate;
        if (!DateTime.TryParseExact(txtIssueDate.Text, DateFormat, CultureInfo.InvariantCulture, DateTimeStyles.None, out issueDate) ||
            !DateTime.TryParseExact(txtDueDate.Text, DateFormat, CultureInfo.InvariantCulture, DateTimeStyles.None, out dueDate))
        {
            ShowMessage("Please enter valid issue and due dates.", "danger");
            return;
        }
        if (issueDate > DateTime.Today)
        {
            ShowMessage("Issue date cannot be in the future.", "danger");
            return;
        }
        if (dueDate < issueDate)
        {
            ShowMessage("Due date must be on or after the issue date.", "danger");
            return;
        }
        if ((dueDate - issueDate).TotalDays > 90)
        {
            ShowMessage("Loan period cannot be longer than 90 days.", "danger");
            return;
        }

        int studentId = int.Parse(ddlStudent.SelectedValue);
        int bookId = int.Parse(ddlBook.SelectedValue);

        string error;
        if (LibraryService.IssueBook(studentId, bookId, issueDate, dueDate, AdminId, out error))
        {
            ShowMessage("Book issued successfully. Due date: " + dueDate.ToString("dd MMM yyyy") + ".", "success");
            LoadBooks();       // quantities have changed
            ResetDates();
        }
        else
        {
            ShowMessage(error, "danger");
        }
        ShowStudentDetails();
    }
}

using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class StudentsPage : AdminPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
            BindStudents();
    }

    private void BindStudents()
    {
        string search = txtSearch.Text.Trim();
        object status = ddlStatus.SelectedValue == "" ? null : (object)(ddlStatus.SelectedValue == "1");

        DataTable students = Db.GetDataTable(@"
            SELECT s.StudentID, s.StudentCode, s.FullName, s.Department, s.YearOfStudy, s.Email, s.Phone, s.IsActive,
                   (SELECT COUNT(*) FROM BookIssues i WHERE i.StudentID = s.StudentID AND i.IssueStatus = 'Issued') AS BooksIssued
            FROM Students s
            WHERE (@Search = '' OR s.FullName LIKE @Like OR s.StudentCode LIKE @Like)
              AND (@IsActive IS NULL OR s.IsActive = @IsActive)
            ORDER BY s.StudentCode",
            Db.P("@Search", search),
            Db.P("@Like", "%" + search + "%"),
            new SqlParameter("@IsActive", SqlDbType.Bit) { Value = status ?? DBNull.Value });

        gvStudents.DataSource = students;
        gvStudents.DataBind();
        litCount.Text = students.Rows.Count + " student(s) found";
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        gvStudents.PageIndex = 0;
        BindStudents();
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        txtSearch.Text = "";
        ddlStatus.SelectedValue = "";
        gvStudents.PageIndex = 0;
        BindStudents();
    }

    protected void gvStudents_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvStudents.PageIndex = e.NewPageIndex;
        BindStudents();
    }

    protected void gvStudents_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow)
            return;

        bool active = (bool)((DataRowView)e.Row.DataItem)["IsActive"];
        ((Literal)e.Row.FindControl("litStatus")).Text = active
            ? "<span class=\"badge bg-success\">Active</span>"
            : "<span class=\"badge bg-secondary\">Inactive</span>";
    }

    protected void gvStudents_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName != "DeleteStudent")
            return;

        int studentId = Convert.ToInt32(e.CommandArgument);
        try
        {
            Db.ExecuteNonQuery("DELETE FROM Students WHERE StudentID = @ID", Db.P("@ID", studentId));
            ShowMessage("Student deleted successfully.", "success");
        }
        catch (SqlException ex)
        {
            if (!Db.IsForeignKeyError(ex))
                throw;
            ShowMessage("This student has borrowing records and cannot be deleted. " +
                        "Edit the student and mark them Inactive instead.", "warning");
        }
        BindStudents();
    }
}

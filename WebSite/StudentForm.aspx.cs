using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class StudentFormPage : AdminPage
{
    // 0 = registering a new student, otherwise the StudentID being edited
    private int StudentId
    {
        get { return QueryInt("id"); }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (StudentId > 0)
        {
            Page.Title = "Edit Student";
            litHeading.Text = "Edit Student";
        }

        if (!IsPostBack && StudentId > 0)
            LoadStudent();
    }

    private void LoadStudent()
    {
        DataTable t = Db.GetDataTable("SELECT * FROM Students WHERE StudentID = @ID", Db.P("@ID", StudentId));
        if (t.Rows.Count == 0)
        {
            ShowMessage("Student not found.", "danger");
            Response.Redirect("~/Students.aspx", true);
        }

        DataRow row = t.Rows[0];
        txtCode.Text = (string)row["StudentCode"];
        txtName.Text = (string)row["FullName"];
        txtEmail.Text = (string)row["Email"];
        txtPhone.Text = (string)row["Phone"];
        ddlYear.SelectedValue = row["YearOfStudy"].ToString();
        chkActive.Checked = (bool)row["IsActive"];

        // Keep departments that are not in the list (e.g. added directly in the database)
        string department = (string)row["Department"];
        if (ddlDepartment.Items.FindByValue(department) == null)
            ddlDepartment.Items.Add(new ListItem(department));
        ddlDepartment.SelectedValue = department;
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid)
            return;

        string code = txtCode.Text.Trim().ToUpperInvariant();
        SqlParameter[] p =
        {
            Db.P("@Code", code),
            Db.P("@Name", txtName.Text.Trim()),
            Db.P("@Email", txtEmail.Text.Trim().ToLowerInvariant()),
            Db.P("@Phone", txtPhone.Text.Trim()),
            Db.P("@Department", ddlDepartment.SelectedValue),
            Db.P("@Year", int.Parse(ddlYear.SelectedValue)),
            Db.P("@IsActive", chkActive.Checked),
            Db.P("@ID", StudentId)
        };

        try
        {
            if (StudentId == 0)
            {
                Db.ExecuteNonQuery(@"
                    INSERT INTO Students (StudentCode, FullName, Email, Phone, Department, YearOfStudy, IsActive)
                    VALUES (@Code, @Name, @Email, @Phone, @Department, @Year, @IsActive)", p);
            }
            else
            {
                Db.ExecuteNonQuery(@"
                    UPDATE Students SET StudentCode = @Code, FullName = @Name, Email = @Email, Phone = @Phone,
                           Department = @Department, YearOfStudy = @Year, IsActive = @IsActive
                    WHERE StudentID = @ID", p);
            }
        }
        catch (SqlException ex)
        {
            if (!Db.IsDuplicateKeyError(ex))
                throw;
            ShowMessage("Another student already uses this Student ID or email address.", "danger");
            return;
        }

        ShowMessage(StudentId == 0 ? "Student registered successfully." : "Student updated successfully.", "success");
        Response.Redirect("~/Students.aspx", true);
    }
}

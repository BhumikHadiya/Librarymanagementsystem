using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class CategoriesPage : AdminPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
            BindCategories();
    }

    private void BindCategories()
    {
        gvCategories.DataSource = Db.GetDataTable(@"
            SELECT c.CategoryID, c.CategoryName, c.Description,
                   COUNT(b.BookID) AS BookCount, ISNULL(SUM(b.TotalQuantity), 0) AS CopyCount
            FROM Categories c
            LEFT JOIN Books b ON b.CategoryID = c.CategoryID
            GROUP BY c.CategoryID, c.CategoryName, c.Description
            ORDER BY c.CategoryName");
        gvCategories.DataBind();
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid)
            return;

        int id = int.Parse(hfCategoryId.Value);
        string name = txtName.Text.Trim();
        string description = txtDescription.Text.Trim();

        try
        {
            if (id == 0)
            {
                Db.ExecuteNonQuery("INSERT INTO Categories (CategoryName, Description) VALUES (@Name, @Description)",
                    Db.P("@Name", name), Db.P("@Description", description.Length == 0 ? null : description));
                ShowMessage("Category \"" + name + "\" added.", "success");
            }
            else
            {
                Db.ExecuteNonQuery("UPDATE Categories SET CategoryName = @Name, Description = @Description WHERE CategoryID = @ID",
                    Db.P("@Name", name), Db.P("@Description", description.Length == 0 ? null : description), Db.P("@ID", id));
                ShowMessage("Category updated.", "success");
            }
        }
        catch (SqlException ex)
        {
            if (!Db.IsDuplicateKeyError(ex))
                throw;
            ShowMessage("A category named \"" + name + "\" already exists.", "danger");
            return;
        }

        ResetForm();
        BindCategories();
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        ResetForm();
    }

    protected void gvCategories_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int id = Convert.ToInt32(e.CommandArgument);

        if (e.CommandName == "EditCategory")
        {
            DataTable t = Db.GetDataTable("SELECT CategoryName, Description FROM Categories WHERE CategoryID = @ID", Db.P("@ID", id));
            if (t.Rows.Count == 0)
                return;

            hfCategoryId.Value = id.ToString();
            txtName.Text = (string)t.Rows[0]["CategoryName"];
            txtDescription.Text = t.Rows[0]["Description"] as string;
            litFormTitle.Text = "Edit Category";
            btnSave.Text = "Update Category";
            btnCancel.Visible = true;
        }
        else if (e.CommandName == "DeleteCategory")
        {
            try
            {
                Db.ExecuteNonQuery("DELETE FROM Categories WHERE CategoryID = @ID", Db.P("@ID", id));
                ShowMessage("Category deleted.", "success");
            }
            catch (SqlException ex)
            {
                if (!Db.IsForeignKeyError(ex))
                    throw;
                ShowMessage("This category still has books. Move or delete those books first.", "warning");
            }
            ResetForm();
            BindCategories();
        }
    }

    private void ResetForm()
    {
        hfCategoryId.Value = "0";
        txtName.Text = "";
        txtDescription.Text = "";
        litFormTitle.Text = "Add Category";
        btnSave.Text = "Add Category";
        btnCancel.Visible = false;
    }
}

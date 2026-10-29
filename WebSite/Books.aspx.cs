using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class BooksPage : AdminPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            LoadCategories();
            BindBooks();
        }
    }

    private void LoadCategories()
    {
        ddlCategory.DataSource = Db.GetDataTable("SELECT CategoryID, CategoryName FROM Categories ORDER BY CategoryName");
        ddlCategory.DataTextField = "CategoryName";
        ddlCategory.DataValueField = "CategoryID";
        ddlCategory.DataBind();
        ddlCategory.Items.Insert(0, new ListItem("All categories", "0"));
    }

    private void BindBooks()
    {
        string search = txtSearch.Text.Trim();
        int categoryId = int.Parse(ddlCategory.SelectedValue);

        DataTable books = Db.GetDataTable(@"
            SELECT b.BookID, b.ISBN, b.Title, b.Author, c.CategoryName, b.ShelfLocation,
                   b.TotalQuantity, b.AvailableQuantity
            FROM Books b
            INNER JOIN Categories c ON c.CategoryID = b.CategoryID
            WHERE (@Search = '' OR b.Title LIKE @Like OR b.Author LIKE @Like OR b.ISBN LIKE @Like)
              AND (@CategoryID = 0 OR b.CategoryID = @CategoryID)
            ORDER BY b.Title",
            Db.P("@Search", search),
            Db.P("@Like", "%" + search + "%"),
            Db.P("@CategoryID", categoryId));

        gvBooks.DataSource = books;
        gvBooks.DataBind();
        litCount.Text = books.Rows.Count + " book title(s) found";
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        gvBooks.PageIndex = 0;
        BindBooks();
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        txtSearch.Text = "";
        ddlCategory.SelectedValue = "0";
        gvBooks.PageIndex = 0;
        BindBooks();
    }

    protected void gvBooks_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvBooks.PageIndex = e.NewPageIndex;
        BindBooks();
    }

    protected void gvBooks_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType != DataControlRowType.DataRow)
            return;

        DataRowView data = (DataRowView)e.Row.DataItem;
        Literal lit = (Literal)e.Row.FindControl("litQty");
        lit.Text = UiHelper.AvailabilityBadge((int)data["AvailableQuantity"], (int)data["TotalQuantity"]);
    }

    protected void gvBooks_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName != "DeleteBook")
            return;

        int bookId = Convert.ToInt32(e.CommandArgument);

        int issuedNow = Convert.ToInt32(Db.ExecuteScalar(
            "SELECT COUNT(*) FROM BookIssues WHERE BookID = @BookID AND IssueStatus = 'Issued'",
            Db.P("@BookID", bookId)));
        if (issuedNow > 0)
        {
            ShowMessage("This book cannot be deleted because " + issuedNow + " copy(ies) are currently issued.", "warning");
            BindBooks();
            return;
        }

        try
        {
            Db.ExecuteNonQuery("DELETE FROM Books WHERE BookID = @BookID", Db.P("@BookID", bookId));
            ShowMessage("Book deleted successfully.", "success");
        }
        catch (SqlException ex)
        {
            if (!Db.IsForeignKeyError(ex))
                throw;
            ShowMessage("This book has borrowing history and cannot be deleted. " +
                        "Set its quantity instead, or keep it for the records.", "warning");
        }
        BindBooks();
    }
}

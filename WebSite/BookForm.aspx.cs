using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

public partial class BookFormPage : AdminPage
{
    // 0 = adding a new book, otherwise the BookID being edited
    private int BookId
    {
        get { return QueryInt("id"); }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        int maxYear = DateTime.Today.Year;
        rvYear.MaximumValue = maxYear.ToString();
        rvYear.ErrorMessage = "Year must be between 1500 and " + maxYear + ".";
        rvYear.Text = rvYear.ErrorMessage;

        if (BookId > 0)
        {
            Page.Title = "Edit Book";
            litHeading.Text = "Edit Book";
        }

        if (!IsPostBack)
        {
            LoadCategories();
            if (BookId > 0)
                LoadBook();
        }
    }

    private void LoadCategories()
    {
        ddlCategory.DataSource = Db.GetDataTable("SELECT CategoryID, CategoryName FROM Categories ORDER BY CategoryName");
        ddlCategory.DataTextField = "CategoryName";
        ddlCategory.DataValueField = "CategoryID";
        ddlCategory.DataBind();
        ddlCategory.Items.Insert(0, new ListItem("-- Select category --", "0"));
    }

    private void LoadBook()
    {
        DataTable t = Db.GetDataTable("SELECT * FROM Books WHERE BookID = @BookID", Db.P("@BookID", BookId));
        if (t.Rows.Count == 0)
        {
            ShowMessage("Book not found.", "danger");
            Response.Redirect("~/Books.aspx", true);
        }

        DataRow row = t.Rows[0];
        txtISBN.Text = (string)row["ISBN"];
        txtTitle.Text = (string)row["Title"];
        txtAuthor.Text = (string)row["Author"];
        txtPublisher.Text = row["Publisher"] as string;
        txtYear.Text = row["PublishYear"] == DBNull.Value ? "" : row["PublishYear"].ToString();
        txtQuantity.Text = row["TotalQuantity"].ToString();
        txtShelf.Text = row["ShelfLocation"] as string;
        ddlCategory.SelectedValue = row["CategoryID"].ToString();

        int issued = (int)row["TotalQuantity"] - (int)row["AvailableQuantity"];
        litQtyHelp.Text = "<div class=\"form-text\">" + row["AvailableQuantity"] + " available, " + issued +
                          " currently issued. Total cannot be less than " + Math.Max(issued, 1) + ".</div>";
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid)
            return;

        // Store ISBN without hyphens/spaces so "978-0-13-235088-4" and "9780132350884" are the same book
        string isbn = txtISBN.Text.Replace("-", "").Replace(" ", "").Trim().ToUpperInvariant();
        if (isbn.Length != 10 && isbn.Length != 13)
        {
            ShowMessage("ISBN must contain exactly 10 or 13 characters (without hyphens).", "danger");
            return;
        }

        int quantity = int.Parse(txtQuantity.Text);
        object year = string.IsNullOrWhiteSpace(txtYear.Text) ? null : (object)int.Parse(txtYear.Text);

        SqlParameter[] p =
        {
            Db.P("@ISBN", isbn),
            Db.P("@Title", txtTitle.Text.Trim()),
            Db.P("@Author", txtAuthor.Text.Trim()),
            Db.P("@Publisher", EmptyToNull(txtPublisher.Text)),
            Db.P("@PublishYear", year),
            Db.P("@CategoryID", int.Parse(ddlCategory.SelectedValue)),
            Db.P("@Total", quantity),
            Db.P("@ShelfLocation", EmptyToNull(txtShelf.Text)),
            Db.P("@BookID", BookId)
        };

        try
        {
            if (BookId == 0)
            {
                Db.ExecuteNonQuery(@"
                    INSERT INTO Books (ISBN, Title, Author, Publisher, PublishYear, CategoryID,
                                       TotalQuantity, AvailableQuantity, ShelfLocation)
                    VALUES (@ISBN, @Title, @Author, @Publisher, @PublishYear, @CategoryID,
                            @Total, @Total, @ShelfLocation)", p);
            }
            else
            {
                // Available copies change by the same amount as the total.
                // The WHERE clause refuses the update if the new total is smaller
                // than the number of copies currently issued.
                int rows = Db.ExecuteNonQuery(@"
                    UPDATE Books SET
                        ISBN = @ISBN, Title = @Title, Author = @Author, Publisher = @Publisher,
                        PublishYear = @PublishYear, CategoryID = @CategoryID, ShelfLocation = @ShelfLocation,
                        AvailableQuantity = AvailableQuantity + (@Total - TotalQuantity),
                        TotalQuantity = @Total
                    WHERE BookID = @BookID AND (TotalQuantity - AvailableQuantity) <= @Total", p);

                if (rows == 0)
                {
                    ShowMessage("Total quantity cannot be less than the number of copies currently issued.", "danger");
                    return;
                }
            }
        }
        catch (SqlException ex)
        {
            if (!Db.IsDuplicateKeyError(ex))
                throw;
            ShowMessage("Another book with ISBN " + isbn + " already exists.", "danger");
            return;
        }

        ShowMessage(BookId == 0 ? "Book added successfully." : "Book updated successfully.", "success");
        Response.Redirect("~/Books.aspx", true);
    }

    private static object EmptyToNull(string value)
    {
        return string.IsNullOrWhiteSpace(value) ? null : value.Trim();
    }
}

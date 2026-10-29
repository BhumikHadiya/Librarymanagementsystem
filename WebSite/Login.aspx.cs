using System;
using System.Data;
using System.Web;
using System.Web.UI;

public partial class LoginPage : Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Already logged in? Go straight to the dashboard.
        if (Session[AdminPage.SessionAdminId] != null)
        {
            Response.Redirect("~/Default.aspx", true);
        }

        if (!IsPostBack && !string.IsNullOrEmpty(Request.QueryString["ReturnUrl"]))
        {
            pnlInfo.Visible = true;
            litInfo.Text = "Please log in to continue.";
        }
    }

    protected void btnLogin_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid)
            return;

        string username = txtUsername.Text.Trim();
        string password = txtPassword.Text;

        DataTable admin = Db.GetDataTable(
            "SELECT AdminID, FullName, PasswordHash FROM Admins WHERE Username = @Username",
            Db.P("@Username", username));

        // Same message for "unknown user" and "wrong password" so attackers cannot guess usernames
        if (admin.Rows.Count == 0 || !PasswordHasher.VerifyPassword(password, (string)admin.Rows[0]["PasswordHash"]))
        {
            pnlError.Visible = true;
            litError.Text = "Invalid username or password.";
            return;
        }

        int adminId = (int)admin.Rows[0]["AdminID"];
        Db.ExecuteNonQuery("UPDATE Admins SET LastLogin = SYSDATETIME() WHERE AdminID = @AdminID",
            Db.P("@AdminID", adminId));

        Session[AdminPage.SessionAdminId] = adminId;
        Session[AdminPage.SessionAdminName] = (string)admin.Rows[0]["FullName"];

        Response.Redirect(GetSafeReturnUrl(), true);
    }

    // Only allow redirects to pages inside this site (prevents "open redirect" attacks)
    private string GetSafeReturnUrl()
    {
        string returnUrl = Request.QueryString["ReturnUrl"];
        if (!string.IsNullOrEmpty(returnUrl) && returnUrl.StartsWith("/") &&
            !returnUrl.StartsWith("//") && !returnUrl.StartsWith("/\\") &&
            !returnUrl.ToLowerInvariant().Contains("login.aspx"))
        {
            return returnUrl;
        }
        return "~/Default.aspx";
    }
}

using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

/// <summary>
/// Base class for every page that only a logged-in admin may open.
/// If there is no admin in the session the user is sent to Login.aspx.
/// </summary>
public class AdminPage : Page
{
    public const string SessionAdminId = "AdminID";
    public const string SessionAdminName = "AdminName";
    public const string SessionFlash = "FlashMessage";

    protected int AdminId
    {
        get { return (int)Session[SessionAdminId]; }
    }

    protected override void OnInit(EventArgs e)
    {
        if (Session[SessionAdminId] == null)
        {
            string returnUrl = HttpUtility.UrlEncode(Request.RawUrl);
            Response.Redirect("~/Login.aspx?ReturnUrl=" + returnUrl, true);
        }

        // Do not let the browser cache admin pages (Back button after logout shows nothing)
        Response.Cache.SetCacheability(HttpCacheability.NoCache);
        Response.Cache.SetNoStore();
        Response.Cache.SetExpires(DateTime.UtcNow.AddMinutes(-1));

        base.OnInit(e);
    }

    // Render every GridView header inside <thead> (needed again after each postback)
    protected override void OnPreRenderComplete(EventArgs e)
    {
        base.OnPreRenderComplete(e);
        ApplyTableHeaders(this);
    }

    private static void ApplyTableHeaders(Control parent)
    {
        foreach (Control child in parent.Controls)
        {
            GridView grid = child as GridView;
            if (grid != null)
                UiHelper.UseTableHeader(grid);
            else if (child.HasControls())
                ApplyTableHeaders(child);
        }
    }

    /// <summary>
    /// Shows a Bootstrap alert at the top of the page. It also survives a
    /// Response.Redirect, so it can be used right before redirecting.
    /// type: success, danger, warning or info
    /// </summary>
    protected void ShowMessage(string message, string type)
    {
        Session[SessionFlash] = type + "|" + message;
    }

    /// <summary>Reads an integer from the query string; returns 0 when missing or invalid.</summary>
    protected int QueryInt(string key)
    {
        int value;
        return int.TryParse(Request.QueryString[key], out value) ? value : 0;
    }
}

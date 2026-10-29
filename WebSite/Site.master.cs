using System;
using System.IO;
using System.Web;
using System.Web.UI;

public partial class SiteMaster : MasterPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        object name = Session[AdminPage.SessionAdminName];
        litAdminName.Text = HttpUtility.HtmlEncode(name == null ? "" : name.ToString());
    }

    // Runs after the page's button click handlers, so messages set there are shown
    protected void Page_PreRender(object sender, EventArgs e)
    {
        if (Response.IsRequestBeingRedirected)
            return; // keep the message for the next page

        string flash = Session[AdminPage.SessionFlash] as string;
        if (string.IsNullOrEmpty(flash))
            return;

        Session.Remove(AdminPage.SessionFlash);
        int split = flash.IndexOf('|');
        string type = flash.Substring(0, split);
        string message = flash.Substring(split + 1);
        string icon = type == "success" ? "check-circle" : (type == "danger" ? "x-circle" : "info-circle");

        litFlash.Text =
            "<div class=\"alert alert-" + type + " alert-dismissible fade show\" role=\"alert\">" +
            "<i class=\"bi bi-" + icon + " me-2\"></i>" + HttpUtility.HtmlEncode(message) +
            "<button type=\"button\" class=\"btn-close\" data-bs-dismiss=\"alert\" aria-label=\"Close\"></button></div>";
    }

    /// <summary>Returns the CSS class for a sidebar link, marking the current page as active.</summary>
    protected string NavClass(params string[] pages)
    {
        string current = Path.GetFileName(Request.Path);
        foreach (string page in pages)
        {
            if (string.Equals(page, current, StringComparison.OrdinalIgnoreCase))
                return "nav-link active";
        }
        return "nav-link";
    }

    protected void lnkLogout_Click(object sender, EventArgs e)
    {
        Session.Clear();
        Session.Abandon();
        // Remove the session cookie so a new session id is used on the next login
        Response.Cookies.Add(new HttpCookie("ASP.NET_SessionId", "") { Expires = DateTime.Now.AddDays(-1) });
        Response.Redirect("~/Login.aspx", true);
    }
}

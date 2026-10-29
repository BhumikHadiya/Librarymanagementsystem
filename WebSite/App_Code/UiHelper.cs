using System;
using System.Web.UI.WebControls;

/// <summary>
/// Small helpers shared by several pages for consistent display.
/// </summary>
public static class UiHelper
{
    /// <summary>
    /// Makes a GridView render its header inside &lt;thead&gt; so Bootstrap
    /// styles it correctly and the JavaScript filter skips it.
    /// </summary>
    public static void UseTableHeader(GridView grid)
    {
        grid.UseAccessibleHeader = true;
        if (grid.HeaderRow != null)
            grid.HeaderRow.TableSection = TableRowSection.TableHeader;
    }

    /// <summary>Coloured badge for an issue: Issued, Overdue or Returned.</summary>
    public static string StatusBadge(string status, DateTime dueDate)
    {
        if (status == "Returned")
            return "<span class=\"badge bg-success\">Returned</span>";
        if (dueDate.Date < DateTime.Today)
            return "<span class=\"badge bg-danger\">Overdue</span>";
        return "<span class=\"badge bg-warning text-dark\">Issued</span>";
    }

    /// <summary>Badge for available quantity (red when none left).</summary>
    public static string AvailabilityBadge(int available, int total)
    {
        string css = available == 0 ? "bg-danger" : (available <= total / 3 ? "bg-warning text-dark" : "bg-success");
        return "<span class=\"badge " + css + "\">" + available + " / " + total + "</span>";
    }
}

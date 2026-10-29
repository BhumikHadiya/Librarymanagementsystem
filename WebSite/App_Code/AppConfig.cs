using System;
using System.Configuration;
using System.Globalization;

/// <summary>
/// Library rules read from the appSettings section of Web.config.
/// </summary>
public static class AppConfig
{
    public static int MaxBooksPerStudent
    {
        get { return GetInt("MaxBooksPerStudent", 3); }
    }

    public static int LoanPeriodDays
    {
        get { return GetInt("LoanPeriodDays", 14); }
    }

    public static decimal FinePerDay
    {
        get
        {
            decimal value;
            string text = ConfigurationManager.AppSettings["FinePerDay"];
            if (decimal.TryParse(text, NumberStyles.Number, CultureInfo.InvariantCulture, out value) && value >= 0)
                return value;
            return 5m;
        }
    }

    public static string CurrencySymbol
    {
        get { return ConfigurationManager.AppSettings["CurrencySymbol"] ?? "Rs."; }
    }

    /// <summary>Formats an amount as money, e.g. "₹ 25.00".</summary>
    public static string Money(object amount)
    {
        decimal value = (amount == null || amount == DBNull.Value) ? 0m : Convert.ToDecimal(amount);
        return CurrencySymbol + " " + value.ToString("0.00", CultureInfo.InvariantCulture);
    }

    private static int GetInt(string key, int defaultValue)
    {
        int value;
        if (int.TryParse(ConfigurationManager.AppSettings[key], out value) && value > 0)
            return value;
        return defaultValue;
    }
}

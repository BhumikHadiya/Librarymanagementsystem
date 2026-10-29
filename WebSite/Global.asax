<%@ Application Language="C#" %>

<script runat="server">

    void Application_Error(object sender, EventArgs e)
    {
        // Write unexpected errors to the Visual Studio Output window / server trace
        Exception ex = Server.GetLastError();
        if (ex != null)
            System.Diagnostics.Trace.TraceError("Unhandled error: " + ex);
    }

</script>

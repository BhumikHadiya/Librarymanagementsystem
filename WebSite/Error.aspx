<%@ Page Language="C#" AutoEventWireup="true" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Something went wrong - Library Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="assets/css/site.css" rel="stylesheet" />
</head>
<body>
    <div class="login-page">
        <div class="card login-card text-center">
            <div class="card-body p-5">
                <h1 class="h4">Something went wrong</h1>
                <p class="text-muted">An unexpected error occurred. Please try again. If the problem continues,
                    check that SQL Server is running and the connection string in Web.config is correct.</p>
                <a href="Default.aspx" class="btn btn-primary">Back to Dashboard</a>
            </div>
        </div>
    </div>
</body>
</html>

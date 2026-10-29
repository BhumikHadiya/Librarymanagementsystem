<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="LoginPage" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Admin Login - Library Management System</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet" />
    <link href="assets/css/site.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="login-page">
            <div class="card login-card">
                <div class="card-body p-4 p-md-5">
                    <div class="text-center mb-4">
                        <i class="bi bi-book-half text-primary" style="font-size: 3rem;"></i>
                        <h2 class="h4 mt-2 mb-1">College Library</h2>
                        <p class="text-muted mb-0">Sign in to the admin panel</p>
                    </div>

                    <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert alert-danger py-2">
                        <i class="bi bi-exclamation-triangle me-1"></i>
                        <asp:Literal ID="litError" runat="server" />
                    </asp:Panel>
                    <asp:Panel ID="pnlInfo" runat="server" Visible="false" CssClass="alert alert-info py-2">
                        <asp:Literal ID="litInfo" runat="server" />
                    </asp:Panel>

                    <div class="mb-3">
                        <label for="txtUsername" class="form-label required">Username</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-person"></i></span>
                            <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" MaxLength="50"
                                ClientIDMode="Static" autocomplete="username" />
                        </div>
                        <asp:RequiredFieldValidator ID="rfvUsername" runat="server" ControlToValidate="txtUsername"
                            ErrorMessage="Username is required." CssClass="field-error" Display="Dynamic" />
                    </div>

                    <div class="mb-4">
                        <label for="txtPassword" class="form-label required">Password</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-lock"></i></span>
                            <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password"
                                MaxLength="100" ClientIDMode="Static" autocomplete="current-password" />
                        </div>
                        <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword"
                            ErrorMessage="Password is required." CssClass="field-error" Display="Dynamic" />
                    </div>

                    <asp:Button ID="btnLogin" runat="server" Text="Login" CssClass="btn btn-primary w-100 py-2"
                        OnClick="btnLogin_Click" />

                    <p class="text-center text-muted small mt-4 mb-0">Default login: admin / Admin@123</p>
                </div>
            </div>
        </div>
    </form>
</body>
</html>

<%@ Page Title="Student Details" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true"
    CodeFile="StudentForm.aspx.cs" Inherits="StudentFormPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="card" style="max-width: 900px;">
        <div class="card-header">
            <i class="bi bi-person-plus me-1"></i> <asp:Literal ID="litHeading" runat="server" Text="Register New Student" />
        </div>
        <div class="card-body">
            <asp:ValidationSummary ID="valSummary" runat="server" CssClass="alert alert-danger py-2"
                HeaderText="Please fix the following:" DisplayMode="BulletList" />

            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label required">Student ID / Roll No.</label>
                    <asp:TextBox ID="txtCode" runat="server" CssClass="form-control" MaxLength="20" placeholder="e.g. STU2026011" />
                    <asp:RequiredFieldValidator ID="rfvCode" runat="server" ControlToValidate="txtCode"
                        ErrorMessage="Student ID is required." Text="Student ID is required." CssClass="field-error" Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="revCode" runat="server" ControlToValidate="txtCode"
                        ValidationExpression="^[A-Za-z0-9\-/]{3,20}$"
                        ErrorMessage="Student ID: 3-20 letters, digits, '-' or '/'."
                        Text="Student ID: 3-20 letters, digits, '-' or '/'." CssClass="field-error" Display="Dynamic" />
                </div>
                <div class="col-md-6">
                    <label class="form-label required">Full Name</label>
                    <asp:TextBox ID="txtName" runat="server" CssClass="form-control" MaxLength="100" />
                    <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName"
                        ErrorMessage="Full name is required." Text="Full name is required." CssClass="field-error" Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="revName" runat="server" ControlToValidate="txtName"
                        ValidationExpression="^[A-Za-z][A-Za-z .']{1,99}$"
                        ErrorMessage="Name can contain only letters, spaces, dots and apostrophes."
                        Text="Name can contain only letters, spaces, dots and apostrophes." CssClass="field-error" Display="Dynamic" />
                </div>
                <div class="col-md-6">
                    <label class="form-label required">Email</label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" MaxLength="100" TextMode="Email" />
                    <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail"
                        ErrorMessage="Email is required." Text="Email is required." CssClass="field-error" Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail"
                        ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                        ErrorMessage="Enter a valid email address." Text="Enter a valid email address." CssClass="field-error" Display="Dynamic" />
                </div>
                <div class="col-md-6">
                    <label class="form-label required">Phone</label>
                    <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" MaxLength="10" placeholder="10-digit mobile number" />
                    <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone"
                        ErrorMessage="Phone is required." Text="Phone is required." CssClass="field-error" Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="revPhone" runat="server" ControlToValidate="txtPhone"
                        ValidationExpression="^\d{10}$"
                        ErrorMessage="Phone must be exactly 10 digits." Text="Phone must be exactly 10 digits." CssClass="field-error" Display="Dynamic" />
                </div>
                <div class="col-md-6">
                    <label class="form-label required">Department</label>
                    <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="form-select">
                        <asp:ListItem Text="-- Select department --" Value="" />
                        <asp:ListItem>Computer Engineering</asp:ListItem>
                        <asp:ListItem>Information Technology</asp:ListItem>
                        <asp:ListItem>Electronics</asp:ListItem>
                        <asp:ListItem>Mechanical Engineering</asp:ListItem>
                        <asp:ListItem>Civil Engineering</asp:ListItem>
                        <asp:ListItem>Management Studies</asp:ListItem>
                        <asp:ListItem>Science</asp:ListItem>
                        <asp:ListItem>Arts</asp:ListItem>
                        <asp:ListItem>Commerce</asp:ListItem>
                    </asp:DropDownList>
                    <asp:RequiredFieldValidator ID="rfvDepartment" runat="server" ControlToValidate="ddlDepartment"
                        ErrorMessage="Please select a department." Text="Please select a department." CssClass="field-error" Display="Dynamic" />
                </div>
                <div class="col-md-3">
                    <label class="form-label required">Year of Study</label>
                    <asp:DropDownList ID="ddlYear" runat="server" CssClass="form-select">
                        <asp:ListItem Text="1st Year" Value="1" />
                        <asp:ListItem Text="2nd Year" Value="2" />
                        <asp:ListItem Text="3rd Year" Value="3" />
                        <asp:ListItem Text="4th Year" Value="4" />
                        <asp:ListItem Text="5th Year" Value="5" />
                        <asp:ListItem Text="6th Year" Value="6" />
                    </asp:DropDownList>
                </div>
                <div class="col-md-3 d-flex align-items-end">
                    <asp:CheckBox ID="chkActive" runat="server" Checked="true" Text="&nbsp;Active (can borrow)" CssClass="mb-2" />
                </div>
            </div>
        </div>
        <div class="card-footer bg-white d-flex gap-2">
            <asp:Button ID="btnSave" runat="server" Text="Save Student" CssClass="btn btn-primary" OnClick="btnSave_Click" />
            <a href="Students.aspx" class="btn btn-outline-secondary">Cancel</a>
        </div>
    </div>
</asp:Content>

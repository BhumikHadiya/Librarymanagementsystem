<%@ Page Title="Change Password" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true"
    CodeFile="ChangePassword.aspx.cs" Inherits="ChangePasswordPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="card" style="max-width: 500px;">
        <div class="card-header"><i class="bi bi-key me-1"></i> Change Your Password</div>
        <div class="card-body">
            <div class="mb-3">
                <label class="form-label required">Current Password</label>
                <asp:TextBox ID="txtCurrent" runat="server" CssClass="form-control" TextMode="Password" MaxLength="100" />
                <asp:RequiredFieldValidator ID="rfvCurrent" runat="server" ControlToValidate="txtCurrent"
                    ErrorMessage="Current password is required." CssClass="field-error" Display="Dynamic" />
            </div>
            <div class="mb-3">
                <label class="form-label required">New Password</label>
                <asp:TextBox ID="txtNew" runat="server" CssClass="form-control" TextMode="Password" MaxLength="100" />
                <asp:RequiredFieldValidator ID="rfvNew" runat="server" ControlToValidate="txtNew"
                    ErrorMessage="New password is required." CssClass="field-error" Display="Dynamic" />
                <asp:RegularExpressionValidator ID="revNew" runat="server" ControlToValidate="txtNew"
                    ValidationExpression="^(?=.*[A-Za-z])(?=.*\d).{8,100}$"
                    ErrorMessage="At least 8 characters, with at least one letter and one number."
                    CssClass="field-error" Display="Dynamic" />
            </div>
            <div class="mb-3">
                <label class="form-label required">Confirm New Password</label>
                <asp:TextBox ID="txtConfirm" runat="server" CssClass="form-control" TextMode="Password" MaxLength="100" />
                <asp:RequiredFieldValidator ID="rfvConfirm" runat="server" ControlToValidate="txtConfirm"
                    ErrorMessage="Please confirm the new password." CssClass="field-error" Display="Dynamic" />
                <asp:CompareValidator ID="cvConfirm" runat="server" ControlToValidate="txtConfirm" ControlToCompare="txtNew"
                    ErrorMessage="Passwords do not match." CssClass="field-error" Display="Dynamic" />
            </div>
        </div>
        <div class="card-footer bg-white">
            <asp:Button ID="btnChange" runat="server" Text="Change Password" CssClass="btn btn-primary" OnClick="btnChange_Click" />
        </div>
    </div>
</asp:Content>

<%@ Page Title="Book Details" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true"
    CodeFile="BookForm.aspx.cs" Inherits="BookFormPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="card" style="max-width: 900px;">
        <div class="card-header">
            <i class="bi bi-journal-plus me-1"></i> <asp:Literal ID="litHeading" runat="server" Text="Add New Book" />
        </div>
        <div class="card-body">
            <asp:ValidationSummary ID="valSummary" runat="server" CssClass="alert alert-danger py-2"
                HeaderText="Please fix the following:" DisplayMode="BulletList" />

            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label required">ISBN</label>
                    <asp:TextBox ID="txtISBN" runat="server" CssClass="form-control" MaxLength="17" placeholder="10 or 13 digits" />
                    <asp:RequiredFieldValidator ID="rfvISBN" runat="server" ControlToValidate="txtISBN"
                        ErrorMessage="ISBN is required." Text="ISBN is required." CssClass="field-error" Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="revISBN" runat="server" ControlToValidate="txtISBN"
                        ValidationExpression="^(\d{9}[\dXx]|\d{13}|[\d-]{11,17}[\dXx])$"
                        ErrorMessage="ISBN must be 10 or 13 digits (hyphens allowed)."
                        Text="ISBN must be 10 or 13 digits (hyphens allowed)." CssClass="field-error" Display="Dynamic" />
                </div>
                <div class="col-md-6">
                    <label class="form-label required">Category</label>
                    <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-select" />
                    <asp:RequiredFieldValidator ID="rfvCategory" runat="server" ControlToValidate="ddlCategory" InitialValue="0"
                        ErrorMessage="Please select a category." Text="Please select a category." CssClass="field-error" Display="Dynamic" />
                </div>
                <div class="col-12">
                    <label class="form-label required">Title</label>
                    <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" MaxLength="200" />
                    <asp:RequiredFieldValidator ID="rfvTitle" runat="server" ControlToValidate="txtTitle"
                        ErrorMessage="Title is required." Text="Title is required." CssClass="field-error" Display="Dynamic" />
                </div>
                <div class="col-md-6">
                    <label class="form-label required">Author</label>
                    <asp:TextBox ID="txtAuthor" runat="server" CssClass="form-control" MaxLength="150" />
                    <asp:RequiredFieldValidator ID="rfvAuthor" runat="server" ControlToValidate="txtAuthor"
                        ErrorMessage="Author is required." Text="Author is required." CssClass="field-error" Display="Dynamic" />
                </div>
                <div class="col-md-6">
                    <label class="form-label">Publisher</label>
                    <asp:TextBox ID="txtPublisher" runat="server" CssClass="form-control" MaxLength="150" />
                </div>
                <div class="col-md-4">
                    <label class="form-label">Publish Year</label>
                    <asp:TextBox ID="txtYear" runat="server" CssClass="form-control" MaxLength="4" TextMode="Number" />
                    <asp:RangeValidator ID="rvYear" runat="server" ControlToValidate="txtYear" Type="Integer"
                        MinimumValue="1500" MaximumValue="2100" CssClass="field-error" Display="Dynamic" />
                </div>
                <div class="col-md-4">
                    <label class="form-label required">Total Quantity</label>
                    <asp:TextBox ID="txtQuantity" runat="server" CssClass="form-control" TextMode="Number" Text="1" />
                    <asp:RequiredFieldValidator ID="rfvQuantity" runat="server" ControlToValidate="txtQuantity"
                        ErrorMessage="Quantity is required." Text="Quantity is required." CssClass="field-error" Display="Dynamic" />
                    <asp:RangeValidator ID="rvQuantity" runat="server" ControlToValidate="txtQuantity" Type="Integer"
                        MinimumValue="1" MaximumValue="1000" ErrorMessage="Quantity must be between 1 and 1000."
                        Text="Quantity must be between 1 and 1000." CssClass="field-error" Display="Dynamic" />
                    <asp:Literal ID="litQtyHelp" runat="server" />
                </div>
                <div class="col-md-4">
                    <label class="form-label">Shelf Location</label>
                    <asp:TextBox ID="txtShelf" runat="server" CssClass="form-control" MaxLength="50" placeholder="e.g. CS-A1" />
                </div>
            </div>
        </div>
        <div class="card-footer bg-white d-flex gap-2">
            <asp:Button ID="btnSave" runat="server" Text="Save Book" CssClass="btn btn-primary" OnClick="btnSave_Click" />
            <a href="Books.aspx" class="btn btn-outline-secondary">Cancel</a>
        </div>
    </div>
</asp:Content>

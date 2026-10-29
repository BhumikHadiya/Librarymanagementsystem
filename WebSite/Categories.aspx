<%@ Page Title="Categories" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true"
    CodeFile="Categories.aspx.cs" Inherits="CategoriesPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row g-3">
        <!-- Add / edit form -->
        <div class="col-lg-4">
            <div class="card">
                <div class="card-header">
                    <i class="bi bi-tag me-1"></i> <asp:Literal ID="litFormTitle" runat="server" Text="Add Category" />
                </div>
                <div class="card-body">
                    <asp:HiddenField ID="hfCategoryId" runat="server" Value="0" />
                    <div class="mb-3">
                        <label class="form-label required">Category Name</label>
                        <asp:TextBox ID="txtName" runat="server" CssClass="form-control" MaxLength="100" />
                        <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName" ValidationGroup="cat"
                            ErrorMessage="Category name is required." CssClass="field-error" Display="Dynamic" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Description</label>
                        <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" MaxLength="250" />
                        <asp:RegularExpressionValidator ID="revDescription" runat="server" ControlToValidate="txtDescription"
                            ValidationGroup="cat" ValidationExpression="^[\s\S]{0,250}$"
                            ErrorMessage="Description can be at most 250 characters." CssClass="field-error" Display="Dynamic" />
                    </div>
                    <div class="d-flex gap-2">
                        <asp:Button ID="btnSave" runat="server" Text="Add Category" CssClass="btn btn-primary"
                            ValidationGroup="cat" OnClick="btnSave_Click" />
                        <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-outline-secondary"
                            CausesValidation="false" OnClick="btnCancel_Click" Visible="false" />
                    </div>
                </div>
            </div>
        </div>

        <!-- List -->
        <div class="col-lg-8">
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <span><i class="bi bi-tags me-1"></i> All Categories</span>
                    <input type="text" class="form-control form-control-sm" data-table-filter="gvCategories"
                        placeholder="Filter..." style="max-width: 200px;" />
                </div>
                <div class="table-responsive">
                    <asp:GridView ID="gvCategories" runat="server" ClientIDMode="Static" AutoGenerateColumns="false"
                        CssClass="table table-hover" GridLines="None" OnRowCommand="gvCategories_RowCommand"
                        EmptyDataText="No categories yet.">
                        <Columns>
                            <asp:BoundField DataField="CategoryName" HeaderText="Name" ItemStyle-CssClass="fw-semibold" />
                            <asp:BoundField DataField="Description" HeaderText="Description" />
                            <asp:BoundField DataField="BookCount" HeaderText="Titles" />
                            <asp:BoundField DataField="CopyCount" HeaderText="Copies" />
                            <asp:TemplateField HeaderText="Actions" ItemStyle-CssClass="text-nowrap">
                                <ItemTemplate>
                                    <asp:LinkButton ID="lnkEdit" runat="server" CommandName="EditCategory"
                                        CommandArgument='<%# Eval("CategoryID") %>' CssClass="btn btn-sm btn-outline-primary"
                                        CausesValidation="false" ToolTip="Edit"><i class="bi bi-pencil"></i></asp:LinkButton>
                                    <asp:LinkButton ID="lnkDelete" runat="server" CommandName="DeleteCategory"
                                        CommandArgument='<%# Eval("CategoryID") %>' CssClass="btn btn-sm btn-outline-danger"
                                        OnClientClick="return confirmDelete('category');" CausesValidation="false"
                                        ToolTip="Delete"><i class="bi bi-trash"></i></asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

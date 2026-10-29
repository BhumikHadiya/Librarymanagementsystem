<%@ Page Title="Books" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true"
    CodeFile="Books.aspx.cs" Inherits="BooksPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="card">
        <div class="card-header d-flex flex-wrap justify-content-between align-items-center gap-2">
            <span><i class="bi bi-journal-bookmark me-1"></i> Book Catalogue</span>
            <a href="BookForm.aspx" class="btn btn-primary btn-sm"><i class="bi bi-plus-lg"></i> Add New Book</a>
        </div>
        <div class="card-body border-bottom">
            <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch" CssClass="row g-2 align-items-end">
                <div class="col-md-5">
                    <label class="form-label small text-muted mb-1">Search by title, author or ISBN</label>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" MaxLength="100" placeholder="e.g. Clean Code" />
                </div>
                <div class="col-md-3">
                    <label class="form-label small text-muted mb-1">Category</label>
                    <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-select" />
                </div>
                <div class="col-md-4 d-flex gap-2">
                    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-primary" OnClick="btnSearch_Click" CausesValidation="false" />
                    <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-outline-secondary" OnClick="btnClear_Click" CausesValidation="false" />
                </div>
            </asp:Panel>
            <div class="mt-2">
                <input type="text" class="form-control form-control-sm" data-table-filter="gvBooks"
                    placeholder="Quick filter on this page..." style="max-width: 300px;" />
            </div>
        </div>
        <div class="table-responsive">
            <asp:GridView ID="gvBooks" runat="server" ClientIDMode="Static" AutoGenerateColumns="false"
                CssClass="table table-hover" GridLines="None" DataKeyNames="BookID"
                AllowPaging="true" PageSize="10" OnPageIndexChanging="gvBooks_PageIndexChanging"
                OnRowCommand="gvBooks_RowCommand" OnRowDataBound="gvBooks_RowDataBound"
                EmptyDataText="No books found." PagerStyle-CssClass="grid-pager">
                <Columns>
                    <asp:BoundField DataField="ISBN" HeaderText="ISBN" />
                    <asp:BoundField DataField="Title" HeaderText="Title" ItemStyle-CssClass="fw-semibold" />
                    <asp:BoundField DataField="Author" HeaderText="Author" />
                    <asp:BoundField DataField="CategoryName" HeaderText="Category" />
                    <asp:BoundField DataField="ShelfLocation" HeaderText="Shelf" />
                    <asp:TemplateField HeaderText="Available / Total">
                        <ItemTemplate><asp:Literal ID="litQty" runat="server" /></ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Actions" ItemStyle-CssClass="text-nowrap">
                        <ItemTemplate>
                            <a href='BookForm.aspx?id=<%# Eval("BookID") %>' class="btn btn-sm btn-outline-primary" title="Edit">
                                <i class="bi bi-pencil"></i></a>
                            <asp:LinkButton ID="lnkDelete" runat="server" CommandName="DeleteBook"
                                CommandArgument='<%# Eval("BookID") %>' CssClass="btn btn-sm btn-outline-danger"
                                OnClientClick="return confirmDelete('book');" CausesValidation="false" ToolTip="Delete">
                                <i class="bi bi-trash"></i></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
        <div class="card-footer bg-white small text-muted">
            <asp:Literal ID="litCount" runat="server" />
        </div>
    </div>
</asp:Content>

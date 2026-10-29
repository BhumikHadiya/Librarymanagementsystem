<%@ Page Title="Students" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true"
    CodeFile="Students.aspx.cs" Inherits="StudentsPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="card">
        <div class="card-header d-flex flex-wrap justify-content-between align-items-center gap-2">
            <span><i class="bi bi-people me-1"></i> Registered Students</span>
            <a href="StudentForm.aspx" class="btn btn-primary btn-sm"><i class="bi bi-person-plus"></i> Register Student</a>
        </div>
        <div class="card-body border-bottom">
            <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch" CssClass="row g-2 align-items-end">
                <div class="col-md-5">
                    <label class="form-label small text-muted mb-1">Search by name or student ID</label>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" MaxLength="100" placeholder="e.g. STU2026001 or Aarav" />
                </div>
                <div class="col-md-3">
                    <label class="form-label small text-muted mb-1">Status</label>
                    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select">
                        <asp:ListItem Text="All" Value="" />
                        <asp:ListItem Text="Active" Value="1" />
                        <asp:ListItem Text="Inactive" Value="0" />
                    </asp:DropDownList>
                </div>
                <div class="col-md-4 d-flex gap-2">
                    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-primary" OnClick="btnSearch_Click" CausesValidation="false" />
                    <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-outline-secondary" OnClick="btnClear_Click" CausesValidation="false" />
                </div>
            </asp:Panel>
            <div class="mt-2">
                <input type="text" class="form-control form-control-sm" data-table-filter="gvStudents"
                    placeholder="Quick filter on this page..." style="max-width: 300px;" />
            </div>
        </div>
        <div class="table-responsive">
            <asp:GridView ID="gvStudents" runat="server" ClientIDMode="Static" AutoGenerateColumns="false"
                CssClass="table table-hover" GridLines="None" AllowPaging="true" PageSize="10"
                OnPageIndexChanging="gvStudents_PageIndexChanging" OnRowCommand="gvStudents_RowCommand"
                OnRowDataBound="gvStudents_RowDataBound" EmptyDataText="No students found." PagerStyle-CssClass="grid-pager">
                <Columns>
                    <asp:BoundField DataField="StudentCode" HeaderText="Student ID" ItemStyle-CssClass="fw-semibold" />
                    <asp:BoundField DataField="FullName" HeaderText="Name" />
                    <asp:BoundField DataField="Department" HeaderText="Department" />
                    <asp:BoundField DataField="YearOfStudy" HeaderText="Year" />
                    <asp:BoundField DataField="Email" HeaderText="Email" />
                    <asp:BoundField DataField="Phone" HeaderText="Phone" />
                    <asp:BoundField DataField="BooksIssued" HeaderText="Books Out" />
                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate><asp:Literal ID="litStatus" runat="server" /></ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Actions" ItemStyle-CssClass="text-nowrap">
                        <ItemTemplate>
                            <a href='Reports.aspx?studentId=<%# Eval("StudentID") %>' class="btn btn-sm btn-outline-secondary" title="Borrowing history">
                                <i class="bi bi-clock-history"></i></a>
                            <a href='StudentForm.aspx?id=<%# Eval("StudentID") %>' class="btn btn-sm btn-outline-primary" title="Edit">
                                <i class="bi bi-pencil"></i></a>
                            <asp:LinkButton ID="lnkDelete" runat="server" CommandName="DeleteStudent"
                                CommandArgument='<%# Eval("StudentID") %>' CssClass="btn btn-sm btn-outline-danger"
                                OnClientClick="return confirmDelete('student');" CausesValidation="false" ToolTip="Delete">
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

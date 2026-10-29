<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true"
    CodeFile="Default.aspx.cs" Inherits="DashboardPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <!-- Summary cards -->
    <div class="row g-3 mb-4">
        <div class="col-sm-6 col-xl-3">
            <div class="card stat-card h-100">
                <div class="card-body">
                    <div class="stat-icon bg-primary"><i class="bi bi-journal-bookmark"></i></div>
                    <div>
                        <div class="stat-value"><asp:Literal ID="litTotalBooks" runat="server" /></div>
                        <div class="stat-label">Total Books (<asp:Literal ID="litTotalTitles" runat="server" /> titles)</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="card stat-card h-100">
                <div class="card-body">
                    <div class="stat-icon bg-success"><i class="bi bi-people"></i></div>
                    <div>
                        <div class="stat-value"><asp:Literal ID="litStudents" runat="server" /></div>
                        <div class="stat-label">Registered Students</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="card stat-card h-100">
                <div class="card-body">
                    <div class="stat-icon bg-warning"><i class="bi bi-box-arrow-up-right"></i></div>
                    <div>
                        <div class="stat-value"><asp:Literal ID="litIssued" runat="server" /></div>
                        <div class="stat-label">Currently Issued</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="card stat-card h-100">
                <div class="card-body">
                    <div class="stat-icon bg-danger"><i class="bi bi-exclamation-octagon"></i></div>
                    <div>
                        <div class="stat-value"><asp:Literal ID="litOverdue" runat="server" /></div>
                        <div class="stat-label">Overdue Books</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Quick actions -->
    <div class="d-flex flex-wrap gap-2 mb-4">
        <a href="IssueBook.aspx" class="btn btn-primary"><i class="bi bi-box-arrow-up-right"></i> Issue Book</a>
        <a href="ReturnBook.aspx" class="btn btn-success"><i class="bi bi-box-arrow-in-down-left"></i> Return Book</a>
        <a href="BookForm.aspx" class="btn btn-outline-primary"><i class="bi bi-plus-lg"></i> Add Book</a>
        <a href="StudentForm.aspx" class="btn btn-outline-primary"><i class="bi bi-person-plus"></i> Add Student</a>
    </div>

    <div class="row g-3">
        <!-- Recently issued -->
        <div class="col-xl-7">
            <div class="card h-100">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <span><i class="bi bi-clock-history me-1"></i> Recently Issued Books</span>
                    <a href="Reports.aspx" class="small">View all</a>
                </div>
                <div class="table-responsive">
                    <asp:GridView ID="gvRecent" runat="server" AutoGenerateColumns="false" CssClass="table table-hover"
                        GridLines="None" EmptyDataText="No books have been issued yet." OnRowDataBound="gvRecent_RowDataBound">
                        <Columns>
                            <asp:BoundField DataField="Title" HeaderText="Book" />
                            <asp:BoundField DataField="StudentName" HeaderText="Student" />
                            <asp:BoundField DataField="IssueDate" HeaderText="Issued" DataFormatString="{0:dd MMM yyyy}" />
                            <asp:BoundField DataField="DueDate" HeaderText="Due" DataFormatString="{0:dd MMM yyyy}" />
                            <asp:TemplateField HeaderText="Status">
                                <ItemTemplate>
                                    <asp:Literal ID="litStatus" runat="server" />
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>

        <!-- Overdue list -->
        <div class="col-xl-5">
            <div class="card h-100">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <span class="text-danger"><i class="bi bi-exclamation-triangle me-1"></i> Overdue Books</span>
                    <a href="Reports.aspx?type=Overdue" class="small">View all</a>
                </div>
                <div class="table-responsive">
                    <asp:GridView ID="gvOverdue" runat="server" AutoGenerateColumns="false" CssClass="table table-hover"
                        GridLines="None" EmptyDataText="No overdue books. Great!">
                        <Columns>
                            <asp:BoundField DataField="Title" HeaderText="Book" />
                            <asp:BoundField DataField="StudentName" HeaderText="Student" />
                            <asp:BoundField DataField="DaysOverdue" HeaderText="Days Late" ItemStyle-CssClass="text-danger fw-semibold" />
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

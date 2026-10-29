<%@ Page Title="Reports" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true"
    CodeFile="Reports.aspx.cs" Inherits="ReportsPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="card mb-3 no-print">
        <div class="card-header"><i class="bi bi-funnel me-1"></i> Report Filters</div>
        <div class="card-body">
            <div class="row g-2 align-items-end">
                <div class="col-md-3">
                    <label class="form-label small text-muted mb-1">Report</label>
                    <asp:DropDownList ID="ddlType" runat="server" CssClass="form-select">
                        <asp:ListItem Text="All transactions" Value="All" />
                        <asp:ListItem Text="Currently issued" Value="Issued" />
                        <asp:ListItem Text="Returned" Value="Returned" />
                        <asp:ListItem Text="Overdue (not returned)" Value="Overdue" />
                        <asp:ListItem Text="Returned late (fined)" Value="Fined" />
                    </asp:DropDownList>
                </div>
                <div class="col-md-3">
                    <label class="form-label small text-muted mb-1">Student (borrowing history)</label>
                    <asp:DropDownList ID="ddlStudent" runat="server" CssClass="form-select" />
                </div>
                <div class="col-md-2">
                    <label class="form-label small text-muted mb-1">Issue date from</label>
                    <asp:TextBox ID="txtFrom" runat="server" CssClass="form-control" TextMode="Date" />
                </div>
                <div class="col-md-2">
                    <label class="form-label small text-muted mb-1">Issue date to</label>
                    <asp:TextBox ID="txtTo" runat="server" CssClass="form-control" TextMode="Date" />
                </div>
                <div class="col-md-2 d-flex gap-2">
                    <asp:Button ID="btnRun" runat="server" Text="Show" CssClass="btn btn-primary" OnClick="btnRun_Click" CausesValidation="false" />
                    <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="btn btn-outline-secondary" OnClick="btnReset_Click" CausesValidation="false" />
                </div>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-header d-flex flex-wrap justify-content-between align-items-center gap-2">
            <span><i class="bi bi-file-earmark-text me-1"></i> <asp:Literal ID="litReportTitle" runat="server" /></span>
            <div class="d-flex gap-2 no-print">
                <input type="text" class="form-control form-control-sm" data-table-filter="gvReport" placeholder="Filter..." style="max-width: 180px;" />
                <button type="button" class="btn btn-sm btn-outline-secondary" onclick="window.print();"><i class="bi bi-printer"></i> Print</button>
            </div>
        </div>
        <div class="card-body border-bottom py-2">
            <div class="row text-center small">
                <div class="col">Records: <strong><asp:Literal ID="litTotal" runat="server" /></strong></div>
                <div class="col">Still out: <strong><asp:Literal ID="litOut" runat="server" /></strong></div>
                <div class="col">Overdue: <strong class="text-danger"><asp:Literal ID="litOverdue" runat="server" /></strong></div>
                <div class="col">Fines: <strong><asp:Literal ID="litFines" runat="server" /></strong></div>
            </div>
        </div>
        <div class="table-responsive">
            <asp:GridView ID="gvReport" runat="server" ClientIDMode="Static" AutoGenerateColumns="false"
                CssClass="table table-hover table-sm" GridLines="None" OnRowDataBound="gvReport_RowDataBound"
                EmptyDataText="No records match the selected filters.">
                <Columns>
                    <asp:BoundField DataField="IssueID" HeaderText="#" />
                    <asp:BoundField DataField="StudentCode" HeaderText="Student ID" />
                    <asp:BoundField DataField="StudentName" HeaderText="Student" />
                    <asp:BoundField DataField="Title" HeaderText="Book" />
                    <asp:BoundField DataField="ISBN" HeaderText="ISBN" />
                    <asp:BoundField DataField="IssueDate" HeaderText="Issued" DataFormatString="{0:dd MMM yyyy}" />
                    <asp:BoundField DataField="DueDate" HeaderText="Due" DataFormatString="{0:dd MMM yyyy}" />
                    <asp:BoundField DataField="ReturnDate" HeaderText="Returned" DataFormatString="{0:dd MMM yyyy}" NullDisplayText="-" />
                    <asp:TemplateField HeaderText="Fine">
                        <ItemTemplate><asp:Literal ID="litFine" runat="server" /></ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate><asp:Literal ID="litStatus" runat="server" /></ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>
</asp:Content>

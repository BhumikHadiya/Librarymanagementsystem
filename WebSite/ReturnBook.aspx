<%@ Page Title="Return Book" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true"
    CodeFile="ReturnBook.aspx.cs" Inherits="ReturnBookPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <!-- Confirmation panel (shown after a row is selected) -->
    <asp:Panel ID="pnlReturn" runat="server" Visible="false" CssClass="card mb-3 border-start border-4 border-success">
        <div class="card-header"><i class="bi bi-box-arrow-in-down-left me-1"></i> Confirm Return</div>
        <div class="card-body">
            <asp:HiddenField ID="hfIssueId" runat="server" />
            <div class="row g-3">
                <div class="col-md-6">
                    <dl class="row mb-0 small">
                        <dt class="col-4">Book</dt><dd class="col-8"><asp:Literal ID="litBook" runat="server" /></dd>
                        <dt class="col-4">Student</dt><dd class="col-8"><asp:Literal ID="litStudent" runat="server" /></dd>
                        <dt class="col-4">Issued</dt><dd class="col-8"><asp:Literal ID="litIssued" runat="server" /></dd>
                        <dt class="col-4">Due</dt><dd class="col-8"><asp:Literal ID="litDue" runat="server" /></dd>
                    </dl>
                </div>
                <div class="col-md-6">
                    <label class="form-label required">Return Date</label>
                    <asp:TextBox ID="txtReturnDate" runat="server" CssClass="form-control" TextMode="Date"
                        AutoPostBack="true" OnTextChanged="txtReturnDate_TextChanged" />
                    <asp:RequiredFieldValidator ID="rfvReturnDate" runat="server" ControlToValidate="txtReturnDate"
                        ValidationGroup="ret" ErrorMessage="Return date is required." CssClass="field-error" Display="Dynamic" />
                    <div class="mt-2">Fine to collect: <strong class="fs-5"><asp:Literal ID="litFine" runat="server" /></strong></div>
                    <div class="form-text"><asp:Literal ID="litFineRule" runat="server" /></div>
                </div>
            </div>
        </div>
        <div class="card-footer bg-white d-flex gap-2">
            <asp:Button ID="btnConfirm" runat="server" Text="Confirm Return" CssClass="btn btn-success"
                ValidationGroup="ret" OnClick="btnConfirm_Click" />
            <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-outline-secondary"
                CausesValidation="false" OnClick="btnCancel_Click" />
        </div>
    </asp:Panel>

    <!-- Currently issued books -->
    <div class="card">
        <div class="card-header"><i class="bi bi-journal-arrow-up me-1"></i> Books Currently Issued</div>
        <div class="card-body border-bottom">
            <asp:Panel ID="pnlSearch" runat="server" DefaultButton="btnSearch" CssClass="row g-2 align-items-end">
                <div class="col-md-6">
                    <label class="form-label small text-muted mb-1">Search by student ID, student name, book title or ISBN</label>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" MaxLength="100" />
                </div>
                <div class="col-md-3">
                    <asp:CheckBox ID="chkOverdueOnly" runat="server" Text="&nbsp;Overdue only" />
                </div>
                <div class="col-md-3 d-flex gap-2">
                    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-primary" CausesValidation="false" OnClick="btnSearch_Click" />
                    <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-outline-secondary" CausesValidation="false" OnClick="btnClear_Click" />
                </div>
            </asp:Panel>
        </div>
        <div class="table-responsive">
            <asp:GridView ID="gvIssued" runat="server" AutoGenerateColumns="false" CssClass="table table-hover"
                GridLines="None" AllowPaging="true" PageSize="10" PagerStyle-CssClass="grid-pager"
                OnPageIndexChanging="gvIssued_PageIndexChanging" OnRowCommand="gvIssued_RowCommand"
                OnRowDataBound="gvIssued_RowDataBound" EmptyDataText="No books are currently issued.">
                <Columns>
                    <asp:BoundField DataField="StudentCode" HeaderText="Student ID" />
                    <asp:BoundField DataField="StudentName" HeaderText="Student" />
                    <asp:BoundField DataField="Title" HeaderText="Book" ItemStyle-CssClass="fw-semibold" />
                    <asp:BoundField DataField="IssueDate" HeaderText="Issued" DataFormatString="{0:dd MMM yyyy}" />
                    <asp:BoundField DataField="DueDate" HeaderText="Due" DataFormatString="{0:dd MMM yyyy}" />
                    <asp:TemplateField HeaderText="Status / Fine Today">
                        <ItemTemplate><asp:Literal ID="litStatus" runat="server" /></ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField>
                        <ItemTemplate>
                            <asp:LinkButton ID="lnkReturn" runat="server" CommandName="SelectIssue"
                                CommandArgument='<%# Eval("IssueID") %>' CssClass="btn btn-sm btn-success" CausesValidation="false">
                                <i class="bi bi-box-arrow-in-down-left"></i> Return</asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>
</asp:Content>

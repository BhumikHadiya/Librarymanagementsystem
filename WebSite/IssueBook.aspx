<%@ Page Title="Issue Book" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true"
    CodeFile="IssueBook.aspx.cs" Inherits="IssueBookPage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row g-3">
        <!-- Issue form -->
        <div class="col-lg-7">
            <div class="card">
                <div class="card-header"><i class="bi bi-box-arrow-up-right me-1"></i> Issue a Book to a Student</div>
                <div class="card-body">
                    <asp:ValidationSummary ID="valSummary" runat="server" CssClass="alert alert-danger py-2"
                        HeaderText="Please fix the following:" DisplayMode="BulletList" />

                    <div class="mb-3">
                        <label class="form-label required">Student</label>
                        <asp:DropDownList ID="ddlStudent" runat="server" CssClass="form-select" AutoPostBack="true"
                            OnSelectedIndexChanged="ddlStudent_SelectedIndexChanged" />
                        <asp:RequiredFieldValidator ID="rfvStudent" runat="server" ControlToValidate="ddlStudent" InitialValue="0"
                            ErrorMessage="Please select a student." Text="Please select a student." CssClass="field-error" Display="Dynamic" />
                        <div class="form-text">Only active students are listed.</div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label required">Book</label>
                        <asp:DropDownList ID="ddlBook" runat="server" CssClass="form-select" />
                        <asp:RequiredFieldValidator ID="rfvBook" runat="server" ControlToValidate="ddlBook" InitialValue="0"
                            ErrorMessage="Please select a book." Text="Please select a book." CssClass="field-error" Display="Dynamic" />
                        <div class="form-text">Only books with at least one available copy are listed.</div>
                    </div>

                    <div class="row g-3">
                        <div class="col-sm-6">
                            <label class="form-label required">Issue Date</label>
                            <asp:TextBox ID="txtIssueDate" runat="server" CssClass="form-control" TextMode="Date" ClientIDMode="Static" />
                            <asp:RequiredFieldValidator ID="rfvIssueDate" runat="server" ControlToValidate="txtIssueDate"
                                ErrorMessage="Issue date is required." Text="Issue date is required." CssClass="field-error" Display="Dynamic" />
                        </div>
                        <div class="col-sm-6">
                            <label class="form-label required">Due Date</label>
                            <asp:TextBox ID="txtDueDate" runat="server" CssClass="form-control" TextMode="Date" ClientIDMode="Static" />
                            <asp:RequiredFieldValidator ID="rfvDueDate" runat="server" ControlToValidate="txtDueDate"
                                ErrorMessage="Due date is required." Text="Due date is required." CssClass="field-error" Display="Dynamic" />
                            <div class="form-text">Default loan period: <asp:Literal ID="litLoanDays" runat="server" /> days.</div>
                        </div>
                    </div>
                </div>
                <div class="card-footer bg-white">
                    <asp:Button ID="btnIssue" runat="server" Text="Issue Book" CssClass="btn btn-primary" OnClick="btnIssue_Click" />
                </div>
            </div>
        </div>

        <!-- Selected student info -->
        <div class="col-lg-5">
            <div class="card">
                <div class="card-header"><i class="bi bi-person-badge me-1"></i> Student Details</div>
                <div class="card-body">
                    <asp:Panel ID="pnlNoStudent" runat="server">
                        <p class="text-muted mb-0">Select a student to see how many books they already have.</p>
                    </asp:Panel>
                    <asp:Panel ID="pnlStudent" runat="server" Visible="false">
                        <h5 class="mb-1"><asp:Literal ID="litStudentName" runat="server" /></h5>
                        <p class="text-muted small mb-2"><asp:Literal ID="litStudentInfo" runat="server" /></p>
                        <p class="mb-2">Books currently borrowed:
                            <strong><asp:Literal ID="litBorrowed" runat="server" /></strong></p>
                        <asp:Literal ID="litLimitWarning" runat="server" />
                        <asp:GridView ID="gvCurrent" runat="server" AutoGenerateColumns="false" CssClass="table table-sm mb-0"
                            GridLines="None" ShowHeaderWhenEmpty="false">
                            <Columns>
                                <asp:BoundField DataField="Title" HeaderText="Book" />
                                <asp:BoundField DataField="DueDate" HeaderText="Due" DataFormatString="{0:dd MMM yyyy}" />
                            </Columns>
                        </asp:GridView>
                    </asp:Panel>
                </div>
            </div>
        </div>
    </div>

    <script>
        // When the issue date changes, suggest a due date = issue date + loan period
        document.addEventListener("DOMContentLoaded", function () {
            var issue = document.getElementById("txtIssueDate");
            var due = document.getElementById("txtDueDate");
            var loanDays = <%= AppConfig.LoanPeriodDays %>;
            issue.addEventListener("change", function () {
                if (!issue.value) return;
                var d = new Date(issue.value + "T00:00:00");
                d.setDate(d.getDate() + loanDays);
                var mm = ("0" + (d.getMonth() + 1)).slice(-2), dd = ("0" + d.getDate()).slice(-2);
                due.value = d.getFullYear() + "-" + mm + "-" + dd;
            });
        });
    </script>
</asp:Content>

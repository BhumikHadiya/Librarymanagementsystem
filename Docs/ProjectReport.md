# Project Report: Library Management System

**Technology:** ASP.NET Web Forms (C#), Microsoft SQL Server, HTML, CSS, Bootstrap 5, JavaScript
**IDE:** Visual Studio 2019/2022

---

## 1. Introduction

A college library handles hundreds of books and students every day. When records are kept in registers or spreadsheets, it is hard to know which books are available and who has borrowed what. It is also easy to make mistakes when calculating late fines.

This project is a web-based **Library Management System** that lets a librarian (admin) manage books, categories and students. The librarian can issue and return books, and fines are calculated automatically. Reports show the state of the library at any time.

## 2. Objectives

1. Keep a central catalogue of books, with categories and copy counts.
2. Maintain student membership records.
3. Issue books with due dates, enforcing availability and a borrowing limit.
4. Record returns, update stock automatically and calculate overdue fines.
5. Give the librarian a dashboard and filterable reports.
6. Protect the system with secure login, hashed passwords and safe database access.

## 3. Scope

**In scope:** single-role admin access, book/category/student CRUD, issue and return, fine calculation, dashboard and reports.

**Out of scope (future work):** a student self-service portal, online fine payment, barcode scanning, email reminders and book reservations.

## 4. System design

### 4.1 Architecture

The system uses a classic three-layer design:

```
Browser (HTML + Bootstrap + JS)
        │  HTTP (postbacks)
ASP.NET Web Forms pages (.aspx + code-behind .cs)
        │  calls
App_Code classes (LibraryService, Db, PasswordHasher, AppConfig)
        │  ADO.NET, parameterized SQL, transactions
SQL Server database (LibraryDB)
```

- **Presentation layer:** the `.aspx` pages share a master page (`Site.master`) with sidebar navigation. GridView controls show the data, and ASP.NET validators check the form fields.
- **Business layer:** `LibraryService` holds the issue/return rules, and `AppConfig` holds the configurable rules.
- **Data layer:** `Db` wraps ADO.NET and accepts only parameterized commands.

### 4.2 Database design (ER summary)

```
Admins (1) ──< BookIssues >── (1) Books >── (1) Categories
                    │
                   (1)
                 Students
```

| Table | Key columns | Important constraints |
|-------|-------------|-----------------------|
| **Admins** | AdminID (PK), Username, FullName, PasswordHash, LastLogin | Username UNIQUE |
| **Categories** | CategoryID (PK), CategoryName, Description | CategoryName UNIQUE |
| **Books** | BookID (PK), ISBN, Title, Author, Publisher, PublishYear, CategoryID (FK), TotalQuantity, AvailableQuantity, ShelfLocation | ISBN UNIQUE and 10 or 13 characters; 0 ≤ Available ≤ Total |
| **Students** | StudentID (PK), StudentCode, FullName, Email, Phone, Department, YearOfStudy, IsActive | StudentCode and Email UNIQUE; Year between 1 and 6 |
| **BookIssues** | IssueID (PK), BookID (FK), StudentID (FK), IssueDate, DueDate, ReturnDate, FineAmount, IssueStatus, IssuedBy (FK), ReturnedTo (FK) | Status is 'Issued' or 'Returned'; DueDate ≥ IssueDate; ReturnDate is NULL exactly when the status is 'Issued'; Fine ≥ 0 |

"Overdue" is not stored. It is calculated as `IssueStatus = 'Issued' AND DueDate < today`, so it is never out of date.

### 4.3 Modules

| Module | Pages | Description |
|--------|-------|-------------|
| Authentication | Login, Logout (master), ChangePassword | Session-based admin login with PBKDF2-hashed passwords |
| Dashboard | Default | Cards for total copies/titles, students, issued and overdue; recent and overdue lists |
| Books | Books, BookForm, Categories | CRUD with search by title/author/ISBN and a category filter |
| Students | Students, StudentForm | CRUD with search by name/ID; active/inactive status |
| Circulation | IssueBook, ReturnBook | Transactional issue and return with fine calculation |
| Reports | Reports | All, issued, returned, overdue and fined records, filtered by student and date, printable |

### 4.4 Key algorithms

**Issuing a book** (`LibraryService.IssueBook`, one SQL transaction):
1. Lock the student row (`UPDLOCK`) and check that the student exists and is active.
2. Count the student's open issues and reject the request if the count is at `MaxBooksPerStudent` or above.
3. Reject the request if the student already holds this title.
4. `UPDATE Books SET AvailableQuantity -= 1 WHERE BookID = @id AND AvailableQuantity > 0`. If no row changed, the book is unavailable.
5. Insert the `BookIssues` row and commit. If any step fails, everything is rolled back.

**Returning a book** (`LibraryService.ReturnBook`, one SQL transaction):
1. Lock the issue row and check that it is still 'Issued'.
2. `Fine = max(0, ReturnDate − DueDate) × FinePerDay`
3. Set the ReturnDate, FineAmount and status to 'Returned', then increase the book's AvailableQuantity by 1. Commit.

Because the availability check happens inside the `UPDATE ... WHERE AvailableQuantity > 0` statement, two librarians cannot issue the last copy at the same time.

## 5. Security measures

- **SQL injection prevention:** every query uses `SqlParameter`.
- **Password storage:** PBKDF2-HMAC-SHA256 with a 16-byte random salt, 10,000 iterations and a constant-time comparison. Plain-text passwords are never stored.
- **Access control:** all admin pages inherit `AdminPage`, which checks the session on `OnInit` and sends no-cache headers.
- **Session handling:** 30-minute timeout and an HTTP-only cookie. Logout clears the session and the cookie.
- **Validation in three layers:** client-side validators, a server-side `Page.IsValid` check plus business checks, and database constraints.
- **Output encoding:** this protects against cross-site scripting (XSS). A safe return URL after login protects against open redirects.

## 6. User interface

- A Bootstrap 5 responsive layout with a fixed dark sidebar that slides in on mobile.
- Coloured summary cards on the dashboard.
- Tables have server-side search plus an instant client-side filter, paging, and status badges (Issued / Overdue / Returned).
- Forms mark required fields with a red asterisk and show inline error messages and a summary.
- Success and error messages appear as dismissible alerts. Delete actions ask for confirmation.
- Reports have a print-friendly style.

## 7. Testing

86 manual test cases are listed in `Docs/TestCases.md`. They cover:
- login and session;
- CRUD validation and duplicate handling;
- the borrowing limit, availability, and inactive-student rules;
- date validation and fine calculation;
- concurrency (the last copy and double returns);
- report filters, the responsive UI and database constraints.

The sample data is created relative to today's date, so overdue and fine scenarios can always be tested.

## 8. Results

The system meets every stated requirement:
- admins can log in securely;
- books, categories and students can be managed with search;
- books are issued and returned with automatic stock updates and fines;
- the dashboard and reports give an up-to-date view of the library.

## 9. Limitations and future enhancements

- Add a student login so students can view their own borrowing history.
- Send email or SMS reminders before the due date.
- Add a book reservation queue for titles that are out of stock.
- Record fine payments (paid or unpaid) and print receipts.
- Use barcodes or QR codes for faster issue and return.
- Support multiple admin roles (librarian or assistant) with different permissions.
- Export reports to Excel or PDF.

## 10. Conclusion

The Library Management System replaces manual record keeping with a simple, secure web application. It is built with standard Microsoft technologies (ASP.NET Web Forms, C# and SQL Server), and the code stays beginner-friendly. It still follows good practices: parameterized queries, hashed passwords, transactions and layered validation.

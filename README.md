# Library Management System (ASP.NET Web Forms + SQL Server)

A web application that helps librarians manage books, categories and students, issue and return books, and calculate overdue fines.

| Layer     | Technology                                              |
|-----------|---------------------------------------------------------|
| Frontend  | HTML5, CSS3, Bootstrap 5.3, Bootstrap Icons, JavaScript |
| Backend   | ASP.NET Web Forms, C# (.NET Framework 4.7.2 or newer)   |
| Database  | Microsoft SQL Server (LocalDB, Express or full edition) |
| IDE       | Visual Studio 2019 / 2022 (Windows)                     |

Default login: **admin / Admin@123**

---

## 1. Project folder structure

```
LibraryManagementSystem/
│
├── README.md                     ← this file (setup instructions)
│
├── Database/
│   ├── 01_CreateDatabase.sql     ← creates LibraryDB, all tables, constraints, default admin
│   └── 02_SampleData.sql         ← sample categories, books, students and issue records
│
├── Docs/
│   ├── TestCases.md              ← manual test cases
│   └── ProjectReport.md          ← short project report
│
└── WebSite/                      ← open THIS folder in Visual Studio
    ├── Web.config                ← connection string + library rules (fine, loan days, limit)
    ├── Global.asax               ← application-level error logging
    ├── Site.master / .cs         ← shared layout: sidebar, top bar, messages, logout
    │
    ├── Login.aspx / .cs          ← admin login (public page)
    ├── Default.aspx / .cs        ← dashboard: summary cards, recent and overdue issues
    ├── Books.aspx / .cs          ← book list, search, delete
    ├── BookForm.aspx / .cs       ← add / edit a book
    ├── Categories.aspx / .cs     ← add / edit / delete categories
    ├── Students.aspx / .cs       ← student list, search, delete
    ├── StudentForm.aspx / .cs    ← register / edit a student
    ├── IssueBook.aspx / .cs      ← issue a book (transaction, borrowing limit)
    ├── ReturnBook.aspx / .cs     ← return a book (transaction, fine calculation)
    ├── Reports.aspx / .cs        ← issued / returned / overdue / history reports with date filters
    ├── ChangePassword.aspx / .cs ← change the admin password
    ├── Error.aspx                ← friendly error page
    │
    ├── App_Code/                 ← shared C# classes (compiled automatically by ASP.NET)
    │   ├── Db.cs                 ← database helper (parameterized queries only)
    │   ├── AppConfig.cs          ← reads library rules from Web.config
    │   ├── PasswordHasher.cs     ← PBKDF2-SHA256 password hashing
    │   ├── AdminPage.cs          ← base class: session check, messages, no-cache
    │   ├── LibraryService.cs     ← issue/return business rules inside SQL transactions
    │   └── UiHelper.cs           ← status badges and table helpers
    │
    └── assets/
        ├── css/site.css          ← custom styles (sidebar, cards, tables, print)
        └── js/site.js            ← sidebar toggle, instant table filter, delete confirmation
```

The project is an **ASP.NET Web Site** (no `.csproj` file). Visual Studio compiles the `.aspx.cs` and `App_Code` files when the site runs, so there are no designer files or build settings to manage. Code-behind files use `CodeFile=` in the `@Page` directive.

---

## 2. Requirements

1. **Visual Studio 2019 or 2022** (Community edition is fine) with the workload **"ASP.NET and web development"**. In the Visual Studio Installer, also tick **".NET Framework 4.7.2 (or 4.8) development tools"** under *Individual components*.
2. **SQL Server**. Any of these will work:
   - **SQL Server Express LocalDB**. It is installed with the workload above, so nothing extra is needed.
   - SQL Server Express or Developer edition.
3. **SQL Server Management Studio (SSMS)**. This is optional; you can also run the scripts inside Visual Studio.
4. An internet connection. Bootstrap is loaded from a CDN (see section 7 for offline use).

---

## 3. Create the database

### Option A: Using Visual Studio (no SSMS needed)
1. Open Visual Studio and go to **View → SQL Server Object Explorer**.
2. Expand **SQL Server → (localdb)\MSSQLLocalDB**. If it is not listed, click *Add SQL Server* and type `(localdb)\MSSQLLocalDB`.
3. Right-click the server, choose **New Query…**, then paste the full contents of `Database/01_CreateDatabase.sql` and click **Execute** (▶ or Ctrl+Shift+E).
4. Open a new query and do the same with `Database/02_SampleData.sql`.

### Option B: Using SSMS
1. Connect to your server (for example `(localdb)\MSSQLLocalDB` or `.\SQLEXPRESS`).
2. **File → Open → File…**, choose `01_CreateDatabase.sql`, and press **F5**.
3. Do the same for `02_SampleData.sql`.

Refresh the *Databases* node and you should see **LibraryDB** with 5 tables.

> You can run both scripts again at any time to reset the database. Script 01 drops and recreates the tables.

---

## 4. Configure the connection string

Open `WebSite/Web.config` and find:

```xml
<add name="LibraryDB"
     connectionString="Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=LibraryDB;Integrated Security=True;..."
```

Change only the `Data Source` part so it matches the server you used in step 3:

| You installed…                    | Data Source value          |
|-----------------------------------|----------------------------|
| LocalDB (with Visual Studio)      | `(localdb)\MSSQLLocalDB`   |
| SQL Server Express                | `.\SQLEXPRESS`             |
| SQL Server full/Developer edition | `.` or `localhost`         |

If you log in to SQL Server with a username and password instead of Windows authentication, use:

```
Data Source=.\SQLEXPRESS;Initial Catalog=LibraryDB;User ID=sa;Password=YourPassword;
```

The library rules are in the same file and can be changed:

```xml
<add key="MaxBooksPerStudent" value="3" />   <!-- borrowing limit -->
<add key="LoanPeriodDays" value="14" />       <!-- default due date = issue date + 14 days -->
<add key="FinePerDay" value="5" />            <!-- fine for each day late -->
<add key="CurrencySymbol" value="₹" />
```

---

## 5. Open and run the project in Visual Studio

1. Start Visual Studio and choose **File → Open → Web Site…** (on the start window: *Continue without code*, then File → Open → Web Site).
2. Select **File System** on the left, browse to the **`LibraryManagementSystem/WebSite`** folder, and click **Open**.
3. If Visual Studio asks to upgrade the target framework, choose **Yes / 4.7.2 or later**.
4. In *Solution Explorer*, right-click **Login.aspx** and choose **Set As Start Page**.
5. Press **F5** (or Ctrl+F5). IIS Express starts and the login page opens in your browser.
6. Log in with **admin / Admin@123**. Then open *Change Password* and set your own password.

If you prefer a solution file, use **File → Save All**. Visual Studio creates a `.sln` you can reopen later.

---

## 6. Using the application

| Page            | What you can do |
|-----------------|-----------------|
| Dashboard       | See total books, students, currently issued and overdue counts, recent issues, overdue list |
| Books           | Search by title/author/ISBN, filter by category, add, edit, delete |
| Categories      | Add, rename and delete categories (only empty ones can be deleted) |
| Students        | Search by name/student ID, register, edit, deactivate, delete, view history |
| Issue Book      | Pick an active student and an available book, set the dates, then issue |
| Return Book     | Find the issued book, pick the return date, see the fine, then confirm |
| Reports         | All, currently issued, returned, overdue, or fined records, filtered by student and issue dates; printable |

**Business rules**
- A book can only be issued if `AvailableQuantity > 0`.
- A student may hold at most `MaxBooksPerStudent` books, and cannot hold two copies of the same title.
- Inactive students cannot borrow books.
- Fine = (return date − due date) in days × `FinePerDay`. No fine if the book comes back on or before the due date.
- Books and students that have borrowing history cannot be deleted. They stay for the records; deactivate students instead.
- A book's total quantity cannot be reduced below the number of copies currently issued.

---

## 7. Security features

| Requirement          | How it is done |
|----------------------|----------------|
| SQL injection        | Every query uses `SqlParameter` (`Db.P(...)`). No user input is concatenated into SQL. |
| Password hashing     | PBKDF2 with SHA-256, a random 16-byte salt and 10,000 iterations (`PasswordHasher.cs`). Comparison runs in constant time. |
| Page protection      | Every admin page inherits `AdminPage`, which redirects to `Login.aspx` when `Session["AdminID"]` is missing. Pages are sent with no-cache headers. |
| Session              | 30-minute timeout, HTTP-only cookie, session cleared and cookie removed on logout. |
| Input validation     | ASP.NET validators on the client, `Page.IsValid` re-checked on the server, plus database CHECK/UNIQUE/FK constraints. |
| Transactions         | `LibraryService.IssueBook` and `ReturnBook` update `Books` and `BookIssues` in one `SqlTransaction`. |
| XSS                  | GridView BoundFields HTML-encode output; dynamic text uses `HttpUtility.HtmlEncode`. |
| Open redirect        | The login `ReturnUrl` must be a local path. |

**Offline Bootstrap (optional):** download `bootstrap.min.css`, `bootstrap.bundle.min.js` and the Bootstrap Icons font folder into `WebSite/assets/`. Then change the `<link>` and `<script>` URLs in `Site.master`, `Login.aspx` and `Error.aspx` to point at those local files.

---

## 8. Troubleshooting

| Problem | Fix |
|---------|-----|
| *A network-related or instance-specific error occurred…* | The `Data Source` in Web.config does not match your SQL Server, or the SQL Server service is not running. |
| *Cannot open database "LibraryDB"* | Run `01_CreateDatabase.sql` first, on the same server named in the connection string. |
| *Login failed for user…* | With Windows authentication, make sure your Windows account has access. Otherwise switch to SQL authentication. |
| *WebForms UnobtrusiveValidationMode requires a ScriptResourceMapping for 'jquery'* | Make sure the `ValidationSettings:UnobtrusiveValidationMode` key is still in Web.config. |
| *The type or namespace 'HashAlgorithmName'…* | The site is targeting an old framework. Set `targetFramework="4.7.2"` (or 4.8) in Web.config and install that targeting pack. |
| Invalid username or password | Re-run `01_CreateDatabase.sql` to reset the admin to `admin / Admin@123`. |
| Page looks unstyled | There is no internet connection for the CDN. See *Offline Bootstrap* above. |

> **Note on C# version:** the code deliberately uses C# 5 syntax (no `$"..."` strings or `?.` operators). It therefore compiles in a Web Site project without installing the Roslyn CodeDom NuGet package.

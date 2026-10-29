/* =====================================================================
   Library Management System - Database Script
   Run this file FIRST in SQL Server Management Studio (SSMS) or in
   Visual Studio (View > SQL Server Object Explorer > New Query).

   It creates the LibraryDB database, all tables, constraints, indexes
   and the default administrator account.

   Default admin login:   Username = admin    Password = Admin@123
   (Change it after the first login from the "Change Password" page.)
   ===================================================================== */

IF DB_ID('LibraryDB') IS NULL
    CREATE DATABASE LibraryDB;
GO

USE LibraryDB;
GO

/* Drop tables in reverse dependency order so the script can be re-run */
IF OBJECT_ID('dbo.BookIssues', 'U') IS NOT NULL DROP TABLE dbo.BookIssues;
IF OBJECT_ID('dbo.Books', 'U')      IS NOT NULL DROP TABLE dbo.Books;
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID('dbo.Students', 'U')   IS NOT NULL DROP TABLE dbo.Students;
IF OBJECT_ID('dbo.Admins', 'U')     IS NOT NULL DROP TABLE dbo.Admins;
GO

/* ---------------------------------------------------------------------
   Admins: librarians who can log in to the system.
   PasswordHash format: PBKDF2$<iterations>$<base64 salt>$<base64 hash>
   --------------------------------------------------------------------- */
CREATE TABLE dbo.Admins
(
    AdminID      INT IDENTITY(1,1) NOT NULL,
    Username     NVARCHAR(50)  NOT NULL,
    FullName     NVARCHAR(100) NOT NULL,
    PasswordHash NVARCHAR(256) NOT NULL,
    CreatedAt    DATETIME2(0)  NOT NULL CONSTRAINT DF_Admins_CreatedAt DEFAULT SYSDATETIME(),
    LastLogin    DATETIME2(0)  NULL,
    CONSTRAINT PK_Admins PRIMARY KEY (AdminID),
    CONSTRAINT UQ_Admins_Username UNIQUE (Username)
);
GO

/* ---------------------------------------------------------------------
   Categories: book categories (Programming, Fiction, ...)
   --------------------------------------------------------------------- */
CREATE TABLE dbo.Categories
(
    CategoryID   INT IDENTITY(1,1) NOT NULL,
    CategoryName NVARCHAR(100) NOT NULL,
    Description  NVARCHAR(250) NULL,
    CONSTRAINT PK_Categories PRIMARY KEY (CategoryID),
    CONSTRAINT UQ_Categories_Name UNIQUE (CategoryName)
);
GO

/* ---------------------------------------------------------------------
   Books: one row per title. TotalQuantity = copies owned,
   AvailableQuantity = copies currently on the shelf.
   --------------------------------------------------------------------- */
CREATE TABLE dbo.Books
(
    BookID            INT IDENTITY(1,1) NOT NULL,
    ISBN              NVARCHAR(13)  NOT NULL,
    Title             NVARCHAR(200) NOT NULL,
    Author            NVARCHAR(150) NOT NULL,
    Publisher         NVARCHAR(150) NULL,
    PublishYear       INT           NULL,
    CategoryID        INT           NOT NULL,
    TotalQuantity     INT           NOT NULL,
    AvailableQuantity INT           NOT NULL,
    ShelfLocation     NVARCHAR(50)  NULL,
    CreatedAt         DATETIME2(0)  NOT NULL CONSTRAINT DF_Books_CreatedAt DEFAULT SYSDATETIME(),
    CONSTRAINT PK_Books PRIMARY KEY (BookID),
    CONSTRAINT UQ_Books_ISBN UNIQUE (ISBN),
    CONSTRAINT FK_Books_Categories FOREIGN KEY (CategoryID) REFERENCES dbo.Categories (CategoryID),
    CONSTRAINT CK_Books_ISBN CHECK (LEN(ISBN) IN (10, 13)),
    CONSTRAINT CK_Books_TotalQuantity CHECK (TotalQuantity >= 0),
    CONSTRAINT CK_Books_AvailableQuantity CHECK (AvailableQuantity >= 0 AND AvailableQuantity <= TotalQuantity),
    CONSTRAINT CK_Books_PublishYear CHECK (PublishYear IS NULL OR PublishYear BETWEEN 1500 AND 2100)
);
GO

/* ---------------------------------------------------------------------
   Students: library members. StudentCode is the college roll number /
   student ID shown to users (e.g. STU2026001).
   --------------------------------------------------------------------- */
CREATE TABLE dbo.Students
(
    StudentID   INT IDENTITY(1,1) NOT NULL,
    StudentCode NVARCHAR(20)  NOT NULL,
    FullName    NVARCHAR(100) NOT NULL,
    Email       NVARCHAR(100) NOT NULL,
    Phone       NVARCHAR(15)  NOT NULL,
    Department  NVARCHAR(100) NOT NULL,
    YearOfStudy TINYINT       NOT NULL,
    IsActive    BIT           NOT NULL CONSTRAINT DF_Students_IsActive DEFAULT 1,
    CreatedAt   DATETIME2(0)  NOT NULL CONSTRAINT DF_Students_CreatedAt DEFAULT SYSDATETIME(),
    CONSTRAINT PK_Students PRIMARY KEY (StudentID),
    CONSTRAINT UQ_Students_Code UNIQUE (StudentCode),
    CONSTRAINT UQ_Students_Email UNIQUE (Email),
    CONSTRAINT CK_Students_Year CHECK (YearOfStudy BETWEEN 1 AND 6)
);
GO

/* ---------------------------------------------------------------------
   BookIssues: every issue / return transaction.
   IssueStatus is 'Issued' while the book is out and 'Returned' after.
   A book is "overdue" when IssueStatus = 'Issued' AND DueDate < today.
   --------------------------------------------------------------------- */
CREATE TABLE dbo.BookIssues
(
    IssueID     INT IDENTITY(1,1) NOT NULL,
    BookID      INT           NOT NULL,
    StudentID   INT           NOT NULL,
    IssueDate   DATE          NOT NULL,
    DueDate     DATE          NOT NULL,
    ReturnDate  DATE          NULL,
    FineAmount  DECIMAL(10,2) NOT NULL CONSTRAINT DF_BookIssues_Fine DEFAULT 0,
    IssueStatus NVARCHAR(10)  NOT NULL CONSTRAINT DF_BookIssues_Status DEFAULT 'Issued',
    IssuedBy    INT           NULL,
    ReturnedTo  INT           NULL,
    Remarks     NVARCHAR(250) NULL,
    CreatedAt   DATETIME2(0)  NOT NULL CONSTRAINT DF_BookIssues_CreatedAt DEFAULT SYSDATETIME(),
    CONSTRAINT PK_BookIssues PRIMARY KEY (IssueID),
    CONSTRAINT FK_BookIssues_Books    FOREIGN KEY (BookID)     REFERENCES dbo.Books (BookID),
    CONSTRAINT FK_BookIssues_Students FOREIGN KEY (StudentID)  REFERENCES dbo.Students (StudentID),
    CONSTRAINT FK_BookIssues_IssuedBy   FOREIGN KEY (IssuedBy)   REFERENCES dbo.Admins (AdminID),
    CONSTRAINT FK_BookIssues_ReturnedTo FOREIGN KEY (ReturnedTo) REFERENCES dbo.Admins (AdminID),
    CONSTRAINT CK_BookIssues_Status CHECK (IssueStatus IN ('Issued', 'Returned')),
    CONSTRAINT CK_BookIssues_DueDate CHECK (DueDate >= IssueDate),
    CONSTRAINT CK_BookIssues_ReturnDate CHECK (ReturnDate IS NULL OR ReturnDate >= IssueDate),
    CONSTRAINT CK_BookIssues_Fine CHECK (FineAmount >= 0),
    /* Status and ReturnDate must agree with each other */
    CONSTRAINT CK_BookIssues_StatusReturn CHECK (
        (IssueStatus = 'Issued'   AND ReturnDate IS NULL) OR
        (IssueStatus = 'Returned' AND ReturnDate IS NOT NULL))
);
GO

/* Indexes that speed up searching and reports */
CREATE INDEX IX_Books_Title          ON dbo.Books (Title);
CREATE INDEX IX_Books_Author         ON dbo.Books (Author);
CREATE INDEX IX_Books_CategoryID     ON dbo.Books (CategoryID);
CREATE INDEX IX_Students_FullName    ON dbo.Students (FullName);
CREATE INDEX IX_BookIssues_Student   ON dbo.BookIssues (StudentID, IssueStatus);
CREATE INDEX IX_BookIssues_Book      ON dbo.BookIssues (BookID, IssueStatus);
CREATE INDEX IX_BookIssues_IssueDate ON dbo.BookIssues (IssueDate);
GO

/* Default administrator  ->  admin / Admin@123  (PBKDF2-SHA256, 10000 iterations) */
INSERT INTO dbo.Admins (Username, FullName, PasswordHash)
VALUES (N'admin', N'Head Librarian',
        N'PBKDF2$10000$+34EGhE4OirZdpT4Q87Jxw==$OmdP06BXSR5LxkzKT93rPEEFz10+LIKUybE95GbWKUc=');
GO

PRINT 'LibraryDB created successfully. Now run 02_SampleData.sql (optional).';
GO

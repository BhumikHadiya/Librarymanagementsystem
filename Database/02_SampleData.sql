/* =====================================================================
   Library Management System - Sample Data (for testing)
   Run AFTER 01_CreateDatabase.sql.
   Issue dates are relative to today, so there will always be some
   current, overdue and returned records whenever you run this script.
   Fine rule used in the samples: 5 per day late (same as Web.config).
   ===================================================================== */
USE LibraryDB;
GO

SET NOCOUNT ON;

DELETE FROM dbo.BookIssues;
DELETE FROM dbo.Books;
DELETE FROM dbo.Categories;
DELETE FROM dbo.Students;
DBCC CHECKIDENT ('dbo.BookIssues', RESEED, 0);
DBCC CHECKIDENT ('dbo.Books',      RESEED, 0);
DBCC CHECKIDENT ('dbo.Categories', RESEED, 0);
DBCC CHECKIDENT ('dbo.Students',   RESEED, 0);
GO

/* ---------- Categories (IDs 1-6) ---------- */
INSERT INTO dbo.Categories (CategoryName, Description) VALUES
 (N'Computer Science', N'Programming, algorithms, databases and networking'),
 (N'Mathematics',      N'Pure and applied mathematics'),
 (N'Electronics',      N'Circuits, devices and communication'),
 (N'Management',       N'Business, finance and marketing'),
 (N'Literature',       N'Novels, poetry and classics'),
 (N'General Science',  N'Physics, chemistry and biology');
GO

/* ---------- Books (IDs 1-15) ----------
   AvailableQuantity starts equal to TotalQuantity and is corrected
   at the end of this script after the sample issues are inserted. */
INSERT INTO dbo.Books (ISBN, Title, Author, Publisher, PublishYear, CategoryID, TotalQuantity, AvailableQuantity, ShelfLocation) VALUES
 (N'9780132350884', N'Clean Code',                                N'Robert C. Martin',            N'Prentice Hall',     2008, 1, 5, 5, N'CS-A1'),
 (N'9780262033848', N'Introduction to Algorithms',                N'Thomas H. Cormen',            N'MIT Press',         2009, 1, 4, 4, N'CS-A2'),
 (N'9780073523323', N'Database System Concepts',                  N'Abraham Silberschatz',        N'McGraw-Hill',       2010, 1, 3, 3, N'CS-B1'),
 (N'9781617294532', N'C# in Depth',                               N'Jon Skeet',                   N'Manning',           2019, 1, 2, 2, N'CS-B2'),
 (N'9780134685991', N'Effective Java',                            N'Joshua Bloch',                N'Addison-Wesley',    2018, 1, 3, 3, N'CS-B3'),
 (N'9780132126953', N'Computer Networks',                         N'Andrew S. Tanenbaum',         N'Pearson',           2010, 1, 2, 2, N'CS-C1'),
 (N'9780470458365', N'Advanced Engineering Mathematics',          N'Erwin Kreyszig',              N'Wiley',             2011, 2, 4, 4, N'MA-A1'),
 (N'9780980232776', N'Introduction to Linear Algebra',            N'Gilbert Strang',              N'Wellesley-Cambridge', 2016, 2, 2, 2, N'MA-A2'),
 (N'9780199339136', N'Microelectronic Circuits',                  N'Adel S. Sedra',               N'Oxford University Press', 2014, 3, 3, 3, N'EC-A1'),
 (N'9780133594140', N'Digital Design',                            N'M. Morris Mano',              N'Pearson',           2017, 3, 2, 2, N'EC-A2'),
 (N'9780133856460', N'Principles of Marketing',                   N'Philip Kotler',               N'Pearson',           2017, 4, 3, 3, N'MG-A1'),
 (N'9780060555665', N'The Intelligent Investor',                  N'Benjamin Graham',             N'Harper Business',   2006, 4, 1, 1, N'MG-A2'),
 (N'9780141439518', N'Pride and Prejudice',                       N'Jane Austen',                 N'Penguin Classics',  2002, 5, 2, 2, N'LT-A1'),
 (N'9780061120084', N'To Kill a Mockingbird',                     N'Harper Lee',                  N'Harper Perennial',  2006, 5, 2, 2, N'LT-A2'),
 (N'9780553380163', N'A Brief History of Time',                   N'Stephen Hawking',             N'Bantam',            1998, 6, 2, 2, N'GS-A1');
GO

/* ---------- Students (IDs 1-10) ---------- */
INSERT INTO dbo.Students (StudentCode, FullName, Email, Phone, Department, YearOfStudy, IsActive) VALUES
 (N'STU2026001', N'Aarav Patel',    N'aarav.patel@college.edu',    N'9876543210', N'Computer Engineering',    3, 1),
 (N'STU2026002', N'Diya Shah',      N'diya.shah@college.edu',      N'9876543211', N'Computer Engineering',    2, 1),
 (N'STU2026003', N'Rohan Mehta',    N'rohan.mehta@college.edu',    N'9876543212', N'Information Technology',  4, 1),
 (N'STU2026004', N'Ananya Joshi',   N'ananya.joshi@college.edu',   N'9876543213', N'Electronics',             1, 1),
 (N'STU2026005', N'Kabir Desai',    N'kabir.desai@college.edu',    N'9876543214', N'Mechanical Engineering',  2, 1),
 (N'STU2026006', N'Isha Kapoor',    N'isha.kapoor@college.edu',    N'9876543215', N'Management Studies',      1, 1),
 (N'STU2026007', N'Vivaan Reddy',   N'vivaan.reddy@college.edu',   N'9876543216', N'Computer Engineering',    4, 1),
 (N'STU2026008', N'Meera Nair',     N'meera.nair@college.edu',     N'9876543217', N'Information Technology',  3, 1),
 (N'STU2026009', N'Arjun Singh',    N'arjun.singh@college.edu',    N'9876543218', N'Electronics',             2, 1),
 (N'STU2026010', N'Sara Khan',      N'sara.khan@college.edu',      N'9876543219', N'Management Studies',      3, 0);  -- inactive student (cannot borrow)
GO

/* ---------- Book issues ---------- */
DECLARE @Today DATE = CAST(GETDATE() AS DATE);

/* Currently issued, NOT overdue */
INSERT INTO dbo.BookIssues (BookID, StudentID, IssueDate, DueDate, ReturnDate, FineAmount, IssueStatus, IssuedBy) VALUES
 (1, 1, DATEADD(DAY, -3,  @Today), DATEADD(DAY, 11, @Today), NULL, 0, N'Issued', 1),
 (4, 1, DATEADD(DAY, -2,  @Today), DATEADD(DAY, 12, @Today), NULL, 0, N'Issued', 1),
 (2, 2, DATEADD(DAY, -5,  @Today), DATEADD(DAY, 9,  @Today), NULL, 0, N'Issued', 1),
 (7, 4, DATEADD(DAY, -1,  @Today), DATEADD(DAY, 13, @Today), NULL, 0, N'Issued', 1),
 (11, 6, @Today,                   DATEADD(DAY, 14, @Today), NULL, 0, N'Issued', 1);

/* Currently issued AND overdue (due date already passed) */
INSERT INTO dbo.BookIssues (BookID, StudentID, IssueDate, DueDate, ReturnDate, FineAmount, IssueStatus, IssuedBy) VALUES
 (3, 3, DATEADD(DAY, -20, @Today), DATEADD(DAY, -6, @Today), NULL, 0, N'Issued', 1),
 (12, 5, DATEADD(DAY, -30, @Today), DATEADD(DAY, -16, @Today), NULL, 0, N'Issued', 1),
 (9, 9, DATEADD(DAY, -16, @Today), DATEADD(DAY, -2, @Today), NULL, 0, N'Issued', 1);

/* Returned on time (no fine) */
INSERT INTO dbo.BookIssues (BookID, StudentID, IssueDate, DueDate, ReturnDate, FineAmount, IssueStatus, IssuedBy, ReturnedTo) VALUES
 (5,  1, DATEADD(DAY, -60, @Today), DATEADD(DAY, -46, @Today), DATEADD(DAY, -50, @Today), 0, N'Returned', 1, 1),
 (13, 2, DATEADD(DAY, -45, @Today), DATEADD(DAY, -31, @Today), DATEADD(DAY, -33, @Today), 0, N'Returned', 1, 1),
 (6,  7, DATEADD(DAY, -40, @Today), DATEADD(DAY, -26, @Today), DATEADD(DAY, -26, @Today), 0, N'Returned', 1, 1),
 (15, 8, DATEADD(DAY, -25, @Today), DATEADD(DAY, -11, @Today), DATEADD(DAY, -15, @Today), 0, N'Returned', 1, 1);

/* Returned late (fine = days late x 5) */
INSERT INTO dbo.BookIssues (BookID, StudentID, IssueDate, DueDate, ReturnDate, FineAmount, IssueStatus, IssuedBy, ReturnedTo) VALUES
 (8,  3, DATEADD(DAY, -50, @Today), DATEADD(DAY, -36, @Today), DATEADD(DAY, -30, @Today), 30.00, N'Returned', 1, 1),  -- 6 days late
 (14, 7, DATEADD(DAY, -35, @Today), DATEADD(DAY, -21, @Today), DATEADD(DAY, -11, @Today), 50.00, N'Returned', 1, 1),  -- 10 days late
 (10, 9, DATEADD(DAY, -70, @Today), DATEADD(DAY, -56, @Today), DATEADD(DAY, -53, @Today), 15.00, N'Returned', 1, 1);  -- 3 days late
GO

/* Make AvailableQuantity consistent with the books that are still out */
UPDATE b
SET    b.AvailableQuantity = b.TotalQuantity -
       (SELECT COUNT(*) FROM dbo.BookIssues i WHERE i.BookID = b.BookID AND i.IssueStatus = N'Issued')
FROM   dbo.Books b;
GO

PRINT 'Sample data inserted successfully.';
GO

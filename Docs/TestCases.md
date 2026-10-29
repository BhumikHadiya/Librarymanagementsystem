# Test Cases – Library Management System

**Preconditions:** both SQL scripts have been run, and the site is running in Visual Studio (F5).
Library rules are the Web.config defaults: a maximum of 3 books per student, a 14-day loan period and a fine of 5 per day.

The sample data contains:
- **STU2026001 (Aarav Patel)**, who currently has 2 books.
- **STU2026010 (Sara Khan)**, who is **inactive**.
- ***The Intelligent Investor***, which has 0 copies available.
- 3 overdue issues and 3 books that were returned late with fines.

Mark each test **Pass** or **Fail** in the *Result* column as you run it.

## 1. Login and session

| ID | Test case | Steps | Expected result | Result |
|----|-----------|-------|-----------------|--------|
| TC-01 | Valid login | Enter `admin` / `Admin@123` and click Login | Dashboard opens; the admin name appears in the top bar | |
| TC-02 | Wrong password | Enter `admin` / `wrong123` | "Invalid username or password." and the user stays on the login page | |
| TC-03 | Unknown user | Enter `nobody` / `Admin@123` | The same generic error as TC-02 (does not reveal which field was wrong) | |
| TC-04 | Empty fields | Click Login with both boxes empty | "Username is required." and "Password is required." appear; no postback | |
| TC-05 | Page protection | Log out, then type `/Books.aspx` in the address bar | Redirects to Login.aspx with "Please log in to continue." | |
| TC-06 | Return URL | From TC-05, log in | Opens Books.aspx (the page you originally asked for) | |
| TC-07 | Logout and Back button | Log in, click Logout, press the browser Back button | The login page is shown or reloaded; admin data is not visible | |
| TC-08 | SQL injection on login | Username `' OR 1=1 --`, any password | Login fails with the generic error; no SQL error | |
| TC-09 | Change password | Change Password: current `Admin@123`, new `Library2026`, confirm the same | "Password changed successfully."; log out and log in with the new password | |
| TC-10 | Change password, mismatch | New `Library2026`, confirm `Library2027` | "Passwords do not match." | |
| TC-11 | Weak new password | New password `abc` | "At least 8 characters, with at least one letter and one number." | |

## 2. Dashboard

| ID | Test case | Steps | Expected result | Result |
|----|-----------|-------|-----------------|--------|
| TC-12 | Summary cards | Open Dashboard after loading the sample data | Total Books = 40 (15 titles), Students = 10, Currently Issued = 8, Overdue = 3 | |
| TC-13 | Recently issued | Look at the "Recently Issued Books" table | Latest issues first, with Issued / Overdue / Returned badges | |
| TC-14 | Overdue list | Look at the "Overdue Books" table | 3 rows with the days late shown in red | |

## 3. Book management

| ID | Test case | Steps | Expected result | Result |
|----|-----------|-------|-----------------|--------|
| TC-15 | Add a book | Add Book: ISBN `9780596007126`, Title `Head First Design Patterns`, Author `Eric Freeman`, Category Computer Science, Qty 2 → Save | "Book added successfully."; the book shows 2 / 2 available | |
| TC-16 | Required fields | Click Save with an empty form | The validation summary lists ISBN, Category, Title, Author | |
| TC-17 | Invalid ISBN | ISBN `12345` | "ISBN must be 10 or 13 digits (hyphens allowed)." | |
| TC-18 | Hyphenated ISBN | ISBN `978-0-596-00712-6` for a new book | Saved as `9780596007126`, or a duplicate error if TC-15 was already run | |
| TC-19 | Duplicate ISBN | Add another book with ISBN `9780132350884` | "Another book with ISBN 9780132350884 already exists." | |
| TC-20 | Quantity range | Quantity `0`, then `5000` | "Quantity must be between 1 and 1000." | |
| TC-21 | Year range | Publish year `1200`, then next year | A year range error is shown | |
| TC-22 | Edit a book | Edit *Clean Code*, change the shelf to `CS-Z9` | "Book updated successfully." and the new shelf is shown | |
| TC-23 | Increase quantity | Edit *Clean Code* (5 total, 4 available) and set total to 7 | Shows 6 / 7 available (available rises by the same amount) | |
| TC-24 | Reduce below issued | Edit *The Intelligent Investor* (1 issued) and set total to 0 | Blocked by the validator (minimum 1) | |
| TC-25 | Reduce below issued (2) | Issue 2 copies of a 2-copy book, then set its total to 1 | "Total quantity cannot be less than the number of copies currently issued." | |
| TC-26 | Search | Search `Cormen`, then `9780073523323`, then `algorithms` | The matching book is found each time | |
| TC-27 | Category filter | Choose category Literature | Only the 2 literature books are listed | |
| TC-28 | Quick filter | Type `Hawking` in the quick filter box | Rows are filtered instantly without a postback | |
| TC-29 | Delete a book in use | Delete *Introduction to Algorithms* (currently issued) | "cannot be deleted because 1 copy(ies) are currently issued." | |
| TC-30 | Delete a book with history | Delete *Effective Java* (returned earlier, none out) | "has borrowing history and cannot be deleted" | |
| TC-31 | Delete a new book | Delete the book from TC-15 and confirm the popup | "Book deleted successfully." | |
| TC-32 | Cancel delete | Click delete, then Cancel in the popup | Nothing happens | |

## 4. Categories

| ID | Test case | Steps | Expected result | Result |
|----|-----------|-------|-----------------|--------|
| TC-33 | Add a category | Name `History` → Add | "Category "History" added." | |
| TC-34 | Duplicate category | Add `Literature` again | "A category named "Literature" already exists." | |
| TC-35 | Edit a category | Edit `History` and rename it to `World History` | "Category updated." | |
| TC-36 | Delete a used category | Delete `Computer Science` | "This category still has books…" | |
| TC-37 | Delete an empty category | Delete `World History` | "Category deleted." | |

## 5. Student management

| ID | Test case | Steps | Expected result | Result |
|----|-----------|-------|-----------------|--------|
| TC-38 | Register a student | ID `STU2026011`, Name `Neha Verma`, Email `neha.verma@college.edu`, Phone `9876500000`, Dept IT, Year 1 | "Student registered successfully." | |
| TC-39 | Required fields | Save an empty form | All required-field messages are shown | |
| TC-40 | Invalid email | Email `neha@` | "Enter a valid email address." | |
| TC-41 | Invalid phone | Phone `98765` or `98765abcde` | "Phone must be exactly 10 digits." | |
| TC-42 | Invalid name | Name `Neha123` | Error about allowed characters in the name | |
| TC-43 | Duplicate student ID / email | Register `STU2026001`, or the email `diya.shah@college.edu` | "Another student already uses this Student ID or email address." | |
| TC-44 | Search | Search `STU2026003`, then `meera` | The correct student is shown | |
| TC-45 | Status filter | Status = Inactive | Only Sara Khan is shown | |
| TC-46 | Edit a student | Change Neha's year to 2 | "Student updated successfully." | |
| TC-47 | Delete a student with history | Delete Aarav Patel | "has borrowing records and cannot be deleted… mark them Inactive" | |
| TC-48 | Delete a new student | Delete Neha Verma (no history) | "Student deleted successfully." | |
| TC-49 | History link | Click the clock icon next to Rohan Mehta | Reports opens filtered to Rohan's transactions | |

## 6. Issue book

| ID | Test case | Steps | Expected result | Result |
|----|-----------|-------|-----------------|--------|
| TC-50 | Default dates | Open Issue Book | Issue date = today, due date = today + 14 | |
| TC-51 | Auto due date | Change the issue date to yesterday | The due date changes to yesterday + 14 | |
| TC-52 | Student details | Select STU2026001 | Shows "2 of 3" and lists the 2 books currently borrowed | |
| TC-53 | Successful issue | STU2026002 + *Digital Design* → Issue | "Book issued successfully…"; available count drops by 1 | |
| TC-54 | Borrowing limit | Give STU2026001 one more book (3 of 3), then try a 4th | "Borrowing limit reached…" and the warning panel is shown | |
| TC-55 | Same title twice | Issue *Clean Code* to STU2026001 (who already has it) | "This student already has a copy of this book." | |
| TC-56 | Unavailable book | Look for *The Intelligent Investor* in the book list | It is not listed (0 available) | |
| TC-57 | Last copy race | Open Issue Book in two tabs for a book with 1 copy, then issue it in both | The first succeeds; the second shows "This book is not available right now" | |
| TC-58 | Inactive student | Look for Sara Khan in the student list | She is not listed (only active students appear) | |
| TC-59 | Future issue date | Set the issue date to tomorrow | "Issue date cannot be in the future." | |
| TC-60 | Due before issue | Set the due date earlier than the issue date | "Due date must be on or after the issue date." | |
| TC-61 | Loan too long | Set the due date to issue + 120 days | "Loan period cannot be longer than 90 days." | |
| TC-62 | Required selection | Click Issue without choosing a student or book | "Please select a student." / "Please select a book." | |

## 7. Return book

| ID | Test case | Steps | Expected result | Result |
|----|-----------|-------|-----------------|--------|
| TC-63 | List issued books | Open Return Book | All 8 or more issued books, earliest due date first | |
| TC-64 | Overdue only | Tick "Overdue only" → Search | Only the 3 overdue records, each with a red "N day(s) late" badge | |
| TC-65 | On-time return | Return Aarav's *Clean Code* with today's date | "Book returned on time. No fine."; available +1 | |
| TC-66 | Late return | Return *The Intelligent Investor* (16 days late) | The preview shows ₹ 80.00; on confirm "Late fine of ₹ 80.00 must be collected." | |
| TC-67 | Change return date | Select an overdue record and change the return date to an earlier day | The fine preview updates | |
| TC-68 | Future return date | Return date = tomorrow | "Return date cannot be in the future." | |
| TC-69 | Return before issue | Return date earlier than the issue date | "Return date cannot be before the issue date…" | |
| TC-70 | Double return | Open the return panel for the same record in two tabs and confirm both | The second shows "This book has already been returned."; quantity rises only once | |

## 8. Reports

| ID | Test case | Steps | Expected result | Result |
|----|-----------|-------|-----------------|--------|
| TC-71 | All transactions | Report = All → Show | Every record; the summary shows records, still out, overdue and total fines | |
| TC-72 | Currently issued | Report = Currently issued | Only "Issued" / "Overdue" status rows | |
| TC-73 | Returned | Report = Returned | Only returned rows, with return dates | |
| TC-74 | Overdue | Report = Overdue | Only not-returned rows past the due date | |
| TC-75 | Fined | Report = Returned late | 3 sample rows; total fines = ₹ 95.00 (before any new returns) | |
| TC-76 | Date filter | From = 30 days ago, To = today | Only issues inside the range | |
| TC-77 | Invalid date range | From later than To | "'From' date must be before 'To' date." | |
| TC-78 | Student history | Student = STU2026007 | All of Vivaan's transactions (2 returned, one with a ₹ 50 fine) | |
| TC-79 | Print | Click Print | The print preview hides the sidebar and filters | |

## 9. UI and responsiveness

| ID | Test case | Steps | Expected result | Result |
|----|-----------|-------|-----------------|--------|
| TC-80 | Mobile layout | Resize the browser to under 992 px wide | The sidebar hides; the ☰ button opens it; tapping outside closes it | |
| TC-81 | Active menu | Visit each page | The current page is highlighted in the sidebar | |
| TC-82 | Messages | Do any save | A green dismissible alert appears and disappears after 5 seconds | |
| TC-83 | Paging | Add more than 10 books and open Books | The pager appears and page 2 works with the search kept | |

## 10. Database integrity (run in SSMS)

| ID | Test case | SQL | Expected result | Result |
|----|-----------|-----|-----------------|--------|
| TC-84 | Quantity check | `UPDATE Books SET AvailableQuantity = 99 WHERE BookID = 1;` | Fails because of CK_Books_AvailableQuantity | |
| TC-85 | Status check | `UPDATE BookIssues SET IssueStatus = 'Lost' WHERE IssueID = 1;` | Fails because of CK_BookIssues_Status | |
| TC-86 | Consistency | `SELECT b.BookID FROM Books b WHERE b.TotalQuantity - b.AvailableQuantity <> (SELECT COUNT(*) FROM BookIssues i WHERE i.BookID = b.BookID AND i.IssueStatus = 'Issued');` | Returns 0 rows after any number of issues and returns | |

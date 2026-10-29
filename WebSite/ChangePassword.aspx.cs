using System;

public partial class ChangePasswordPage : AdminPage
{
    protected void btnChange_Click(object sender, EventArgs e)
    {
        if (!Page.IsValid)
            return;

        string storedHash = (string)Db.ExecuteScalar("SELECT PasswordHash FROM Admins WHERE AdminID = @ID",
            Db.P("@ID", AdminId));

        if (!PasswordHasher.VerifyPassword(txtCurrent.Text, storedHash))
        {
            ShowMessage("Current password is incorrect.", "danger");
            return;
        }

        Db.ExecuteNonQuery("UPDATE Admins SET PasswordHash = @Hash WHERE AdminID = @ID",
            Db.P("@Hash", PasswordHasher.HashPassword(txtNew.Text)),
            Db.P("@ID", AdminId));

        ShowMessage("Password changed successfully.", "success");
    }
}

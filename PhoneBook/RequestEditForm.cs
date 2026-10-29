using System;
using System.Data;
using System.Windows.Forms;

public class RequestEditForm : Form
{
    readonly int? requestId;
    TextBox tbId, tbLast, tbFirst, tbPhone;
    ComboBox cbGroup;

    public RequestEditForm(int? id)
    {
        requestId = id;
        Text = id == null ? "Новая заявка на добавление контакта" : "Изменение заявки";
        Width = 450; Height = 310;
        StartPosition = FormStartPosition.CenterScreen;
        FormBorderStyle = FormBorderStyle.FixedDialog;
        MaximizeBox = false; MinimizeBox = false;

        tbId = Ui.Field(this, "ID", 20);
        tbId.ReadOnly = true;
        tbId.Text = id.HasValue ? id.Value.ToString() : "(автоматически)";

        tbLast = Ui.Field(this, "Фамилия *", 55);
        tbLast.MaxLength = 50;
        tbFirst = Ui.Field(this, "Имя *", 90);
        tbFirst.MaxLength = 50;
        tbPhone = Ui.Field(this, "Телефон *", 125);
        tbPhone.MaxLength = 20;
        cbGroup = Ui.Combo(this, "Группа *", 160);
        cbGroup.Items.AddRange(Ui.LoadItems("SELECT id, name FROM contact_groups ORDER BY id").ToArray());

        Ui.Btn(this, "Сохранить", 150, 210, 110, Save);
        Ui.Btn(this, "Отмена", 270, 210, 110, () => DialogResult = DialogResult.Cancel);

        if (id == null)
        {
            if (cbGroup.Items.Count > 0) cbGroup.SelectedIndex = 0;
        }
        else
        {
            DataTable dt = Db.Query(
                "SELECT last_name, first_name, phone, group_id FROM contact_requests WHERE id = @id", ("id", id.Value));
            if (dt.Rows.Count == 0) throw new UserMessageException("Заявка не найдена.");
            DataRow r = dt.Rows[0];
            tbLast.Text = Convert.ToString(r["last_name"]);
            tbFirst.Text = Convert.ToString(r["first_name"]);
            tbPhone.Text = Convert.ToString(r["phone"]);
            int g = Convert.ToInt32(r["group_id"]);
            foreach (Item it in cbGroup.Items)
                if (it.Id == g) { cbGroup.SelectedItem = it; break; }
        }
    }

    void Save()
    {
        string last = tbLast.Text.Trim();
        string first = tbFirst.Text.Trim();
        string phone = Ui.NormalizePhone(tbPhone.Text);
        if (last.Length == 0) { Ui.Error("Введите фамилию."); return; }
        if (first.Length == 0) { Ui.Error("Введите имя."); return; }
        if (!Ui.IsPhone(phone)) { Ui.Error(Ui.PhoneHelp); return; }
        if (cbGroup.SelectedItem == null) { Ui.Error("Выберите группу."); return; }
        int grp = ((Item)cbGroup.SelectedItem).Id;

        bool ok = Ui.Try(() =>
        {
            if (requestId == null)
            {
                Db.Exec(
                    "INSERT INTO contact_requests(user_id, last_name, first_name, phone, group_id) " +
                    "VALUES (@me, @l, @f, @p, @g)",
                    ("me", Session.UserId), ("l", last), ("f", first), ("p", phone), ("g", grp));
            }
            else
            {
                int n = Db.Exec(
                    "UPDATE contact_requests SET last_name = @l, first_name = @f, phone = @p, group_id = @g, " +
                    "admin_id = @me, status_id = 3 WHERE id = @id AND status_id = 2",
                    ("l", last), ("f", first), ("p", phone), ("g", grp), ("me", Session.UserId), ("id", requestId.Value));
                if (n == 0)
                    throw new UserMessageException("Изменить можно только заявку, которую принял менеджер.");
            }
        });
        if (ok) DialogResult = DialogResult.OK;
    }
}

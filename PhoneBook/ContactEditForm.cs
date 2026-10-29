using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Windows.Forms;

public class PhoneRow
{
    public int? Id;
    public int TypeId;
    public string TypeName;
    public string Number;
    public override string ToString() { return TypeName + ": " + Number; }
}

public class ContactEditForm : Form
{
    readonly int? contactId;
    TextBox tbId, tbLast, tbFirst, tbNumber;
    ComboBox cbGroup, cbType;
    ListBox lbPhones;
    readonly List<PhoneRow> phones = new List<PhoneRow>();
    readonly List<int> removed = new List<int>();

    public ContactEditForm(int? id)
    {
        contactId = id;
        Text = id == null ? "Новый контакт" : "Изменение контакта";
        Width = 450; Height = 520;
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

        cbGroup = Ui.Combo(this, "Группа *", 125);
        cbGroup.Items.AddRange(Ui.LoadItems("SELECT id, name FROM contact_groups ORDER BY id").ToArray());

        Controls.Add(new Label { Text = "Телефоны *", Left = 20, Top = 165, Width = 130, Height = 20 });
        lbPhones = new ListBox { Left = 150, Top = 162, Width = 260, Height = 90 };
        Controls.Add(lbPhones);
        Ui.Btn(this, "Удалить номер", 150, 258, 130, DeletePhone);

        tbNumber = Ui.Field(this, "Новый номер", 305);
        tbNumber.MaxLength = 20;
        cbType = Ui.Combo(this, "Тип номера", 340);
        cbType.Items.AddRange(Ui.LoadItems("SELECT id, name FROM phone_types ORDER BY id").ToArray());
        if (cbType.Items.Count > 0) cbType.SelectedIndex = 0;
        Ui.Btn(this, "Добавить номер", 150, 372, 130, AddPhone);

        Ui.Btn(this, "Сохранить", 150, 425, 110, Save);
        Ui.Btn(this, "Отмена", 270, 425, 110, () => DialogResult = DialogResult.Cancel);

        if (id == null)
        {
            if (cbGroup.Items.Count > 0) cbGroup.SelectedIndex = 0;
        }
        else
        {
            DataTable dt = Db.Query("SELECT last_name, first_name, group_id FROM contacts WHERE id = @id", ("id", id.Value));
            if (dt.Rows.Count == 0) throw new UserMessageException("Контакт не найден.");
            DataRow r = dt.Rows[0];
            tbLast.Text = Convert.ToString(r["last_name"]);
            tbFirst.Text = Convert.ToString(r["first_name"]);
            SelectId(cbGroup, Convert.ToInt32(r["group_id"]));

            DataTable pt = Db.Query(
                "SELECT p.id, p.phone_type_id, t.name AS type_name, p.number " +
                "FROM phones p JOIN phone_types t ON t.id = p.phone_type_id " +
                "WHERE p.contact_id = @id ORDER BY p.id", ("id", id.Value));
            foreach (DataRow pr in pt.Rows)
                phones.Add(new PhoneRow
                {
                    Id = Convert.ToInt32(pr["id"]),
                    TypeId = Convert.ToInt32(pr["phone_type_id"]),
                    TypeName = Convert.ToString(pr["type_name"]),
                    Number = Convert.ToString(pr["number"])
                });
            RefreshList();
        }
    }

    static void SelectId(ComboBox cb, int id)
    {
        foreach (Item it in cb.Items)
            if (it.Id == id) { cb.SelectedItem = it; return; }
    }

    void RefreshList()
    {
        lbPhones.Items.Clear();
        foreach (var p in phones) lbPhones.Items.Add(p);
    }

    void AddPhone()
    {
        string number = Ui.NormalizePhone(tbNumber.Text);
        if (!Ui.IsPhone(number)) { Ui.Error(Ui.PhoneHelp); return; }
        if (phones.Any(x => x.Number == number)) { Ui.Error("Такой номер у контакта уже есть."); return; }
        if (cbType.SelectedItem == null) { Ui.Error("Выберите тип номера."); return; }

        var type = (Item)cbType.SelectedItem;
        phones.Add(new PhoneRow { TypeId = type.Id, TypeName = type.Name, Number = number });
        RefreshList();
        tbNumber.Text = "";
    }

    void DeletePhone()
    {
        int i = lbPhones.SelectedIndex;
        if (i < 0) { Ui.Info("Выберите номер в списке."); return; }
        if (phones[i].Id != null) removed.Add(phones[i].Id.Value);
        phones.RemoveAt(i);
        RefreshList();
    }

    void Save()
    {
        string last = tbLast.Text.Trim();
        string first = tbFirst.Text.Trim();
        if (last.Length == 0) { Ui.Error("Введите фамилию."); return; }
        if (first.Length == 0) { Ui.Error("Введите имя."); return; }
        if (cbGroup.SelectedItem == null) { Ui.Error("Выберите группу."); return; }
        if (phones.Count == 0) { Ui.Error("Добавьте хотя бы один номер телефона."); return; }
        int grp = ((Item)cbGroup.SelectedItem).Id;

        bool ok = Ui.Try(() =>
        {
            using var c = Db.Open();
            using var tx = c.BeginTransaction();
            int cid;
            if (contactId == null)
            {
                cid = Convert.ToInt32(Db.Scalar(c, tx,
                    "INSERT INTO contacts(last_name, first_name, group_id, created_by) " +
                    "VALUES (@l, @f, @g, @me) RETURNING id",
                    ("l", last), ("f", first), ("g", grp), ("me", Session.UserId)));
            }
            else
            {
                cid = contactId.Value;
                int n = Db.Exec(c, tx,
                    "UPDATE contacts SET last_name = @l, first_name = @f, group_id = @g WHERE id = @id",
                    ("l", last), ("f", first), ("g", grp), ("id", cid));
                if (n == 0)
                    throw new UserMessageException("Контакт не найден. Возможно, его уже удалили.");
            }

            foreach (int pid in removed)
                Db.Exec(c, tx, "DELETE FROM phones WHERE id = @pid AND contact_id = @cid", ("pid", pid), ("cid", cid));

            foreach (var p in phones.Where(x => x.Id == null))
                Db.Exec(c, tx,
                    "INSERT INTO phones(contact_id, phone_type_id, number) VALUES (@cid, @t, @num)",
                    ("cid", cid), ("t", p.TypeId), ("num", p.Number));

            tx.Commit();
        });
        if (ok) DialogResult = DialogResult.OK;
    }
}

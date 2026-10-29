using System;
using System.Data;
using System.Windows.Forms;

public class RequestsForm : Form
{
    DataGridView grid;
    ComboBox cbStat;
    Label lblCount;

    public RequestsForm()
    {
        Text = "Заявки на добавление контакта — " + Session.Role;
        Width = 1050; Height = 560;
        StartPosition = FormStartPosition.CenterScreen;

        var top = new Panel { Dock = DockStyle.Top, Height = 55 };
        var bottom = new FlowLayoutPanel { Dock = DockStyle.Bottom, Height = 50, Padding = new Padding(8, 8, 0, 0) };
        grid = Ui.Grid();

        top.Controls.Add(new Label { Text = "Статус", Left = 10, Top = 8, Width = 200, Height = 18 });
        cbStat = new ComboBox { Left = 10, Top = 26, Width = 220, DropDownStyle = ComboBoxStyle.DropDownList };
        top.Controls.Add(cbStat);
        Ui.Btn(top, "Показать", 245, 24, 100, () => Ui.Try(Reload));
        lblCount = new Label { Left = 360, Top = 31, Width = 300, Height = 20 };
        top.Controls.Add(lblCount);

        string role = Session.Role;
        var bNew = Ui.Btn(bottom, "Подать заявку", 0, 0, 130, NewRequest);
        var bReceive = Ui.Btn(bottom, "Получить результат", 0, 0, 160, Receive);
        var bAccept = Ui.Btn(bottom, "Принять", 0, 0, 100, () => SetByManager(2, "принять"));
        var bReject = Ui.Btn(bottom, "Отклонить", 0, 0, 100, () => SetByManager(4, "отклонить"));
        var bEdit = Ui.Btn(bottom, "Изменить данные", 0, 0, 150, Edit);
        Ui.Btn(bottom, "Закрыть", 0, 0, 100, Close);

        bNew.Visible = role == "Пользователь";
        bReceive.Visible = role == "Пользователь";
        bAccept.Visible = role == "Менеджер";
        bReject.Visible = role == "Менеджер";
        bEdit.Visible = role == "Администратор";

        Controls.Add(grid);
        Controls.Add(top);
        Controls.Add(bottom);
        grid.BringToFront();

        Load += (s, e) => Ui.Try(Init);
    }

    void Init()
    {
        cbStat.Items.Add(new Item(0, "Все"));
        foreach (var it in Ui.LoadItems("SELECT id, name FROM request_statuses ORDER BY id")) cbStat.Items.Add(it);
        cbStat.SelectedIndex = 0;
        Reload();
    }

    void Reload()
    {
        var where = "TRUE";
        var ps = new System.Collections.Generic.List<(string, object)>();

        if (Session.Role == "Пользователь")
        {
            where += " AND r.user_id = @me";
            ps.Add(("me", Session.UserId));
        }
        if (cbStat.SelectedItem is Item si && si.Id != 0)
        {
            where += " AND r.status_id = @st";
            ps.Add(("st", si.Id));
        }

        var dt = Db.Query(
            "SELECT r.id AS \"ID\", u.full_name AS \"Автор\", r.last_name AS \"Фамилия\", r.first_name AS \"Имя\", " +
            "r.phone AS \"Телефон\", g.name AS \"Группа\", s.name AS \"Статус\", " +
            "m.full_name AS \"Менеджер\", a.full_name AS \"Администратор\" " +
            "FROM contact_requests r " +
            "JOIN users u ON u.id = r.user_id " +
            "JOIN contact_groups g ON g.id = r.group_id " +
            "JOIN request_statuses s ON s.id = r.status_id " +
            "LEFT JOIN users m ON m.id = r.manager_id " +
            "LEFT JOIN users a ON a.id = r.admin_id " +
            "WHERE " + where + " ORDER BY r.id DESC", ps.ToArray());
        grid.DataSource = dt;
        lblCount.Text = "Найдено заявок: " + dt.Rows.Count;
    }

    int? SelectedId()
    {
        if (grid.CurrentRow == null)
        {
            Ui.Info("Выберите заявку в таблице.");
            return null;
        }
        return Convert.ToInt32(grid.CurrentRow.Cells["ID"].Value);
    }

    void NewRequest()
    {
        Ui.Try(() =>
        {
            using var f = new RequestEditForm(null);
            if (f.ShowDialog(this) == DialogResult.OK) Reload();
        });
    }

    void Edit()
    {
        var id = SelectedId();
        if (id == null) return;
        Ui.Try(() =>
        {
            using var f = new RequestEditForm(id);
            if (f.ShowDialog(this) == DialogResult.OK) Reload();
        });
    }

    void SetByManager(int newStatus, string verb)
    {
        var id = SelectedId();
        if (id == null) return;
        Ui.Try(() =>
        {
            int n = Db.Exec(
                "UPDATE contact_requests SET status_id = @st, manager_id = @me WHERE id = @id AND status_id = 1",
                ("st", newStatus), ("me", Session.UserId), ("id", id.Value));
            if (n == 0)
                throw new UserMessageException("Можно " + verb + " только новую заявку.");
            Reload();
        });
    }

    void Receive()
    {
        var id = SelectedId();
        if (id == null) return;
        Ui.Try(() =>
        {
            using var c = Db.Open();
            using var tx = c.BeginTransaction();
            var dt = Db.Query(c, tx,
                "SELECT last_name, first_name, phone, group_id, user_id, status_id " +
                "FROM contact_requests WHERE id = @id FOR UPDATE", ("id", id.Value));
            if (dt.Rows.Count == 0)
                throw new UserMessageException("Заявка не найдена.");

            DataRow r = dt.Rows[0];
            int owner = Convert.ToInt32(r["user_id"]);
            int status = Convert.ToInt32(r["status_id"]);
            if (owner != Session.UserId)
                throw new UserMessageException("Получить результат можно только по своей заявке.");
            if (status == 5)
                throw new UserMessageException("Результат по этой заявке уже получен.");
            if (status != 2 && status != 3)
                throw new UserMessageException("Заявка ещё не принята менеджером или была отклонена. Получить результат пока нельзя.");

            int cid = Convert.ToInt32(Db.Scalar(c, tx,
                "INSERT INTO contacts(last_name, first_name, group_id, created_by) " +
                "VALUES (@l, @f, @g, @me) RETURNING id",
                ("l", Convert.ToString(r["last_name"])), ("f", Convert.ToString(r["first_name"])),
                ("g", Convert.ToInt32(r["group_id"])), ("me", owner)));
            Db.Exec(c, tx,
                "INSERT INTO phones(contact_id, phone_type_id, number) " +
                "VALUES (@cid, (SELECT id FROM phone_types ORDER BY id LIMIT 1), @num)",
                ("cid", cid), ("num", Convert.ToString(r["phone"])));
            Db.Exec(c, tx, "UPDATE contact_requests SET status_id = 5 WHERE id = @id", ("id", id.Value));
            tx.Commit();

            Ui.Info("Заявка выполнена: контакт добавлен в телефонную книгу.");
            Reload();
        });
    }
}

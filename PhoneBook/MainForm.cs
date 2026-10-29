using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Windows.Forms;
using ClosedXML.Excel;

public class MainForm : Form
{
    public bool LoggedOut;

    TextBox tbSearch;
    ComboBox cbGroup, cbType, cbSort1, cbSort2;
    DataGridView grid;
    Label lblCount;
    DataTable table;

    static readonly Dictionary<string, string> Sorts = new Dictionary<string, string>
    {
        ["Фамилия: А–Я"] = "c.last_name ASC, c.first_name ASC",
        ["Фамилия: Я–А"] = "c.last_name DESC, c.first_name DESC",
        ["Имя: А–Я"] = "c.first_name ASC",
        ["Группа"] = "g.name ASC",
        ["Номер телефона"] = "(SELECT min(p.number) FROM phones p WHERE p.contact_id = c.id) ASC NULLS LAST",
        ["Новые сначала"] = "c.id DESC"
    };

    public MainForm()
    {
        Text = "Телефонная книга — " + Session.FullName + " (" + Session.Role + ")";
        Width = 1100; Height = 650;
        StartPosition = FormStartPosition.CenterScreen;

        var top = new Panel { Dock = DockStyle.Top, Height = 105 };
        var bottom = new FlowLayoutPanel { Dock = DockStyle.Bottom, Height = 50, Padding = new Padding(8, 8, 0, 0) };
        grid = Ui.Grid();

        tbSearch = new TextBox();
        cbGroup = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList };
        cbType = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList };
        cbSort1 = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList };
        cbSort2 = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList };

        Place(top, "Поиск (фамилия, имя, номер)", tbSearch, 10, 8, 240);
        Place(top, "Группа", cbGroup, 260, 8, 150);
        Place(top, "Тип телефона", cbType, 420, 8, 150);
        Place(top, "Сортировка 1", cbSort1, 10, 52, 240);
        Place(top, "Сортировка 2", cbSort2, 260, 52, 240);
        Ui.Btn(top, "Найти", 510, 68, 90, () => Ui.Try(Reload));
        Ui.Btn(top, "Сбросить", 610, 68, 90, ResetFilters);
        lblCount = new Label { Left = 720, Top = 75, Width = 250, Height = 20 };
        top.Controls.Add(lblCount);

        tbSearch.KeyDown += (s, e) =>
        {
            if (e.KeyCode == Keys.Enter) { e.SuppressKeyPress = true; Ui.Try(Reload); }
        };

        string role = Session.Role;
        var bCreate = Ui.Btn(bottom, "Создать", 0, 0, 100, Create);
        var bEdit = Ui.Btn(bottom, "Изменить", 0, 0, 100, Edit);
        var bDelete = Ui.Btn(bottom, "Удалить", 0, 0, 100, Delete);
        Ui.Btn(bottom, "Заявки", 0, 0, 100, OpenRequests);
        var bReport = Ui.Btn(bottom, "Отчёт Excel", 0, 0, 110, Report);
        var bUsers = Ui.Btn(bottom, "Пользователи", 0, 0, 120, OpenUsers);
        Ui.Btn(bottom, "Выйти", 0, 0, 90, () => { LoggedOut = true; Close(); });

        bCreate.Visible = role != "Пользователь";
        bEdit.Visible = role != "Пользователь";
        bDelete.Visible = role == "Администратор";
        bReport.Visible = role != "Пользователь";
        bUsers.Visible = role == "Администратор";

        Controls.Add(grid);
        Controls.Add(top);
        Controls.Add(bottom);
        grid.BringToFront();

        Load += (s, e) => Ui.Try(Init);
    }

    static void Place(Panel p, string label, Control c, int x, int y, int w)
    {
        p.Controls.Add(new Label { Text = label, Left = x, Top = y, Width = w, Height = 18 });
        c.Left = x; c.Top = y + 18; c.Width = w;
        p.Controls.Add(c);
    }

    void FillCombo(ComboBox cb, string sql)
    {
        cb.Items.Clear();
        cb.Items.Add(new Item(0, "Все"));
        foreach (var it in Ui.LoadItems(sql)) cb.Items.Add(it);
        cb.SelectedIndex = 0;
    }

    void Init()
    {
        FillCombo(cbGroup, "SELECT id, name FROM contact_groups ORDER BY id");
        FillCombo(cbType, "SELECT id, name FROM phone_types ORDER BY id");
        foreach (var cb in new[] { cbSort1, cbSort2 })
        {
            cb.Items.Add("— нет —");
            foreach (var k in Sorts.Keys) cb.Items.Add(k);
            cb.SelectedIndex = 0;
        }
        cbSort1.SelectedItem = "Фамилия: А–Я";
        Reload();
    }

    void ResetFilters()
    {
        tbSearch.Text = "";
        cbGroup.SelectedIndex = 0;
        cbType.SelectedIndex = 0;
        cbSort1.SelectedItem = "Фамилия: А–Я";
        cbSort2.SelectedIndex = 0;
        Ui.Try(Reload);
    }

    void Reload()
    {
        var where = new List<string> { "TRUE" };
        var ps = new List<(string, object)>();

        string search = tbSearch.Text.Trim();
        if (search.Length > 0)
        {
            where.Add("(c.last_name ILIKE @search OR c.first_name ILIKE @search OR EXISTS " +
                      "(SELECT 1 FROM phones p WHERE p.contact_id = c.id AND p.number LIKE @search))");
            ps.Add(("search", "%" + Ui.LikeEscape(search) + "%"));
        }
        if (cbGroup.SelectedItem is Item gi && gi.Id != 0) { where.Add("c.group_id = @grp"); ps.Add(("grp", gi.Id)); }
        if (cbType.SelectedItem is Item ti && ti.Id != 0)
        {
            where.Add("EXISTS (SELECT 1 FROM phones p WHERE p.contact_id = c.id AND p.phone_type_id = @typ)");
            ps.Add(("typ", ti.Id));
        }

        var order = new List<string>();
        foreach (var cb in new[] { cbSort1, cbSort2 })
            if (cb.SelectedItem is string key && Sorts.ContainsKey(key)) order.Add(Sorts[key]);
        order.Add("c.id");

        string sql =
            "SELECT c.id AS \"ID\", c.last_name AS \"Фамилия\", c.first_name AS \"Имя\", g.name AS \"Группа\", " +
            "(SELECT string_agg(p.number, ', ' ORDER BY p.id) FROM phones p WHERE p.contact_id = c.id) AS \"Телефоны\", " +
            "u.full_name AS \"Добавил\" " +
            "FROM contacts c " +
            "JOIN contact_groups g ON g.id = c.group_id " +
            "JOIN users u ON u.id = c.created_by " +
            "WHERE " + string.Join(" AND ", where) +
            " ORDER BY " + string.Join(", ", order);

        table = Db.Query(sql, ps.ToArray());
        grid.DataSource = table;
        lblCount.Text = "Найдено контактов: " + table.Rows.Count;
    }

    int? SelectedId()
    {
        if (grid.CurrentRow == null)
        {
            Ui.Info("Выберите контакт в таблице.");
            return null;
        }
        return Convert.ToInt32(grid.CurrentRow.Cells["ID"].Value);
    }

    void Create()
    {
        Ui.Try(() =>
        {
            using var f = new ContactEditForm(null);
            if (f.ShowDialog(this) == DialogResult.OK) Reload();
        });
    }

    void Edit()
    {
        var id = SelectedId();
        if (id == null) return;
        Ui.Try(() =>
        {
            using var f = new ContactEditForm(id);
            if (f.ShowDialog(this) == DialogResult.OK) Reload();
        });
    }

    void Delete()
    {
        var id = SelectedId();
        if (id == null) return;
        if (!Ui.Confirm("Удалить контакт №" + id + " вместе с его телефонами?")) return;
        Ui.Try(() =>
        {
            int n = Db.Exec("DELETE FROM contacts WHERE id = @id", ("id", id.Value));
            if (n == 0)
                throw new UserMessageException("Контакт уже удалён.");
            Reload();
        });
    }

    void OpenRequests()
    {
        Ui.Try(() =>
        {
            using var f = new RequestsForm();
            f.ShowDialog(this);
            Reload();
        });
    }

    void Report()
    {
        if (table == null || table.Rows.Count == 0)
        {
            Ui.Info("Нет данных для отчёта.");
            return;
        }
        using var dlg = new SaveFileDialog
        {
            Filter = "Excel (*.xlsx)|*.xlsx",
            FileName = "Отчёт по контактам " + DateTime.Now.ToString("yyyy-MM-dd") + ".xlsx"
        };
        if (dlg.ShowDialog() != DialogResult.OK) return;

        Ui.Try(() =>
        {
            using var wb = new XLWorkbook();
            var ws = wb.Worksheets.Add("Контакты");
            for (int c = 0; c < table.Columns.Count; c++)
            {
                ws.Cell(1, c + 1).Value = table.Columns[c].ColumnName;
                ws.Cell(1, c + 1).Style.Font.Bold = true;
            }
            for (int r = 0; r < table.Rows.Count; r++)
                for (int c = 0; c < table.Columns.Count; c++)
                {
                    object v = table.Rows[r][c];
                    if (v == DBNull.Value) continue;
                    ws.Cell(r + 2, c + 1).Value = Convert.ToString(v);
                }

            var st = wb.Worksheets.Add("Статистика");
            st.Cell(1, 1).Value = "Группа";
            st.Cell(1, 2).Value = "Количество контактов";
            st.Cell(1, 1).Style.Font.Bold = true;
            st.Cell(1, 2).Style.Font.Bold = true;
            int row = 2;
            foreach (var g in table.AsEnumerable()
                         .GroupBy(x => Convert.ToString(x["Группа"]))
                         .OrderByDescending(grp => grp.Count()))
            {
                st.Cell(row, 1).Value = g.Key;
                st.Cell(row, 2).Value = g.Count();
                row++;
            }

            ws.Columns().AdjustToContents();
            st.Columns().AdjustToContents();
            wb.SaveAs(dlg.FileName);
            Ui.Info("Отчёт сохранён.");
        });
    }

    void OpenUsers()
    {
        using var f = new UsersForm();
        f.ShowDialog(this);
    }
}

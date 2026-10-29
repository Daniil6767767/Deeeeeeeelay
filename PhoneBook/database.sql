DROP TABLE IF EXISTS contact_requests, phones, contacts, users, request_statuses, phone_types, contact_groups, roles CASCADE;
DROP FUNCTION IF EXISTS prevent_id_change() CASCADE;
DROP DOMAIN IF EXISTS d_login, d_password_hash, d_full_name, d_name, d_phone;

CREATE DOMAIN d_login         AS VARCHAR(50)  CHECK (char_length(trim(VALUE)) >= 3);
CREATE DOMAIN d_password_hash AS VARCHAR(255) CHECK (char_length(VALUE) >= 8);
CREATE DOMAIN d_full_name     AS VARCHAR(100) CHECK (char_length(trim(VALUE)) > 0);
CREATE DOMAIN d_name          AS VARCHAR(50)  CHECK (char_length(trim(VALUE)) > 0);
CREATE DOMAIN d_phone         AS VARCHAR(16)  CHECK (VALUE ~ '^\+?[0-9]{10,15}$');

CREATE TABLE roles (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE contact_groups (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE phone_types (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE request_statuses (
    id   SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE users (
    id            SERIAL PRIMARY KEY,
    login         d_login         NOT NULL UNIQUE,
    password_hash d_password_hash NOT NULL,
    full_name     d_full_name     NOT NULL,
    role_id       INT NOT NULL REFERENCES roles(id)
);

CREATE TABLE contacts (
    id         SERIAL PRIMARY KEY,
    last_name  d_name NOT NULL,
    first_name d_name NOT NULL,
    group_id   INT NOT NULL REFERENCES contact_groups(id),
    created_by INT NOT NULL REFERENCES users(id)
);

CREATE TABLE phones (
    id            SERIAL PRIMARY KEY,
    contact_id    INT NOT NULL REFERENCES contacts(id) ON DELETE CASCADE,
    phone_type_id INT NOT NULL REFERENCES phone_types(id),
    number        d_phone NOT NULL,
    CONSTRAINT uq_phones_contact_number UNIQUE (contact_id, number)
);

CREATE TABLE contact_requests (
    id         SERIAL PRIMARY KEY,
    user_id    INT NOT NULL REFERENCES users(id),
    manager_id INT NULL REFERENCES users(id),
    admin_id   INT NULL REFERENCES users(id),
    status_id  INT NOT NULL DEFAULT 1 REFERENCES request_statuses(id),
    last_name  d_name NOT NULL,
    first_name d_name NOT NULL,
    phone      d_phone NOT NULL,
    group_id   INT NOT NULL REFERENCES contact_groups(id)
);

CREATE INDEX idx_contacts_name ON contacts (last_name, first_name);
CREATE INDEX idx_phones_number ON phones (number);

CREATE OR REPLACE FUNCTION prevent_id_change() RETURNS trigger AS $$
BEGIN
    IF to_jsonb(NEW)->>TG_ARGV[0] IS DISTINCT FROM to_jsonb(OLD)->>TG_ARGV[0] THEN
        RAISE EXCEPTION 'Изменение идентификатора (%) запрещено', TG_ARGV[0];
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_roles_id            BEFORE UPDATE ON roles            FOR EACH ROW EXECUTE FUNCTION prevent_id_change('id');
CREATE TRIGGER trg_contact_groups_id   BEFORE UPDATE ON contact_groups   FOR EACH ROW EXECUTE FUNCTION prevent_id_change('id');
CREATE TRIGGER trg_phone_types_id      BEFORE UPDATE ON phone_types      FOR EACH ROW EXECUTE FUNCTION prevent_id_change('id');
CREATE TRIGGER trg_request_statuses_id BEFORE UPDATE ON request_statuses FOR EACH ROW EXECUTE FUNCTION prevent_id_change('id');
CREATE TRIGGER trg_users_id            BEFORE UPDATE ON users            FOR EACH ROW EXECUTE FUNCTION prevent_id_change('id');
CREATE TRIGGER trg_contacts_id         BEFORE UPDATE ON contacts         FOR EACH ROW EXECUTE FUNCTION prevent_id_change('id');
CREATE TRIGGER trg_phones_id           BEFORE UPDATE ON phones           FOR EACH ROW EXECUTE FUNCTION prevent_id_change('id');
CREATE TRIGGER trg_contact_requests_id BEFORE UPDATE ON contact_requests FOR EACH ROW EXECUTE FUNCTION prevent_id_change('id');

INSERT INTO roles(name)            VALUES ('Администратор'), ('Менеджер'), ('Пользователь');
INSERT INTO contact_groups(name)   VALUES ('Семья'), ('Друзья'), ('Работа'), ('Клиенты'), ('Другое');
INSERT INTO phone_types(name)      VALUES ('Мобильный'), ('Рабочий'), ('Домашний');
INSERT INTO request_statuses(name) VALUES ('Новая'), ('Принята менеджером'), ('Изменена администратором'), ('Отклонена'), ('Выполнена');

INSERT INTO users(login, password_hash, full_name, role_id)
SELECT 'user' || i,
       md5('pass' || i),
       (ARRAY['Иванов','Петров','Сидоров','Смирнов','Кузнецов','Попов','Лебедев','Козлов'])[1 + i % 8]
         || ' ' || (ARRAY['Иван','Пётр','Алексей','Дмитрий','Сергей','Андрей'])[1 + i % 6],
       CASE WHEN i = 1 THEN 1 WHEN i <= 10 THEN 2 ELSE 3 END
FROM generate_series(1, 120) AS i;

INSERT INTO contacts(last_name, first_name, group_id, created_by)
SELECT (ARRAY['Иванов','Петров','Сидоров','Смирнов','Кузнецов','Попов','Лебедев','Козлов','Новиков','Морозов','Волков','Соколов','Павлов','Орлов','Егоров'])[1 + floor(random() * 15)::int],
       (ARRAY['Иван','Пётр','Алексей','Дмитрий','Сергей','Андрей','Михаил','Николай','Артём','Максим','Евгений','Олег','Роман','Антон','Кирилл'])[1 + floor(random() * 15)::int],
       1 + floor(random() * 5)::int,
       1 + floor(random() * 120)::int
FROM generate_series(1, 150);

INSERT INTO phones(contact_id, phone_type_id, number)
SELECT id, 1, '+79' || lpad(floor(random() * 1000000000)::bigint::text, 9, '0')
FROM contacts;

INSERT INTO phones(contact_id, phone_type_id, number)
SELECT id, 2 + floor(random() * 2)::int, '+79' || lpad(floor(random() * 1000000000)::bigint::text, 9, '0')
FROM contacts
WHERE random() < 0.4
ON CONFLICT DO NOTHING;

INSERT INTO contact_requests(user_id, manager_id, admin_id, status_id, last_name, first_name, phone, group_id)
SELECT author,
       CASE WHEN s > 1 THEN mgr END,
       CASE WHEN s = 3 THEN 1 END,
       s, ln, fn, ph, grp
FROM (
    SELECT 11 + floor(random() * 110)::int AS author,
           2 + floor(random() * 9)::int AS mgr,
           1 + floor(random() * 5)::int AS s,
           (ARRAY['Иванов','Петров','Сидоров','Смирнов','Кузнецов','Попов','Лебедев','Козлов','Новиков','Морозов','Волков','Соколов','Павлов','Орлов','Егоров'])[1 + floor(random() * 15)::int] AS ln,
           (ARRAY['Иван','Пётр','Алексей','Дмитрий','Сергей','Андрей','Михаил','Николай','Артём','Максим','Евгений','Олег','Роман','Антон','Кирилл'])[1 + floor(random() * 15)::int] AS fn,
           '+79' || lpad(floor(random() * 1000000000)::bigint::text, 9, '0') AS ph,
           1 + floor(random() * 5)::int AS grp
    FROM generate_series(1, 100)
    OFFSET 0
) t;

SELECT 'users' AS таблица, count(*) AS записей FROM users
UNION ALL SELECT 'contacts', count(*) FROM contacts
UNION ALL SELECT 'phones', count(*) FROM phones
UNION ALL SELECT 'contact_requests', count(*) FROM contact_requests;

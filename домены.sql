DROP TABLE IF EXISTS task_history, tasks, categories, priorities, statuses CASCADE;

DROP TABLE IF EXISTS contact_requests CASCADE;
DROP TABLE IF EXISTS phones           CASCADE;
DROP TABLE IF EXISTS contacts         CASCADE;
DROP TABLE IF EXISTS users            CASCADE;
DROP TABLE IF EXISTS request_statuses CASCADE;
DROP TABLE IF EXISTS phone_types      CASCADE;
DROP TABLE IF EXISTS contact_groups   CASCADE;
DROP TABLE IF EXISTS roles            CASCADE;
DROP DOMAIN IF EXISTS d_login, d_password_hash, d_full_name, d_name, d_phone;
DROP FUNCTION IF EXISTS prevent_id_change();

CREATE DOMAIN d_login         AS VARCHAR(50)  CHECK (char_length(trim(VALUE)) >= 3);
CREATE DOMAIN d_password_hash AS VARCHAR(255) CHECK (char_length(VALUE) >= 32);
CREATE DOMAIN d_full_name     AS VARCHAR(100) CHECK (char_length(trim(VALUE)) > 0);
CREATE DOMAIN d_name          AS VARCHAR(50)  CHECK (char_length(trim(VALUE)) > 0);
CREATE DOMAIN d_phone         AS VARCHAR(16)  CHECK (VALUE ~ '^\+?[0-9]{10,15}$');

CREATE TABLE roles (
    id   SERIAL      PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE contact_groups (
    id   SERIAL      PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE phone_types (
    id   SERIAL      PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE request_statuses (
    id   SERIAL      PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE users (
    id            SERIAL       PRIMARY KEY,
    login         d_login         NOT NULL UNIQUE,
    password_hash d_password_hash NOT NULL,
    full_name     d_full_name     NOT NULL,
    role_id       INT          NOT NULL REFERENCES roles (id)
);

CREATE TABLE contacts (
    id         SERIAL      PRIMARY KEY,
    last_name  d_name      NOT NULL,
    first_name d_name      NOT NULL,
    group_id   INT         NOT NULL REFERENCES contact_groups (id),
    created_by INT         NOT NULL REFERENCES users (id)
);

CREATE TABLE phones (
    id            SERIAL      PRIMARY KEY,
    contact_id    INT         NOT NULL REFERENCES contacts (id) ON DELETE CASCADE,
    phone_type_id INT         NOT NULL REFERENCES phone_types (id),
    number        d_phone     NOT NULL,
    UNIQUE (contact_id, number)
);

CREATE TABLE contact_requests (
    id         SERIAL      PRIMARY KEY,
    user_id    INT         NOT NULL REFERENCES users (id),
    manager_id INT         REFERENCES users (id),
    admin_id   INT         REFERENCES users (id),
    status_id  INT         NOT NULL DEFAULT 1 REFERENCES request_statuses (id),
    last_name  d_name      NOT NULL,
    first_name d_name      NOT NULL,
    phone      d_phone     NOT NULL,
    group_id   INT         NOT NULL REFERENCES contact_groups (id)
);

CREATE INDEX idx_contacts_name  ON contacts (last_name, first_name);
CREATE INDEX idx_phones_number  ON phones (number);

CREATE FUNCTION prevent_id_change() RETURNS trigger AS $$
BEGIN
    IF NEW.id <> OLD.id THEN
        RAISE EXCEPTION 'Изменять id запрещено (таблица %)', TG_TABLE_NAME;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_roles_id            BEFORE UPDATE OF id ON roles            FOR EACH ROW EXECUTE FUNCTION prevent_id_change();
CREATE TRIGGER trg_contact_groups_id   BEFORE UPDATE OF id ON contact_groups   FOR EACH ROW EXECUTE FUNCTION prevent_id_change();
CREATE TRIGGER trg_phone_types_id      BEFORE UPDATE OF id ON phone_types      FOR EACH ROW EXECUTE FUNCTION prevent_id_change();
CREATE TRIGGER trg_request_statuses_id BEFORE UPDATE OF id ON request_statuses FOR EACH ROW EXECUTE FUNCTION prevent_id_change();
CREATE TRIGGER trg_users_id            BEFORE UPDATE OF id ON users            FOR EACH ROW EXECUTE FUNCTION prevent_id_change();
CREATE TRIGGER trg_contacts_id         BEFORE UPDATE OF id ON contacts         FOR EACH ROW EXECUTE FUNCTION prevent_id_change();
CREATE TRIGGER trg_phones_id           BEFORE UPDATE OF id ON phones           FOR EACH ROW EXECUTE FUNCTION prevent_id_change();


CREATE TRIGGER trg_contact_requests_id BEFORE UPDATE OF id ON contact_requests FOR EACH ROW EXECUTE FUNCTION prevent_id_change();

INSERT INTO roles (name) VALUES ('Администратор'), ('Менеджер'), ('Пользователь');
INSERT INTO contact_groups (name) VALUES ('Семья'), ('Друзья'), ('Работа'), ('Клиенты'), ('Другое');
INSERT INTO phone_types (name) VALUES ('Мобильный'), ('Рабочий'), ('Домашний');
INSERT INTO request_statuses (name) VALUES ('Новая'), ('Принята менеджером'), ('Изменена администратором'), ('Отклонена'), ('Выполнена');

INSERT INTO users (login, password_hash, full_name, role_id)
VALUES ('admin', encode(sha256('123456'::bytea), 'hex'), 'Администратор Системы', 1);

INSERT INTO users (login, password_hash, full_name, role_id)
SELECT 'manager' || g, encode(sha256('123456'::bytea), 'hex'), 'Менеджер ' || g, 2
FROM generate_series(1, 4) g;

WITH n AS (
    SELECT
        ARRAY['Иванов','Петров','Сидоров','Смирнов','Кузнецов','Попов','Васильев','Соколов','Михайлов','Новиков',
              'Фёдоров','Морозов','Волков','Алексеев','Лебедев','Семёнов','Егоров','Павлов','Козлов','Степанов'] AS fam,
        ARRAY['Александр','Дмитрий','Максим','Сергей','Андрей','Алексей','Артём','Илья','Кирилл','Михаил',
              'Анна','Мария','Елена','Ольга','Наталья','Екатерина','Татьяна','Ирина','Юлия','Светлана'] AS im
)
INSERT INTO users (login, password_hash, full_name, role_id)
SELECT 'user' || g,
       encode(sha256('123456'::bytea), 'hex'),
       n.fam[1 + floor(random() * 20)::int] || ' ' || n.im[1 + floor(random() * 20)::int],
       3
FROM generate_series(1, 95) g, n;

WITH n AS (
    SELECT
        ARRAY['Иванов','Петров','Сидоров','Смирнов','Кузнецов','Попов','Васильев','Соколов','Михайлов','Новиков',
              'Фёдоров','Морозов','Волков','Алексеев','Лебедев','Семёнов','Егоров','Павлов','Козлов','Степанов'] AS fam,
        ARRAY['Александр','Дмитрий','Максим','Сергей','Андрей','Алексей','Артём','Илья','Кирилл','Михаил',
              'Анна','Мария','Елена','Ольга','Наталья','Екатерина','Татьяна','Ирина','Юлия','Светлана'] AS im,
        (SELECT array_agg(id) FROM users) AS uid
)
INSERT INTO contacts (last_name, first_name, group_id, created_by)
SELECT n.fam[1 + floor(random() * 20)::int],
       n.im[1 + floor(random() * 20)::int],
       1 + floor(random() * 5)::int,
       n.uid[1 + floor(random() * array_length(n.uid, 1))::int]
FROM generate_series(1, 120) g, n;

INSERT INTO phones (contact_id, phone_type_id, number)
SELECT id, 1, '+79' || lpad(floor(random() * 1000000000)::bigint::text, 9, '0')
FROM contacts;

INSERT INTO phones (contact_id, phone_type_id, number)
SELECT id, 2 + floor(random() * 2)::int, '+79' || lpad(floor(random() * 1000000000)::bigint::text, 9, '0')
FROM contacts
WHERE random() < 0.35
ON CONFLICT DO NOTHING;

WITH n AS (
    SELECT
        ARRAY['Иванов','Петров','Сидоров','Смирнов','Кузнецов','Попов','Васильев','Соколов','Михайлов','Новиков',
              'Фёдоров','Морозов','Волков','Алексеев','Лебедев','Семёнов','Егоров','Павлов','Козлов','Степанов'] AS fam,
        ARRAY['Александр','Дмитрий','Максим','Сергей','Андрей','Алексей','Артём','Илья','Кирилл','Михаил',
              'Анна','Мария','Елена','Ольга','Наталья','Екатерина','Татьяна','Ирина','Юлия','Светлана'] AS im,
        (SELECT array_agg(id) FROM users WHERE role_id = 3) AS u,
        (SELECT array_agg(id) FROM users WHERE role_id = 2) AS m,
        (SELECT min(id) FROM users WHERE role_id = 1)       AS a
)
INSERT INTO contact_requests (user_id, manager_id, admin_id, status_id, last_name, first_name, phone, group_id)
SELECT s.uid,
       CASE WHEN s.st > 1 THEN s.mid END,
       CASE WHEN s.st = 3 THEN s.aid END,
       s.st, s.fam, s.im, s.ph, s.grp
FROM (
    SELECT n.u[1 + floor(random() * array_length(n.u, 1))::int] AS uid,
           n.m[1 + floor(random() * array_length(n.m, 1))::int] AS mid,
           n.a AS aid,
           1 + floor(random() * 5)::int AS st,
           n.fam[1 + floor(random() * 20)::int] AS fam,
n.im[1 + floor(random() * 20)::int] AS im,
           '+79' || lpad(floor(random() * 1000000000)::bigint::text, 9, '0') AS ph,
           1 + floor(random() * 5)::int AS grp
    FROM generate_series(1, 100) g, n
) s;

SELECT 'users' AS таблица, count(*) AS записей FROM users
UNION ALL SELECT 'contacts', count(*) FROM contacts
UNION ALL SELECT 'phones', count(*) FROM phones
UNION ALL SELECT 'contact_requests', count(*) FROM contact_requests;
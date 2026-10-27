DROP TABLE IF EXISTS contact_requests CASCADE;
DROP TABLE IF EXISTS phones           CASCADE;
DROP TABLE IF EXISTS contacts         CASCADE;
DROP TABLE IF EXISTS users            CASCADE;
DROP TABLE IF EXISTS request_statuses CASCADE;
DROP TABLE IF EXISTS phone_types      CASCADE;
DROP TABLE IF EXISTS contact_groups   CASCADE;
DROP TABLE IF EXISTS roles            CASCADE;
DROP FUNCTION IF EXISTS prevent_id_change();

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
    login         VARCHAR(50)  NOT NULL UNIQUE CHECK (char_length(login) >= 3),
    password_hash VARCHAR(255) NOT NULL,
    full_name     VARCHAR(100) NOT NULL,
    role_id       INT          NOT NULL REFERENCES roles (id)
);

CREATE TABLE contacts (
    id         SERIAL      PRIMARY KEY,
    last_name  VARCHAR(50) NOT NULL CHECK (btrim(last_name) <> ''),
    first_name VARCHAR(50) NOT NULL CHECK (btrim(first_name) <> ''),
    group_id   INT         NOT NULL REFERENCES contact_groups (id),
    created_by INT         NOT NULL REFERENCES users (id)
);

CREATE TABLE phones (
    id            SERIAL      PRIMARY KEY,
    contact_id    INT         NOT NULL REFERENCES contacts (id) ON DELETE CASCADE,
    phone_type_id INT         NOT NULL REFERENCES phone_types (id),
    number        VARCHAR(16) NOT NULL CHECK (number ~ '^\+?[0-9]{10,15}$'),
    UNIQUE (contact_id, number)
);

CREATE TABLE contact_requests (
    id         SERIAL      PRIMARY KEY,
    user_id    INT         NOT NULL REFERENCES users (id),
    manager_id INT         REFERENCES users (id),
    admin_id   INT         REFERENCES users (id),
    status_id  INT         NOT NULL DEFAULT 1 REFERENCES request_statuses (id),
    last_name  VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    phone      VARCHAR(16) NOT NULL CHECK (phone ~ '^\+?[0-9]{10,15}$'),
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
DROP TABLE IF EXISTS task_history, tasks, categories, priorities, statuses CASCADE;
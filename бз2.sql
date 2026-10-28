DELETE FROM contact_requests WHERE last_name = 'Заявкин';
DELETE FROM contacts WHERE last_name IN ('Тестов', 'Заявкин', 'Удалов');
DELETE FROM users WHERE login = 'newuser';

SELECT 1 FROM users WHERE login = 'newuser';

INSERT INTO users (login, password_hash, full_name, role_id)
VALUES ('newuser', '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92',
        'Новый Пользователь', (SELECT id FROM roles WHERE name = 'Пользователь'))
RETURNING id;

SELECT u.id, u.full_name, r.name AS role
FROM users u
JOIN roles r ON r.id = u.role_id
WHERE u.login = 'newuser'
  AND u.password_hash = '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92';

SELECT c.id, c.last_name, c.first_name, g.name AS group_name,
       string_agg(p.number, ', ' ORDER BY p.id) AS phones
FROM contacts c
JOIN contact_groups g ON g.id = c.group_id
LEFT JOIN phones p ON p.contact_id = c.id
GROUP BY c.id, g.name
ORDER BY c.last_name, c.first_name
LIMIT 20;

SELECT r.id, u.full_name AS author, r.last_name, r.first_name, r.phone, g.name AS group_name
FROM contact_requests r
JOIN users u ON u.id = r.user_id
JOIN contact_groups g ON g.id = r.group_id
WHERE r.status_id = 1
ORDER BY r.id
LIMIT 20;

SELECT u.id, u.login, u.full_name, r.name AS role
FROM users u
JOIN roles r ON r.id = u.role_id
ORDER BY u.id
LIMIT 20;

WITH upd AS (
    UPDATE users
    SET role_id = (SELECT id FROM roles WHERE name = 'Менеджер')
    WHERE login = 'newuser'
    RETURNING id, login, role_id
)
SELECT upd.id, upd.login, r.name AS role
FROM upd
JOIN roles r ON r.id = upd.role_id;

SELECT id, name FROM roles ORDER BY id;
SELECT id, name FROM contact_groups ORDER BY id;
SELECT id, name FROM phone_types ORDER BY id;
SELECT id, name FROM request_statuses ORDER BY id;

WITH new_contact AS (
    INSERT INTO contacts (last_name, first_name, group_id, created_by)
    VALUES ('Тестов', 'Тест',
            (SELECT min(id) FROM contact_groups),
            (SELECT id FROM users WHERE login = 'admin'))
    RETURNING id
)
INSERT INTO phones (contact_id, phone_type_id, number)
SELECT id, (SELECT min(id) FROM phone_types), '+79001234567'
FROM new_contact
RETURNING contact_id, number;

SELECT c.id, c.last_name, c.first_name, g.name AS group_name,
       string_agg(p.number, ', ' ORDER BY p.id) AS phones
FROM contacts c
JOIN contact_groups g ON g.id = c.group_id
LEFT JOIN phones p ON p.contact_id = c.id
WHERE c.last_name = 'Тестов'
GROUP BY c.id, g.name;

UPDATE contacts
SET first_name = 'Тимофей',
    group_id = (SELECT id FROM contact_groups WHERE name = 'Работа')
WHERE last_name = 'Тестов'
RETURNING id, last_name, first_name, group_id;

UPDATE phones
SET number = '+79007654321'
WHERE contact_id = (SELECT id FROM contacts WHERE last_name = 'Тестов')
RETURNING id, contact_id, number;

INSERT INTO contacts (last_name, first_name, group_id, created_by)
VALUES ('Удалов', 'Тест', (SELECT min(id) FROM contact_groups), (SELECT id FROM users WHERE login = 'admin'));

DELETE FROM contacts
WHERE last_name = 'Удалов'
RETURNING id, last_name, first_name;

SELECT c.id, c.last_name, c.first_name, g.name AS group_name,
       string_agg(p.number, ', ' ORDER BY p.id) AS phones
FROM contacts c
JOIN contact_groups g ON g.id = c.group_id
LEFT JOIN phones p ON p.contact_id = c.id
WHERE (c.last_name ILIKE '%ов%' OR c.first_name ILIKE '%а%' OR p.number LIKE '%900%')
  AND c.group_id = (SELECT min(id) FROM contact_groups)
GROUP BY c.id, g.name
ORDER BY g.name, c.last_name, c.first_name;

INSERT INTO contact_requests (user_id, last_name, first_name, phone, group_id)
VALUES ((SELECT id FROM users WHERE login = 'user1'), 'Заявкин', 'Тест', '+79005556677',
        (SELECT min(id) FROM contact_groups))
RETURNING id, status_id;

UPDATE contact_requests
SET manager_id = (SELECT id FROM users WHERE login = 'manager1'), status_id = 2
WHERE last_name = 'Заявкин' AND status_id = 1
RETURNING id, status_id, manager_id;

UPDATE contact_requests
SET first_name = 'Тимур', admin_id = (SELECT id FROM users WHERE login = 'admin'), status_id = 3
WHERE last_name = 'Заявкин' AND status_id = 2
RETURNING id, first_name, status_id, admin_id;

WITH r AS (
    SELECT * FROM contact_requests
    WHERE last_name = 'Заявкин' AND status_id IN (2, 3)
), new_contact AS (
    INSERT INTO contacts (last_name, first_name, group_id, created_by)
    SELECT last_name, first_name, group_id, user_id FROM r
    RETURNING id
), new_phone AS (
    INSERT INTO phones (contact_id, phone_type_id, number)
    SELECT nc.id, 1, r.phone FROM new_contact nc, r
    RETURNING contact_id
)
UPDATE contact_requests
SET status_id = 5
WHERE id IN (SELECT id FROM r)
RETURNING id, status_id;

SELECT r.id, r.last_name, r.first_name, r.phone, s.name AS status,
       m.full_name AS manager, a.full_name AS admin
FROM contact_requests r
JOIN request_statuses s ON s.id = r.status_id
LEFT JOIN users m ON m.id = r.manager_id
LEFT JOIN users a ON a.id = r.admin_id
WHERE r.last_name = 'Заявкин';

SELECT c.id, c.last_name, c.first_name, p.number
FROM contacts c
JOIN phones p ON p.contact_id = c.id
WHERE c.last_name = 'Заявкин';

SELECT g.name AS group_name, count(c.id) AS contacts_count
FROM contact_groups g
LEFT JOIN contacts c ON c.group_id = g.id
GROUP BY g.name
ORDER BY contacts_count DESC;

SELECT s.name AS status, count(r.id) AS requests_count
FROM request_statuses s
LEFT JOIN contact_requests r ON r.status_id = s.id
GROUP BY s.name
ORDER BY s.name;

SELECT u.full_name, count(c.id) AS contacts_count
FROM users u
LEFT JOIN contacts c ON c.created_by = u.id
GROUP BY u.full_name
ORDER BY contacts_count DESC
LIMIT 10;

SELECT c.id, c.last_name, c.first_name, count(p.id) AS phones_count
FROM contacts c
LEFT JOIN phones p ON p.contact_id = c.id
GROUP BY c.id
HAVING count(p.id) > 1
ORDER BY phones_count DESC, c.last_name
LIMIT 20;
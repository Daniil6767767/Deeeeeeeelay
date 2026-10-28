SELECT id, name
FROM roles
WHERE name = 'Менеджер';

SELECT id, login
FROM users
WHERE login IN ('admin', 'newuser');

WITH upd AS (
    UPDATE users
    SET role_id = (
        SELECT MIN(id)
        FROM roles
        WHERE name = 'Менеджер'
    )
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
    VALUES (
        'Тестов',
        'Тест',
        (SELECT MIN(id) FROM contact_groups),
        (SELECT MIN(id) FROM users WHERE login = 'admin')
    )
    RETURNING id
)
INSERT INTO phones (contact_id, phone_type_id, number)
SELECT
    id,
    (SELECT MIN(id) FROM phone_types),
    '+79001234567'
FROM new_contact
RETURNING contact_id, number;
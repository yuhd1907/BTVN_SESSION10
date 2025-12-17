CREATE TABLE employees (
                           id SERIAL PRIMARY KEY,
                           name VARCHAR(100),
                           position VARCHAR(50),
                           salary NUMERIC
);

CREATE TABLE employees_log (
                               log_id SERIAL PRIMARY KEY,
                               employee_id INT,
                               operation VARCHAR(10),
                               old_data JSONB,
                               new_data JSONB,
                               change_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_employee_changes()
    RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO employees_log(employee_id, operation, old_data, new_data)
        VALUES (NEW.id, 'INSERT', NULL, row_to_json(NEW));
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO employees_log(employee_id, operation, old_data, new_data)
        VALUES (NEW.id, 'UPDATE', row_to_json(OLD), row_to_json(NEW));
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO employees_log(employee_id, operation, old_data, new_data)
        VALUES (OLD.id, 'DELETE', row_to_json(OLD), NULL);
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_audit_employees
    AFTER INSERT OR UPDATE OR DELETE ON employees
    FOR EACH ROW
EXECUTE FUNCTION log_employee_changes();

INSERT INTO employees (name, position, salary) VALUES ('Nguyen Van A', 'Dev', 1000);
UPDATE employees SET salary = 2000 WHERE id = 1;
DELETE FROM employees WHERE id = 1;

SELECT * FROM employees_log;
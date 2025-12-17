CREATE TABLE products (
                          id SERIAL PRIMARY KEY,
                          name VARCHAR(100),
                          stock INT
);

CREATE TABLE orders (
                        id SERIAL PRIMARY KEY,
                        product_id INT REFERENCES products(id),
                        quantity INT
);

INSERT INTO products (name, stock) VALUES ('iPhone 15', 100);

CREATE OR REPLACE FUNCTION update_inventory()
    RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE products
        SET stock = stock - NEW.quantity
        WHERE id = NEW.product_id;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE products
        SET stock = stock + OLD.quantity
        WHERE id = OLD.product_id;
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE products
        SET stock = stock + OLD.quantity
        WHERE id = OLD.product_id;

        UPDATE products
        SET stock = stock - NEW.quantity
        WHERE id = NEW.product_id;
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_manage_stock
    AFTER INSERT OR UPDATE OR DELETE ON orders
    FOR EACH ROW
EXECUTE FUNCTION update_inventory();

INSERT INTO orders (product_id, quantity) VALUES (1, 10);
UPDATE orders SET quantity = 5 WHERE id = 1;
DELETE FROM orders WHERE id = 1;

SELECT * FROM products;
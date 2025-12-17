create schema ex2;
set search_path to ex2;
-- Tạo bảng customers
CREATE TABLE customers
(
    id           SERIAL PRIMARY KEY,
    name         VARCHAR(100)   NOT NULL,
    credit_limit DECIMAL(12, 2) NOT NULL
);
-- Tạo bảng orders
CREATE TABLE orders
(
    id           SERIAL PRIMARY KEY,
    customer_id  INT            NOT NULL,
    order_amount DECIMAL(12, 2) NOT NULL,
    CONSTRAINT fk_customer
        FOREIGN KEY (customer_id)
            REFERENCES customers (id)
);
-- Nhập dữ liệu vào 2 bảng customers và orders
INSERT INTO customers (name, credit_limit)
VALUES ('Nguyễn Văn An', 5000000),
       ('Trần Thị Bình', 8000000),
       ('Lê Văn Cường', 3000000),
       ('Phạm Thị Dung', 10000000),
       ('Hoàng Văn Em', 6000000);
INSERT INTO orders (customer_id, order_amount)
VALUES (1, 1200000),
       (1, 2500000),
       (2, 4000000),
       (3, 1500000),
       (4, 7000000),
       (5, 2000000),
       (2, 1800000);
-- Viết function check_credit_limit() để kiểm tra tổng giá trị đơn hàng của khách hàng trước khi insert đơn mới. Nếu vượt hạn mức, raise exception
create or replace function check_credit_limit()
    returns trigger
    language plpgsql
as
$$
declare
    f_credit_limit decimal(12, 2);
    total_amount   decimal(12, 2);
begin
    select sum(order_amount) into total_amount from orders where customer_id = new.customer_id;
    select credit_limit into f_credit_limit from customers where id = new.customer_id;
    if total_amount + new.order_amount > f_credit_limit then
        raise exception 'Vuợt hạn mức';
    end if;
    return new;
end;
$$;
-- Tạo Trigger trg_check_credit gắn với bảng orders để gọi Function trước khi insert
create or replace trigger trg_check_credit
    before insert
    on orders
    for each row
execute function check_credit_limit();

INSERT INTO orders (customer_id, order_amount)
VALUES (1, 2000000);
INSERT INTO orders (customer_id, order_amount)
VALUES (3, 1000000);




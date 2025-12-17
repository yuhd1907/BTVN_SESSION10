create database session10;

create schema ex1;
set search_path to ex1;

create table products
(
    id            serial primary key,
    name          varchar(100)   not null,
    price         decimal(10, 2) not null,
    last_modified date           not null
);

INSERT INTO products (name, price, last_modified)
VALUES ('Laptop Dell Inspiron 15', 18500000.00, '2024-12-01'),
       ('Chuột không dây Logitech', 450000.00, '2024-11-20'),
       ('Bàn phím cơ Keychron K6', 2100000.00, '2024-11-25'),
       ('Màn hình Samsung 24 inch', 3200000.00, '2024-12-05'),
       ('Tai nghe Sony WH-1000XM4', 6900000.00, '2024-10-18'),
       ('Ổ cứng SSD Samsung 1TB', 2650000.00, '2024-11-30'),
       ('USB Kingston 64GB', 180000.00, '2024-09-12'),
       ('Webcam Logitech C920', 2250000.00, '2024-12-02'),
       ('Loa Bluetooth JBL Charge 5', 3990000.00, '2024-10-28'),
       ('Router WiFi TP-Link AX3000', 1950000.00, '2024-11-15');


create or replace function update_last_modified()
    returns trigger
    language plpgsql
as
$$
begin
    new.last_modified = current_date;
    return new;
end;
$$;

create trigger trg_update_last_modified
    before update
    on products
    for each row
execute function update_last_modified();

update products set price = 400000 where name = 'Chuột không dây Logitech';
-- Online Retail Sales Management System
-- MySQL 8.0+ | Run this script in MySQL Workbench or the MySQL CLI.
DROP DATABASE IF EXISTS online_retail_sales;
CREATE DATABASE online_retail_sales
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE online_retail_sales;

CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(25),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(80) NOT NULL UNIQUE,
    description VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    product_name VARCHAR(120) NOT NULL,
    sku VARCHAR(40) NOT NULL UNIQUE,
    unit_price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_products_category
      FOREIGN KEY (category_id) REFERENCES Categories(category_id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_products_price CHECK (unit_price >= 0),
    CONSTRAINT chk_products_stock CHECK (stock_quantity >= 0)
) ENGINE=InnoDB;

CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    order_status ENUM('Pending','Processing','Shipped','Delivered','Cancelled')
      NOT NULL DEFAULT 'Pending',
    shipping_address VARCHAR(255) NOT NULL,
    CONSTRAINT fk_orders_customer
      FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
      ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE OrderItems (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price_at_purchase DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    CONSTRAINT fk_orderitems_order
      FOREIGN KEY (order_id) REFERENCES Orders(order_id)
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_orderitems_product
      FOREIGN KEY (product_id) REFERENCES Products(product_id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_orderitems_quantity CHECK (quantity > 0),
    CONSTRAINT chk_orderitems_price CHECK (unit_price_at_purchase >= 0)
) ENGINE=InnoDB;

CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('Card','UPI','NetBanking','CashOnDelivery','Wallet') NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_status ENUM('Pending','Successful','Failed','Refunded')
      NOT NULL DEFAULT 'Pending',
    transaction_reference VARCHAR(100) UNIQUE,
    CONSTRAINT fk_payments_order
      FOREIGN KEY (order_id) REFERENCES Orders(order_id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_payments_amount CHECK (amount >= 0)
) ENGINE=InnoDB;

CREATE TABLE Shipments (
    shipment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL UNIQUE,
    carrier VARCHAR(80) NOT NULL,
    tracking_number VARCHAR(100) UNIQUE,
    shipped_date DATE,
    delivered_date DATE,
    shipment_status ENUM('Preparing','InTransit','Delivered','Returned')
      NOT NULL DEFAULT 'Preparing',
    CONSTRAINT fk_shipments_order
      FOREIGN KEY (order_id) REFERENCES Orders(order_id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_shipment_dates CHECK (
      delivered_date IS NULL OR shipped_date IS NULL OR delivered_date >= shipped_date
    )
) ENGINE=InnoDB;

-- Categories
INSERT INTO Categories (category_id, category_name, description) VALUES
(1,'Electronics','Devices and accessories'),
(2,'Home & Kitchen','Useful products for the home'),
(3,'Books','Printed books and learning material'),
(4,'Fashion','Clothing and accessories'),
(5,'Sports','Fitness and outdoor products');

-- Customers
INSERT INTO Customers (customer_id, first_name, last_name, email, phone, created_at) VALUES
(1,'Aarav','Sharma','aarav.sharma@example.com','9876501001','2026-01-03 10:15:00'),
(2,'Diya','Rao','diya.rao@example.com','9876501002','2026-01-10 12:30:00'),
(3,'Kabir','Nair','kabir.nair@example.com','9876501003','2026-02-02 09:00:00'),
(4,'Ananya','Iyer','ananya.iyer@example.com','9876501004','2026-02-14 16:20:00'),
(5,'Rohan','Patel','rohan.patel@example.com','9876501005','2026-03-01 11:45:00'),
(6,'Meera','Das','meera.das@example.com','9876501006','2026-03-12 14:10:00'),
(7,'Ishaan','Verma','ishaan.verma@example.com','9876501007','2026-04-05 08:50:00'),
(8,'Sana','Khan','sana.khan@example.com','9876501008','2026-04-18 17:05:00');

-- Products
INSERT INTO Products (product_id, category_id, product_name, sku, unit_price, stock_quantity, is_active) VALUES
(1,1,'Wireless Mouse','ELE-MOU-001',799.00,45,TRUE),
(2,1,'Bluetooth Headphones','ELE-HEA-002',2499.00,22,TRUE),
(3,1,'USB-C Hub','ELE-HUB-003',1599.00,30,TRUE),
(4,2,'Insulated Water Bottle','HOM-BOT-001',599.00,60,TRUE),
(5,2,'Desk Lamp','HOM-LAM-002',1299.00,18,TRUE),
(6,3,'SQL Fundamentals','BOO-SQL-001',650.00,35,TRUE),
(7,3,'Data Analytics Handbook','BOO-DAT-002',899.00,25,TRUE),
(8,4,'Cotton T-Shirt','FAS-TSH-001',499.00,80,TRUE),
(9,4,'Canvas Backpack','FAS-BAG-002',1199.00,27,TRUE),
(10,5,'Yoga Mat','SPO-YOG-001',999.00,40,TRUE);

-- Orders
INSERT INTO Orders (order_id, customer_id, order_date, order_status, shipping_address) VALUES
(1001,1,'2026-05-01 10:05:00','Delivered','12 MG Road, Bengaluru'),
(1002,2,'2026-05-02 13:25:00','Delivered','8 Indiranagar, Bengaluru'),
(1003,1,'2026-05-05 17:40:00','Shipped','12 MG Road, Bengaluru'),
(1004,3,'2026-05-07 09:15:00','Delivered','22 Marine Drive, Kochi'),
(1005,4,'2026-05-10 11:30:00','Processing','5 Anna Nagar, Chennai'),
(1006,5,'2026-05-12 15:50:00','Delivered','41 Viman Nagar, Pune'),
(1007,6,'2026-05-14 12:00:00','Cancelled','17 Park Street, Kolkata'),
(1008,2,'2026-05-18 18:10:00','Delivered','8 Indiranagar, Bengaluru'),
(1009,7,'2026-05-20 08:45:00','Pending','3 Civil Lines, Jaipur'),
(1010,8,'2026-05-22 14:35:00','Shipped','19 Banjara Hills, Hyderabad');

-- Order line items; prices are snapshots at purchase time.
INSERT INTO OrderItems (order_id, product_id, quantity, unit_price_at_purchase) VALUES
(1001,1,2,799.00),(1001,6,1,650.00),
(1002,2,1,2499.00),(1002,4,2,599.00),
(1003,3,1,1599.00),(1003,7,1,899.00),
(1004,8,3,499.00),(1004,10,1,999.00),
(1005,5,1,1299.00),(1005,9,1,1199.00),
(1006,6,2,650.00),(1006,7,1,899.00),
(1007,4,1,599.00),
(1008,1,1,799.00),(1008,8,2,499.00),
(1009,10,2,999.00),
(1010,2,1,2499.00),(1010,3,1,1599.00);

-- Payments
INSERT INTO Payments (payment_id, order_id, payment_date, payment_method, amount, payment_status, transaction_reference) VALUES
(1,1001,'2026-05-01 10:06:00','UPI',2248.00,'Successful','TXN-1001-A'),
(2,1002,'2026-05-02 13:26:00','Card',3697.00,'Successful','TXN-1002-A'),
(3,1003,'2026-05-05 17:41:00','UPI',2498.00,'Successful','TXN-1003-A'),
(4,1004,'2026-05-07 09:16:00','NetBanking',2496.00,'Successful','TXN-1004-A'),
(5,1005,'2026-05-10 11:31:00','Card',2498.00,'Pending','TXN-1005-A'),
(6,1006,'2026-05-12 15:51:00','UPI',2199.00,'Successful','TXN-1006-A'),
(7,1007,'2026-05-14 12:01:00','Wallet',599.00,'Refunded','TXN-1007-A'),
(8,1008,'2026-05-18 18:11:00','Card',1797.00,'Successful','TXN-1008-A'),
(9,1009,'2026-05-20 08:46:00','CashOnDelivery',1998.00,'Pending','TXN-1009-A'),
(10,1010,'2026-05-22 14:36:00','UPI',4098.00,'Successful','TXN-1010-A');

-- Shipments: only orders that have shipment records are included.
INSERT INTO Shipments (shipment_id, order_id, carrier, tracking_number, shipped_date, delivered_date, shipment_status) VALUES
(1,1001,'BlueDart','BD-1001','2026-05-02','2026-05-04','Delivered'),
(2,1002,'Delhivery','DL-1002','2026-05-03','2026-05-06','Delivered'),
(3,1003,'BlueDart','BD-1003','2026-05-06',NULL,'InTransit'),
(4,1004,'India Post','IP-1004','2026-05-08','2026-05-11','Delivered'),
(5,1006,'Delhivery','DL-1006','2026-05-13','2026-05-16','Delivered'),
(6,1008,'Ecom Express','EC-1008','2026-05-19','2026-05-22','Delivered'),
(7,1010,'BlueDart','BD-1010','2026-05-23',NULL,'InTransit');

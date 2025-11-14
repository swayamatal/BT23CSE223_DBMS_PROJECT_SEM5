-- SQL Queries used in Supply Chain DBMS Project
-- Commented all non-MySQL parts

-- Database Creation
DROP DATABASE IF EXISTS inventory_app;
CREATE DATABASE inventory_app;
USE inventory_app;

-- Products Table
CREATE TABLE Products (
  prod_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  category VARCHAR(100),
  unit_price DECIMAL(10,2) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Warehouses Table
CREATE TABLE Warehouses (
  wh_id INT AUTO_INCREMENT PRIMARY KEY,
  location VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Inventory Table
CREATE TABLE Inventory (
  inv_id INT AUTO_INCREMENT PRIMARY KEY,
  prod_id INT NOT NULL,
  wh_id INT NOT NULL,
  stock_qty INT NOT NULL DEFAULT 0,
  safety_stock INT NOT NULL DEFAULT 0,
  last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (prod_id) REFERENCES Products(prod_id) ON DELETE RESTRICT,
  FOREIGN KEY (wh_id) REFERENCES Warehouses(wh_id) ON DELETE CASCADE
);

-- Suppliers Table
CREATE TABLE Suppliers (
  supplier_id INT AUTO_INCREMENT PRIMARY KEY,
  company_name VARCHAR(255) NOT NULL,
  rating TINYINT DEFAULT 3,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders Table
CREATE TABLE Orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  supplier_id INT,
  prod_id INT NOT NULL,
  qty INT NOT NULL,
  order_date DATE DEFAULT (CURRENT_DATE()),
  expected_date DATE,
  status ENUM('Placed','Shipped','Delivered','Completed','Cancelled') DEFAULT 'Placed',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id) ON DELETE SET NULL,
  FOREIGN KEY (prod_id) REFERENCES Products(prod_id) ON DELETE RESTRICT
);

-- Sales Table
CREATE TABLE Sales (
  sale_id INT AUTO_INCREMENT PRIMARY KEY,
  prod_id INT NOT NULL,
  wh_id INT NOT NULL,
  sale_qty INT NOT NULL,
  sale_date DATE DEFAULT (CURRENT_DATE()),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (prod_id) REFERENCES Products(prod_id) ON DELETE RESTRICT,
  FOREIGN KEY (wh_id) REFERENCES Warehouses(wh_id) ON DELETE RESTRICT
);

-- Users Table
CREATE TABLE Users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('admin','client') NOT NULL DEFAULT 'client',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ClientOrders Table
CREATE TABLE ClientOrders (
  corder_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  prod_id INT NOT NULL,
  wh_id INT NOT NULL,
  qty INT NOT NULL DEFAULT 1,
  order_date DATE DEFAULT (CURRENT_DATE()),
  status ENUM('Placed','Shipped','Delivered','Cancelled') DEFAULT 'Placed',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (prod_id) REFERENCES Products(prod_id) ON DELETE RESTRICT,
  FOREIGN KEY (wh_id) REFERENCES Warehouses(wh_id) ON DELETE RESTRICT
);

-- Trigger removed completely

-- Indexes
CREATE INDEX idx_inventory_prod_wh ON Inventory(prod_id, wh_id);
CREATE INDEX idx_sales_prod_date ON Sales(prod_id, sale_date);

-- Initial Data
INSERT INTO Warehouses (location) 
VALUES ('Main Warehouse'), ('Secondary Warehouse');

INSERT INTO Products (name, category, unit_price) 
VALUES ('Widget A','Widgets',10.00),
       ('Gadget B','Gadgets',15.50);

INSERT INTO Inventory (prod_id, wh_id, stock_qty, safety_stock) 
VALUES (1,1,100,20),
       (2,1,50,10),
       (1,2,30,10);

INSERT INTO Suppliers (company_name, rating) 
VALUES ('Acme Supplies',4),
       ('Global Parts',3);

-- Authentication Queries
-- SELECT user_id FROM Users WHERE email=?
-- INSERT INTO Users (name,email,password_hash,role) VALUES (?,?,?,?)
-- SELECT user_id, name, email, password_hash, role FROM Users WHERE email=?

-- Product Queries
-- SELECT * FROM Products;
-- INSERT INTO Products (name,category,unit_price) VALUES (?,?,?);
-- UPDATE Products SET name=?, category=?, unit_price=? WHERE prod_id=?;
-- DELETE FROM Products WHERE prod_id=?;

-- Inventory Queries
-- SELECT i.*, p.name, w.location FROM Inventory i 
-- JOIN Products p ON i.prod_id = p.prod_id 
-- JOIN Warehouses w ON i.wh_id = w.wh_id;
-- UPDATE Inventory SET stock_qty=?, last_updated=CURRENT_TIMESTAMP WHERE inv_id=?;
-- SELECT ... WHERE i.stock_qty < i.safety_stock;

-- Warehouse Queries
-- SELECT * FROM Warehouses;
-- INSERT INTO Warehouses (location) VALUES (?);
-- UPDATE Warehouses SET location=? WHERE wh_id=?;
-- DELETE FROM Warehouses WHERE wh_id=?;

-- Supplier Queries
-- SELECT * FROM Suppliers;
-- INSERT INTO Suppliers (company_name, rating) VALUES (?,?);
-- UPDATE Suppliers SET company_name=?, rating=? WHERE supplier_id=?;
-- DELETE FROM Suppliers WHERE supplier_id=?;

-- Order Queries
-- INSERT INTO Orders (supplier_id, prod_id, qty, expected_date, status) VALUES (?,?,?,?,?);
-- UPDATE Orders SET status=? WHERE order_id=?;

-- Sales
-- SELECT * FROM Sales ORDER BY created_at DESC;

-- Client Orders
-- SELECT inv_id, stock_qty FROM Inventory WHERE prod_id=? AND wh_id=? FOR UPDATE;
-- INSERT INTO ClientOrders (user_id, prod_id, wh_id, qty) VALUES (?,?,?,?);
-- SELECT * FROM ClientOrders WHERE user_id=?;


-- 1. CREACIÓN DEL ESQUEMA Y LIMPIEZA

CREATE SCHEMA IF NOT EXISTS proyecto_final_bd;
USE proyecto_final_bd;

-- Borramos versiones viejas en orden inverso por las llaves foráneas
DROP TABLE IF EXISTS Reseñas;
DROP TABLE IF EXISTS Detalles_Pedido;
DROP TABLE IF EXISTS Pedidos;
DROP TABLE IF EXISTS Productos;
DROP TABLE IF EXISTS Clientes;
DROP TABLE IF EXISTS Categorias;


-- 2. CREACIÓN DE TABLAS CON NOMBRES LIMPIOS(osea para que no repitan y en cada ejecucion sea un nombre nuevo) 

CREATE TABLE Categorias (
    id_categoria INT PRIMARY KEY,
    nombre VARCHAR(50),
    descripcion VARCHAR(200)
);

CREATE TABLE Clientes (
    id_cliente INT PRIMARY KEY,
    nombre VARCHAR(100),
    correo VARCHAR(100) UNIQUE, 
    telefono VARCHAR(20),
    direccion VARCHAR(200)
);

CREATE TABLE Productos (
    id_producto INT PRIMARY KEY,
    nombre VARCHAR(100),
    descripcion VARCHAR(200),
    precio DECIMAL(10,2),
    stock INT,
    id_categoria INT,
    FOREIGN KEY (id_categoria) REFERENCES Categorias(id_categoria)
);

CREATE TABLE Pedidos (
    id_pedido INT PRIMARY KEY,
    id_cliente INT,
    fecha_pedido DATE,
    estado VARCHAR(20),
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
);

CREATE TABLE Detalles_Pedido (
    id_detalle INT PRIMARY KEY,
    id_pedido INT,
    id_producto INT,
    cantidad INT,
    precio_unitario DECIMAL(10,2),
    FOREIGN KEY (id_pedido) REFERENCES Pedidos(id_pedido),
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);

CREATE TABLE Reseñas (
    id_reseña INT PRIMARY KEY,
    id_producto INT,
    id_cliente INT,
    calificacion INT,
    comentario VARCHAR(255),
    fecha DATE,
    FOREIGN KEY (id_producto) REFERENCES Productos(id_producto),
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
);


-- 3. RESTRICCIONES (Constraints)

ALTER TABLE Clientes ADD CONSTRAINT uk_correo UNIQUE (correo);
ALTER TABLE Productos ADD CONSTRAINT chk_stock CHECK (stock >= 0);


-- 4. ÍNDICES (Optimización)

CREATE INDEX idx_producto_nombre ON Productos(nombre);
CREATE INDEX idx_producto_categoria ON Productos(id_categoria);
CREATE INDEX idx_pedido_cliente ON Pedidos(id_cliente);


-- 5. POBLACIÓN DE DATOS (Con nombres de columnas explícitos)

INSERT IGNORE INTO Categorias (id_categoria, nombre, descripcion) VALUES
(1, 'Laptops', 'Computadoras portatiles'), (2, 'Smartphones', 'Telefonos moviles'),
(3, 'Audio', 'Audifonos y bocinas'), (4, 'Accesorios', 'Cables y cargadores'), (5, 'Monitores', 'Pantallas para PC');

INSERT IGNORE INTO Clientes (id_cliente, nombre, correo, telefono, direccion) VALUES
(1, 'Juan Perez', 'juan@email.com', '5551112222', 'Calle 1'), (2, 'Maria Garcia', 'maria@email.com', '5552223333', 'Calle 2'),
(3, 'Carlos Lopez', 'carlos@email.com', '5553334444', 'Calle 3'), (4, 'Ana Martinez', 'ana@email.com', '5554445555', 'Calle 4'),
(5, 'Luis Rodriguez', 'luis@email.com', '5555556666', 'Calle 5');

INSERT IGNORE INTO Productos (id_producto, id_categoria, nombre, descripcion, precio, stock) VALUES
(1, 1, 'Laptop HP', 'Core i5 8GB RAM', 12000.00, 10), (2, 1, 'Laptop Dell', 'Core i7 16GB RAM', 15000.00, 5),
(3, 1, 'MacBook Air', 'Chip M1 8GB', 18000.00, 8), (4, 1, 'Laptop Lenovo', 'Ryzen 5 8GB RAM', 11000.00, 12),
(5, 1, 'Laptop Asus', 'Ryzen 7 1600RAM', 14500.00, 3), (6, 2, 'iPhone 13', '128GB', 16000.00, 15),
(7, 2, 'Samsung S22', '256GB', 14000.00, 20), (11, 3, 'Audifonos Sony', 'Bluetooth', 1500.00, 40),
(12, 3, 'Bocina JBL', 'Portatil', 1200.00, 35), (16, 4, 'Cable USB C', '1 metro', 150.00, 100),
(17, 4, 'Cargador Universal', 'Carga rapida', 300.00, 50), (21, 5, 'Monitor Samsung', '24 pulgadas', 3000.00, 20),
(22, 5, 'Monitor LG', '27 pulgadas', 4000.00, 15);

INSERT IGNORE INTO Pedidos (id_pedido, id_cliente, fecha_pedido, estado) VALUES
(1, 1, '2023-11-01', 'Completado'), (2, 2, '2023-11-02', 'Completado'),
(3, 3, '2023-11-03', 'Enviado'), (4, 4, '2023-11-04', 'Pendiente'), (5, 5, '2023-11-05', 'Completado');

INSERT IGNORE INTO Detalles_Pedido (id_detalle, id_pedido, id_producto, cantidad, precio_unitario) VALUES
(1, 1, 1, 1, 12000.00), (2, 1, 16, 2, 150.00), (3, 2, 6, 1, 16000.00), (4, 3, 11, 1, 1500.00), (5, 4, 21, 1, 3000.00);

INSERT IGNORE INTO Reseñas (id_reseña, id_producto, id_cliente, calificacion, comentario, fecha) VALUES
(1, 1, 1, 5, 'Muy buena laptop', '2023-11-05'), (2, 6, 2, 4, 'Me gusto el celular', '2023-11-10');
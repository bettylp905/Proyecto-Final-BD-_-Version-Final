USE proyecto_final_bd;

-- ========================================================
-- 1. CONSULTAS DE LECTURA (JOIN)
-- ========================================================

-- Consulta A: Productos por categoría ordenados por precio
SELECT c.nombre AS categoria, p.nombre AS producto, p.precio 
FROM Productos p
JOIN Categorias c ON p.id_categoria = c.id_categoria
ORDER BY c.nombre, p.precio;

-- Consulta B: Clientes con pedidos pendientes
SELECT c.nombre, COUNT(p.id_pedido) AS total_pendientes
FROM Clientes c
JOIN Pedidos p ON c.id_cliente = p.id_cliente
WHERE p.estado = 'Pendiente'
GROUP BY c.id_cliente;

-- Consulta C: Top 5 productos mejor calificados
SELECT p.nombre, AVG(r.calificacion) AS promedio
FROM Productos p
JOIN Reseñas r ON p.id_producto = r.id_producto
GROUP BY p.id_producto
ORDER BY promedio DESC
LIMIT 5;


-- ========================================================
-- 2. PROCEDIMIENTOS ALMACENADOS (Con seguridad DROP)
-- ========================================================
DROP PROCEDURE IF EXISTS sp_registrar_pedido;
DROP PROCEDURE IF EXISTS sp_registrar_reseña;
DROP PROCEDURE IF EXISTS sp_actualizar_stock;
DROP PROCEDURE IF EXISTS sp_cambiar_estado_pedido;
DROP PROCEDURE IF EXISTS sp_eliminar_reseñas_producto;
DROP PROCEDURE IF EXISTS sp_agregar_producto;
DROP PROCEDURE IF EXISTS sp_actualizar_cliente;
DROP PROCEDURE IF EXISTS sp_reporte_stock_bajo;

DELIMITER //

-- 1. Registrar pedido (Valida máximo 5 pendientes)
CREATE PROCEDURE sp_registrar_pedido(IN p_cliente INT)
BEGIN
    DECLARE v_pendientes INT;
    DECLARE v_id INT;
    SELECT COUNT(*) INTO v_pendientes FROM Pedidos WHERE id_cliente = p_cliente AND estado = 'Pendiente';
    
    IF v_pendientes < 5 THEN
        SELECT IFNULL(MAX(id_pedido), 0) + 1 INTO v_id FROM Pedidos;
        INSERT INTO Pedidos (id_pedido, id_cliente, fecha_pedido, estado) VALUES (v_id, p_cliente, CURDATE(), 'Pendiente');
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Límite de pedidos pendientes alcanzado';
    END IF;
END //

-- 2. Registrar reseña (Valida que el cliente haya comprado el producto)
CREATE PROCEDURE sp_registrar_reseña(IN p_prod INT, IN p_cli INT, IN p_cal INT, IN p_com VARCHAR(255))
BEGIN
    DECLARE v_compra INT;
    DECLARE v_id INT;
    SELECT COUNT(*) INTO v_compra FROM Detalles_Pedido d JOIN Pedidos p ON d.id_pedido = p.id_pedido 
    WHERE p.id_cliente = p_cli AND d.id_producto = p_prod;
    
    IF v_compra > 0 THEN
        SELECT IFNULL(MAX(id_reseña), 0) + 1 INTO v_id FROM Reseñas;
        INSERT INTO Reseñas (id_reseña, id_producto, id_cliente, calificacion, comentario, fecha) VALUES (v_id, p_prod, p_cli, p_cal, p_com, CURDATE());
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El cliente no ha comprado este producto';
    END IF;
END //

-- 3. Actualizar stock
CREATE PROCEDURE sp_actualizar_stock(IN p_prod INT, IN p_cantidad INT)
BEGIN
    UPDATE Productos SET stock = stock - p_cantidad WHERE id_producto = p_prod;
END //

-- 4. Cambiar estado de pedido
CREATE PROCEDURE sp_cambiar_estado_pedido(IN p_pedido INT, IN p_nuevo_estado VARCHAR(20))
BEGIN
    UPDATE Pedidos SET estado = p_nuevo_estado WHERE id_pedido = p_pedido;
END //

-- 5. Eliminar reseñas de un producto
CREATE PROCEDURE sp_eliminar_reseñas_producto(IN p_prod INT)
BEGIN
    DELETE FROM Reseñas WHERE id_producto = p_prod;
END //

-- 6. Agregar producto evitando duplicados
CREATE PROCEDURE sp_agregar_producto(IN p_cat INT, IN p_nom VARCHAR(100), IN p_desc VARCHAR(255), IN p_precio DECIMAL(10,2), IN p_stock INT)
BEGIN
    DECLARE v_existe INT;
    DECLARE v_id INT;
    SELECT COUNT(*) INTO v_existe FROM Productos WHERE nombre = p_nom AND id_categoria = p_cat;
    
    IF v_existe = 0 THEN
        SELECT IFNULL(MAX(id_producto), 0) + 1 INTO v_id FROM Productos;
        INSERT INTO Productos (id_producto, id_categoria, nombre, descripcion, precio, stock) VALUES (v_id, p_cat, p_nom, p_desc, p_precio, p_stock);
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto ya existe';
    END IF;
END //

-- 7. Actualizar cliente
CREATE PROCEDURE sp_actualizar_cliente(IN p_id INT, IN p_tel VARCHAR(15), IN p_dir VARCHAR(255))
BEGIN
    UPDATE Clientes SET telefono = p_tel, direccion = p_dir WHERE id_cliente = p_id;
END //

-- 8. Reporte stock bajo
CREATE PROCEDURE sp_reporte_stock_bajo()
BEGIN
    SELECT nombre, stock FROM Productos WHERE stock < 5;
END //

DELIMITER ;


-- ========================================================
-- 3. APARTADO DE VALIDACIÓN Y OPTIMIZACIÓN (Tus Capturas)
-- ========================================================
-- Ejecuta estas líneas una por una para tomar tus capturas de pantalla con datos reales:

-- Prueba de procedimiento 1: Reporte stock bajo
CALL sp_reporte_stock_bajo();

-- Prueba de procedimiento 2: Registrar pedido exitoso
CALL sp_registrar_pedido(1);

-- Prueba de Optimización: Demostración de uso de Índices
EXPLAIN SELECT * FROM Productos WHERE nombre = 'Laptop HP';
USE proyecto_final_bd;

-- Prueba de procedimiento 1: Reporte de stock bajo (menor a 5)
CALL sp_reporte_stock_bajo();

-- Prueba de procedimiento 2: Registrar un nuevo pedido exitoso
CALL sp_registrar_pedido(1);

-- Prueba de Optimización: Uso de Índices (Comprobación)
EXPLAIN SELECT * FROM Productos WHERE nombre = 'Laptop HP';
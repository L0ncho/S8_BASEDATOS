/* INFORME STOCK*/
-- SECUENCIA PARA CADA VEZ QUE SE INSERTA UNA FILA EN LA TABLA
CREATE SEQUENCE SQ_CONTROL_STOCK START WITH 1 INCREMENT BY 1;

--CREAMOS LA TABLA PARA DE RESULTADOS
CREATE TABLE CONTROL_STOCK_LIBROS (
    ID_CONTROL NUMBER PRIMARY KEY,
    LIBRO_ID NUMBER,
    NOMBRE_LIBRO VARCHAR2(100),
    TOTAL_EJEMPLARES NUMBER,
    EN_PRESTAMO NUMBER,
    DISNIBLES NUMBER,
    PORCENTAJE_PRESTAMOS VARCHAR2(20),
    STOCK_CRITICO VARCHAR(1)
);

/*MEJORA ESTA CONSULTA, QUE NO QUEDE COMO PEGADA DE IA*/

-- 3. Inserción con Subconsulta (Para evitar error ORA-02287)
INSERT INTO CONTROL_STOCK_LIBROS
SELECT 
    SQ_CONTROL_STOCK.NEXTVAL, -- La secuencia va AFUERA
    DATOS.*
FROM (
    -- ADENTRO: Toda la lógica de agrupamiento y cálculo
    SELECT 
        L.libroid,
        L.nombre_libro,
        -- Total Ejemplares (Subconsulta)
        (SELECT COUNT(*) FROM SYN_EJEMPLAR E WHERE E.libroid = L.libroid) AS TOTAL,
        -- En Préstamo
        COUNT(P.prestamoid) AS PRESTADOS,
        -- Disponibles
        (SELECT COUNT(*) FROM SYN_EJEMPLAR E WHERE E.libroid = L.libroid) - COUNT(P.prestamoid) AS DISPONIBLES,
        -- Porcentaje
        TO_CHAR(ROUND((COUNT(P.prestamoid) / NULLIF((SELECT COUNT(*) FROM SYN_EJEMPLAR E WHERE E.libroid = L.libroid),0)) * 100, 0)) || '%' AS PCT,
        -- Stock Crítico
        CASE 
            WHEN ((SELECT COUNT(*) FROM SYN_EJEMPLAR E WHERE E.libroid = L.libroid) - COUNT(P.prestamoid)) > 2 THEN 'S'
            ELSE 'N'
        END AS CRITICO

    FROM SYN_LIBRO L
    JOIN SYN_PRESTAMO P ON L.libroid = P.libroid
    WHERE 
        TO_CHAR(P.fecha_inicio, 'YYYY') = TO_CHAR(SYSDATE, 'YYYY') - 2
        AND P.empleadoid IN (150, 180, 190)
    GROUP BY L.libroid, L.nombre_libro
    ORDER BY L.libroid
) DATOS;

COMMIT;

SELECT * FROM CONTROL_STOCK_LIBROS;
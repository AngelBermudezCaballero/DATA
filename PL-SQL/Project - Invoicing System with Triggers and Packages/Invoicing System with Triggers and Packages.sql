--PRUEBA EXAMEN 1

--PAQUETE FACTURAS

--CABECERA

CREATE OR REPLACE PACKAGE paquete_facturas AS

--PROCEDIMIENTOS
    PROCEDURE alta_factura (
        codigo_factura      NUMBER,
        fecha_factura       DATE,
        descripcion_factura VARCHAR2
    );

    PROCEDURE baja_factura (
        codigo_factura NUMBER
    );

    PROCEDURE mod_descri (
        codigo_factura      NUMBER,
        descripcion_factura VARCHAR2
    );

    PROCEDURE mod_fecha (
        codigo_factura NUMBER,
        fecha_factura  DATE
    );
--FUNCIONES
    FUNCTION num_facturas (
        fecha_inicio DATE,
        fecha_fin    DATE
    ) RETURN NUMBER;

    FUNCTION total_factura (
        codigo_factura NUMBER
    ) RETURN NUMBER;

END paquete_facturas;

CREATE OR REPLACE PACKAGE BODY paquete_facturas AS

    --FUNCION DELNTRO DEL CUERPO
    FUNCTION existe_factura (
        codigo_factura NUMBER
    ) RETURN BOOLEAN AS
        contador NUMBER := 0;
    BEGIN
        SELECT
            COUNT(*)
        INTO contador
        FROM
            facturas
        WHERE
            cod_factura = codigo_factura;

        IF contador > 0 THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END existe_factura;

    PROCEDURE alta_factura (
        codigo_factura      NUMBER,
        fecha_factura       DATE,
        descripcion_factura VARCHAR2
    ) AS
    BEGIN
        IF existe_factura(codigo_factura) THEN
            raise_application_error(-20001, 'EL CODIGO COINCIDE CON NINGUNA FACTURA YA EXISTENTE');
        ELSE
            INSERT INTO facturas VALUES ( codigo_factura,
                                          fecha_factura,
                                          descripcion_factura );

        END IF;
    END alta_factura;

    PROCEDURE baja_factura (
        codigo_factura NUMBER
    ) AS
    BEGIN
        IF NOT existe_factura(codigo_factura) THEN
            raise_application_error(-20002, 'EL CODIGO NO COINCIDE CON UNA FACTURA YA EXISTENTE');
        ELSE
            DELETE FROM facturas
            WHERE
                codigo_factura = cod_factura;

            DELETE FROM lineas_factura
            WHERE
                codigo_factura = cod_factura;

        END IF;
    END baja_factura;

    PROCEDURE mod_descri (
        codigo_factura      NUMBER,
        descripcion_factura VARCHAR2
    ) AS
    BEGIN
        IF NOT existe_factura(codigo_factura) THEN
            raise_application_error(-20003, 'EL CODIGO NO COINCIDE CON NINGUNA FACTURA YA EXISTENTE');
        ELSE
            UPDATE facturas
            SET
                descripcion = descripcion_factura
            WHERE
                codigo_factura = cod_factura;

        END IF;
    END mod_descri;

    PROCEDURE mod_fecha (
        codigo_factura NUMBER,
        fecha_factura  DATE
    ) AS
    BEGIN
        IF NOT existe_factura(codigo_factura) THEN
            raise_application_error(-20004, 'EL CODIGO NO COINCIDE CON NINGUNA FACTURA YA EXISTENTE');
        ELSE
            UPDATE facturas
            SET
                fecha = fecha_factura
            WHERE
                codigo_factura = cod_factura;

        END IF;
    END mod_fecha;

    FUNCTION num_facturas (
        fecha_inicio DATE,
        fecha_fin    DATE
    ) RETURN NUMBER AS
        contador NUMBER := 0;
    BEGIN
        SELECT
            COUNT(*)
        INTO contador
        FROM
            facturas
        WHERE
            fecha BETWEEN fecha_inicio AND fecha_fin;

        RETURN contador;
    END num_facturas;

    FUNCTION total_factura (
        codigo_factura NUMBER
    ) RETURN NUMBER AS
        suma_total NUMBER := 0;
    BEGIN
        SELECT
            SUM(pvp * unidades)
        INTO suma_total
        FROM
            lineas_factura
        WHERE
            cod_factura = codigo_factura;

        RETURN suma_total;
    END total_factura;

END paquete_facturas;

--PAQUETE LINEAS_FACTURAS

--CABECERA

CREATE OR REPLACE PACKAGE linea_facturas AS

--PROCEDIMIENTOS
    PROCEDURE alta_linea (
        codigo_factura  NUMBER,
        codigo_producto NUMBER,
        unidades_linea  NUMBER,
        fecha_linea     DATE
    );

    PROCEDURE baja_linea (
        codigo_factura  NUMBER,
        codigo_producto NUMBER
    );

    PROCEDURE mod_producto (
        codigo_factura  NUMBER,
        codigo_producto NUMBER,
        unidades_linea  NUMBER
    );

    PROCEDURE mod_producto (
        codigo_factura  NUMBER,
        codigo_producto NUMBER,
        fecha_linea     DATE
    );
--FUNCIONES
    FUNCTION num_lineas (
        codigo_factura NUMBER
    ) RETURN NUMBER;

END linea_facturas;

CREATE OR REPLACE PACKAGE BODY linea_facturas AS

 --FUNCION DELNTRO DEL CUERPO
    FUNCTION existe_factura (
        codigo_factura NUMBER
    ) RETURN BOOLEAN AS
        contador NUMBER := 0;
    BEGIN
        SELECT
            COUNT(*)
        INTO contador
        FROM
            facturas
        WHERE
            cod_factura = codigo_factura;

        IF contador > 0 THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END existe_factura;

    --FUNCION DENTRO DEL CUERPO
    FUNCTION existe_producto (
        codigo_producto NUMBER
    ) RETURN BOOLEAN AS
        contador NUMBER := 0;
    BEGIN
        SELECT
            COUNT(*)
        INTO contador
        FROM
            productos
        WHERE
            cod_producto = codigo_producto;

        IF contador > 0 THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END existe_producto;

    PROCEDURE alta_linea (
        codigo_factura  NUMBER,
        codigo_producto NUMBER,
        unidades_linea  NUMBER,
        fecha_linea     DATE
    ) AS
        pvp_linea NUMBER;
    BEGIN
        IF NOT existe_factura(codigo_factura) THEN
            raise_application_error(-20006, 'EL CODIGO NO COINCIDE CON NINGUNA FACTURA YA EXISTENTE');
        END IF;
        IF NOT existe_producto(codigo_producto) THEN
            raise_application_error(-20005, 'EL CODIGO NO COINCIDE CON NINGUN PRODUCTO YA EXISTENTE');
        END IF;
        SELECT
            pvp
        INTO pvp_linea
        FROM
            productos
        WHERE
            codigo_producto = cod_producto;

        INSERT INTO lineas_factura (
            cod_factura,
            cod_producto,
            pvp,
            unidades,
            fecha
        ) VALUES ( codigo_factura,
                   codigo_producto,
                   pvp_linea,
                   unidades_linea,
                   fecha_linea );

    END alta_linea;

    PROCEDURE baja_linea (
        codigo_factura  NUMBER,
        codigo_producto NUMBER
    ) AS
    BEGIN
        IF NOT existe_factura(codigo_factura) THEN
            raise_application_error(-20007, 'EL CODIGO NO COINCIDE CON NINGUNA FACTURA YA EXISTENTE');
        END IF;
        IF NOT existe_producto(codigo_producto) THEN
            raise_application_error(-20008, 'EL CODIGO NO COINCIDE CON NINGUN PRODUCTO YA EXISTENTE');
        END IF;
        DELETE FROM lineas_factura
        WHERE
                codigo_factura = cod_factura
            AND cod_producto = codigo_producto;

    END baja_linea;

    PROCEDURE mod_producto (
        codigo_factura  NUMBER,
        codigo_producto NUMBER,
        unidades_linea  NUMBER
    ) AS
    BEGIN
        IF NOT existe_factura(codigo_factura) THEN
            raise_application_error(-20007, 'EL CODIGO NO COINCIDE CON NINGUNA FACTURA YA EXISTENTE');
        END IF;
        IF NOT existe_producto(codigo_producto) THEN
            raise_application_error(-20008, 'EL CODIGO NO COINCIDE CON NINGUN PRODUCTO YA EXISTENTE');
        END IF;
        UPDATE lineas_factura
        SET
            unidades = unidades_linea
        WHERE
                codigo_factura = cod_factura
            AND codigo_producto = cod_producto;

    END mod_producto;

    PROCEDURE mod_producto (
        codigo_factura  NUMBER,
        codigo_producto NUMBER,
        fecha_linea     DATE
    ) AS
    BEGIN
        IF NOT existe_factura(codigo_factura) THEN
            raise_application_error(-20007, 'EL CODIGO NO COINCIDE CON NINGUNA FACTURA YA EXISTENTE');
        END IF;
        IF NOT existe_producto(codigo_producto) THEN
            raise_application_error(-20008, 'EL CODIGO NO COINCIDE CON NINGUN PRODUCTO YA EXISTENTE');
        END IF;
        UPDATE lineas_factura
        SET
            fecha = fecha_linea
        WHERE
                codigo_factura = cod_factura
            AND codigo_producto = cod_producto;

    END mod_producto;

    FUNCTION num_lineas (
        codigo_factura NUMBER
    ) RETURN NUMBER AS
        contador NUMBER := 0;
    BEGIN
        IF NOT existe_factura(codigo_factura) THEN
            raise_application_error(-20007, 'EL CODIGO NO COINCIDE CON NINGUNA FACTURA YA EXISTENTE');
        END IF;
        SELECT
            COUNT(*)
        INTO contador
        FROM
            lineas_factura
        WHERE
            codigo_factura = cod_factura;

        RETURN contador;
    END num_lineas;

END linea_facturas;

--TRIGGERS

CREATE OR REPLACE TRIGGER controlar_total_vendido BEFORE
    DELETE OR INSERT OR UPDATE ON lineas_factura
    FOR EACH ROW
DECLARE
    unidades_totales NUMBER;
BEGIN
    IF inserting THEN
        SELECT
            ( SUM(unidades) + :new.unidades )
        INTO unidades_totales
        FROM
            lineas_factura
        WHERE
            cod_producto = :new.cod_producto
        GROUP BY
            cod_producto;

        UPDATE productos
        SET
            total_vendidos = unidades_totales
        WHERE
            cod_producto = :new.cod_producto;

    END IF;

    IF deleting THEN
        UPDATE productos
        SET
            total_vendidos = coalesce(total_vendidos, 0) - :old.unidades
        WHERE
            cod_producto = :old.cod_producto;

    END IF;

    IF updating('UNIDADES') THEN
        IF :old.unidades > :new.unidades THEN
            unidades_totales := :old.unidades - :new.unidades;
            UPDATE productos
            SET
                total_vendidos = coalesce(total_vendidos, 0) - unidades_totales
            WHERE
                cod_producto = :new.cod_producto;

        END IF;

        IF :old.unidades < :new.unidades THEN
            unidades_totales := :new.unidades - :old.unidades;
            UPDATE productos
            SET
                total_vendidos = coalesce(total_vendidos, 0) + unidades_totales
            WHERE
                cod_producto = :new.cod_producto;

        END IF;

    END IF;

END;

/*COMPROBACIONES:

BEGIN
 LINEA_FACTURAS.MOD_PRODUCTO(1,2,TO_DATE('31-01-2002'));
END;
SET SERVEROUTPUT ON
BEGIN
  DBMS_OUTPUT.PUT_LINE(LINEA_FACTURAS.NUM_LINEAS(1));
END;*/
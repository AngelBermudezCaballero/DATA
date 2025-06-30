--PRUEBA EXAMEN 2

CREATE OR REPLACE PACKAGE PKG_VENTA AS
--PROCEDIMIENTOS:
PROCEDURE AGREGAR_VENTA(VENTA_ID NUMBER, CL_ID NUMBER ,PR_ID NUMBER,VENTA_FECHA DATE,VENTA_SUBTOTAL NUMBER);

PROCEDURE VENTAS_REALIZADAS(DIA NUMBER,MES NUMBER);

PROCEDURE INSERTAR_VENTAS_REALIZADAS(DIA NUMBER,MES NUMBER);

END PKG_VENTA;


--CUERPO:

CREATE OR REPLACE
PACKAGE BODY PKG_VENTA AS

     FUNCTION existe_venta (
        venta_id NUMBER
    ) RETURN BOOLEAN AS
        contador NUMBER := 0;
    BEGIN
        SELECT
            COUNT(*)
        INTO contador
        FROM
            venta
        WHERE
            id = venta_id;

        IF contador > 0 THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END existe_venta;
    
     FUNCTION existe_producto (
        pr_id NUMBER
    ) RETURN BOOLEAN AS
        contador NUMBER := 0;
    BEGIN
        SELECT
            COUNT(*)
        INTO contador
        FROM
            producto2
        WHERE
            id = pr_id;

        IF contador > 0 THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END existe_producto;
       
     FUNCTION existe_cliente (
        cl_id NUMBER
    ) RETURN BOOLEAN AS
        contador NUMBER := 0;
    BEGIN
        SELECT
            COUNT(*)
        INTO contador
        FROM
            cliente
        WHERE
            id = cl_id;

        IF contador > 0 THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END existe_cliente;
    
     PROCEDURE AGREGAR_VENTA(VENTA_ID NUMBER, CL_ID NUMBER ,PR_ID NUMBER,VENTA_FECHA DATE,VENTA_SUBTOTAL NUMBER) AS
  BEGIN
    IF existe_venta(venta_id) THEN
            raise_application_error(-20001, 'ya hay una venta con ese ID');
    end if;
    IF not existe_producto(pr_id) THEN
            raise_application_error(-20001, 'no hay ningun producto con ese ID');
    end if;
    IF not existe_cliente(cl_id) THEN
            raise_application_error(-20001, 'no hay ningun cliente con ese ID');
    end if;
    
    insert into VENTA VALUES(VENTA_ID , CL_ID  ,PR_ID ,VENTA_FECHA ,VENTA_SUBTOTAL );
    
  END AGREGAR_VENTA;

     PROCEDURE VENTAS_REALIZADAS(DIA NUMBER,MES NUMBER) AS

  BEGIN
    -- Recorremos todas las ventas que coincidan con el día y mes especificados
    FOR I IN (
        SELECT ID , CLIENTE_ID , PRODUCTO_ID , FECHA , SUBTOTAL 
        FROM VENTA 
        WHERE EXTRACT(DAY FROM FECHA) = DIA 
          AND EXTRACT(MONTH FROM FECHA) = MES
    ) LOOP
        -- Imprimimos la información de cada venta
        DBMS_OUTPUT.PUT_LINE(
            'ID_VENTA:' || I.ID || 
            ' ID_CLIENTE:' || I.CLIENTE_ID || 
            ' ID_PRODUCTO:' || I.PRODUCTO_ID || 
            ' FECHA:' || I.FECHA || 
            ' SUBTOTAL:' || I.SUBTOTAL || 
            ' -> FILTRO: DIA=' || DIA || ' MES=' || MES
        );
    END LOOP;
  END VENTAS_REALIZADAS;

     PROCEDURE INSERTAR_VENTAS_REALIZADAS(DIA NUMBER,MES NUMBER) AS
    TABLE_NAME_P VARCHAR2(50);
    CONTADOR_EXISTE NUMBER;
    BEGIN
        -- GENERACION DEL NOMBRE DE LA TABLA DINAMICAMENTE
        TABLE_NAME_P := 'VENTAS_D'||DIA||'M'||MES;
        
        -- VERIFICAR SI LA TABLA YA EXISTE
        SELECT COUNT(*) INTO CONTADOR_EXISTE FROM USER_TABLES WHERE TABLE_NAME = UPPER(TABLE_NAME_P);
        
        -- SI LA TABLA NO EXISTE, LA CREAMOS
        IF CONTADOR_EXISTE = 0 THEN
            EXECUTE IMMEDIATE 'CREATE TABLE '|| TABLE_NAME_P || '(
                ID_VENTA NUMBER PRIMARY KEY,
                FECHA DATE
                )';
        END IF;
        
        -- INSERTAR LAS VENTAS EN LA TABLA DINAMICA
        EXECUTE IMMEDIATE 'INSERT INTO ' || TABLE_NAME_P || '(ID_VENTA, FECHA)
                            SELECT ID, FECHA FROM VENTA
                            WHERE EXTRACT(DAY FROM FECHA) = :1 AND EXTRACT(MONTH FROM FECHA) = :2'
        USING DIA, MES;
        
        DBMS_OUTPUT.PUT_LINE('VENTAS ALMACENADAS EN LA TABLA: '||TABLE_NAME_P);        
  END INSERTAR_VENTAS_REALIZADAS;

END PKG_VENTA;



CREATE OR REPLACE TRIGGER TRIGGER2 
BEFORE insert  ON venta
FOR EACH ROW 
declare 
stock_actual number;

BEGIN
    select stock INTO STOCK_ACTUAL from producto2 where ID=:new.producto_id;
    if :NEW.subtotal > stock_actual then 
        raise_application_error(-20007, 'EL SUBTOTAL DE LA VENTA NO PUEDE SER MAYOR AL DEL STOCK');
    ELSE UPDATE PRODUCTO2 SET STOCK=STOCK-:NEW.SUBTOTAL WHERE :new.producto_id=id;
    END IF;
        
END;

------------------------------------------------------------------------------------------------------------------------

--COMPROBAR PROCEDURE INSERTAR_VENTAS_REALIZADAS
-- IMPORTANTE!! EJECUTAR ESTOS DOS COMANDOS DESDE SYS O SYSTEM PARA PODER PROBAR EL PKG_VENTA.ALMACENAR_VENTAS_DINAMICO
GRANT CREATE TABLE TO HR;
GRANT UNLIMITED TABLESPACE TO HR;
BEGIN
 PKG_VENTA.INSERTAR_VENTAS_REALIZADAS(1,2);
END;

---COMPROBAR PROCEDURE AGREGAR_VENTA
BEGIN
 PKG_VENTA.agregar_venta(10,1,1,TO_DATE('01-01-2023'),4);
END;

---COMPROBAR PROCEDURE VENTAS_REALIZADAS
SET SERVEROUTPUT ON
BEGIN
 PKG_VENTA.VENTAS_REALIZADAS(1,1);
END;
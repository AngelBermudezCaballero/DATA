-- EXAMEN GENERADO POR DEEPSEEK PARA PRACTICAR.
-- Tabla DEPARTAMENTO  
--CREATE TABLE DEPARTAMENTO (  
--    ID_DEPTO      NUMBER PRIMARY KEY,  
--    NOMBRE        VARCHAR2(50) NOT NULL,  
--    PRESUPUESTO   NUMBER(10,2),  
--    DEPTO_PADRE   NUMBER,  -- Jerarquía departamental (autoreferencia)  
--    CONSTRAINT FK_DEPTO_PADRE FOREIGN KEY (DEPTO_PADRE) REFERENCES DEPARTAMENTO(ID_DEPTO)  
--);  
--
---- Tabla EMPLEADO  
--CREATE TABLE EMPLEADO (  
--    ID_EMPLEADO   NUMBER PRIMARY KEY,  
--    NOMBRE        VARCHAR2(50) NOT NULL,  
--    APELLIDO      VARCHAR2(50) NOT NULL,  
--    SALARIO_BASE  NUMBER(10,2) CHECK (SALARIO_BASE >= 0),  
--    FECHA_INGRESO DATE,  
--    ID_DEPTO      NUMBER,  
--    ID_JEFE       NUMBER,  -- Autoreferencia para jerarquía de empleados  
--    CONSTRAINT FK_DEPTO_EMP FOREIGN KEY (ID_DEPTO) REFERENCES DEPARTAMENTO(ID_DEPTO),  
--    CONSTRAINT FK_JEFE_EMP FOREIGN KEY (ID_JEFE) REFERENCES EMPLEADO(ID_EMPLEADO)  
--);  
--
---- Tabla HISTORIAL_SALARIAL  
--CREATE TABLE HISTORIAL_SALARIAL (  
--    ID_HISTORIAL  NUMBER PRIMARY KEY,  
--    ID_EMPLEADO   NUMBER,  
--    SALARIO_ANTIGUO NUMBER(10,2),  
--    SALARIO_NUEVO  NUMBER(10,2),  
--    FECHA_CAMBIO  DATE,  
--    MOTIVO        VARCHAR2(100),  
--    CONSTRAINT FK_HIST_EMP FOREIGN KEY (ID_EMPLEADO) REFERENCES EMPLEADO(ID_EMPLEADO)  
--);  
--
---- Tabla AUDITORIA_CAMBIOS  
--CREATE TABLE AUDITORIA_CAMBIOS (  
--    ID_AUDITORIA  NUMBER PRIMARY KEY,  
--    TABLA_AFECTADA VARCHAR2(50),  
--    OPERACION     VARCHAR2(10) CHECK (OPERACION IN ('INSERT', 'UPDATE', 'DELETE')),  
--    USUARIO       VARCHAR2(30),  
--    FECHA         TIMESTAMP,  
--    DETALLES      CLOB  -- Almacenará un JSON con los cambios (ej: {"CAMPO": "SALARIO", "VALOR_ANTIGUO": 3000, "VALOR_NUEVO": 3500})  
--);  
--
---- Inserts iniciales
--INSERT INTO DEPARTAMENTO VALUES (1, 'Dirección', 1000000, NULL);  
--INSERT INTO DEPARTAMENTO VALUES (2, 'TI', 500000, 1);  
--INSERT INTO DEPARTAMENTO (ID_DEPTO, NOMBRE, PRESUPUESTO, DEPTO_PADRE) VALUES (3, 'Desarrollo', 600000, 2);
--INSERT INTO DEPARTAMENTO (ID_DEPTO, NOMBRE, PRESUPUESTO, DEPTO_PADRE) VALUES (4, 'Finanzas', 800000, NULL);
--INSERT INTO DEPARTAMENTO (ID_DEPTO, NOMBRE, PRESUPUESTO, DEPTO_PADRE) VALUES (5, 'Recursos Humanos', 500000, NULL);
--INSERT INTO DEPARTAMENTO (ID_DEPTO, NOMBRE, PRESUPUESTO, DEPTO_PADRE) VALUES (6, 'Tecnología', 1200000, NULL);
--INSERT INTO EMPLEADO VALUES (100, 'Carlos', 'Ruiz', 4500, SYSDATE, 1, NULL);  
--INSERT INTO EMPLEADO VALUES (101, 'Laura', 'Sánchez', 3200, SYSDATE, 2, 100);  
--INSERT INTO EMPLEADO (ID_EMPLEADO, NOMBRE, APELLIDO, SALARIO_BASE, FECHA_INGRESO, ID_DEPTO, ID_JEFE) VALUES (103, 'Pedro', 'Lopez', 55000, TO_DATE('2019-08-21', 'YYYY-MM-DD'), 3, 102);
--INSERT INTO EMPLEADO (ID_EMPLEADO, NOMBRE, APELLIDO, SALARIO_BASE, FECHA_INGRESO, ID_DEPTO, ID_JEFE) VALUES (104, 'Ana', 'Martinez', 58000, TO_DATE('2021-01-05', 'YYYY-MM-DD'), 3, 102);
--INSERT INTO EMPLEADO (ID_EMPLEADO, NOMBRE, APELLIDO, SALARIO_BASE, FECHA_INGRESO, ID_DEPTO, ID_JEFE) VALUES (105, 'Luis', 'Ramirez', 62000, TO_DATE('2017-12-10', 'YYYY-MM-DD'), 4, NULL);
--INSERT INTO EMPLEADO (ID_EMPLEADO, NOMBRE, APELLIDO, SALARIO_BASE, FECHA_INGRESO, ID_DEPTO, ID_JEFE) VALUES (106, 'Juan', 'Perez', 40000, TO_DATE('2018-06-12', 'YYYY-MM-DD'), 1, NULL);
--INSERT INTO EMPLEADO (ID_EMPLEADO, NOMBRE, APELLIDO, SALARIO_BASE, FECHA_INGRESO, ID_DEPTO, ID_JEFE) VALUES (107, 'Maria', 'Gomez', 60000, TO_DATE('2020-03-15', 'YYYY-MM-DD'), 2, NULL);

--2.1. Paquete PKG_RRHH
--Implementa un paquete con las siguientes funcionalidades:
--
--Procedimientos:
--    AUMENTAR_SALARIO (p_id_empleado IN NUMBER, p_porcentaje IN NUMBER, p_motivo IN VARCHAR2):
--        Calcula el nuevo salario aplicando el porcentaje al salario base.
--        Registra el cambio en HISTORIAL_SALARIAL.
--        Validación: No permitir aumentos > 20% en una sola operación (lanzar error ORA-20001).
--    REASIGNAR_DEPTO (p_id_empleado IN NUMBER, p_id_depto_nuevo IN NUMBER):
--        Actualiza el departamento del empleado y verifica que el nuevo departamento exista.
--        Si el empleado es jefe de otros, transferir automáticamente a sus subordinados al nuevo departamento.
--    CALCULAR_NOMINA (p_id_depto IN NUMBER):
--        Genera un informe con el total de salarios por departamento, incluyendo bonificación del 5% si el total no supera el presupuesto.
--        Usa un cursor explícito para recorrer empleados y un bucle para acumular totales.
--
--Funciones:
--    OBTENER_JERARQUIA (p_id_empleado IN NUMBER) RETURN VARCHAR2:
--        Retorna la cadena de mando del empleado (ej: "Carlos Ruiz → Laura Sánchez → [Tú]"). Usa recursividad SQL o CONNECT BY.
--    VALIDAR_PRESUPUESTO (p_id_depto IN NUMBER) RETURN BOOLEAN:
--        Retorna TRUE si la suma de salarios del departamento no supera el 70% de su presupuesto.

CREATE OR REPLACE 
PACKAGE PKG_RRHH AS 

    --DECLARACION DE LOS PROCEDIMIENTOS
    PROCEDURE AUMENTAR_SALARIO (p_id_empleado IN NUMBER, p_porcentaje IN NUMBER, p_motivo IN VARCHAR2);
    PROCEDURE REASIGNAR_DEPTO (p_id_empleado IN NUMBER, p_id_depto_nuevo IN NUMBER);
    PROCEDURE CALCULAR_NOMINA (p_id_depto IN NUMBER);
    
    --DECLARACION DE LAS FUNCIONES
    FUNCTION OBTENER_JERARQUIA (p_id_empleado IN NUMBER) RETURN VARCHAR2;
    FUNCTION VALIDAR_PRESUPUESTO (p_id_depto IN NUMBER) RETURN BOOLEAN;
    
END PKG_RRHH;
/


CREATE OR REPLACE
PACKAGE BODY PKG_RRHH AS

    -- FUNCIONES PRIVADAS DEL PAQUETE
    FUNCTION EXISTE_EMPLEADO(ID_V NUMBER) RETURN BOOLEAN AS
      CONTADOR_EXISTE NUMBER := 0;  
    BEGIN
        SELECT COUNT(*) INTO CONTADOR_EXISTE FROM EMPLEADO WHERE ID_EMPLEADO = ID_V;
        IF CONTADOR_EXISTE > 0 THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END EXISTE_EMPLEADO;
    
    FUNCTION EXISTE_DEPARTAMENTO(ID_V NUMBER) RETURN BOOLEAN AS
      CONTADOR_EXISTE NUMBER := 0;  
    BEGIN
        SELECT COUNT(*) INTO CONTADOR_EXISTE FROM DEPARTAMENTO WHERE ID_DEPTO = ID_V;
        IF CONTADOR_EXISTE > 0 THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END EXISTE_DEPARTAMENTO;
    
    FUNCTION ES_JEFE(ID_V NUMBER) RETURN BOOLEAN AS
      CONTADOR_EXISTE NUMBER := 0;  
    BEGIN
        SELECT COUNT(*) INTO CONTADOR_EXISTE FROM EMPLEADO WHERE ID_JEFE = ID_V;
        IF CONTADOR_EXISTE > 0 THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END ES_JEFE;    
    
    -- FUNCIONES PUBLICAS DEL PAQUETE
    PROCEDURE AUMENTAR_SALARIO (p_id_empleado IN NUMBER, p_porcentaje IN NUMBER, p_motivo IN VARCHAR2) AS
        ERROR_MSG VARCHAR2(100);
        SALARIO_BASE_P NUMBER;
        SALARIO_FINAL NUMBER;
        ID_HISTORIAL_V NUMBER;
    BEGIN
        -- COMPROBAMOS QUE SOCIO Y LIBRO EXISTAN
        IF NOT EXISTE_EMPLEADO(p_id_empleado) THEN
            ERROR_MSG := 'EL EMPLEADO ' || p_id_empleado || ' NO EXISTE.';
        ELSIF p_porcentaje > 20 THEN
            ERROR_MSG := 'NO SE PERMITE UN AUMENTO DE MAS DEL 20% EN UNA SOLA OPERACION.';
        END IF;
        
        -- Si hay error, lanzamos la excepción
        IF ERROR_MSG IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20001, ERROR_MSG);
        END IF;
        
        -- GENERAMOS ID_HISTORIAL DE MANERA QUE SE VAYA INCREMENTANDO
        SELECT NVL(MAX(ID_HISTORIAL), 0) + 1 INTO ID_HISTORIAL_V FROM HISTORIAL_SALARIAL;
        
        -- OBTENGO EL SALARIO_BASE Y MODIFICO EL SALARIO FINAL CON EL PORCENTAJE RESPECTO A ESTE
        SELECT SALARIO_BASE INTO SALARIO_BASE_P FROM EMPLEADO WHERE ID_EMPLEADO = p_id_empleado;
        SALARIO_FINAL := SALARIO_BASE_P + (SALARIO_BASE_P * p_porcentaje/100);
        
        UPDATE EMPLEADO SET SALARIO_BASE = SALARIO_FINAL WHERE ID_EMPLEADO = p_id_empleado;
        INSERT INTO HISTORIAL_SALARIAL (ID_HISTORIAL, ID_EMPLEADO, SALARIO_ANTIGUO, SALARIO_NUEVO, FECHA_CAMBIO, MOTIVO) 
        VALUES (ID_HISTORIAL_V, p_id_empleado, SALARIO_BASE_P, SALARIO_FINAL, SYSDATE, p_motivo);
        
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002, 'ERROR AL AUMENTAR EL SALARIO: ' || SQLERRM);
    END AUMENTAR_SALARIO;
    
    PROCEDURE REASIGNAR_DEPTO (p_id_empleado IN NUMBER, p_id_depto_nuevo IN NUMBER) AS
        ERROR_MSG VARCHAR2(100);
        v_subordinados_actualizados NUMBER;
    BEGIN
        -- COMPROBAMOS QUE DEPARTAMENTO Y EMPLEADO EXISTAN
        IF NOT EXISTE_DEPARTAMENTO(p_id_depto_nuevo) THEN
            ERROR_MSG := 'EL DEPARTAMENTO ' || p_id_depto_nuevo || ' NO EXISTE.';
        ELSIF NOT EXISTE_EMPLEADO(p_id_empleado) THEN
            ERROR_MSG := 'EL EMPLEADO ' || p_id_depto_nuevo || ' NO EXISTE.';
        END IF;
        
        -- Si hay error, lanzamos la excepción
        IF ERROR_MSG IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20001, ERROR_MSG);
        END IF;
        
        -- REALIZAMOS EL UPDATE
        UPDATE EMPLEADO SET ID_DEPTO = p_id_depto_nuevo WHERE ID_EMPLEADO = p_id_empleado;
        
        -- EN CASO DE QUE SEA JEFE, CAMBIO TAMBIEN A LOS SUBORDINADOS DE DEPARTAMENTO
        IF ES_JEFE(p_id_empleado) THEN
            UPDATE EMPLEADO SET ID_DEPTO = p_id_depto_nuevo WHERE ID_JEFE = p_id_empleado;
            -- Capturamos el número de filas afectadas
            v_subordinados_actualizados := SQL%ROWCOUNT;
            DBMS_OUTPUT.PUT_LINE('SUBORDINADOS AFECTADOS: ' || v_subordinados_actualizados);
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002, 'ERROR AL REASIGNAR EL DEPARTAMENTO: ' || SQLERRM);
    END REASIGNAR_DEPTO;
    
    PROCEDURE CALCULAR_NOMINA (p_id_depto IN NUMBER) AS
        v_presupuesto      DEPARTAMENTO.PRESUPUESTO%TYPE;
        v_salario_empleado EMPLEADO.SALARIO_BASE%TYPE;
        v_sum_salarios     NUMBER := 0;
        v_total            NUMBER;
        v_count            NUMBER;
        ERROR_MSG          VARCHAR2(100);
        
        -- Cursor explícito para obtener salarios de empleados del departamento
        CURSOR c_empleados IS
            SELECT SALARIO_BASE
            FROM EMPLEADO
            WHERE ID_DEPTO = p_id_depto;
        
    BEGIN
        -- COMPROBAMOS QUE DEPARTAMENTO Y EMPLEADO EXISTAN
        IF NOT EXISTE_DEPARTAMENTO(p_id_depto) THEN
            ERROR_MSG := 'EL DEPARTAMENTO ' || p_id_depto || ' NO EXISTE.';
        END IF;
        
        -- Si hay error, lanzamos la excepción
        IF ERROR_MSG IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20001, ERROR_MSG);
        END IF;
        
        -- Obtener presupuesto del departamento
        SELECT PRESUPUESTO
        INTO v_presupuesto
        FROM DEPARTAMENTO
        WHERE ID_DEPTO = p_id_depto;
        
        -- Calcular suma de salarios usando cursor explícito
        OPEN c_empleados;
        LOOP
            FETCH c_empleados INTO v_salario_empleado;
            EXIT WHEN c_empleados%NOTFOUND;
            v_sum_salarios := v_sum_salarios + v_salario_empleado;
        END LOOP;
        CLOSE c_empleados;
        
        -- Aplicar bonificación del 5% si no supera el presupuesto
        IF v_sum_salarios <= v_presupuesto THEN
            v_total := v_sum_salarios * 1.05;
        ELSE
            v_total := v_sum_salarios;
        END IF;
        
        -- Generar informe por consola
        DBMS_OUTPUT.PUT_LINE('=== INFORME DE NÓMINA ===');
        DBMS_OUTPUT.PUT_LINE('Departamento ID: ' || p_id_depto);
        DBMS_OUTPUT.PUT_LINE('Presupuesto: ' || TO_CHAR(v_presupuesto, 'L999G999G990D00'));
        DBMS_OUTPUT.PUT_LINE('Suma de salarios: ' || TO_CHAR(v_sum_salarios, 'L999G999G990D00'));
        DBMS_OUTPUT.PUT_LINE('Bonificación aplicada: ' || CASE WHEN v_sum_salarios <= v_presupuesto THEN '5%' ELSE '0%' END);
        DBMS_OUTPUT.PUT_LINE('Total a pagar: ' || TO_CHAR(v_total, 'L999G999G990D00'));
        
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Error inesperado: ' || SQLERRM);
    END CALCULAR_NOMINA;
    
    FUNCTION OBTENER_JERARQUIA (p_id_empleado IN NUMBER) RETURN VARCHAR2 AS
        ERROR_MSG VARCHAR2(50);
        V_JERARQUIA VARCHAR2(4000);
    BEGIN
        IF NOT EXISTE_EMPLEADO(p_id_empleado) THEN
            ERROR_MSG := 'EL EMPLEADO ' || p_id_empleado || ' NO EXISTE.';
        END IF;
        
        -- Si hay error, lanzamos la excepción
        IF ERROR_MSG IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20001, ERROR_MSG);
        END IF;
        
        -- Obtener cadena jerárquica usando CONNECT BY
        SELECT 
            LISTAGG(NOMBRE_COMPLETO, ' → ') WITHIN GROUP (ORDER BY LEVEL DESC)
        INTO V_JERARQUIA
        FROM (
            SELECT 
                NOMBRE || ' ' || APELLIDO AS NOMBRE_COMPLETO,
                LEVEL
            FROM EMPLEADO
            START WITH ID_EMPLEADO = (SELECT ID_JEFE FROM EMPLEADO WHERE ID_EMPLEADO = p_id_empleado)
            CONNECT BY PRIOR ID_JEFE = ID_EMPLEADO
        );
        
        -- Manejar caso donde el empleado no tiene jefes
        IF V_JERARQUIA IS NULL THEN
            RETURN 'EMPLEADO SIN JEFES';
        END IF;
    
        RETURN V_JERARQUIA;
    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'EMPLEADO SIN JEFES';  -- Empleado sin jefes
        WHEN OTHERS THEN
            RETURN 'Error: ' || SQLERRM;
    END OBTENER_JERARQUIA;
    
    FUNCTION VALIDAR_PRESUPUESTO (p_id_depto IN NUMBER) RETURN BOOLEAN AS
        ERROR_MSG VARCHAR2(100);
        SUMA_SALARIOS NUMBER;
        PRESUPUESTO_DEPTO NUMBER;
    BEGIN
        -- COMPROBAMOS QUE DEPARTAMENTO Y EMPLEADO EXISTAN
        IF NOT EXISTE_DEPARTAMENTO(p_id_depto) THEN
            ERROR_MSG := 'EL DEPARTAMENTO ' || p_id_depto || ' NO EXISTE.';
        END IF;
        
        -- Si hay error, lanzamos la excepción
        IF ERROR_MSG IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20001, ERROR_MSG);
        END IF;
        
        -- OBTENEMOS LA SUMA TOTAL DE LOS SALARIOS DEL DEPARTAMENTO Y EL PRESUPUESTO DEL DEPARTAMENTO
        SELECT SUM(SALARIO_BASE) INTO SUMA_SALARIOS FROM EMPLEADO WHERE ID_DEPTO = p_id_depto GROUP BY ID_DEPTO;
        SELECT PRESUPUESTO INTO PRESUPUESTO_DEPTO FROM DEPARTAMENTO WHERE ID_DEPTO = p_id_depto;
        
        IF SUMA_SALARIOS <= (PRESUPUESTO_DEPTO*0.7) THEN
            RETURN TRUE;
        ELSE 
            RETURN FALSE;
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20000, 'Error inesperado: ' || SQLERRM);
    END VALIDAR_PRESUPUESTO;

END PKG_RRHH;
/





--2.2. Triggers
--    Trigger de Auditoría Avanzada (Fila + Sentencia):
--        Crea un trigger compuesto que registre en AUDITORIA_CAMBIOS:
--            Para INSERT/DELETE: Detalles completos de la fila afectada en formato JSON.
--            Para UPDATE: Campos modificados con valores antiguos y nuevos.
--        Usa :OLD y :NEW, y la función JSON_OBJECT para construir el CLOB.
--    
--    Trigger de Integridad Jerárquica:
--        Impide que un empleado sea asignado como jefe de alguien en un departamento diferente.
--        Lanza error: 'Un jefe debe pertenecer al mismo departamento que su subordinado'.

-- creacion de la secuencia necesaria para el trigger 1 (AUDITORIA_SEQ)
--CREATE SEQUENCE AUDITORIA_SEQ
--START WITH 1
--INCREMENT BY 1
--NOCACHE;
--/


CREATE OR REPLACE TRIGGER TRG_AUDITORIA_AVANZADA 
FOR INSERT OR UPDATE OR DELETE ON EMPLEADO
COMPOUND TRIGGER

    -- Variables para almacenar detalles de auditoría
    TYPE t_auditoria IS RECORD (
        tabla_afectada  VARCHAR2(50),
        operacion       VARCHAR2(10),
        usuario         VARCHAR2(30),
        detalles        CLOB
    );
    
    v_auditoria t_auditoria;

    -- Procedimiento para registrar auditoría
    PROCEDURE REGISTRAR_AUDITORIA IS
    BEGIN
        INSERT INTO AUDITORIA_CAMBIOS (ID_AUDITORIA, TABLA_AFECTADA, OPERACION, USUARIO, FECHA, DETALLES)
        VALUES (AUDITORIA_SEQ.NEXTVAL, v_auditoria.tabla_afectada, v_auditoria.operacion, v_auditoria.usuario, SYSTIMESTAMP, v_auditoria.detalles);
    END REGISTRAR_AUDITORIA;

    -- Antes de cada fila (para capturar :OLD y :NEW)
    BEFORE EACH ROW IS
    BEGIN
        v_auditoria.tabla_afectada := 'EMPLEADO';
        v_auditoria.usuario := USER;

        IF INSERTING THEN
            v_auditoria.operacion := 'INSERT';
            v_auditoria.detalles := JSON_OBJECT(
                'ID_EMPLEADO' VALUE :NEW.ID_EMPLEADO,
                'NOMBRE' VALUE :NEW.NOMBRE,
                'APELLIDO' VALUE :NEW.APELLIDO,
                'SALARIO_BASE' VALUE :NEW.SALARIO_BASE,
                'FECHA_INGRESO' VALUE TO_CHAR(:NEW.FECHA_INGRESO, 'YYYY-MM-DD'),
                'ID_DEPTO' VALUE :NEW.ID_DEPTO,
                'ID_JEFE' VALUE :NEW.ID_JEFE
            );
        ELSIF UPDATING THEN
            v_auditoria.operacion := 'UPDATE';
            v_auditoria.detalles := JSON_OBJECT(
                'CAMPO' VALUE CASE
                    WHEN :OLD.NOMBRE != :NEW.NOMBRE THEN 'NOMBRE'
                    WHEN :OLD.APELLIDO != :NEW.APELLIDO THEN 'APELLIDO'
                    WHEN :OLD.SALARIO_BASE != :NEW.SALARIO_BASE THEN 'SALARIO_BASE'
                    WHEN :OLD.FECHA_INGRESO != :NEW.FECHA_INGRESO THEN 'FECHA_INGRESO'
                    WHEN :OLD.ID_DEPTO != :NEW.ID_DEPTO THEN 'ID_DEPTO'
                    WHEN :OLD.ID_JEFE != :NEW.ID_JEFE THEN 'ID_JEFE'
                END,
                'VALOR_ANTIGUO' VALUE CASE
                    WHEN :OLD.NOMBRE != :NEW.NOMBRE THEN :OLD.NOMBRE
                    WHEN :OLD.APELLIDO != :NEW.APELLIDO THEN :OLD.APELLIDO
                    WHEN :OLD.SALARIO_BASE != :NEW.SALARIO_BASE THEN TO_CHAR(:OLD.SALARIO_BASE)
                    WHEN :OLD.FECHA_INGRESO != :NEW.FECHA_INGRESO THEN TO_CHAR(:OLD.FECHA_INGRESO, 'YYYY-MM-DD')
                    WHEN :OLD.ID_DEPTO != :NEW.ID_DEPTO THEN TO_CHAR(:OLD.ID_DEPTO)
                    WHEN :OLD.ID_JEFE != :NEW.ID_JEFE THEN TO_CHAR(:OLD.ID_JEFE)
                END,
                'VALOR_NUEVO' VALUE CASE
                    WHEN :OLD.NOMBRE != :NEW.NOMBRE THEN :NEW.NOMBRE
                    WHEN :OLD.APELLIDO != :NEW.APELLIDO THEN :NEW.APELLIDO
                    WHEN :OLD.SALARIO_BASE != :NEW.SALARIO_BASE THEN TO_CHAR(:NEW.SALARIO_BASE)
                    WHEN :OLD.FECHA_INGRESO != :NEW.FECHA_INGRESO THEN TO_CHAR(:NEW.FECHA_INGRESO, 'YYYY-MM-DD')
                    WHEN :OLD.ID_DEPTO != :NEW.ID_DEPTO THEN TO_CHAR(:NEW.ID_DEPTO)
                    WHEN :OLD.ID_JEFE != :NEW.ID_JEFE THEN TO_CHAR(:NEW.ID_JEFE)
                END
            );
        ELSIF DELETING THEN
            v_auditoria.operacion := 'DELETE';
            v_auditoria.detalles := JSON_OBJECT(
                'ID_EMPLEADO' VALUE :OLD.ID_EMPLEADO,
                'NOMBRE' VALUE :OLD.NOMBRE,
                'APELLIDO' VALUE :OLD.APELLIDO,
                'SALARIO_BASE' VALUE :OLD.SALARIO_BASE,
                'FECHA_INGRESO' VALUE TO_CHAR(:OLD.FECHA_INGRESO, 'YYYY-MM-DD'),
                'ID_DEPTO' VALUE :OLD.ID_DEPTO,
                'ID_JEFE' VALUE :OLD.ID_JEFE
            );
        END IF;
    END BEFORE EACH ROW;

    -- Después de cada sentencia (para registrar auditoría)
    AFTER STATEMENT IS
    BEGIN
        REGISTRAR_AUDITORIA;
    END AFTER STATEMENT;

END TRG_AUDITORIA_AVANZADA;
/




CREATE OR REPLACE TRIGGER TRG_INTEGRIDAD_JERARQUICA
BEFORE INSERT OR UPDATE ON EMPLEADO
FOR EACH ROW
DECLARE
    v_depto_jefe DEPARTAMENTO.ID_DEPTO%TYPE;
    v_depto_subordinado DEPARTAMENTO.ID_DEPTO%TYPE;
    ex_jefe_departamento_diferente EXCEPTION;
BEGIN
    -- Verificar si se está asignando un jefe (ID_JEFE no es NULL)
    IF :NEW.ID_JEFE IS NOT NULL THEN
        -- Obtener el departamento del jefe
        SELECT ID_DEPTO
        INTO v_depto_jefe
        FROM EMPLEADO
        WHERE ID_EMPLEADO = :NEW.ID_JEFE;

        -- Obtener el departamento del subordinado
        SELECT ID_DEPTO
        INTO v_depto_subordinado
        FROM EMPLEADO
        WHERE ID_EMPLEADO = :NEW.ID_EMPLEADO;

        -- Comparar departamentos
        IF v_depto_jefe != v_depto_subordinado THEN
            RAISE ex_jefe_departamento_diferente;
        END IF;
    END IF;

EXCEPTION
    WHEN ex_jefe_departamento_diferente THEN
        RAISE_APPLICATION_ERROR(-20005, 'Un jefe debe pertenecer al mismo departamento que su subordinado.');
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20006, 'El jefe o el subordinado no existen en la base de datos.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20000, 'Error inesperado: ' || SQLERRM);
END TRG_INTEGRIDAD_JERARQUICA;
/





--2.3. SQL Dinámico y Transacciones
--    Crea un procedimiento GENERAR_REPORTE_ANUAL (p_anio IN NUMBER) que:
--        Cree una tabla particionada por mes: REPORTE_NOMINA_[año] (ej: REPORTE_NOMINA_2024).
--        Inserte en cada partición los datos de nómina mensual (empleado, salario, bonificación).
--        Utiliza EXECUTE IMMEDIATE con parámetros dinámicos y maneja transacciones para asegurar atomicidad.

CREATE OR REPLACE PROCEDURE GENERAR_REPORTE_ANUAL(p_anio IN NUMBER) AS
    V_NOMBRE_TABLA VARCHAR2(50);
    CONTADOR_EXISTE NUMBER;
BEGIN
    -- CREACION DEL NOMBRE DE LA TABLA DINAMICA
    V_NOMBRE_TABLA := 'REPORTE_NOMINA_'||p_anio;
    
    -- VERIFICAMOS SI EXISTE YA LA TABLA ANTES DE CREARLA
    SELECT COUNT(*) INTO CONTADOR_EXISTE FROM USER_TABLES WHERE TABLE_NAME = V_NOMBRE_TABLA;
    
    IF CONTADOR_EXISTE > 0 THEN
        EXECUTE IMMEDIATE 'CREATE TABLE ' || V_NOMBRE_TABLA || ' (
                            ID_EMPLEADO NUMBER,
                            NOMBRE VARCHAR2(100),
                            SALARIO NUMBER(10,2),
                            BONIFICACION NUMBER(10,2),
                            MES NUMBER(2),
                            CONSTRAINT PK_' || V_NOMBRE_TABLA || ' PRIMARY KEY (ID_EMPLEADO, MES)
                          ) PARTITION BY LIST (MES) (
                            PARTITION P_ENE VALUES (1),
                            PARTITION P_FEB VALUES (2),
                            PARTITION P_MAR VALUES (3),
                            PARTITION P_ABR VALUES (4),
                            PARTITION P_MAY VALUES (5),
                            PARTITION P_JUN VALUES (6),
                            PARTITION P_JUL VALUES (7),
                            PARTITION P_AGO VALUES (8),
                            PARTITION P_SEP VALUES (9),
                            PARTITION P_OCT VALUES (10),
                            PARTITION P_NOV VALUES (11),
                            PARTITION P_DIC VALUES (12)
                          )';
    END IF;
    
    -- INICIO DE LA TRANSACCION
    BEGIN
        -- INSERCIÓN DE DATOS EN LA TABLA RECIÉN CREADA
        FOR MES IN 1..12 LOOP
            EXECUTE IMMEDIATE 'INSERT INTO ' || V_NOMBRE_TABLA || ' (ID_EMPLEADO, NOMBRE, SALARIO, BONIFICACION, MES)
                               SELECT ID_EMPLEADO, NOMBRE, SALARIO, BONIFICACION, ' || MES || '
                               FROM NOMINA
                               WHERE EXTRACT(YEAR FROM FECHA_PAGO) = :1
                               AND EXTRACT(MONTH FROM FECHA_PAGO) = :2'
            USING p_anio, MES;
        END LOOP;
        
        COMMIT; -- CONFIRMAMOS LA TRANSACCIÓN SI TODO SALE BIEN
        DBMS_OUTPUT.PUT_LINE('Reporte anual generado en la tabla: ' || V_NOMBRE_TABLA);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; -- DESHACER LOS CAMBIOS SI OCURRE ALGÚN ERROR
            RAISE_APPLICATION_ERROR(-20001, 'Error al generar el reporte anual: ' || SQLERRM);
    END;
    
END GENERAR_REPORTE_ANUAL;
/





--3. Requisitos Adicionales
--    Implementa bloques autónomos para registrar auditorías sin afectar transacciones principales.
--    Usa %ROWTYPE y colecciones PL/SQL (ej: VARRAY) en cálculos de nómina.
--    Incluye manejo de excepciones personalizadas (ej: salario negativo, departamento inexistente).
--    Optimiza el código para evitar bloqueos con FOR UPDATE NOWAIT en operaciones críticas.










































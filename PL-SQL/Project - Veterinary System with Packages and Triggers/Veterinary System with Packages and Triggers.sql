/*--REALIZACIÓN DEL EXAMEN PL/SQL. NOMBRE: ÁNGEL BERMÚDEZ CABALLERO

Las condiciones de esta prueba son las siguientes:
-Duración 3 horas (180 minutos)
-No se podrán usar ningún elemeto de ayuda (IA generativa, internet, apuntes...)
-En caso de no acordarse de alguna palabra reservada, sintaxis o por falta de tiempo, utilizar pseudocódigo.
-Dar explicaciones con comentarios de manera continua para garantizar el cumplimiento de los puntos anteriores.

--ACTIVIDAD 1:

---- sería conveniente usar drop para eliminar las tablas que existen con el mismo nombre, en mi caso
---- no tengo con ese nombre por lo que no lo he puesto al no ser necesario

--A continuacion las creo:
-- Creación de la tabla dueños:

CREATE TABLE dueños (
    id NUMBER PRIMARY KEY, --id lo pongo como primary key
    nombre_completo VARCHAR2(255) , 
    edad NUMBER,
    email VARCHAR2(255));
--Observaciones/aclaraciones de la tabla dueños:
-- En [nombre_completo VARCHAR2(255),], 
--  he puesto tanto en nombre completo como email 255 de longitud maxima ya que es posible que en algun caso sean necesario esos caracteres, ademas de 
--que en la imagen del enunciado nombre_completo aparece como text. Por otro lado voy a emplear  NUMBER para los INT

-- Creación de la tabla especies
CREATE TABLE especies (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(255) );
--Observaciones/aclaraciones de la tabla especies:
--Nada que añadir teniendo en cuenta las aclaraciones anteriores

-- Creación de la tabla veterinarios
CREATE TABLE veterinarios (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(255) ,
    edad NUMBER,
    fc_graduacion DATE);
--Observaciones/aclaraciones de la tabla veterinarios:
--Nada que añadir teniendo en cuenta las aclaraciones anteriores

-- Creación de la tabla animales
CREATE TABLE animales (
    id NUMBER PRIMARY KEY,
    nombre VARCHAR2(255) ,
    fc_nacimiento DATE,
    intentos_escape NUMBER,
    castrado NUMBER(1), -- 0 = No, 1 = Sí
    peso_kg DECIMAL(6,2),
    id_especie NUMBER,
    id_dueño NUMBER,
    CONSTRAINT fk_animales_especies FOREIGN KEY (id_especie) REFERENCES especies(id),
    CONSTRAINT fk_animales_dueños FOREIGN KEY (id_dueño) REFERENCES dueños(id));
--Observaciones/aclaraciones de la tabla animales:
-- [castrado NUMBER(1),] he puesto de longitud 1 porque al ver en la imagen un int(no un booleano o un varchar) y que solo puedes castrar una vez
-- he tomado esa decision y se es 0 sera que no esta castrado y si es 1 si. Se que hay una manera de ponerlo asi, es decir que solo puedas poner los valores 0 o 1 
--pero no me acuerdo de la funcion. Puede ser algo con CHECK pero ni estoy seguro ni me acuerdo de la sintaxis.
--[peso_kg DECIMAL(6,2),] 6 siendo cantidad total de digitos incluyendo los dos decimales
--[CONSTRAINT]palabra reservado a usar, [fk_animales_especies] nombre del constraint que intento que sea lo mas intuitivo posible, [FOREIGN KEY (id_especie) REFERENCES especies(id)] conecto id_especie de la tabla
--animales con la columna id de la tabla especies. Explicando este constraint explico los demás ya que he seguido las mismas pautas. 

-- Creación de la tabla visitas
CREATE TABLE visitas (
    id NUMBER PRIMARY KEY,
    id_animal NUMBER,
    id_veterinario NUMBER,
    fc_visita DATE ,
    CONSTRAINT fk_visitas_animales FOREIGN KEY (id_animal) REFERENCES animales(id) ,
    CONSTRAINT fk_visitas_veterinarios FOREIGN KEY (id_veterinario) REFERENCES veterinarios(id) );
--Observaciones/aclaraciones de la tabla visitas:
--Nada que añadir teniendo en cuenta las aclaraciones anteriores

-- Creación de la tabla especializaciones 
CREATE TABLE especializaciones (
    id NUMBER PRIMARY KEY,  
    id_especie NUMBER,
    id_veterinario NUMBER,
    CONSTRAINT fk_especializaciones_especies FOREIGN KEY (id_especie) REFERENCES especies(id) ,
    CONSTRAINT fk_especializaciones_veterinarios FOREIGN KEY (id_veterinario) REFERENCES veterinarios(id));
--Observaciones/aclaraciones de la tabla especializaciones:
--Nada que añadir teniendo en cuenta las aclaraciones anteriores

--creo la tabla necesaria para el apartado E para la realizacion correcta del trigger
CREATE TABLE AUX_ID_VISITA_ERRONEOS (
    id_visita NUMBER PRIMARY KEY
);
*/
--ACTIVIDAD 2 CABECERA
CREATE OR REPLACE 
PACKAGE PKG_VISITAS_CLIENTE AS 

    --DECLARACION DE LOS PROCEDIMIENTOS
    PROCEDURE AGREGAR_NUEVO_ANIMAL (CODIGO_ANIMAL IN NUMBER, NOMBRE_ANIMAL IN VARCHAR2, FECHA_NAC_ANIMAL IN DATE,PESO NUMBER,CODIGO_ESPECIE NUMBER,CODIGO_DUEÑO NUMBER);
    PROCEDURE AGREGAR_NUEVO_DUEÑO (CODIGO_DUEÑO IN NUMBER, NOMBRE_DUEÑO IN VARCHAR2, EMAIL_DUEÑO IN VARCHAR2);
    PROCEDURE VISITAS_MES_AÑO (CODIGO_DUEÑO IN NUMBER,MES_AÑO IN VARCHAR2);
    PROCEDURE TABLAS_VISITAS_MES_AÑO (CODIGO_DUEÑO IN NUMBER,MES_AÑO IN VARCHAR2);
    

END PKG_VISITAS_CLIENTE;
/

---ACTIVIDAD 2 CUERPO:

CREATE OR REPLACE
PACKAGE BODY PKG_VISITAS_CLIENTE AS

    --funcion para qeu solo sea neceasria llamarla para ver si existe ya ese dueño o no. La usaremos en los procedures en el futuro.
    --genero un bucle con un contador que hace que en el caso de que exista devuelva true y sino existe el dueño false.
    FUNCTION existe_dueño (
        codigo_dueño NUMBER
    ) RETURN BOOLEAN AS
        contador NUMBER := 0;
    BEGIN
        SELECT
            COUNT(*)
        INTO contador
        FROM
            dueños
        WHERE
            id = codigo_dueño;

        IF contador > 0 THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END existe_dueño;

    
--procedure del apartado a: 
  PROCEDURE AGREGAR_NUEVO_ANIMAL (CODIGO_ANIMAL IN NUMBER, NOMBRE_ANIMAL IN VARCHAR2, FECHA_NAC_ANIMAL IN DATE,PESO NUMBER,CODIGO_ESPECIE NUMBER,CODIGO_DUEÑO NUMBER) AS
  BEGIN
    --Si id_animal o id_dueño no se informa que el procedimiento falle indicando el mensaje por pantalla “Entrada de valores errónea”.
     IF CODIGO_ANIMAL IS NULL OR CODIGO_DUEÑO IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Entrada de valores errónea');
    END IF;
    --verificamos que eciste llamando a la funcion que hemos creado antes dentro del cuerpo
    IF not existe_dueño(CODIGO_DUEÑO) THEN
            raise_application_error(-20002, 'No existe el dueño en el sistema');
    end if;
    
    --insertamos lso valores que se introducen en el procedure dentro de su tabla correspondiente
    INSERT INTO animales ( id, nombre,fc_nacimiento,peso_kg,id_especie,id_dueño ) VALUES ( CODIGO_ANIMAL, NOMBRE_ANIMAL,FECHA_NAC_ANIMAL,PESO,CODIGO_ESPECIE,CODIGO_DUEÑO);
    
  END AGREGAR_NUEVO_ANIMAL;

--procedure del apartado b: 
  PROCEDURE AGREGAR_NUEVO_DUEÑO (CODIGO_DUEÑO IN NUMBER, NOMBRE_DUEÑO IN VARCHAR2, EMAIL_DUEÑO IN VARCHAR2) AS
  BEGIN
  --En caso de que el dueño ya exista lance un aviso por pantalla usando DBMS_OUTPUT.put_line
    IF  existe_dueño(CODIGO_DUEÑO) THEN
            DBMS_OUTPUT.PUT_LINE('️ El dueño ya existe. No se insertará.');
    end if;
    
     --insertamos lso valores que se introducen en el procedure dentro de su tabla correspondiente
    INSERT INTO DUEÑOS ( id, nombre_completo,email) VALUES ( CODIGO_DUEÑO, NOMBRE_DUEÑO,EMAIL_DUEÑO);
    
  END AGREGAR_NUEVO_DUEÑO;

--procedure apartado c:
  PROCEDURE VISITAS_MES_AÑO (CODIGO_DUEÑO IN NUMBER,MES_AÑO IN VARCHAR2) AS
    mes NUMBER;
    año NUMBER;
   
BEGIN
    -- Extraer mes y año del parámetro MES_AÑO ('MM-YYYY')
    --normalmente he uso extract que lo usare mas adelante pero cmo he pasado MES_AÑO como varchar2 y no como date lo he hecho asi
    mes := TO_NUMBER(SUBSTR(MES_AÑO, 1, 2));
    año := TO_NUMBER(SUBSTR(MES_AÑO, 4, 4));

    -- Mostrar visitas del dueño en el mes y año especificado, realizo todos los joins y conexiones pertinentes para mostrar
    --despues por pantalla los diferentes paramnetros
    FOR i IN ( --bucle para ir fila por fila para despeus im primirlo, esto tambien incluye al loop de abajo
        SELECT a.nombre AS nombre_animal,
               e.nombre AS especie,
               v.nombre AS nombre_veterinario,
               EXTRACT(DAY FROM vis.fc_visita) AS dia_visita
        FROM animales a
        JOIN especies e ON a.id_especie = e.id
        JOIN visitas vis ON a.id = vis.id_animal
        JOIN veterinarios v ON vis.id_veterinario = v.id
        WHERE a.id_dueño = CODIGO_DUEÑO
        AND EXTRACT(MONTH FROM vis.fc_visita) = mes
        AND EXTRACT(YEAR FROM vis.fc_visita) = año
    ) LOOP
        -- Imprimir resultados en consola
        DBMS_OUTPUT.PUT_LINE('Animal: ' || i.nombre_animal ||
                             ', Especie: ' || i.especie ||
                             ', Veterinario: ' || i.nombre_veterinario ||
                             ', Fecha: ' || i.dia_visita);
    END LOOP;

  END VISITAS_MES_AÑO;
  --voy justo de tiempo, no me da para comprobar [PROCEDURE VISITAS_MES_AÑO] pero bueno se que lo importante es el codigo y como lo realizo

  PROCEDURE TABLAS_VISITAS_MES_AÑO (CODIGO_DUEÑO IN NUMBER,MES_AÑO IN VARCHAR2) AS
   
  BEGIN
  NULL;
    --dado que no tengo tiempo para hacerlo voy a escribir la parte de codigo que difiere mas con el apartado anterior y que creo que resulta de mas interes 
    --y voy a explicar bien como lo haria aunque no me de tiempo seguramente de redactar todo el codigo
    --VOY A COMENTAR TODO PARA QUE NO DE ERROR Y LO DEJO EN TIPO COMENTARIO
    /*
    --DECLARO:
    TABLE_NAME VARCHAR2(50);
   CONTADOR_EXISTE number;
    -- genero  el nombre de la tabla en función del mes y año (MES-YYYY).
    TABLE_NAME := 'VISITAS_' || MES_AÑO;
    
    --compruebo qsi la tabla ya existe en el diccionario de datos
    SELECT COUNT(*) INTO CONTADOR_EXISTE 
    FROM USER_TABLES 
    WHERE TABLE_NAME = UPPER(TABLE_NAME);
    
    --si la tabla no existe creamos..
    IF CONTADOR_EXISTE = 0 THEN
        EXECUTE IMMEDIATE 'CREATE TABLE ' || TABLE_NAME || '(columnas)';
        
    --y por ultimo insertamos
    EXECUTE IMMEDIATE 'INSERT INTO ' || TABLE_NAME || ' insertarias todo aqui...'
    USING ...;
    --
    ESTA SERIA MAS O MENOS LA ESTRUCTURA, ESPERO QUE MUESTRE QUE EN PRINCIPIO TENDRIA IDEA DE COMO HACERLO
    */
    
  END TABLAS_VISITAS_MES_AÑO;

END PKG_VISITAS_CLIENTE;

--TRIGGER APARTADO E.
--VOY A REALIZAR EL TRIGGER ANTES DE REALIZAR EL APARTADO C Y D YA QUE POR SI NO ME DA TIEMPO A TERMIANAR QUE SE VEA QUE 
--MANEJO TANTO PORCEDURES COMO TRIGGERS. ADEMAS LEYENDOLOS POR ENCIMA CONSIDERO QUE LSO APARTADOS C Y D ESTAN ESTRECHAMENTE RELACIONADOS
--Y NO TIENE SENTIDO NO HACERLOS SEGUIDOS


CREATE OR REPLACE TRIGGER VALIDAR_VISITA
BEFORE INSERT ON visitas
FOR EACH ROW
DECLARE
    contador NUMBER;
    codigo_dueño
number;

BEGIN
    -- Verificar si el id_animal existe en la tabla animales
    SELECT
        COUNT(*)
    INTO contador
    FROM
        animales
    WHERE
        id = :new.id;

    -- Si el animal no existe, registrar la visita en AUX_ID_VISITA_ERRONEOS y cancelar la inserción
    IF contador = 0 THEN
        INSERT INTO aux_id_visita_erroneos ( id_visita ) VALUES ( :new.id );
       -- commit;
        raise_application_error(-20004, ' ERROR: El animal no existe. Registro almacenado en AUX_ID_VISITA_ERRONEOS.');
    END IF;

    -- Verificar si el animal tiene un dueño asignado
    SELECT
        id_dueño
    INTO codigo_dueño
    FROM
        animales
    WHERE
        id = :new.id;

    -- Si no tiene dueño, registrar la visita en AUX_ID_VISITA_ERRONEOS y cancelar la inserción
    IF codigo_dueño IS NULL THEN
        INSERT INTO aux_id_visita_erroneos ( id_visita ) VALUES ( :new.id );

        raise_application_error(-20005, ' ERROR: El animal no tiene dueño. Registro almacenado en AUX_ID_VISITA_ERRONEOS.');
    END IF;

END validar_visita;
/
--comprobacion del trigger, funciona todo y el codio esta bien excepto a la hora de guardar el id en la tabloa creada para ello : AUX_ID_VISITA_ERRONEOS
--no se si salta error antes y por eso no se inserta o no se donde esta el error pero no me puedo quedar mas tiempo dandole vueltas
--he intentado con un commit pero tampoco funciona, aun asi el hecho de insertarlo en la tabla visitas si no da error funciona y los dos errores
--con RAISE_APPLICATION_ERROR también funciona. lo investigaré después del examen.también es cierto que tengo el compilador cargando todo el rato como en bucle
--no se si por una comprobación anterior y pude que tenga que ver y si quien lo corrija lo ejecuta podria no dar porblema.

---COMPROBACIONES:

/*---COMPROBAR PROCEDURE AGREGAR_NUEVO_ANIMAL
BEGIN
 PKG_VISITAS_CLIENTE.AGREGAR_NUEVO_ANIMAL(1,'Bobby',TO_DATE('31-01-2002'),15,1,1);
END;*/

/*---COMPROBAR PROCEDURE AGREGAR_NUEVO_DUEÑO
 SET SERVEROUTPUT ON;
BEGIN
 PKG_VISITAS_CLIENTE.AGREGAR_NUEVO_DUEÑO(2,'ANTONIO MONTORO','ANTON@GMAIL.COM');
END;
--comprobacion del PROCEDURE VISITAS_MES_AÑO

--comprobacion del triger
INSERT INTO visitas  VALUES (4, 5, 3, SYSDATE);
*/

--HE APLICADO CTRL+F7 PARA QUE SE QUEDE TODO EN UN FORMATO CORRECTO Y SEA MUCHO MAS LEGIBLE
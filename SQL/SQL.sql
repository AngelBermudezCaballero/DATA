USE AdventureWorks2022

-- Ejercicio 1 --

-- 1.
SELECT BirthDate, COUNT(BusinessEntityID) n_employees
	FROM HumanResources.Employee
	GROUP BY BirthDate



-- 2.
SELECT BirthDate, COUNT(BusinessEntityID) n_employees
	FROM HumanResources.Employee
	GROUP BY BirthDate
	HAVING COUNT(BusinessEntityID) > 1



-- 3.
WITH countbirth AS (
	SELECT BirthDate, COUNT(BusinessEntityID) n_employees
		FROM HumanResources.Employee
		GROUP BY BirthDate
		HAVING COUNT(BusinessEntityID) > 1
),

-- Teniendo ya los empleados que cumplen años en el mismo día, los sumamos
sumequalbirth AS (
	SELECT SUM(n_employees) subtotal_employees
		FROM countbirth)

-- Juntamos las dos tablas directamente en el from ya que no hace falta que esten relacionadas
SELECT * 
	FROM countbirth, sumequalbirth



-- 4.
WITH countbirth AS (
	SELECT BirthDate, COUNT(BusinessEntityID) n_employees
		FROM HumanResources.Employee
		GROUP BY BirthDate
		HAVING COUNT(BusinessEntityID) > 1
),

sumequalbirth AS (
	SELECT SUM(n_employees) subtotal_employees
		FROM countbirth),

-- Contamos el número de empleados
countemployees AS (
	SELECT COUNT(*) tot_employes
		FROM HumanResources.Employee)

-- Juntamos las tablas sin relación en el from ya que no hace falta que esten relacionadas
SELECT * 
	FROM countbirth, sumequalbirth, countemployees



-- 5.
WITH countbirth AS (
	SELECT BirthDate, COUNT(BusinessEntityID) n_employees
		FROM HumanResources.Employee
		GROUP BY BirthDate
		HAVING COUNT(BusinessEntityID) > 1
),

sumequalbirth AS (
	SELECT SUM(n_employees) subtotal_employees
		FROM countbirth),

countemployees AS (
	SELECT COUNT(*) tot_employes
		FROM HumanResources.Employee)

-- Multiplicamos subtotal_employees por 1.00 para poder calcular con decimales
SELECT *, subtotal_employees * 1.00 / tot_employes prob_sameBirthday
	FROM countbirth, sumequalbirth, countemployees



-- 6.
WITH countbirth AS (
	SELECT BirthDate, COUNT(BusinessEntityID) n_employees
		FROM HumanResources.Employee
		GROUP BY BirthDate
		HAVING COUNT(BusinessEntityID) > 1
)

-- Esto devuelve el mayor número de empleados que cumplen el mismo día
SELECT MAX(n_employees) max_n_employees
	FROM countbirth

-- No hay 3 personas que cumplan años el mismo día



-- EJERCICIO 2 --

-- 1. A)

-- 2. C)

-- 3. C)

-- 4. B) Y D)

-- 5. D)

-- 6. B)



-- EJERCICIO 3 --

-- 1.
SELECT edh.DepartmentID, COUNT(*) n_employees
	FROM HumanResources.EmployeeDepartmentHistory edh
	JOIN HumanResources.Employee e
	ON edh.BusinessEntityID = e.BusinessEntityID
	GROUP BY edh.DepartmentID
	HAVING COUNT(*) <= 4



-- 2.
SELECT e.OrganizationNode, e.OrganizationLevel, e.JobTitle, e.BusinessEntityID
	FROM HumanResources.Employee e
	JOIN HumanResources.EmployeeDepartmentHistory edh
	ON edh.BusinessEntityID = e.BusinessEntityID
	
	-- Utilizamos IN para comparar entre varios valores y ver si alguno coincide, 
	-- usando la consulta anterior como una subconsulta para devolver el listado de departamentos y comparar
	WHERE edh.DepartmentID IN (SELECT edh.DepartmentID
									FROM HumanResources.EmployeeDepartmentHistory edh
									JOIN HumanResources.Employee e
									ON edh.BusinessEntityID = e.BusinessEntityID
									GROUP BY edh.DepartmentID
									HAVING COUNT(*) <= 4)
	ORDER BY e.BusinessEntityID



-- 3.
SELECT e.OrganizationNode, e.OrganizationLevel, e.JobTitle, e.BusinessEntityID, ea.EmailAddress
	FROM HumanResources.Employee e
	JOIN HumanResources.EmployeeDepartmentHistory edh
	ON edh.BusinessEntityID = e.BusinessEntityID
	
	-- UTILIZAMOS UN LEFT JOIN PARA DEJAR VALORES NULOS SI NO EXISTE EL EMAIL
	LEFT JOIN Person.EmailAddress ea

	-- Relaciono directamente BusinessEntityID de la tabla Employee con BusinessEntityID de la tabla EmailAddress,
	-- ya que al tener la tabla Person la columna BusinessEntityID como PK y una FK directa con la tabla Employee
	-- y tener en la tabla EmailAddress la columna BusinessEntityID como PK y una FK directa a la tabla Person, están directamente relacionadas
	ON e.BusinessEntityID = ea.BusinessEntityID
	WHERE edh.DepartmentID IN (SELECT edh.DepartmentID
									FROM HumanResources.EmployeeDepartmentHistory edh
									JOIN HumanResources.Employee e
									ON edh.BusinessEntityID = e.BusinessEntityID
									GROUP BY edh.DepartmentID
									HAVING COUNT(*) <= 4)
	ORDER BY e.BusinessEntityID



-- 4.
SELECT e.OrganizationNode, e.OrganizationLevel, e.JobTitle, e.BusinessEntityID, ea.EmailAddress,

		-- Comprueba si existe un @ en el email
		CASE WHEN CHARINDEX('@', ea.EmailAddress) > 1 

				-- Si existe, nos quedamos con toda la parte izquierda incluyendo @ y añadimos 'test.com'
			THEN CONCAT(LEFT(ea.EmailAddress, CHARINDEX('@', ea.EmailAddress)), 'test.com') 
			ELSE ea.EmailAddress
		END
	FROM HumanResources.Employee e
	JOIN HumanResources.EmployeeDepartmentHistory edh
	ON edh.BusinessEntityID = e.BusinessEntityID
	LEFT JOIN Person.EmailAddress ea
	ON e.BusinessEntityID = ea.BusinessEntityID
	WHERE edh.DepartmentID IN (SELECT edh.DepartmentID
									FROM HumanResources.EmployeeDepartmentHistory edh
									JOIN HumanResources.Employee e
									ON edh.BusinessEntityID = e.BusinessEntityID
									GROUP BY edh.DepartmentID
									HAVING COUNT(*) <= 4)
	ORDER BY e.BusinessEntityID



-- EJERCICIO 4 --

-- 1.
SELECT p.BusinessEntityID, p.FirstName, p.LastName, pp.PhoneNumber, ea.EmailAddress
	FROM Person.Person p

	-- LEFT JOIN para mostrar también los empleados que no tienen número de teléfono 
	LEFT JOIN Person.PersonPhone pp
	ON p.BusinessEntityID = pp.BusinessEntityID

	-- LEFT JOIN para mostrar también los empleados que no tienen email
	LEFT JOIN Person.EmailAddress ea
	ON ea.BusinessEntityID = p.BusinessEntityID

	-- Comprobamos que solo sean empleados comparando el ID de la persona con los ID que están en la tabla de empleados
	WHERE p.BusinessEntityID IN (SELECT BusinessEntityID FROM HumanResources.Employee);

-- 2.
SELECT p.BusinessEntityID, p.FirstName, p.LastName, pp.PhoneNumber, ea.EmailAddress
	FROM Person.Person p
	LEFT JOIN Person.PersonPhone pp
	ON p.BusinessEntityID = pp.BusinessEntityID
	LEFT JOIN Person.EmailAddress ea
	ON ea.BusinessEntityID = p.BusinessEntityID

	-- Añadimos la tabla de ventas con un left para detectar los empleados que no han hecho ventas a traves de nulos
	LEFT JOIN Sales.SalesOrderHeader soh

	-- Unimos las tablas de person con BusinessEntityID con SalesPersonID de la tabla SalesOrderHeader
	-- ya que están relacionados a través de la tabla SalesPerson, donde la PK de la tabla SalesPerson es BusinessEntityID
	-- que está relacionada con la PK de la tabla Employee
	-- y tiene una FK de esta columna a la columna SalesPersonID de la tabla SalesOrderHeader.
	-- No hace falta unir la tabla employee ya que en el WHERE comprobamos las personas sean trabajadores
	ON p.BusinessEntityID = soh.SalesPersonID

	-- Comprobamos que las personas sean trabajadores por lo que no hace falta unir la tabla Employee
	WHERE p.BusinessEntityID IN (SELECT BusinessEntityID FROM HumanResources.Employee) 
		
		-- Filtramos por los empleados que no tienen un SalesPersonID en la tabla SalesOrderHeader
		-- por lo que no han hecho nunca ninguna venta
		AND soh.SalesPersonID IS NULL

-- 3.
SELECT p.FirstName, p.LastName, YEAR(OrderDate) Año, COUNT(SalesOrderID) NVentas
	FROM Person.Person p

	-- Hacemos un INNER JOIN para dejar las personas que solo tengan ventas
	JOIN Sales.SalesOrderHeader soh

	-- Sabemos que BusinessEntityID de Person está relacionado con SalesPersonID de Ventas
	-- y en el where comprobamos que las personas sean trabajadores por lo que no hace falta unir la tabla Employee
	ON p.BusinessEntityID = soh.SalesPersonID
	WHERE p.BusinessEntityID IN (SELECT BusinessEntityID FROM HumanResources.Employee) 
	GROUP BY p.FirstName, p.LastName, YEAR(OrderDate)
	ORDER BY FirstName, Año DESC

# Columnas, tipos de datos y valores nulos
DESCRIBE EquipA.BANK_marketing;

# Primer pantallazo del dataset
SELECT * FROM EquipA.BANK_marketing;

# Número de registros: 11162
SELECT COUNT(*) AS observations
FROM EquipA.BANK_marketing;

# Edades mínimas y máximas
SELECT MIN(age) as min_age, MAX(age) AS max_age
FROM EquipA.BANK_marketing;

# Valores únicos y número de registros por trabajo
SELECT job, COUNT(*) AS observations
FROM EquipA.BANK_marketing
GROUP BY job
ORDER BY observations DESC;

# Valores únicos y número de registros por estado civil
SELECT marital, COUNT(*) AS observations
FROM EquipA.BANK_marketing
GROUP BY marital
ORDER BY COUNT(*) DESC;

# Valores únicos y número de registros por tipo de educación
SELECT education, COUNT(*) AS observations
FROM EquipA.BANK_marketing
GROUP BY education
ORDER BY COUNT(*) DESC;

SELECT DISTINCT
	(SELECT COUNT(*) FROM EquipA.BANK_marketing WHERE balance < 0) AS negative_balance,
	(SELECT COUNT(*) FROM EquipA.BANK_marketing WHERE balance >= 0) AS positive_balance
FROM EquipA.BANK_marketing;

# Valores únicos y número de registros por default
SELECT `default`, COUNT(*) AS observations
FROM EquipA.BANK_marketing
GROUP BY `default`
ORDER BY COUNT(*) DESC;

# Valores únicos y número de registros por hipoteca
SELECT housing, COUNT(*) AS observations
FROM EquipA.BANK_marketing
GROUP BY housing
ORDER BY COUNT(*) DESC;

# Valores únicos y número de registros por préstamo
SELECT loan, COUNT(*) AS observations
FROM EquipA.BANK_marketing
GROUP BY loan
ORDER BY COUNT(*) DESC;

# Valores únicos y número de registros por tipo de contacto
SELECT contact, COUNT(*) AS observations
FROM EquipA.BANK_marketing
GROUP BY contact
ORDER BY COUNT(*) DESC;

# Valores únicos y número de registros por campaña
SELECT campaign, COUNT(*) AS observations
FROM EquipA.BANK_marketing
GROUP BY campaign
ORDER BY COUNT(*) DESC;

# Valores únicos y número de registros por contactos previos
SELECT previous, COUNT(*) AS observations
FROM EquipA.BANK_marketing
GROUP BY previous
ORDER BY COUNT(*) DESC;

# Valores únicos y número de registros por previous outcome
SELECT poutcome, COUNT(*) AS observations
FROM EquipA.BANK_marketing
GROUP BY poutcome
ORDER BY COUNT(*) DESC;

# Valores únicos y número de registros por resultado de la llamada
SELECT deposit, COUNT(*) AS observations
FROM EquipA.BANK_marketing
GROUP BY deposit
ORDER BY COUNT(*) DESC;

# Creamos vista para perfil de cliente. Nos quedamos solo con las variables demográficas y recodificamos las variables de age y balance
CREATE VIEW perfil_Cliente AS (
	SELECT id, 
			CASE 
				WHEN age < 20 THEN "1X"
				WHEN age >= 20 AND age < 30 THEN "2X"
                WHEN age >= 30 AND age < 40 THEN "3X"
                WHEN age >= 40 AND age < 50 THEN "4X"
                WHEN age >= 50 AND age < 60 THEN "5X"
                WHEN age >= 60 AND age < 70 THEN "6X"
                WHEN age >= 70 AND age < 80 THEN "7X"
                WHEN age >= 80 AND age < 90 THEN "8X"
                ELSE "9X"
                END AS age_slot,
			job, marital, education,
            CASE 
				WHEN balance >= 0 THEN "positive" ELSE "negative" END AS balance,
			deposit
    FROM EquipA.BANK_marketing
);

SELECT * FROM EquipA.perfil_Cliente;

SELECT 
	age_slot, 
    COUNT(*) AS people
 FROM EquipA.perfil_Cliente 
 GROUP BY age_slot
 ORDER BY 2 DESC;

# Analizamos el porcentaje de depósitos realizados para cada grupo de edad
WITH cte AS 
(
	SELECT age_slot,
    SUM(CASE WHEN deposit = "yes" THEN 1 ELSE 0 END) AS deposits,
    COUNT(*) AS total_calls
    FROM EquipA.perfil_Cliente
	GROUP BY age_slot
)
SELECT age_slot, 
	deposits,
    total_calls,
	ROUND(deposits / total_calls * 100, 2) AS deposit_rate
FROM cte
ORDER BY deposit_rate DESC;

# Por tipo de trabajo
WITH cte AS 
(
	SELECT job,
    SUM(CASE WHEN deposit = "yes" THEN 1 ELSE 0 END) AS deposits,
    COUNT(*) AS total_calls
    FROM EquipA.perfil_Cliente
    WHERE job <> "unknown"
	GROUP BY job
)
SELECT job, 
	deposits,
    total_calls,
	ROUND(deposits / total_calls * 100, 2) AS deposit_rate
FROM cte
ORDER BY deposit_rate DESC;

# Por nivel de educación
WITH cte AS 
(
	SELECT education,
    SUM(CASE WHEN deposit = "yes" THEN 1 ELSE 0 END) AS deposits,
    COUNT(*) AS total_calls
    FROM EquipA.perfil_Cliente
    WHERE education <> "unknown"
	GROUP BY education
)
SELECT education, 
	deposits,
    total_calls,
	ROUND(deposits / total_calls * 100, 2) AS deposit_rate
FROM cte
ORDER BY deposit_rate DESC;

# Por estado civil
WITH cte AS 
(
	SELECT marital,
    SUM(CASE WHEN deposit = "yes" THEN 1 ELSE 0 END) AS deposits,
    COUNT(*) AS total_calls
    FROM EquipA.perfil_Cliente
	GROUP BY marital
)
SELECT marital, 
	deposits,
    total_calls,
	ROUND(deposits / total_calls * 100, 2) AS deposit_rate
FROM cte
ORDER BY deposit_rate DESC;

# Por balance positivo o negativo
WITH cte AS 
(
	SELECT balance,
    SUM(CASE WHEN deposit = "yes" THEN 1 ELSE 0 END) AS deposits,
    COUNT(*) AS total_calls
    FROM EquipA.perfil_Cliente
	GROUP BY balance
)
SELECT balance, 
	deposits,
    total_calls,
	ROUND(deposits / total_calls * 100, 2) AS deposit_rate
FROM cte
ORDER BY deposit_rate DESC;

# Sumamos el tipo de trabajo y vemos los tres con mejor conversión para cada grupo de edad
WITH cte AS 
(
	SELECT age_slot,
    job,
    SUM(CASE WHEN deposit = "yes" THEN 1 ELSE 0 END) AS deposits,
    COUNT(*) AS total_calls,
    ROUND(SUM(CASE WHEN deposit = "yes" THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS deposit_rate
    FROM EquipA.perfil_Cliente
    WHERE job <> "unknown"
	GROUP BY age_slot, job
)
SELECT *
FROM (
	SELECT *,
            RANK() OVER(PARTITION BY age_slot ORDER BY deposit_rate DESC) AS ranking
	FROM cte
    ) sub
WHERE ranking <= 3
ORDER BY age_slot, deposit_rate DESC;

# Agrupamos ahora por trabajo y estado civil
WITH cte AS 
(
	SELECT job, 
			marital,
			SUM(CASE WHEN deposit = "yes" THEN 1 ELSE 0 END) AS deposits,
			COUNT(*) AS total_calls
	FROM EquipA.perfil_Cliente
    WHERE job <> "unknown"
	GROUP BY job, marital
)
SELECT job, 
		marital,
        deposits,
		total_calls,
		ROUND(deposits / total_calls * 100, 2) AS deposit_rate
FROM cte
ORDER BY job, deposit_rate DESC;

# Agrupamos ahora por trabajo y educación
WITH cte AS 
(
	SELECT job, 
			education,
			SUM(CASE WHEN deposit = "yes" THEN 1 ELSE 0 END) AS deposits,
			COUNT(*) AS total_calls
	FROM EquipA.perfil_Cliente
    WHERE job <> "unknown"
    AND education <> "unknown"
	GROUP BY job, education
)
SELECT job, 
		education,
        deposits,
		total_calls,
		ROUND(deposits / total_calls * 100, 2) AS deposit_rate
FROM cte
ORDER BY job, deposit_rate DESC;

# Para continuar con nuestro análisis, tomaremos los trabajos con un deposit_rate general mayor al 50%
WITH cte AS 
(
	SELECT job,
    ROUND(SUM(CASE WHEN deposit = "yes" THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS deposit_rate
    FROM EquipA.perfil_Cliente
    WHERE job <> "unknown"
	GROUP BY job
)
SELECT DISTINCT job, deposit_rate
FROM cte 
WHERE deposit_rate > 50
ORDER BY deposit_rate DESC;

# Agrupamos estos 4 trabajos con la segmentación por educación
SELECT 
	job, 
    education,
    COUNT(*) AS total_calls,
    ROUND(SUM(CASE WHEN deposit = "yes" THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS deposit_rate
FROM EquipA.perfil_Cliente
WHERE job IN ("management", "student", "unemployed", "retired")
AND education <> "unknown"
GROUP BY job, education
ORDER BY job, deposit_rate DESC;

# Y segmentamos también por balance positivo y negativo
SELECT 
	job, 
    balance,
    COUNT(*) AS total_calls,
    ROUND(SUM(CASE WHEN deposit = "yes" THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS deposit_rate
FROM EquipA.perfil_Cliente
WHERE job IN ("management", "student", "unemployed", "retired")
GROUP BY job, balance
ORDER BY job, deposit_rate DESC;

# Y segmentamos también por edad
SELECT 
	job, 
    age_slot,
    COUNT(*) AS total_calls,
    ROUND(SUM(CASE WHEN deposit = "yes" THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS deposit_rate
FROM EquipA.perfil_Cliente
WHERE job IN ("management", "student", "unemployed", "retired")
GROUP BY job, age_slot
ORDER BY job, deposit_rate DESC;

# Edad entre 30 y 60
SELECT job,
    age_slot,
    COUNT(*) AS total_calls,
    ROUND(SUM(CASE WHEN deposit = "yes" THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS deposit_rate
FROM EquipA.perfil_Cliente
WHERE age_slot IN ("3X", "4X", "5X")
GROUP BY job, age_slot
ORDER BY age_slot,deposit_rate DESC;








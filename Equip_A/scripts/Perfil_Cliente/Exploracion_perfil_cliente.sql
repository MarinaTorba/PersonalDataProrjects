# Columnas, tipos de datos y valores nulos
DESCRIBE EquipA.BANK_marketing;

# Primer pantallazo del dataset
SELECT * FROM EquipA.BANK_marketing;

# Número de registros: 11162
SELECT COUNT(*) AS observations
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

# Creamos vista para perfil de cliente. Nos quedamos solo con las variables demográficas y agregamos dos nuevas columnas: age_slot y balance_binary
CREATE VIEW perfil_Cliente AS (
	SELECT id, 
		age,
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
			balance,
            CASE 
				WHEN balance >= 0 THEN "positive" ELSE "negative" END AS balance_binary,
			deposit
    FROM EquipA.BANK_marketing
);

SELECT * FROM EquipA.perfil_Cliente;

SELECT age_slot, count(*) FROM EquipA.perfil_Cliente group by age_slot;

SELECT COUNT(*)
FROM EquipA.BANK_marketing;

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
ORDER BY 4 DESC;

# Sumamos el tipo de trabajo
WITH cte AS 
(
	SELECT age_slot,
    job,
    SUM(CASE WHEN deposit = "yes" THEN 1 ELSE 0 END) AS deposits,
    COUNT(*) AS total_calls
    FROM EquipA.perfil_Cliente
	GROUP BY age_slot, job
)
SELECT age_slot, 
		job
	deposits,
    total_calls,
	ROUND(deposits / total_calls * 100, 2) AS deposit_rate
FROM cte
WHERE age_slot NOT IN ("3X", "4X", "5X") 
ORDER BY age_slot, deposit_rate DESC;

# Depósitos de las personas con balance anual negativo
SELECT 
	SUM(CASE WHEN deposit = "yes" THEN 1 ELSE 0 END) AS deposits,
	COUNT(*) AS total_calls,
    ROUND(SUM(CASE WHEN deposit = "yes" THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS deposit_rate
FROM EquipA.perfil_Cliente
WHERE balance_binary = "negative";

WITH cte AS 
(
	SELECT job, 
			education,
			marital,
			SUM(CASE WHEN deposit = "yes" THEN 1 ELSE 0 END) AS deposits,
			COUNT(*) AS total_calls
	FROM EquipA.perfil_Cliente
    WHERE job <> "unknown"
    AND education <> "unknown"
	GROUP BY job, education, marital
)
SELECT job, 
		education,
		marital,
        deposits,
		total_calls,
		ROUND(deposits / total_calls * 100, 2) AS deposit_rate
FROM cte
ORDER BY 6 DESC;

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

SELECT *
FROM EquipA.perfil_Cliente
WHERE job = "student";

SELECT AVG(age)
FROM EquipA.perfil_Cliente;

SELECT * FROM EquipA.BANK_marketing131024;

/* Valores duplicados (no hay)*/

SELECT id, age, job, marital, education, `default`, balance, housing, loan, contact, `day`, `month`, duration, campaign, pdays, previous, poutcome, deposit, COUNT(*) AS conteo
FROM BANK_marketing131024
GROUP BY id, age, job, marital, education, `default`, balance, housing, loan, contact, `day`, `month`, duration, campaign, pdays, previous, poutcome, deposit
HAVING COUNT(*) > 1;

/* Nulos en edad (Hay 13) */
SELECT *
FROM BANK_marketing131024
WHERE age IS NULL OR age = 0;

/* Para completarlos, utilizemos la media de cada grupo marital: soltero, casado, divorciado */

WITH avg_married_age AS 
	(
		SELECT ROUND(AVG(age)) AS avg_age
		FROM BANK_marketing131024
		WHERE marital = "married"
        )
UPDATE BANK_marketing131024
SET age = (SELECT avg_age FROM avg_married_age)
WHERE marital = "married"
AND age IS NULL;

WITH avg_divorced_age AS 
	(
		SELECT ROUND(AVG(age)) AS avg_age
		FROM BANK_marketing131024
		WHERE marital = "divorced"
        )
UPDATE BANK_marketing131024
SET age = (SELECT avg_age FROM avg_divorced_age)
WHERE marital = "divorced"
AND age IS NULL;

WITH avg_single_age AS 
	(
		SELECT ROUND(AVG(age)) AS avg_age
		FROM BANK_marketing131024
		WHERE marital = "single"
        )
UPDATE BANK_marketing131024
SET age = (SELECT avg_age FROM avg_single_age)
WHERE marital = "single"
AND age IS NULL;

/* Nulos en marital (Hay 9) */
SELECT *
FROM BANK_marketing131024
WHERE marital IS NULL;

/* Convertimos los nulos a casados por ser el valor más frecuente */

UPDATE BANK_marketing131024
SET marital = "married"
WHERE marital IS NULL;

/* Nulos en education (Hay 7) */
SELECT *
FROM BANK_marketing131024
WHERE education IS NULL;

/* Convertimos los nulos a secondary por ser el valor más frecuente */

UPDATE BANK_marketing131024
SET education = "secondary"
WHERE education IS NULL;

SELECT housing, COUNT(*)
FROM BANK_marketing131024
GROUP BY housing;

SELECT housing, loan, `default`, deposit, AVG(balance) AS avg_balance, COUNT(*) AS calls
FROM BANK_marketing131024
GROUP BY housing, loan, deposit, `default`
ORDER BY calls DESC;

/* Observemos los nulos de housing ahora. Como hay muchos registros duplicados, utilizaremos el valor de la fila duplicada para rellenar los nulls. */

SELECT *
FROM BANK_marketing131024
WHERE housing IS NULL;

# duplicado
SELECT *
FROM BANK_marketing131024
WHERE duration = 270 AND balance = 2785;

UPDATE BANK_marketing131024
SET housing = "no"
WHERE duration = 270 AND balance = 2785;

# duplicado
SELECT *
FROM BANK_marketing131024
WHERE duration = 221 AND balance = 687;

UPDATE BANK_marketing131024
SET housing = "yes"
WHERE duration = 221 AND balance = 687;

# duplicado
SELECT *
FROM BANK_marketing131024
WHERE duration = 705 AND balance = 1940;

UPDATE BANK_marketing131024
SET housing = "no"
WHERE duration = 705 AND balance = 1940;

# duplicado
SELECT *
FROM BANK_marketing131024
WHERE duration = 798 AND balance = 883;

UPDATE BANK_marketing131024
SET housing = "yes"
WHERE duration = 798 AND balance = 883;

# no duplicado
SELECT *
FROM BANK_marketing131024
WHERE duration = 309 AND balance = 330;

# no duplicado
SELECT *
FROM BANK_marketing131024
WHERE duration = 328 AND balance = -150;

# no duplicado
SELECT *
FROM BANK_marketing131024
WHERE duration = 668 AND balance = 729;

# no duplicado
SELECT *
FROM BANK_marketing131024
WHERE duration = 171 AND balance = -31;

# no duplicado
SELECT *
FROM BANK_marketing131024
WHERE duration = 154 AND balance = 89;

# duplicado
SELECT *
FROM BANK_marketing131024
WHERE duration = 95 AND balance = 2557;

UPDATE BANK_marketing131024
SET housing = "no"
WHERE duration = 95 AND balance = 2557;

# no duplicado
SELECT *
FROM BANK_marketing131024
WHERE duration = 167 AND balance = 110;

# no duplicado
SELECT *
FROM BANK_marketing131024
WHERE duration = 350 AND balance = 421;

# duplicado
SELECT *
FROM BANK_marketing131024
WHERE duration = 27 AND balance = 53;

UPDATE BANK_marketing131024
SET housing = "yes"
WHERE duration = 27 AND balance = 53;

# duplicado
SELECT *
FROM BANK_marketing131024
WHERE duration = 90 AND balance = 1310;

UPDATE BANK_marketing131024
SET housing = "no"
WHERE duration = 90 AND balance = 1310;

# duplicado
SELECT *
FROM BANK_marketing131024
WHERE duration = 28 AND balance = 3884;

UPDATE BANK_marketing131024
SET housing = "yes"
WHERE duration = 28 AND balance = 3884;

# duplicado
SELECT *
FROM BANK_marketing131024
WHERE duration = 331 AND balance = 454;

UPDATE BANK_marketing131024
SET housing = "no"
WHERE duration = 331 AND balance = 454;

# duplicado
SELECT *
FROM BANK_marketing131024
WHERE duration = 763 AND balance = 792;

UPDATE BANK_marketing131024
SET housing = "no"
WHERE duration = 763 AND balance = 792;

# duplicado
SELECT *
FROM BANK_marketing131024
WHERE duration = 97 AND balance = -338;

UPDATE BANK_marketing131024
SET housing = "yes"
WHERE duration = 97 AND balance = -338;

# duplicado
SELECT *
FROM BANK_marketing131024
WHERE duration = 1178 AND balance = 691;

UPDATE BANK_marketing131024
SET housing = "no"
WHERE duration = 1178 AND balance = 691;

# duplicado
SELECT *
FROM BANK_marketing131024
WHERE duration = 257 AND balance = 1664;

UPDATE BANK_marketing131024
SET housing = "no"
WHERE duration = 257 AND balance = 1664;

/* Si no hay duplicado, entonces imputaremos con "no" por ser el valor más frecuente */

UPDATE BANK_marketing131024
SET housing = "no"
WHERE housing IS NULL;

/* Eliminamos el punto final de "admin." */

UPDATE BANK_marketing131024
SET job = "admin"
WHERE job = "admin.";

/* Cambiamos los que no tengan contacto previo a "n/a" (8324) */

UPDATE BANK_marketing131024
SET poutcome = "n/a"
WHERE poutcome = "Unknown"
AND previous = 0;

/* Y asignamos los dos registros restantes a la categoría "other" */

UPDATE BANK_marketing131024
SET poutcome = "other"
WHERE poutcome = "Unknown";
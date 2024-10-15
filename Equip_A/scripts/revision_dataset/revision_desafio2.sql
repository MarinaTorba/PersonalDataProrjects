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
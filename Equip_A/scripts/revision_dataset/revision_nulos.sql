/* Valores duplicados (solo hay uno)*/

SELECT age, job, marital, education, `default`, balance, housing, loan, contact, `day`, `month`, duration, campaign, pdays, previous, poutcome, deposit, COUNT(*) AS conteo
FROM BANK_marketing
GROUP BY age, job, marital, education, `default`, balance, housing, loan, contact, `day`, `month`, duration, campaign, pdays, previous, poutcome, deposit
HAVING COUNT(*) > 1;

/* Lo eliminamos porque el segundo registro no está presente en el dataset original*/

DELETE FROM BANK_marketing
WHERE id IN (
	WITH duplicate_CTE AS 
	(
		SELECT *,
			ROW_NUMBER() OVER(PARTITION BY age, job, marital, education, `default`, 
			balance, housing, loan, contact, `day`, `month`, duration, campaign, pdays, previous, poutcome, deposit) AS row_n
		FROM BANK_marketing
	)

	SELECT id 
	FROM duplicate_CTE
	WHERE row_n > 1);
    
/* Como se borró el id 1, necesitamos actualizar todos los id de la tabla para que tengan un número menos (que el 2 pase a ser el 1, el 3 pase a ser el 2, etc.) */

UPDATE EquipA.BANK_marketing
SET id = id - 1;

/* Nulos en edad (Hay 10) */
SELECT *
FROM BANK_marketing
WHERE age IS NULL OR age = 0;

/* Para completarlos, utilizemos la media de cada grupo marital: soltero, casado, divorciado /*

/* Edad media de solteros: 33 */
SELECT ROUND(AVG(age))
FROM BANK_marketing
WHERE marital = "single";

/* Edad media de casados: 45 */
SELECT ROUND(AVG(age))
FROM BANK_marketing
WHERE marital = "married";

/* Edad media de divorciados: 47 */
SELECT ROUND(AVG(age))
FROM BANK_marketing
WHERE marital = "divorced";

/* Actualizamos los valores nulos en "age" de las personas solteras */
WITH avg_single_age AS 
	(
		SELECT ROUND(AVG(age)) AS avg_age
		FROM BANK_marketing
		WHERE marital = "single"
        )
UPDATE BANK_marketing
SET age = (SELECT avg_age FROM avg_single_age)
WHERE marital = "single"
AND age IS NULL;

/* Actualizamos los valores nulos en "age" de los personas casadas */
WITH avg_married_age AS 
	(
		SELECT ROUND(AVG(age)) AS avg_age
		FROM BANK_marketing
		WHERE marital = "married"
        )
UPDATE BANK_marketing
SET age = (SELECT avg_age FROM avg_married_age)
WHERE marital = "married"
AND age IS NULL;

/* Actualizamos los valores nulos en "age" de los personas divorciadas */
WITH avg_divorced_age AS 
	(
		SELECT ROUND(AVG(age)) AS avg_age
		FROM BANK_marketing
		WHERE marital = "divorced"
        )
UPDATE BANK_marketing
SET age = (SELECT avg_age FROM avg_divorced_age)
WHERE marital = "divorced"
AND age IS NULL;

/* Nulos en job (0) */
SELECT COUNT(*)
FROM BANK_marketing
WHERE job IS NULL;

/* Nulos en marital (5) */
SELECT *
FROM BANK_marketing
WHERE marital IS NULL;

/* Convertimos los nulos a casados por ser el valor más frecuente */

UPDATE BANK_marketing
SET marital = "married"
WHERE marital IS NULL;

/* Nulos en education (7)*/
SELECT *
FROM BANK_marketing
WHERE education IS NULL;

/* Para rellenar esta información, utilizaremos los trabajos actuales. Veamos la educación más frecuente de los technician (secondary)*/
SELECT education, COUNT(*)
FROM BANK_marketing
WHERE job = "technician"
GROUP BY education;

/* Veamos la educación más frecuente de student (secondary)*/
SELECT education, COUNT(*)
FROM BANK_marketing
WHERE job = "student"
GROUP BY education;

/* Veamos la educación más frecuente de management (tertiary)*/
SELECT education, COUNT(*)
FROM BANK_marketing
WHERE job = "management"
GROUP BY education;

/* Veamos la educación más frecuente de services (secondary)*/
SELECT education, COUNT(*)
FROM BANK_marketing
WHERE job = "services"
GROUP BY education;

/* Veamos la educación más frecuente de entrepreneur (secondary)*/
SELECT education, COUNT(*)
FROM BANK_marketing
WHERE job = "entrepreneur"
GROUP BY education;

/* Completamos los nulos de management con "tertiary" */

UPDATE BANK_marketing
SET education = "tertiary"
WHERE job = "management"
AND education IS NULL;

/* Y el resto de nulos con "secondary" */

UPDATE BANK_marketing
SET education = "secondary"
WHERE education IS NULL;

/* Nulos en default (0)*/
SELECT *
FROM BANK_marketing
WHERE `default` IS NULL;

/* Nulos en balance (0) Valor = 0 (774)*/
SELECT *
FROM BANK_marketing
WHERE balance IS NULL OR balance < 0;

/* Nulos en housing (0)*/
SELECT *
FROM BANK_marketing
WHERE housing IS NULL;

/* Nulos en loan (0)*/
SELECT *
FROM BANK_marketing
WHERE loan IS NULL;

/* Nulos en contact (0)*/
SELECT *
FROM BANK_marketing
WHERE contact IS NULL;

/* Nulos en day (0) Ceros (0)*/
SELECT *
FROM BANK_marketing
WHERE `day` IS NULL OR `day` = 0 ;

/* Nulos en month (0)*/
SELECT *
FROM BANK_marketing
WHERE `month` IS NULL;

/* Nulos en duration (0) Cero (0)*/
SELECT *
FROM BANK_marketing
WHERE duration IS NULL OR duration = 0;

/* Nulos en campaign (0) Cero (0)*/
SELECT *
FROM BANK_marketing
WHERE campaign IS NULL OR campaign = 0;

/* Nulos en pdays (0)*/
SELECT *
FROM BANK_marketing
WHERE pdays IS NULL;

/* Nulos en previous (0)*/
SELECT *
FROM BANK_marketing
WHERE previous IS NULL;

/* Nulos en poutcome (0)*/
SELECT *
FROM BANK_marketing
WHERE poutcome IS NULL;

/* Nulos en deposit (0)*/
SELECT *
FROM BANK_marketing
WHERE deposit IS NULL;

/* Eliminamos el punto final de "admin." */

UPDATE BANK_marketing
SET job = "admin"
WHERE job = "admin."

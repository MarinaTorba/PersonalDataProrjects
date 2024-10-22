/* PARA REALIZAR MODIFICACIONES USO: */
SET SQL_SAFE_UPDATES=0;

/* SE QUITA EL PUNTO EN ADMIN */
UPDATE BANK_marketing211024
SET job = "admin"
WHERE job = "admin.";

/* CONSULTA DE VALORES NULOS EN AGE: 23 NULL*/
SELECT *
FROM BANK_marketing211024
WHERE age IS NULL OR age = 0;

/* Para completarlos, utilizemos la media de cada grupo marital: soltero, casado, divorciado /*

/* Edad media de solteros: 33 */
SELECT ROUND(AVG(age))
FROM BANK_marketing211024
WHERE marital = "single";

/* Edad media de casados: 45 */
SELECT ROUND(AVG(age))
FROM BANK_marketing211024
WHERE marital = "married";

/* Edad media de divorciados: 47 */
SELECT ROUND(AVG(age))
FROM BANK_marketing211024
WHERE marital = "divorced";

/* Actualizamos los valores nulos en "age" de las personas solteras */
WITH avg_single_age AS 
	(
		SELECT ROUND(AVG(age)) AS avg_age
		FROM BANK_marketing211024
		WHERE marital = "single"
        )
UPDATE BANK_marketing211024
SET age = (SELECT avg_age FROM avg_single_age)
WHERE marital = "single"
AND age IS NULL;

/* Actualizamos los valores nulos en "age" de las personas casadas */
WITH avg_married_age AS 
	(
		SELECT ROUND(AVG(age)) AS avg_age
		FROM BANK_marketing211024
		WHERE marital = "married"
        )
UPDATE BANK_marketing211024
SET age = (SELECT avg_age FROM avg_married_age)
WHERE marital = "married"
AND age IS NULL;

/* Actualizamos los valores nulos en "age" de las personas divorciadas */
WITH avg_divorced_age AS 
	(
		SELECT ROUND(AVG(age)) AS avg_age
		FROM BANK_marketing211024
		WHERE marital = "divorced"
        )
UPDATE BANK_marketing211024
SET age = (SELECT avg_age FROM avg_divorced_age)
WHERE marital = "divorced"
AND age IS NULL;


/* CONSULTA DE VALORES NULOS EN MARITAL: 17 NULL*/
SELECT *
FROM BANK_marketing211024
WHERE marital IS NULL;

/* USANDO EL CRITERIO ACTUAL, SE IMPUTAN COMO CASADOS AL SER MAYORÍA EN EL DATASET Y MAYORES 30 AÑOS EN LOS NULL*/
UPDATE BANK_marketing211024
SET marital = "married"
WHERE marital IS NULL;

/* CONSULTA DE VALORES NULOS EN EDUCATION: 12 NULL*/
SELECT *
FROM BANK_marketing211024
WHERE education IS NULL;

/* SE COMPLETAN LOS NULOS DE MANAGEMENT CON "tertiary" */

UPDATE BANK_marketing211024
SET education = "tertiary"
WHERE job = "management"
AND education IS NULL;

/* SE COMPLETA EL RESTO CON "secondary" */

UPDATE BANK_marketing211024
SET education = "secondary"
WHERE education IS NULL;

/* CONSULTA DE VALORES NULOS EN DEFAULT: 15 NULL*/
SELECT *
FROM BANK_marketing211024
WHERE `default` IS NULL;

/* SE TRATAN COMO "yes" LOS NULL DE DEFAULT QUE TENGAN UN PRÉSTAMO COMO "yes" (SOLO HAY 1) */

UPDATE BANK_marketing211024
SET `default` = "yes"
WHERE `default` IS NULL AND  loan = "yes";

/* EL RESTO SE IMPUTA UN "no" AL SER LA MAYORÍA DE "yes" EN ESTA COLUMNA */

UPDATE BANK_marketing211024
SET `default` = "no"
WHERE `default` IS NULL;

/* CONSULTA DE VALORES NULOS EN HOUSING: 80 NULL*/
SELECT *
FROM BANK_marketing211024
WHERE housing IS NULL;

/* CONSULTA DE "unknown" EN poutcome PARA CAMBIAR A "n/a" */ 
SELECT COUNT(*)
FROM BANK_marketing211024
WHERE poutcome = "Unknown";

/* Cambiamos los que no tengan contacto previo a "n/a" (19532) */

UPDATE BANK_marketing211024
SET poutcome = "n/a"
WHERE poutcome = "Unknown"
AND previous = 0;

/* Y asignamos los dos registros restantes a la categoría "other" */

UPDATE BANK_marketing211024
SET poutcome = "other"
WHERE poutcome = "Unknown";
﻿
/* Ponemos no en los trabajos con menor porcentaje de hipotecas */
UPDATE BANK_marketing211024
SET housing = "no"
WHERE housing IS NULL
AND job IN ("student", "retired", "unemployed", "housemaid");

/* Ponemos no en las personas mayores de 60 */
UPDATE BANK_marketing211024
SET housing = "no"
WHERE housing IS NULL
AND age >= 60;

/* Ponemos no en las combinaciones de trabajo y estado civil donde el porcentaje de hipoteca sea menor al 50% */
WITH CTE AS (
    SELECT job, marital,
           SUM(CASE WHEN housing = 'yes' THEN 1 ELSE 0 END) / COUNT(*) * 100 AS housing_rate
    FROM BANK_marketing211024
    WHERE job NOT IN ('student', 'retired', 'unemployed', 'housemaid', 'unknown')
    GROUP BY job, marital
)
UPDATE BANK_marketing211024
SET housing = 'no'
WHERE housing IS NULL
AND (job, marital) IN (
    SELECT job, marital
    FROM CTE
    WHERE housing_rate < 50
);

/* Completamos con la moda de la combinación de trabajo, estado civil y educación */
WITH count_housing AS (
    SELECT job, marital, education, housing,
           COUNT(housing) AS count_housing
    FROM BANK_marketing211024
    WHERE housing IS NOT NULL
    GROUP BY job, marital, education, housing
),
ranking_housing AS (
    SELECT job, marital, education, housing,
           RANK() OVER (PARTITION BY job, marital ORDER BY count_housing DESC) AS rank_number
    FROM count_housing
)
UPDATE BANK_marketing211024
SET housing = (
		SELECT housing
		FROM ranking_housing 
		WHERE BANK_marketing211024.job = ranking_housing.job
		AND BANK_marketing211024.marital = ranking_housing.marital
		AND BANK_marketing211024.education = ranking_housing.education
		AND ranking_housing.rank_number = 1)
WHERE housing IS NULL;

/* Nos quedan 6 registros que completaremos con "no" por ser el valor más frecuente */
UPDATE BANK_marketing211024
SET housing = "no"
WHERE housing IS NULL;

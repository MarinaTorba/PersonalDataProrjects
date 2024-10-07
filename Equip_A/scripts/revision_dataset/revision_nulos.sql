/* Valores duplicados (solo hay uno)*/

SELECT age, job, marital, education, `default`, balance, housing, loan, contact, `day`, `month`, duration, campaign, pdays, previous, poutcome, deposit, COUNT(*) AS conteo
FROM BANK_marketing
GROUP BY age, job, marital, education, `default`, balance, housing, loan, contact, `day`, `month`, duration, campaign, pdays, previous, poutcome, deposit
HAVING COUNT(*) > 1;

/* Nulos en edad (Hay 10) */
SELECT *
FROM BANK_marketing
WHERE age IS NULL OR age = 0;

/* Nulos en job (0) */
SELECT COUNT(*)
FROM BANK_marketing
WHERE job IS NULL;

/* Nulos en marital (5) */
SELECT *
FROM BANK_marketing
WHERE marital IS NULL;

/* Nulos en education (7)*/
SELECT *
FROM BANK_marketing
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

/* Nulos en loann (0)*/
SELECT *
FROM BANK_marketing
WHERE loan IS NULL;

/* Nulos en contact (0)*/
SELECT *
FROM BANK_marketing
WHERE contact IS NULL;

/* Nulos en education (0) Ceros (0)*/
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


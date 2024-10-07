/* Consulta de todas las columnas 20 filas */

SELECT * 
FROM BANK_marketing
LIMIT 20;

/* Cantidad de registros */
SELECT COUNT(campaign) AS Registros
FROM BANK_marketing
;

/* Usuarios por edad*/
SELECT age AS edad, COUNT(age) AS cantidad
FROM BANK_marketing
GROUP BY age
ORDER BY cantidad DESC;

/* Usuarios por tipo de trabajo (blue-collar son obreros) */
SELECT job, COUNT(job) AS cantidad
FROM BANK_marketing
GROUP BY job
ORDER BY cantidad DESC;

/* Usuarios por estado civil */
SELECT marital, COUNT(marital) AS cantidad
FROM BANK_marketing
GROUP BY marital
ORDER BY cantidad DESC;

/* Usuarios por formación académica */
SELECT education, COUNT(education) AS cantidad
FROM BANK_marketing
GROUP BY education
ORDER BY cantidad DESC;

/* Hay crédito impagado? */
SELECT `default` AS credito_impagado, COUNT(`default`) AS cantidad
FROM BANK_marketing
GROUP BY credito_impagado
ORDER BY cantidad DESC;

/* Usuarios con hipoteca */
SELECT housing, COUNT(housing) AS cantidad
FROM BANK_marketing
GROUP BY housing
ORDER BY cantidad DESC;

/* Usuarios por préstamos contratados */
SELECT loan, COUNT(loan) AS cantidad
FROM BANK_marketing
GROUP BY loan
ORDER BY cantidad DESC;

/* Usuarios por forma de contacto */
SELECT contact, COUNT(contact) AS cantidad
FROM BANK_marketing
GROUP BY contact
ORDER BY cantidad DESC;

/* Cantidad de llamadas en laBANK_marketingBANK_marketingBANK_marketing campaña*/
SELECT campaign, COUNT(campaign) AS cantidad
FROM BANK_marketing
GROUP BY campaign
ORDER BY cantidad DESC;

/* poutcome=resultado de la campaña */
SELECT poutcome, COUNT(poutcome) AS cantidad
FROM BANK_marketing
GROUP BY poutcome
ORDER BY cantidad DESC;

/* El cliente ha contratado un depósito? */
SELECT deposit, COUNT(deposit) AS cantidad
FROM BANK_marketing
GROUP BY deposit
ORDER BY cantidad DESC;


/* Valores duplicados (solo hay uno)*/

SELECT age, job, marital, education, `default`, balance, housing, loan, contact, `day`, `month`, duration, campaign, pdays, previous, poutcome, deposit, COUNT(*) AS conteo
FROM BANK_marketing
GROUP BY age, job, marital, education, `default`, balance, housing, loan, contact, `day`, `month`, duration, campaign, pdays, previous, poutcome, deposit
HAVING COUNT(*) > 1;


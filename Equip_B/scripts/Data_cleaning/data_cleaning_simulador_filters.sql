-- Rellenar Age
SELECT *
FROM BANK_marketing;

SELECT *
FROM BANK_marketing
WHERE marital IS NULL or marital =  ""
;

Select AVG(age), job, marital
FROM BANK_marketing
GROUP BY job, marital
ORDER BY job desc;

SELECT MODE(marital), job, age
FROM BANK_marketing
GROUP BY job, age
ORDER BY job, age desc;

SELECT marital, AVG(age), job, COUNT(*) AS frecuencia
FROM BANK_marketing
GROUP BY marital, job
ORDER BY frecuencia DESC;



USE EquipA;

DESCRIBE EquipA.BANK_marketing;

SELECT * FROM EquipA.BANK_marketing;

WITH duplicate_CTE AS 
(
	SELECT *,
		ROW_NUMBER() OVER(PARTITION BY age, job, marital, education, `default`, 
        balance, housing, loan, contact, `day`, `month`, duration, campaign, pdays, previous, poutcome, deposit) AS row_n
FROM EquipA.BANK_marketing
)

SELECT * 
FROM duplicate_CTE
WHERE row_n > 1;

SELECT COUNT(*)
FROM EquipA.BANK_marketing;

SELECT * 
FROM EquipA.BANK_marketing
WHERE age IS NULL;

SELECT job, COUNT(*) AS observations
FROM EquipA.BANK_marketing
GROUP BY job
ORDER BY observations DESC;

WITH CTE AS (

	SELECT job,
		SUM(CASE WHEN deposit = "yes" THEN 1 ELSE 0 END) AS deposits,
		SUM(CASE WHEN deposit = "no" THEN 1 ELSE 0 END) AS rejected
	FROM EquipA.BANK_marketing
	GROUP BY job
	ORDER BY deposits DESC
)

SELECT job, 
	deposits,
    rejected,
	ROUND(deposits / (deposits + rejected) * 100, 2) AS deposit_rate
FROM CTE
ORDER BY deposit_rate DESC;

SELECT marital, COUNT(*) 
FROM EquipA.BANK_marketing
GROUP BY marital
ORDER BY COUNT(*) DESC;

SELECT *
FROM EquipA.BANK_marketing
WHERE marital IS NULL;

SELECT education, COUNT(*) 
FROM EquipA.BANK_marketing
GROUP BY education
ORDER BY COUNT(*) DESC;

SELECT *
FROM EquipA.BANK_marketing
WHERE education IS NULL;

SELECT education, COUNT(*)
FROM EquipA.BANK_marketing
WHERE job = "management"
GROUP BY education;

SELECT `default`, COUNT(*) 
FROM EquipA.BANK_marketing
GROUP BY `default`
ORDER BY COUNT(*) DESC;

SELECT housing, COUNT(*) 
FROM EquipA.BANK_marketing
GROUP BY housing
ORDER BY COUNT(*) DESC;

SELECT loan, COUNT(*) 
FROM EquipA.BANK_marketing
GROUP BY loan
ORDER BY COUNT(*) DESC;

SELECT contact, COUNT(*) 
FROM EquipA.BANK_marketing
GROUP BY contact
ORDER BY COUNT(*) DESC;

SELECT campaign, COUNT(*) 
FROM EquipA.BANK_marketing
GROUP BY campaign
ORDER BY COUNT(*) DESC;

SELECT previous, COUNT(*) 
FROM EquipA.BANK_marketing
GROUP BY previous
ORDER BY COUNT(*) DESC;

SELECT poutcome, COUNT(*) 
FROM EquipA.BANK_marketing
GROUP BY poutcome
ORDER BY COUNT(*) DESC;

SELECT DISTINCT previous, poutcome, COUNT(*)
FROM EquipA.BANK_marketing
WHERE poutcome = "Unknown"
GROUP BY previous, poutcome;

SELECT deposit, COUNT(*) 
FROM EquipA.BANK_marketing
GROUP BY deposit
ORDER BY COUNT(*) DESC;

CREATE VIEW perfil_Cliente AS (
	SELECT *
    FROM EquipA.BANK_marketing
);

SELECT *
FROM EquipA.BANK_marketing;

SELECT COUNT(*)
FROM EquipA.BANK_marketing;

ALTER VIEW perfil_Cliente AS (
	SELECT id, 
			CASE 
				WHEN age < 25 THEN "under 25"
				WHEN age >= 25 AND age < 30 THEN "25-29"
                WHEN age >= 30 AND age < 35 THEN "30-34"
                WHEN age >= 35 AND age < 40 THEN "35-39"
                WHEN age >= 40 AND age < 45 THEN "40-44"
                WHEN age >= 45 AND age < 50 THEN "45-49"
                WHEN age >= 50 AND age < 55 THEN "50-54"
                WHEN age >= 55 AND age < 60 THEN "55-59"
                ELSE "60+"
                END AS age_group,
			job,
            marital,
            education,
            CASE 
				WHEN education = "tertiary" THEN "yes"
                ELSE "no" 
                END AS college_university,
			`default`,
            balance,
            housing,
            loan,
            contact,
            `day`,
            `month`,
            duration,
            pdays,
            previous,
            poutcome,
            deposit
    FROM EquipA.BANK_marketing
);

SELECT * FROM EquipA.perfil_Cliente;


WITH CTE AS 
(
	SELECT age_group,
    SUM(CASE WHEN deposit = "yes" THEN 1 ELSE 0 END) AS deposits,
    COUNT(*) AS total_calls
    FROM EquipA.perfil_Cliente
	GROUP BY age_group
)
SELECT age_group, 
	deposits,
    total_calls,
	ROUND(deposits / total_calls * 100, 2) AS deposit_rate
FROM CTE
ORDER BY 4 DESC;




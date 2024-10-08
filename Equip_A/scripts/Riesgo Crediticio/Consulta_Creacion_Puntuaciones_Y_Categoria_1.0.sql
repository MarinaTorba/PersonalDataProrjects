WITH puntuaciones AS (SELECT  id, job, 

		CASE job
			WHEN 'management' THEN 10
			WHEN 'technician' THEN 9
			WHEN 'admin' THEN 8
			WHEN 'entrepreneur' THEN 7
			WHEN 'self-employed' THEN 7
			WHEN 'services' THEN 5
			WHEN 'blue-collar' THEN 5
			WHEN 'retired' THEN 5
			WHEN 'housemaid' THEN 4
			WHEN 'student' THEN 3
			WHEN 'unemployed' THEN 2
			ELSE 4
		END AS puntuacion_trabj,
		
		age, 
		CASE 
		  WHEN age BETWEEN 50 and 64 THEN 4
		  WHEN age BETWEEN 30 AND 49 THEN 8
		  WHEN age BETWEEN 20 AND 29 THEN 4
		  WHEN age < 20 THEN  2
		  ELSE 2
		  
		  END AS age_puntuacion,    
		
		marital, 
		CASE marital
			WHEN 'married' THEN 3
			WHEN 'single' THEN 2
			WHEN 'divorced' THEN 1
			ELSE 2 
		END AS marital_puntuacion,
		
		education,
		CASE education
		WHEN "tertiary" THEN 3
		WHEN "secondary" THEN 2
		WHEN "primary" THEN	1
		ELSE 2
		END AS education_puntuacion,
		
		`default`, 
		CASE `default`
		WHEN "no" THEN 10
		WHEN "yes" THEN 0
		END AS default_puntuacion,
		
		balance, 
		CASE
		WHEN balance >= 3000 THEN 3
		WHEN balance BETWEEN 123 AND 2999  THEN 2
		WHEN balance BETWEEN 0 AND 122 THEN 1
		ELSE 0
		END AS balance_puntuacion,
		
		housing, 
		CASE housing
		WHEN "no" THEN 5
		WHEN "yes" THEN 0
		ELSE 1
		END AS housing_puntuacion,
		
		loan,
		CASE loan
		WHEN "no" THEN 5
		WHEN "yes" THEN 0
		ELSE 1
		END AS loan_puntuacion
		
		FROM BANK_marketing)
    
	SELECT id, job, puntuacion_trabj, age, age_puntuacion, marital, marital_puntuacion, education, education_puntuacion, `default`,  default_puntuacion,  balance,  balance_puntuacion, housing, 
	housing_puntuacion, loan, loan_puntuacion,
	(puntuacion_trabj + age_puntuacion + marital_puntuacion + education_puntuacion + default_puntuacion + balance_puntuacion + housing_puntuacion + loan_puntuacion) AS puntuacion_total,
		
	CASE  
		WHEN (puntuacion_trabj + age_puntuacion + marital_puntuacion + education_puntuacion + default_puntuacion + balance_puntuacion + housing_puntuacion + loan_puntuacion) BETWEEN 0 AND 16 THEN "MUY ALTO"
		WHEN (puntuacion_trabj + age_puntuacion + marital_puntuacion + education_puntuacion + default_puntuacion + balance_puntuacion + housing_puntuacion + loan_puntuacion) BETWEEN 17 AND 26 THEN "ALTO"
		WHEN (puntuacion_trabj + age_puntuacion + marital_puntuacion + education_puntuacion + default_puntuacion + balance_puntuacion + housing_puntuacion + loan_puntuacion) BETWEEN 27 AND 36 THEN "BAJO"
		ELSE "MUY BAJO"
	END AS riesgo_cred

	FROM puntuaciones;
SELECT * FROM EquipB.BANK_marketing301024;

SELECT 
    SUM(CASE WHEN id IS NULL OR "" THEN 1 ELSE 0 END) AS null_id,
    SUM(CASE WHEN age IS NULL OR ""THEN 1 ELSE 0 END) AS null_age,
    SUM(CASE WHEN job IS NULL OR ""THEN 1 ELSE 0 END) AS null_job,
    SUM(CASE WHEN marital IS NULL OR ""THEN 1 ELSE 0 END) AS null_marital,
    SUM(CASE WHEN education IS NULL OR ""THEN 1 ELSE 0 END) AS null_education,
    SUM(CASE WHEN `default` IS NULL OR ""THEN 1 ELSE 0 END) AS null_default,
    SUM(CASE WHEN balance IS NULL OR ""THEN 1 ELSE 0 END) AS null_balance,
    SUM(CASE WHEN housing IS NULL OR ""THEN 1 ELSE 0 END) AS null_housing,
    SUM(CASE WHEN loan IS NULL OR ""THEN 1 ELSE 0 END) AS null_loan,
    SUM(CASE WHEN contact IS NULL OR ""THEN 1 ELSE 0 END) AS null_contact,
    SUM(CASE WHEN `day` IS NULL OR ""THEN 1 ELSE 0 END) AS null_day,
    SUM(CASE WHEN `month` IS NULL OR ""THEN 1 ELSE 0 END) AS null_month,
    SUM(CASE WHEN duration IS NULL OR ""THEN 1 ELSE 0 END) AS null_duration,
    SUM(CASE WHEN campaign IS NULL OR ""THEN 1 ELSE 0 END) AS null_campaign,
    SUM(CASE WHEN pdays IS NULL OR ""THEN 1 ELSE 0 END) AS null_pdays,
    SUM(CASE WHEN previous IS NULL OR ""THEN 1 ELSE 0 END) AS null_previous,
    SUM(CASE WHEN poutcome IS NULL OR ""THEN 1 ELSE 0 END) AS null_poutcome,
    SUM(CASE WHEN deposit IS NULL OR ""THEN 1 ELSE 0 END) AS null_deposit
FROM BANK_marketing301024;

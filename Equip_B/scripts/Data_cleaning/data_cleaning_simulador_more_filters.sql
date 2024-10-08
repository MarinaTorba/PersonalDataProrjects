-- Filter
SELECT *
FROM BANK_marketing
WHERE job  IS NULL or job  = '' ;

SELECT *
FROM BANK_marketing
WHERE `default`  IS NULL or `default`  = '' ;

-- Filter
SELECT *
FROM BANK_marketing
WHERE balance  IS NULL or balance  = '' ;

SELECT *
FROM BANK_marketing
WHERE `day`  IS NULL or `day`  = '' ;

-- Info to find
SELECT campaign , COUNT(*)
FROM BANK_marketing
GROUP BY campaign ;

SELECT *
FROM BANK_marketing;

SELECT *
FROM BANK_marketing



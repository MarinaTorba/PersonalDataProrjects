
/* Depositos por duration_slot */

SELECT duration_slot,
  COUNT(CASE WHEN deposit = "yes" THEN 1 END) AS qty_yes,
  COUNT(CASE WHEN deposit <> "yes" THEN 1 END) AS qty_no
FROM v_marketing
GROUP BY duration_slot
ORDER BY duration_slot ASC;

/* DEPOSITOS POR ESTADO CIVIL */
SELECT marital,
  COUNT(CASE WHEN deposit = "yes" THEN 1 END) AS qty_yes,
  COUNT(CASE WHEN deposit <> "yes" THEN 1 END) AS qty_no
FROM v_marketing
GROUP BY marital
ORDER BY marital ASC;

/* Consulta de depositos por education */
SELECT education,
  COUNT(CASE WHEN deposit = "yes" THEN 1 END) AS qty_yes,
  COUNT(CASE WHEN deposit <> "yes" THEN 1 END) AS qty_no
FROM v_marketing
GROUP BY education;

/* Consulta depositos por mes */
SELECT month,
  COUNT(CASE WHEN deposit = "yes" THEN 1 END) AS qty_yes,
  COUNT(CASE WHEN deposit <> "yes" THEN 1 END) AS qty_no
FROM BANK_marketing
GROUP BY month
ORDER BY month ASC;

/* Consulta depositos por mes y duration_slot*/
SELECT contact_month, duration_slot,
  COUNT(CASE WHEN deposit = "yes" THEN 1 END) AS qty_yes,
  COUNT(CASE WHEN deposit <> "yes" THEN 1 END) AS qty_no
FROM v_marketing
GROUP BY contact_month, duration_slot
ORDER BY contact_month ASC;

/* Consulta deposit por campaign */
SELECT campaign,
  COUNT(CASE WHEN deposit = "yes" THEN 1 END) AS qty_yes,
  COUNT(CASE WHEN deposit <> "yes" THEN 1 END) AS qty_no
FROM v_marketing
GROUP BY campaign
ORDER BY campaign ASC;

/* Consulta duration_slot por deposit */
SELECT duration_slot,deposit,COUNT(id)  
FROM v_marketing 
GROUP BY duration_slot,deposit 
ORDER BY duration_slot;

/* Consulta duration_slot por deposit Y contact */
SELECT contact,duration_slot, deposit, COUNT(id) 
FROM v_marketing 
GROUP BY duration_slot,contact, deposit 
ORDER BY contact, duration_slot,deposit;

/* Consulta age_slot por duration_slot */
SELECT age_slot,duration_slot,COUNT(id)  
FROM v_marketing 
GROUP BY age_slot,duration_slot 
ORDER BY COUNT(id) desc;

/* Consulta  distintos valores de pdays_slot */
SELECT DISTINCT pdays_slot,COUNT(id) 
FROM EquipA.v_marketing 
GROUP BY pdays_slot 
ORDER BY pdays_slot;

/* Consulta más de 20 llamadas recibidas */
SELECT COUNT(id) 
FROM EquipA.v_marketing 
WHERE campaign>20;
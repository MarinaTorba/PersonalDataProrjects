Select duration_slot,deposit,count(id)  from v_marketing group by duration_slot,deposit order by duration_slot;

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

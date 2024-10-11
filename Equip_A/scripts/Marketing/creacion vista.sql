USE EquipA;
/* 
Creación Vista v_marketing 
Se modifica el nombre de day y month para mayor comodidad en lAS queries y explicación de lo que representa el campo
Se añaden los campos calculados duration_slot, age_slot y pdays_slot para categorizar los datos en franjAS
*/

CREATE  view v_marketing AS 
(SELECT id, age,job, marital, education,`default` AS default_credit, contact, `day` AS 'contact_day', `month` AS 'contact_month',
duration, campaign, pdays, previous, poutcome, deposit, 
CONCAT(substring(age,1,1) ,'X') AS age_slot, 
	IF (duration<150 ,'d02',IF(duration < 300,'d05', 
    IF (duration <450,'d07', 
	If (duration <600,'d10',
    'dmAS10')))) 
AS duration_slot, 
	IF (pdays=-1 ,'nc',IF(pdays < 30,'m01', 
	IF (pdays <60,'m02', 
	If (pdays <90,'m03',
	IF(pdays < 120,'m04',
	IF(pdays < 150,'m05',
	IF(pdays < 180,'m06',
	IF(pdays < 210,'m07',
	IF(pdays < 240,'m08',
	IF(pdays < 270,'m09',
	IF(pdays < 300,'m10',
	IF(pdays < 330,'m11',
	IF(pdays < 360,'m12',
	IF(pdays < 450,'m15',
	'mAS15'))))))))))))))   
AS pdays_slot 
FROM EquipA.BANK_marketing
);
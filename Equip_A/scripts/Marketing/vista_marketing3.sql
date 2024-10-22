/* Creación Vista v_marketing3 
Se modifica el nombre de day y month (de uso restringido y complica las consultas y mejorar la explicación de que representa el campo.

Se añaden los campos calculados duration_slot, age_slot y pdays_slot para categorizar los datos en franjas
*/

USE EquipA;

CREATE  view v_marketing3 AS 
(SELECT id, age,job, marital, education,`default` AS default_credit, contact, `day` AS 'contact_day', `month` AS 'contact_month',
duration, campaign, pdays, previous, poutcome, deposit, 
CONCAT(substring(age,1,1) ,'X') AS age_slot, 
	IF (duration<150 ,'d<2',IF(duration < 300,'d<5', 
    IF (duration <450,'d<7', 
	If (duration <600,'d<10',
    'd>10')))) 
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
AS prevdays_slot 
FROM EquipA.BANK_marketing211024
);
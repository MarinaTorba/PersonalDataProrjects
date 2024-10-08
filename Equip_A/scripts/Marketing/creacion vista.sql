USE EquipA;

Create  view v_marketing as 
(select id, age,job, marital, education,`default` as default_credit, contact, `day` as 'contact_day', `month` as 'contact_month',
duration,campaign, pdays, previous,poutcome, deposit, IF (duration<150 ,'d02',IF(duration < 300,'d05', IF (duration <450,'d07', 
If (duration <600,'d10','dmas10')))) as duration_slot, concat(substring(age,1,1) ,'X') as age_slot
 from EquipA.BANK_marketing
);

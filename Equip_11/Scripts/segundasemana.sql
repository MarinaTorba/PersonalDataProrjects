select * from RRHH_16062025;

select * from RRHH_16062025
where Absenteeism_hours>0;


select ID, Reason_absence, Month_absence, day_week, Seasons,
 Transportation_expense, Distance_Residence_Work, Service_time, Age,
 Work_load_Average_day, Hit_target, Disciplinary_failure, Education,
 Son, Social_drinker, Social_smoker, Pet, Weight, Height,
 Body_mass_index, Absenteeism_hours, count(*) as veces
 from RRHH_16062025
 group by ID, Reason_absence, Month_absence, day_week, Seasons,
 Transportation_expense, Distance_Residence_Work, Service_time, Age,
 Work_load_Average_day, Hit_target, Disciplinary_failure, Education,
 Son, Social_drinker, Social_smoker, Pet, Weight, Height,
 Body_mass_index, Absenteeism_hours
 having veces > 1;
 
 select ID, count(*) as veces
 from RRHH_16062025
 group by ID
 having veces > 1;
 
 
 SELECT COUNT(DISTINCT ID) AS cantidad_distintos
FROM RRHH_16062025;

ALTER TABLE RRHH_16062025
MODIFY COLUMN Son INT;

ALTER TABLE RRHH_16062025
MODIFY COLUMN Work_load_Average_day decimal(6, 3);

SET SQL_SAFE_UPDATES = 0;
UPDATE RRHH_16062025
SET Seasons = CASE
    WHEN Month_absence IN (12, 1, 2) THEN 3  -- Invierno
    WHEN Month_absence IN (3, 4, 5) THEN 4   -- Primavera
    WHEN Month_absence IN (6, 7, 8) THEN 1   -- Verano
    WHEN Month_absence IN (9, 10, 11) THEN 2 -- Otoño
    ELSE Seasons  -- Por si acaso hay algún valor inválido
END;
SET SQL_SAFE_UPDATES = 1;

UPDATE RRHH_16062025
SET Work_load_Average_day = REPLACE(Work_load_Average_day, ',', '.');

ALTER TABLE RRHH_16062025
MODIFY COLUMN Work_load_Average_day DECIMAL(10, 3);

CREATE TABLE Equip_11.RRHH_16062025_sin_duplicados AS
WITH duplicados AS (
  SELECT *,
         ROW_NUMBER() OVER (
           PARTITION BY 
             ID, Reason_absence, Month_absence, Day_week, Seasons, 
             Transportation_expense, Distance_Residence_Work, Service_time,
             Age, Work_load_Average_day, Hit_target, Disciplinary_failure,
             Education, Son, Social_drinker, Social_smoker, Pet, Weight,
             Height, Body_mass_index, Absenteeism_hours
           ORDER BY (SELECT NULL)
         ) AS rn
  FROM Equip_11.RRHH_16062025
)
SELECT 
    ID, Reason_absence, Month_absence, Day_week, Seasons, 
    Transportation_expense, Distance_Residence_Work, Service_time,
    Age, Work_load_Average_day, Hit_target, Disciplinary_failure,
    Education, Son, Social_drinker, Social_smoker, Pet, Weight,
    Height, Body_mass_index, Absenteeism_hours
FROM duplicados
WHERE NOT (Absenteeism_hours IN (112, 120) AND rn > 1);

select ID, Reason_absence, Month_absence, day_week, Seasons,
 Transportation_expense, Distance_Residence_Work, Service_time, Age,
 Work_load_Average_day, Hit_target, Disciplinary_failure, Education,
 Son, Social_drinker, Social_smoker, Pet, Weight, Height,
 Body_mass_index, Absenteeism_hours, count(*) as veces
 from RRHH_16062025_sin_duplicados
 group by ID, Reason_absence, Month_absence, day_week, Seasons,
 Transportation_expense, Distance_Residence_Work, Service_time, Age,
 Work_load_Average_day, Hit_target, Disciplinary_failure, Education,
 Son, Social_drinker, Social_smoker, Pet, Weight, Height,
 Body_mass_index, Absenteeism_hours
 having veces > 1;
 
 select * from RRHH_16062025_sin_duplicados;
 
 DROP TABLE Equip_11.RRHH_16062025;
RENAME TABLE Equip_11.RRHH_16062025_sin_duplicados TO RRHH_16062025;
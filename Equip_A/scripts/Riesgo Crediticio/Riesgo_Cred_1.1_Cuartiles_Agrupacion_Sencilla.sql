SELECT * FROM EquipA.BANK_marketing;

/* Buscamos los rangos de los cuartiles*/
WITH ranked_balances AS (
    SELECT 
        balance, 
        NTILE(4) OVER (ORDER BY balance) AS quartile
    FROM BANK_marketing
)
SELECT 
    MIN(balance) AS Min_Balance,
    MAX(balance) AS Max_Balance,
    quartile
FROM ranked_balances
GROUP BY quartile
ORDER BY quartile;

/* visualizamos la columna "quartile" para ver los grupos separados  */
SELECT *, 
       NTILE(4) OVER (ORDER BY balance) AS quartile
FROM BANK_marketing;



/* Sabiendo los rangos de los cuatiles, podemos tomar el valor 550 como tope para considerar un balance de riesgo, por lo tanto
 todo aquel balance inferior a 550 se considerará de RIESGO */
 
 /*Otros factores a tener en cuenta para el análisis de un riesgo alto serían: 
 "job" si tiene trabajo o no o que tipo de trabjo;
 "default" si ya ha tenido incumplimientos;
 "loan" si ya tiene otros prestamos
 "housing" si no tiene hipoteca
 
 otros datos a tener en cuenta que podrian afectar al riesgo serían:
 "marital" se supone que podria compartir carga financiera
 "education" puede influir en la estabilidad
 */
 
 
 
 
 /*Abordamos la primera variable JOB para categorizarlas, aqui el primer problema que nos encontramos es los UNKNOWN, puesto que nuestro trabajo es crear la politica de riesgos
 podemos abordarla de dos maneras:
 Teniendo en cuenta que segmentaremos todos los trabajos segun su puesto siendo: Altos cargos y similares el grupo 3, Empleos de mediana remuneración: 2 y
 desmpleados, empleos de baja remuneracion, y retirados: 1
 
 1ra: Tratarlos como un grupo independiente exigiendole la mismas reglas que los demas
 
 2da: Establecer unos parametros para categorizar los unknown dentro del grupo anterior(job), por ejemplo si estan dentro del mayor rango de cuartil
 y no tienen impagos, ni hipotecas serán del grupo 3 ---tambien se puede tener en cuenta la educación--
 
 En este caso, optaremos por la opción numero 1
 */
 


/*Este es un primer tratamiento de los riesgos, solo tienendo en cuenta el balance entre los rangos cuartiles*/

SELECT id, job, balance, housing, loan, `default`,
    CASE
        -- Alto riesgo (1): Clientes con balance bajo o con factores de riesgo
        WHEN balance < 550 THEN "Alto Riesgo"
        WHEN loan = 'yes' THEN "Alto Riesgo"
        WHEN housing = 'yes' THEN "Alto Riesgo"
        WHEN `default` = 'yes' THEN "Alto Riesgo"

        -- Bajo riesgo (3): Clientes con balance alto y sin factores de riesgo
        WHEN balance >= 1710 AND loan = 'no' AND housing = 'no' AND `default` = 'no' THEN "Bajo Riesgo"

        -- Riesgo moderado (2): Todos los demás casos
        ELSE "Riesgo Moderado"
    END AS Riesgo_Crediticio
FROM BANK_marketing;

/*Sin embargo, yo creo que lo mas conveniente es establecer un sistema de puntuación de cada parametro para poder captar tambien la solvencia de cada trabajo, estado civil,etc
 por ello poder contabilizar una puntuación te pueda dar más al detalle los riesgos sin sesgarlos tanto*/


 
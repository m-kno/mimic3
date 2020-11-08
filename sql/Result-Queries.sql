-- War die erste Extubation erfolgreich? 1 = Ja, 0 = Nein
SELECT DISTINCT i2.hadm_id,
    v.icustay_id,
    extu.ex,
    extu.amount,
        CASE
            WHEN extu.amount = 1 THEN 1
            WHEN extu.amount IS NULL THEN '-1'::integer
            ELSE 0
        END AS label
FROM ventsettings v
JOIN icustays i2 ON i2.icustay_id::numeric = v.icustay_id
JOIN ( SELECT DISTINCT ve.icustay_id,
            ve.ex,
            count(ve.icustay_id) AS amount
           FROM vw_extubations ve
          WHERE ve.ex = '-1'::integer
          GROUP BY ve.icustay_id, ve.ex) extu ON extu.icustay_id = v.icustay_id
WHERE (i2.hadm_id IN ( SELECT hadm_overview.hadm_id
           FROM hadm_overview))
ORDER BY v.icustay_id
  
 SELECT DISTINCT ve.icustay_id,
            count(ve.icustay_id) AS amount
           FROM vw_extubations ve
          WHERE ve.ex = '-1'::integer
          GROUP BY ve.icustay_id


-- Timestamp of extubation
select hadm_id, charttime 
from vw_timestamp_extubation vte ;

-- Timestamp of first extubation
select hadm_id, min(charttime)
from vw_timestamp_extubation vte
group by hadm_id 
order by hadm_id ;
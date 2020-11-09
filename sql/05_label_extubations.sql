/*
 * Getting the label from the duraton between extubation and intubation.
 */

CREATE OR REPLACE VIEW public.vw_label_extubations
AS 
	SELECT res.hadm_id,
	    res.icustay_id,
	    res.dauer,
	    res.label
	   FROM 
	   -- Creating a label by thed duration of extubation. If null or > 48h the extubation is succesfully = 1, else 0
	   		( SELECT duration.hadm_id,
	            duration.icustay_id,
	            max(duration.dauer_h) AS dauer,
	                CASE
	                    WHEN max(duration.dauer_h) IS NULL THEN 1
	                    WHEN max(duration.dauer_h) > 48::double precision THEN 1
	                    ELSE 0
	                END AS label
	           FROM 
	           -- Calculated the time between extubation and the next possible intubation in hours
	           		( SELECT first_tube.hadm_id,
	                    first_tube.icustay_id,
	                    first_tube.ts_first,
	                    first_tube.ex,
	                    date_part('epoch'::text, first_tube.ts_first - lag(first_tube.ts_first, 1) OVER (PARTITION BY first_tube.icustay_id ORDER BY first_tube.ts_first)) / 3600::double precision AS dauer_h
	                   FROM 
	                   --Extract the first changes of mechanical ventilation
	                   		( SELECT ve.hadm_id,
	                            ve.icustay_id,
	                            min(ve.charttime) AS ts_first,	--first timestamp of the change
	                            ve.ex
	                           FROM vw_extubations ve
	                          WHERE ve.ex <> 0
	                          GROUP BY ve.hadm_id, ve.icustay_id, ve.ex
	                          ORDER BY ve.icustay_id, (min(ve.charttime))) first_tube
	                  ORDER BY first_tube.icustay_id, first_tube.ts_first) duration
	          GROUP BY duration.hadm_id, duration.icustay_id
	          ORDER BY duration.icustay_id) res
	  WHERE res.dauer <> 0::double precision OR res.dauer IS NULL;
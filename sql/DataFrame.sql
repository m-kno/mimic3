/*
 * Abfrage zur Selection der Features.
 */
--CREATE OR REPLACE VIEW public.vw_patient_group AS 
SELECT  distinct vle."label" , ho.hadm_id , icu.icustay_id ,
    a."SUBJECT_ID",
    p.gender,
    a.admittime,
    p.dob,
        CASE
            WHEN (date_part('year'::text, a.admittime) - date_part('year'::text, p.dob)) > 89::double precision THEN 90::double precision
            ELSE date_part('year'::text, a.admittime) - date_part('year'::text, p.dob)
        END AS sub_age,
    last_diagnosis.icd9_code AS last_icd9_code,
    last_diagnosis.amount AS numb_diagn,
    icu.last_careunit,
    icu.los,
    case 
    	when trach.hadm_id is not null then 1
    	else 0
    end as tracheo
   FROM hadm_overview ho
     JOIN admissions a ON a.hadm_id = ho.hadm_id
     JOIN patients p ON p.subject_id = a."SUBJECT_ID"
     JOIN ( SELECT di.hadm_id,
            di.icd9_code,
            max_seq.last AS amount
           FROM diagnoses_icd di
             JOIN ( SELECT di_1.hadm_id,
                    max(di_1.seq_num) AS last
                   FROM diagnoses_icd di_1
                  GROUP BY di_1.hadm_id) max_seq ON max_seq.hadm_id = di.hadm_id AND max_seq.last = di.seq_num) last_diagnosis ON last_diagnosis.hadm_id = ho.hadm_id
     -- ICU unit zu der ersten Extubation ermittelt. 
     JOIN (select distinct i.hadm_id, i.icustay_id, i.last_careunit, i.los 
			from icustays i 
			left join (select icustay_id, min(charttime) as first_extubation
						from vw_timestamp_extubation vte
						group by icustay_id) ts on ts.icustay_id = i.icustay_id 
			where i.hadm_id in (SELECT hadm_overview.hadm_id
			           FROM hadm_overview)
				and ts.first_extubation between i.intime and i.outtime ) icu ON icu.hadm_id = ho.hadm_id
	join vw_label_extubations vle on vle.icustay_id = icu.icustay_id 
	left join (select d.hadm_id from drgcodes d 
				where description like '%Tracheostomy%') trach on ho.hadm_id = trach.hadm_id
  WHERE (ho.hadm_id IN ( SELECT hadm_overview.hadm_id
           FROM hadm_overview))
order by ho.hadm_id  
;
           
          
-- ICU unit zu der ersten Extubation ermittelt.
select distinct hadm_id, count(icustay_id) from (
select i.hadm_id, i.icustay_id, i.last_careunit, i.los 
from icustays i 
left join (select icustay_id, min(charttime) as first_extubation
			from vw_timestamp_extubation vte
			group by icustay_id) ts on ts.icustay_id = i.icustay_id 
where i.hadm_id in (SELECT hadm_overview.hadm_id FROM hadm_overview)
	and ts.first_extubation between i.intime and i.outtime 
order by icustay_id ) a
group by hadm_id 
order by count(icustay_id) DESC
;
					
select vte.hadm_id, icustay_id, min(charttime) as first_extubation
from vw_timestamp_extubation vte
group by vte.hadm_id ,icustay_id;



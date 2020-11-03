--PATIENT GROUP
drop view vw_patient_group ;
create view vw_patient_group as (
select ho.hadm_id, a."SUBJECT_ID", p.gender ,
	a.admittime , p.dob, 
	case 
		when DATE_PART('year', a.admittime) - DATE_PART('year', p.dob) > 89 then 90
	else
		DATE_PART('year', a.admittime) - DATE_PART('year', p.dob)
	end as sub_AGE,
	last_diagnosis.icd9_code as last_icd9_code,
	i.last_careunit, i.los 
from hadm_overview ho
inner join admissions a on a.hadm_id = ho.hadm_id
inner join patients p on p.subject_id = a."SUBJECT_ID" 
inner join (select di.hadm_id, di.icd9_code
			from diagnoses_icd di 
			inner join (select hadm_id , max(seq_num) as last
						from diagnoses_icd di 
						group by hadm_id) as max_seq
			on (max_seq.hadm_id = di.hadm_id and max_seq.last = di.seq_num)) as last_diagnosis
			on last_diagnosis.hadm_id = ho.hadm_id
inner join icustays i on i.hadm_id = ho.hadm_id 
where ho.hadm_id in (select * from hadm_overview)
)
;
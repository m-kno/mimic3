CREATE OR REPLACE VIEW public.hadm_overview as
SELECT c2.hadm_id
   FROM cptevents c2
  WHERE (c2.hadm_id IN ( SELECT vw_ards_patient.hadm_id
           FROM vw_ards_patient)) AND (c2.cpt_cd::text = ANY (ARRAY['94003'::character varying, '94002'::character varying]::text[]))
UNION
 SELECT pi2.hadm_id
   FROM procedures_icd pi2
  WHERE (pi2.hadm_id IN ( SELECT vw_ards_patient.hadm_id
           FROM vw_ards_patient)) AND (pi2.icd9_code::text = ANY (ARRAY['9672'::character varying, '9671'::character varying, '9670'::character varying]::text[]))
UNION
 SELECT pm.hadm_id
   FROM procedureevents_mv pm
  WHERE (pm.hadm_id IN ( SELECT vw_ards_patient.hadm_id
           FROM vw_ards_patient)) AND pm.itemid = 225792
UNION
 SELECT d.hadm_id
   FROM drgcodes d
  WHERE (d.hadm_id IN ( SELECT vw_ards_patient.hadm_id
           FROM vw_ards_patient)) AND (d.drg_code::text = ANY (ARRAY['1303'::character varying, 
           														'475'::character varying,
           														'566'::character varying,
           														'576'::character varying,
           														'208'::character varying]::text[]));
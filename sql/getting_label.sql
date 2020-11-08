
select vtc.hadm_id , max(vtc.charttime)
from vw_t_chartevents vtc 
where itemid in (211, 220045)
	and vtc.charttime <= '2188-05-28 09:00:00'
	--and vtc.hadm_id = 100016 
group by vtc.hadm_id
--having itemid in (211, 220045)
--order by vtc.charttime DESC ;

select vte.* 
	vte.charttime - lag(vte.charttime, 1) OVER (PARTITION BY vte.icustay_id ORDER BY vte.icustay_id, vte.charttime) AS time
from vw_timestamp_extubation vte 
;

--------------------------------------------------------------------------------------------------
/*
 * Wir haben die Extubationen festgelegt als Änderung der mechanischen Ventilation von 0 auf 1.
 * Eine Intubation ist entsprechend andersherum.
 * Für die Spalte ex gilt daher:
 * Extubation = -1 
 * Intubation = 1
 */
select * from vw_extubations ve ;

/*
 * Daraus ergibt sich durch Filterung auf ungleich 0 (Null werte dann ebenfalls ausgeschlossen) 
 * um alle Ex- und Intubationen zu finden. Gleichzeitig kann sich die Differenz zwischen Extubation und
 * Intubation errechnen lassen.
 */

select hadm_id, icustay_id ,charttime ,ex ,
	extract(EPOCH FROM
	ve.charttime - lag(ve.charttime, 1) over 
	(partition by ve.icustay_id order by ve.icustay_id, ve.charttime))/3600 as dauer_h
from vw_extubations ve 
where ve.ex <> 0
order by ve.icustay_id , ve.charttime ;

/*
 * Wir möchten und nur die erste Extubation eines ICU-Stays anschauen und filtern die ersten Einträge
 */
select ve.hadm_id , ve.icustay_id , min(ve.charttime) , ex
from vw_extubations ve 
where ve.ex <> 0
group by ve.hadm_id , icustay_id , ex 
order by ve.icustay_id, min(ve.charttime) ;


/*
 * Von den ersten Extubationen müssen wir die Dauer bis zu nächsten Intubation errechnen. 
 * 
 */
select first_tube.*,
	extract(EPOCH from 
		ts_first - lag(ts_first, 1) over (partition by icustay_id order by ts_first)
	)/3600 as dauer_h
from (
	select ve.hadm_id , ve.icustay_id , min(ve.charttime) as ts_first, ex
	from vw_extubations ve 
	where ve.ex <> 0
	group by ve.hadm_id , icustay_id , ex 
	order by ve.icustay_id, min(ve.charttime)
	) first_tube
order by icustay_id, ts_first
;

/*
 * Herauslösen der erfolgreichen Extubation anhand der Dauer bis zur nächsten Intubation.
 * Ist keine weitere Intubation erfolgt, oder ist mehr 48 Stunden nach der Extubation, gilt die Extubation 
 * als erfolgreich.
 */
select hadm_id, icustay_id, max(dauer_h) as ext_duration,
	case
		when max(dauer_h) is null then 1
		when max(dauer_h) > 48 then 1
		else 0
	end as "label"
from (
	select first_tube.*,
		extract(EPOCH from 
			ts_first - lag(ts_first, 1) over (partition by icustay_id order by ts_first)
		)/3600 as dauer_h
	from (
		select ve.hadm_id , ve.icustay_id , min(ve.charttime) as ts_first, ex
		from vw_extubations ve 
		where ve.ex <> 0
		group by ve.hadm_id , icustay_id , ex 
		order by ve.icustay_id, min(ve.charttime)
		) first_tube
	order by icustay_id, ts_first
	) duration
--where max(dauer_h) <> 0 or max(dauer_h) is null
group by hadm_id, icustay_id
order by icustay_id 
;

/*
 * Creating the view to merge with patient_group and saving the result
 */
create or replace view vw_label_extubations as
select res.*
from (
	select hadm_id, icustay_id, max(dauer_h) as dauer,
		case
			when max(dauer_h) is null then 1
			when max(dauer_h) > 48 then 1
			else 0
		end as "label"
	from (
		select first_tube.*,
			extract(EPOCH from 
				ts_first - lag(ts_first, 1) over (partition by icustay_id order by ts_first)
			)/3600 as dauer_h
		from (
			select ve.hadm_id , ve.icustay_id , min(ve.charttime) as ts_first, ex
			from vw_extubations ve 
			where ve.ex <> 0
			group by ve.hadm_id , icustay_id , ex 
			order by ve.icustay_id, min(ve.charttime)
			) first_tube
		order by icustay_id, ts_first
		) duration
	group by hadm_id, icustay_id
	order by icustay_id 
) res
where res.dauer <> 0 or res.dauer is null 
;
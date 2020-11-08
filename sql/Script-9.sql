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
 * Nun haben wir die Differenz zwischen extubation und intubation errechnet. Wenn die Differenz 
 * größer als 48 Stunden ist, ist sie erfolgreich. Andernfalls nicht. 
 * 
 * extract(EPOCH FROM
	ve.charttime - lag(ve.charttime, 1) over 
	(partition by ve.icustay_id order by ve.icustay_id, ve.charttime))/3600 as dauer_h
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



select tub_diff.*
from (select hadm_id, icustay_id ,charttime ,ex ,
	extract(EPOCH FROM
	ve.charttime - lag(ve.charttime, 1) over 
	(partition by ve.icustay_id order by ve.icustay_id, ve.charttime))/3600 as dauer_h
from vw_extubations ve 
where ve.ex <> 0) tub_diff
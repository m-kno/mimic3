
CREATE TABLE chartev_values as
select vtc.icustay_id, vtc.value as value , 
	case 
		when vtc.itemid in (211, 220045) then 'hr' 
		when vtc.itemid in (52, 456, 225312, 220181, 220052) then 'blood_pr'
		when vtc.itemid in (676,  677, 223762) then 'temp'
		when vtc.itemid in (646, 834, 220277, 220227) then 'SaO2'
		when vtc.itemid in (618 ,  220210 , 224688) then 'resp_rat'
		when vtc.itemid in (445, 448, 449, 224687, 1340, 1486, 1600) then 'breath_min_vol'
		when vtc.itemid in (189, 190, 3420, 3422, 223835) then 'FiO2'
		when vtc.itemid in (681, 682, 683, 684, 224685, 224684, 224686) then 'tidal_vol'
		when vtc.itemid in (444, 224697) then 'mean_insp_pressure'
		when vtc.itemid in (506, 220339) then 'PEEP'
		when vtc.itemid in (1127, 861, 1542, 220546) then 'leuko'
		when vtc.itemid in (225668, 1531, 818) then 'lactic_acid'
	end as item
from vw_t_chartevents vtc 
inner join (
	select last_events.icustay_id, max(last_events.charttime) as ts
	from (
		select c.icustay_id, c.charttime , value 
		from vw_t_chartevents c 
		inner join (select hadm_id, icustay_id, min(charttime) as ext_ts
				from vw_timestamp_extubation vte
				group by hadm_id, icustay_id) min_ts 
				on (min_ts.icustay_id = c.icustay_id and min_ts.ext_ts > c.charttime)
		where c.itemid in (211, 220045,
							52, 456, 225312, 220181, 220052,
							676,  677, 223762,
							646, 834, 220277, 220227,
							618 ,  220210 , 224688,
							445, 448, 449, 224687, 1340, 1486, 1600,
							189, 190, 3420, 3422, 223835,
							681, 682, 683, 684, 224685, 224684, 224686,
							444, 224697,
							506, 220339,
							1127, 861, 1542, 220546,
							225668, 1531, 818)
	) as last_events
	group by last_events.icustay_id
	) x on (x.icustay_id = vtc.icustay_id and x.ts = vtc.charttime)
where vtc.itemid in (211, 220045,
							52, 456, 225312, 220181, 220052,
							676,  677, 223762,
							646, 834, 220277, 220227,
							618 ,  220210 , 224688,
							445, 448, 449, 224687, 1340, 1486, 1600,
							189, 190, 3420, 3422, 223835,
							681, 682, 683, 684, 224685, 224684, 224686,
							444, 224697,
							506, 220339,
							1127, 861, 1542, 220546,
							225668, 1531, 818);

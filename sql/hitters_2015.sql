copy

(
select
ps.year,
ps.player_name as name,
ps.team_name as team,
'D'||sd.div_id as div,
ps.class_year,
ps.position,
coalesce(ps.ab,0)+coalesce(ps.bb,0)+coalesce(ps.hbp,0) as pa,

(
(coalesce(ps.h,0)+coalesce(ps.bb,0)+coalesce(ps.hbp,0))::float/(coalesce(ps.ab,0)+coalesce(ps.bb,0)+coalesce(ps.hbp,0))
)::numeric(4,3) as obp,

(
(coalesce(ps.h,0)+coalesce(ps.bb,0)+coalesce(ps.hbp,0))::float/(coalesce(ps.ab,0)+coalesce(ps.bb,0)+coalesce(ps.hbp,0))
/sqrt(schedule_field_park_defensive*pd.exp_factor))::numeric(4,3) as adj_obp,

((
coalesce(ps.h,0)+coalesce(ps.d,0)+2*coalesce(ps.t,0)+3*coalesce(ps.hr,0)
)::float
/(coalesce(ps.ab,0)))::numeric(4,3) as slg,

((
coalesce(ps.h,0)+coalesce(ps.d,0)+2*coalesce(ps.t,0)+3*coalesce(ps.hr,0)
)::float
/(coalesce(ps.ab,0))
/sqrt(schedule_field_park_defensive*pd.exp_factor))::numeric(4,3) as adj_slg,

((2*
(coalesce(ps.h,0)+coalesce(ps.bb,0)+coalesce(ps.hbp,0))::float/(coalesce(ps.ab,0)+coalesce(ps.bb,0)+coalesce(ps.hbp,0))
/sqrt(schedule_field_park_defensive*pd.exp_factor))+

((
coalesce(ps.h,0)+coalesce(ps.d,0)+2*coalesce(ps.t,0)+3*coalesce(ps.hr,0)
)::float
/(coalesce(ps.ab,0))

/sqrt(schedule_field_park_defensive*pd.exp_factor))
)::numeric(4,3) as index

--sd.year,
--sd.school_id,
--sd.school_name as school,
--sd.div_id as division,

--year_factor::numeric(4,3) as year_factor,

--park::numeric(4,3) as park_factor,

--(sf.offensive*h.exp_factor)::numeric(4,3) as offensive,

--(sf.defensive*p.exp_factor)::numeric(4,3) as defensive,

--(sf.strength*h.exp_factor/p.exp_factor)::numeric(4,3) as strength,

--park_offensive::numeric(4,3),
--park_defensive::numeric(4,3),
--schedule_park::numeric(4,3),
--schedule_offensive::numeric(4,3),
--schedule_defensive::numeric(4,3),
--schedule_strength::numeric(4,3),
--schedule_field::numeric(4,3),
--schedule_park_offensive::numeric(4,3),
--schedule_park_defensive::numeric(4,3),
--schedule_field_park_offensive::numeric(4,3),
--schedule_field_park_defensive::numeric(4,3)

from ncaa_pbp.player_summaries_hitting ps
join ncaa._schedule_factors sf
  on (sf.school_id,sf.year)=(ps.team_id,ps.year)
join ncaa.schools_divisions sd
  on (sd.school_id,sd.year)=(sf.school_id,sf.year)

join ncaa._factors hd
  on (hd.parameter,hd.level::integer)=('h_div',sd.div_id)
join ncaa._factors pd
  on (pd.parameter,pd.level::integer)=('p_div',sd.div_id)

where 

    ps.class_year ilike 'sr'

and coalesce(ps.ab,0)+coalesce(ps.bb,0)+coalesce(ps.hbp,0) >= 150

and sf.year=2015
and sd.div_id in (1,2,3)

order by index desc nulls last

limit 200
)
to '/tmp/hitters_2015.csv' csv header;

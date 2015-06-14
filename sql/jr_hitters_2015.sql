copy

(
select
ps.year as year,
ps.player_name as name,
ps.team_name as team,
sd.div_id as div,
ps.class_year as cl,
ps.position as pos,
ps.ab+ps.bb+coalesce(ps.hbp,0) as pa,

(
(ps.h+ps.bb+coalesce(ps.hbp,0))::float/(ps.ab+ps.bb+coalesce(ps.hbp,0))
/sqrt(schedule_field_park_defensive*pd.exp_factor))::numeric(4,3) as adj_obp,

ps.slg::numeric(4,3) as slg,
(ps.slg/sqrt(schedule_field_park_defensive*pd.exp_factor))::numeric(4,3) as adj_slg,

((2*
(ps.h+ps.bb+coalesce(ps.hbp,0))::float/(ps.ab+ps.bb+coalesce(ps.hbp,0))
/sqrt(schedule_field_park_defensive*pd.exp_factor))+
(ps.slg/sqrt(schedule_field_park_defensive*pd.exp_factor))
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

    ps.class_year ilike 'jr'

and ps.ab+ps.bb+coalesce(ps.hbp,0) >= 150

and sf.year=2015
and sd.div_id in (1,2,3)

order by index desc

limit 100
)
to '/tmp/jr_hitters_2015.csv' csv header;

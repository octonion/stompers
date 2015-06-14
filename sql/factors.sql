copy

(
select
sd.year,
sd.school_id,
sd.school_name as school,
sd.div_id as division,

year_factor::numeric(4,3) as year_factor,

park::numeric(4,3) as park_factor,

(sf.offensive*h.exp_factor)::numeric(4,3) as offensive,

(sf.defensive*p.exp_factor)::numeric(4,3) as defensive,

(sf.strength*h.exp_factor/p.exp_factor)::numeric(4,3) as strength,

park_offensive::numeric(4,3),
park_defensive::numeric(4,3),
schedule_park::numeric(4,3),
schedule_offensive::numeric(4,3),
schedule_defensive::numeric(4,3),
schedule_strength::numeric(4,3),
schedule_field::numeric(4,3),
schedule_park_offensive::numeric(4,3),
schedule_park_defensive::numeric(4,3),
schedule_field_park_offensive::numeric(4,3),
schedule_field_park_defensive::numeric(4,3)

from ncaa._schedule_factors sf
join ncaa.schools_divisions sd
  on (sd.school_id,sd.year)=(sf.school_id,sf.year)

join ncaa._factors h
  on (h.parameter,h.level::integer)=('h_div',sd.div_id)

join ncaa._factors p
  on (p.parameter,p.level::integer)=('p_div',sd.div_id)

where sf.year=2013
)
to '/tmp/factors_2013.csv' csv header;

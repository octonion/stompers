copy

(
select
ps.year,
ps.player_name as name,
ps.team_name as team,
'D'||sd.div_id as div,
ps.class_year as class,
ps.position as pos,
ps.gs as gs,
ps.ip,
ps.so,
ps.bb,

3*split_part(ip,'.',1)::integer+
(
case when coalesce(split_part(ip,'.',2),'0')='' then '0'
     else coalesce(split_part(ip,'.',2),'0')
end)::integer as outs,

(
27*so/
(
3*split_part(ip,'.',1)::integer+
(
case when coalesce(split_part(ip,'.',2),'0')='' then '0'
     else coalesce(split_part(ip,'.',2),'0')
end)::integer
)*sqrt(sf.schedule_offensive*hd.exp_factor)

)::numeric(5,2) as adj_so9,

(
27*bb/
(
3*split_part(ip,'.',1)::integer+
(
case when coalesce(split_part(ip,'.',2),'0')='' then '0'
     else coalesce(split_part(ip,'.',2),'0')
end)::integer
)/sqrt(sf.schedule_offensive*hd.exp_factor)
)::numeric(5,2) as adj_bb9,


(3*
27*so/
(
3*split_part(ip,'.',1)::integer+
(
case when coalesce(split_part(ip,'.',2),'0')='' then '0'
     else coalesce(split_part(ip,'.',2),'0')
end)::integer
)*sqrt(sf.schedule_offensive*hd.exp_factor)

-

(
10*
27*bb/
(
3*split_part(ip,'.',1)::integer+
(
case when coalesce(split_part(ip,'.',2),'0')='' then '0'
     else coalesce(split_part(ip,'.',2),'0')
end)::integer
)/sqrt(sf.schedule_offensive*hd.exp_factor)
)
)::numeric(5,2) as index


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

from ncaa_pbp.player_summaries_pitching ps
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

and ip is not null
and not(ip='')

and
3*split_part(ip,'.',1)::integer+
(
case when coalesce(split_part(ip,'.',2),'0')='' then '0'
     else coalesce(split_part(ip,'.',2),'0')
end)::integer >= 100

--and ps.gs >= 10

and sf.year=2015
and sd.div_id in (1,2,3)

order by index desc

limit 200
)
to '/tmp/pitchers_2015.csv' csv header;

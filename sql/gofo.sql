
/*
select
p.player_name as name,
p.team_name as team,
p.class_year as cl,
p.ip,
p.so,
p.bb,
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
)*sqrt(sf.schedule_offensive)

)::numeric(4,2) as adj_so9,

(
27*bb/
(
3*split_part(ip,'.',1)::integer+
(
case when coalesce(split_part(ip,'.',2),'0')='' then '0'
     else coalesce(split_part(ip,'.',2),'0')
end)::integer
)/sqrt(sf.schedule_offensive)
)::numeric(4,2) as adj_bb9,


(3*
27*so/
(
3*split_part(ip,'.',1)::integer+
(
case when coalesce(split_part(ip,'.',2),'0')='' then '0'
     else coalesce(split_part(ip,'.',2),'0')
end)::integer
)*sqrt(sf.schedule_offensive)

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
)/sqrt(sf.schedule_offensive)
)
)::numeric(4,2) as index,
(go::float/fo::float)::numeric(4,3) as gofo
from ncaa_pbp.player_summaries_pitching p
join ncaa_pbp.teams t
  on (t.team_id,t.year)=(p.team_id,p.year)
where go is not null
and fo is not null
and go+fo>=100
and p.year=2015
and t.division_id=1
and p.class_year ilike 'sr'
order by go_fo desc
limit 100;
*/

copy (
select
p.player_name as name,
p.team_name as team,
p.class_year as cl,
p.ip,
p.so,
p.bb,
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

)::numeric(4,2) as adj_so9,

(
27*bb/
(
3*split_part(ip,'.',1)::integer+
(
case when coalesce(split_part(ip,'.',2),'0')='' then '0'
     else coalesce(split_part(ip,'.',2),'0')
end)::integer
)/sqrt(sf.schedule_offensive*hd.exp_factor)
)::numeric(4,2) as adj_bb9,


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
)::numeric(4,2) as index,
(go::float/fo::float)::numeric(4,3) as gofo
from ncaa_pbp.player_summaries_pitching p

join ncaa_pbp.teams t
  on (t.team_id,t.year)=(p.team_id,p.year)
  
join ncaa._schedule_factors sf
  on (sf.school_id,sf.year)=(p.team_id,p.year)
join ncaa.schools_divisions sd
  on (sd.school_id,sd.year)=(sf.school_id,sf.year)

join ncaa._factors hd
  on (hd.parameter,hd.level::integer)=('h_div',sd.div_id)
join ncaa._factors pd
  on (pd.parameter,pd.level::integer)=('p_div',sd.div_id)
  
where go is not null
and fo is not null
and go+fo>=100
and p.year=2015
and t.division_id=3
and p.class_year ilike 'sr'
order by gofo desc
limit 100)
to '/tmp/d3_gofo.csv' csv header;

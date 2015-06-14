library(MASS)
library(RdbiPgSQL)

conn <- dbConnect(PgSQL(), host="basetek-prod.sdpinternal.com", port="5432",
     dbname="boxscore", user="clong",password="psqlnik")

query <- dbSendQuery(conn, "
select
mlb_id as mlb_id,
(case when h.sport_code is null then 0
      when h.sport_code='rok' then 1
      when h.sport_code='asx' then 2
      when h.sport_code='afx' then 3
      when h.sport_code='afa' then 4
      when h.sport_code='aax' then 5
      when h.sport_code='aaa' then 6
      when h.sport_code='mlb' then 7 end) as class,
(('6/15/'||nh.year::text)::date-p.birth_date)::float/365.24 as age,
12.0*p.height_feet+p.height_inches as height,
p.weight as weight,
27.0*nh.rc/nh.outs as rcg,
nh.pa as pa,
nh.eye as eye,
nh.iso as power,
nh.avg as average,
nh.sx as speed,
nh.swing_speed as swing_speed,
nh.obp as obp,
nh.slg as slg,
nh.xb_so as xb_so,
nh.tb_so as tb_so,
nh.bb_rate as bb_rate,
nh.so_rate as so_rate,
(case when h.sport_code is null then 1
      when h.ab+h.bb+h.hbp <= 125 then 0
      else 1 end) as pf
from padres.player_master p
join padres.ncaa_yd_hit2 nh on (nh.mlb_id)=(p.bis_player_id)
join mlb.pp_master pm on (p.bis_player_id)=(pm.player_id)

--join padres.hit_ytd h on
-- (h.m,h.year,h.type)=(p.player_id,nh.year+3,0)

join padres.hit_ytd h on
 (h.m,h.type)=(p.player_id,0)
where

    (h.m=p.player_id or h.sport_code is null)

--and (h.ab>99 or h.team is null)
-- Previously used
----and nh.ab>99

and nh.pa>99
--and h.ab+h.bb+h.hbp >= 125

--and nh.year<=2003
--and nh.year=pm.r4year-1
--and nh.year=pm.r4year

and (('6/15/'||h.year::text)::date-p.birth_date)::float/365.24>=23.5
and (('6/15/'||h.year::text)::date-p.birth_date)::float/365.24<=24.5

and (not(h.team like 'All%') or h.sport_code is null)
and (h.sport_code is not null)

and ((h.sport_code in ('rok','asx','afx','afa','aax','aaa','mlb'))
     or h.sport_code is null);")

player_pairs <- dbGetResult(query)

player_pairs$class <- as.ordered(player_pairs$class)

dim(player_pairs)

player_model <- class ~ age*power + speed*age + bb_rate*so_rate + average + I(age^2)

player_prospects.plr <- polr(player_model,data=player_pairs,weights=pf,Hess=T)

player_prospects.plr
summary(player_prospects.plr)

##library(nnet)

##player_prospects.mnlr <- multinom(player_model,data=player_pairs,weights=pf)
##player_prospects.mnlr
##summary(player_prospects.mnlr)

#
#pchisq(deviance(player_prospects.plr)-deviance(player_prospects.mnlr),
#                36-11,lower.tail=F)

#predict(player_prospects.plr,type="probs")

#player_prospects.step <- stepAIC(player_prospects.plr,steps=100000000,
#                                 direction = c("both"),trace=T)
#summary(player_prospects.step)

dbDisconnect(conn)

copy
(
select
distinct
year,year_factor::numeric(4,3)
from ncaa._schedule_factors
order by year desc
)

to '/tmp/runs_year.csv' csv header;

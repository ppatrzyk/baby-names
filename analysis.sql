create table first_total as 
    select
        *,
        round(100 * count / sum(count) over (partition by gender, year), 4) as yearly_perc,
        rank() over (partition by gender, year order by count desc) as yearly_rank
    from read_parquet("./data/first_total.parquet")
    order by year asc, first_name asc;

create table middle_total as 
    select
        *,
        round(100 * count / sum(count) over (partition by gender, year), 4) AS yearly_perc,
        rank() over (partition by gender, year order by count desc) as yearly_rank
    from read_parquet("./data/middle_total.parquet");

create table first_voivodeship as 
    select
        *,
        round(100 * count / sum(count) over (partition by gender, year, voivodeship), 4) AS yearly_perc,
        rank() over (partition by gender, year, voivodeship order by count desc) as yearly_rank
    from read_parquet("./data/first_voivodeship.parquet");

-- global names stats
copy first_total to './static/names.parquet' (format parquet);

-- voivodeship level stats
copy (
    select 
        first_voivodeship.*,
        first_total.yearly_perc as total_yearly_perc,
        first_total.yearly_rank as total_yearly_rank,
        round(first_voivodeship.yearly_perc - total_yearly_perc, 4) as relative_prevalence,
        round(first_voivodeship.yearly_rank - total_yearly_rank, 4) as relative_rank
    from first_voivodeship
    left join first_total on 
        first_voivodeship.first_name = first_total.first_name and 
        first_voivodeship.gender = first_total.gender and 
        first_voivodeship.year = first_total.year
    order by first_voivodeship.year asc, first_voivodeship.first_name asc
)
to './static/voivodeships.parquet' (format parquet);

-- biggest changes in first name popularity
-- used as defaults in ts plot
create table changes as
    select
        first_name,
        count(*) as total_years,
        sum(count) as total_count,
        corr(year, count) as cor,
        regr_slope(year, count) as slope,
    from first_total
    group by first_name;

copy (
    select first_name
    from changes
    where (total_count/(select max(total_count) from changes) >= 0.005)
    order by cor asc
    limit 10
)
to './static/change_neg.parquet' (format parquet);

copy (
    select first_name
    from changes
    where (total_count/(select max(total_count) from changes) >= 0.005)
    order by cor desc
    limit 10
)
to './static/change_pos.parquet' (format parquet);

-- most variability across voivodeships
copy (
    select first_name
    from (
        select * 
        from first_voivodeship
        where year == 2023
    )
    group by first_name
    order by var_pop(yearly_perc) desc
    limit 10
)
to './static/voivodeshipsvar2023.parquet' (format parquet);

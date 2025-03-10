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

-- update names that work for both genders
create table ambiguous as 
    with male as (
        select distinct(first_name) as name
        from first_total
        where gender = 'male'
    ), female as (
        select distinct(first_name) as name
        from first_total
        where gender = 'female'
    )
    select male.name
    from male
    inner join female
    on male.name = female.name;

update first_total
set first_name = (
    case when ((select count(*) from ambiguous where name = first_name) > 0) 
    then concat(first_name, '[', substring(gender, 1, 1), ']')
    else first_name
    end
);

update first_voivodeship
set first_name = (
    case when ((select count(*) from ambiguous where name = first_name) > 0) 
    then concat(first_name, '[', substring(gender, 1, 1), ']')
    else first_name
    end
);

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
        arg_max(yearly_perc, year) - arg_min(yearly_perc, year) as change20202023
    from first_total
    group by first_name;

copy (
    select first_name
    from changes
    -- where min_max_diff > 0.5
    order by change20202023 asc
    limit 10
)
to './static/change_neg.parquet' (format parquet);

copy (
    select first_name
    from changes
    -- where min_max_diff > 0.5
    order by change20202023 desc
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
    limit 20
)
to './static/voivodeshipsvar2023.parquet' (format parquet);

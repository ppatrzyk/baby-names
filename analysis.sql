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

copy first_total to './static/names.parquet' (format parquet);
copy (
    select distinct(first_name) as first_name
    from first_total
    order by first_name asc
)
to './static/unique_names.parquet' (format parquet);

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

-- TODO combine with coefficient and 2000-2023 change? add mix/max
-- TODO limit 10 or change plot style?
-- biggest changes in first name popularity
-- used as defaults in ts plot
create table changes as
    select
        first_name,
        count(*) as total,
        corr(year, count) as cor,
    from first_total
    group by first_name
    having total >= 10;

copy (
    select first_name
    from changes
    order by cor asc
    limit 20
)
to './static/change_neg.parquet' (format parquet);

copy (
    select first_name
    from changes
    order by cor desc
    limit 20
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

-- past code for making all year/name combinations here: problem parquet file 
-- create table test as
--     select * from (
--         select distinct f1.first_name, f1.gender, f2.year
--         from first_total f1
--         cross join first_total f2
--     ) c
--     left join first_total
--     on c.first_name = first_total.first_name and c.gender = first_total.gender and c.year = first_total.year
--     order by c.year asc, c.first_name asc;

-- first vs second name popularity
-- select 
--     first_total.first_name as name,
--     first_total.gender,
--     first_total.year,
--     first_total.count as first_name_count,
--     middle_total.count as middle_name_count,
--     first_total.yearly_rank as first_name_rank,
--     middle_total.yearly_rank as middle_name_rank,
--     first_total.yearly_perc as first_name_perc,
--     middle_total.yearly_perc as middle_name_perc,
--     round(middle_name_perc - first_name_perc, 4) as perc_diff,
--     round(middle_name_rank - first_name_rank, 4) as rank_diff
-- from first_total
-- full outer join middle_total
-- on first_total.first_name = middle_total.middle_name and first_total.gender = middle_total.gender and first_total.year = middle_total.year
-- order by first_total.year desc, perc_diff desc;

-- old absolute 2000-2023 change code
-- copy (
--     with perc2000 as (
--         select
--             first_name,
--             gender,
--             yearly_rank as rank2000,
--             yearly_perc as perc2000
--         from first_total 
--         where year = 2000
--     ), perc2023 as (
--         select
--             first_name,
--             gender,
--             yearly_rank as rank2023,
--             yearly_perc as perc2023 
--         from first_total 
--         where year = 2023
--     )
--     select first_name from (
--         select 
--             perc2000.first_name,
--             perc2000.gender,
--             rank2000,
--             rank2023,
--             perc2000,
--             perc2023,
--             round(perc2023 - perc2000, 4) as perc_change,
--             round(rank2023 - rank2000, 4) as rank_change,
--             rank() over (order by perc_change desc) as rank_pos_change,
--             rank() over (order by perc_change asc) as rank_neg_change,
--         from perc2000
--         inner join perc2023
--         on perc2000.first_name = perc2023.first_name and perc2000.gender = perc2023.gender
--     )
--     where rank_pos_change <= 20 or rank_neg_change <= 20
-- )
-- to './static/change20202023.parquet' (format parquet);

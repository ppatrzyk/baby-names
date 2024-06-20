create table names as select * from read_csv("baby_names_pl/*/*.csv", filename=true, union_by_name=true);
update names set gender = regexp_replace(gender, '^M.*', 'male');
update names set gender = regexp_replace(gender, '^K.*', 'female');
update names set year = regexp_extract(filename, '\d\d\d\d') where year is null;
update names set first_name = concat(upper(substring(first_name, 1, 1)), lower(substring(first_name, 2)));
update names set middle_name = concat(upper(substring(middle_name, 1, 1)), lower(substring(middle_name, 2)));
update names set voivodeship = concat(upper(substring(voivodeship, 1, 1)), lower(substring(voivodeship, 2)));

create table names_dedup as
select * from names
qualify row_number() over (partition by middle_name, gender, first_name, voivodeship, year) = 1;

create table first_total as 
    select
        first_name,
        gender,
        year,
        count,
        round(100 * count / sum(count) over (partition by gender, year), 4) as yearly_perc,
        rank() over (partition by gender, year order by count desc) as yearly_rank
    from names_dedup 
    where voivodeship is NULL and first_name is not NULL;

create table middle_total as 
    select
        middle_name,
        gender,
        year,
        count,
        round(100 * count / sum(count) over (partition by gender, year), 4) AS yearly_perc,
        rank() over (partition by gender, year order by count desc) as yearly_rank
    from names_dedup
    where voivodeship is NULL and middle_name is not NULL;

create table first_voivodeship as 
    select
        first_name,
        gender,
        year,
        voivodeship,
        count,
        round(100 * count / sum(count) over (partition by gender, year, voivodeship), 4) AS yearly_perc,
        rank() over (partition by gender, year, voivodeship order by count desc) as yearly_rank
    from names_dedup
    where voivodeship is not NULL and first_name is not NULL;
    -- todo join with country level perc and rank

-- create table middle_voivodeship as select middle_name, gender, year, voivodeship, count, round(100 * count / sum(count) over (partition by year, voivodeship), 4) AS yearly_perc, rank() over (partition by year, voivodeship order by count desc) as yearly_rank from names_dedup where voivodeship is not NULL and middle_name is not NULL;

-- biggest changes in first name popularity
with perc2000 as (
    select
        first_name,
        gender,
        yearly_rank as rank2000,
        yearly_perc as perc2000
    from first_total 
    where year = 2000
), perc2023 as (
    select
        first_name,
        gender,
        yearly_rank as rank2023,
        yearly_perc as perc2023 
    from first_total 
    where year = 2023
)
select 
    perc2000.first_name,
    perc2000.gender,
    rank2000,
    rank2023,
    perc2000,
    perc2023,
    round(perc2023 - perc2000, 4) as perc_change
    round(rank2023 - rank2000, 4) as rank_change
from perc2000
inner join perc2023
on perc2000.first_name = perc2023.first_name and perc2000.gender = perc2023.gender
order by change desc;


-- first vs second name popularity
select 
    first_total.first_name as name,
    first_total.gender,
    first_total.year,
    first_total.yearly_rank as first_name_rank,
    middle_total.yearly_rank as middle_name_rank,
    first_total.yearly_perc as first_name_perc,
    middle_total.yearly_perc as middle_name_perc,
    round(middle_name_perc - first_name_perc, 4) as perc_diff,
    round(middle_name_rank - first_name_rank, 4) as rank_diff
from first_total
inner join middle_total
on first_total.first_name = middle_total.middle_name and first_total.gender = middle_total.gender and first_total.year = middle_total.year
order by perc_diff desc;

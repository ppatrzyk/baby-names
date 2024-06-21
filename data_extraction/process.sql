create table names as select * from read_csv("baby_names_pl/*/*.csv", filename=true, union_by_name=true);
update names set gender = regexp_replace(gender, '^M.*', 'male');
update names set gender = regexp_replace(gender, '^K.*', 'female');
update names set year = regexp_extract(filename, '\d\d\d\d') where year is null;
update names set first_name = concat(upper(substring(first_name, 1, 1)), lower(substring(first_name, 2))) where first_name is not NULL;
update names set middle_name = concat(upper(substring(middle_name, 1, 1)), lower(substring(middle_name, 2))) where middle_name is not NULL;
update names set voivodeship = concat(upper(substring(voivodeship, 1, 1)), lower(substring(voivodeship, 2))) where voivodeship is not NULL;

create table names_dedup as
select * from names
qualify row_number() over (partition by middle_name, gender, first_name, voivodeship, year) = 1;

create table first_total as 
    select
        first_name,
        gender,
        year,
        count
    from names_dedup 
    where voivodeship is NULL and first_name is not NULL;

create table middle_total as 
    select
        middle_name,
        gender,
        year,
        count
    from names_dedup
    where voivodeship is NULL and middle_name is not NULL;

create table first_voivodeship as 
    select
        first_name,
        gender,
        year,
        voivodeship,
        count
    from names_dedup
    where voivodeship is not NULL and first_name is not NULL;

create table middle_voivodeship as 
    select
        middle_name,
        gender,
        year,
        voivodeship,
        count
    from names_dedup
    where voivodeship is not NULL and middle_name is not NULL;

copy first_total to './../data/first_total.parquet' (format parquet);
copy middle_total to './../data/middle_total.parquet' (format parquet);
copy first_voivodeship to './../data/first_voivodeship.parquet' (format parquet);
copy middle_voivodeship to './../data/middle_voivodeship.parquet' (format parquet);

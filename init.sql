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


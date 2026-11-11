use fintech_lending;

-- Memasukkan data nasional
insert into national_monthly(
	Period,
    Source_File,
    Source_Sheet,
    Source_Publication_Period,
    active_borrower_accounts,
    outstanding,
    twp90
)
select
	str_to_date(concat(Period, '-01'), '%Y-%m-%d'),
    Source_File,
    Source_Sheet,
    Source_Publication_Period,
    cast(active_borrower_accounts as unsigned),
    cast(replace(outstanding, ',', '.') as decimal(20,9)),
    cast(replace(twp90, ',', '.') as decimal(18,17))
from stg_national;

show warnings;

-- Memasukkan data provinsi
insert into province_monthly (
	Region_Source,
    Province_Name,
    Period,
    Source_File,
    Source_Sheet,
    Source_Publication_Period,
    active_borrower_accounts,
    outstanding,
    twp90
)
select
	Region_Source,
    Province_Name,
    str_to_date(concat(Period, '-01'), '%Y-%m-%d'),
    Source_File,
    Source_Sheet,
    Source_Publication_Period,
    cast(active_borrower_accounts as unsigned),
    cast(replace(outstanding, ',', '.')as decimal(20,9)),
    cast(replace(twp90, ',', '.') as decimal(18,17))
from stg_province;

show warnings;

-- Memastikan jumlah baris dan rentang periode sesuai konversi
select
	'Nasional' as dataset,
    count(*) as jumlah_baris,
    min(Period) as periode_awal,
    max(Period) as periode_akhir
from national_monthly

union all

select
	'Provinsi' as dataset,
    count(*) as jumlah_baris,
    min(Period) as periode_awal,
    max(Period) as periode_akhir
from province_monthly;

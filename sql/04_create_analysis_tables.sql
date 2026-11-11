use fintech_lending;

-- Data Nasional: satu baris untuk setiap bulan
create table national_monthly (
	Period date not null,
    Source_File varchar(255) not null,
    Source_Sheet varchar(50) not null,
    Source_Publication_Period  char(7) not null,
    active_borrower_accounts bigint unsigned not null,
    outstanding decimal(20,9) not null,
    twp90 decimal(18,17) not null,
    
    primary key (Period),
    
    constraint chk_national_outstanding
		check (outstanding >= 0),
        
	constraint chk_national_twp90
		check (twp90 between 0 and 1),
        
	constraint chk_national_month_start
		check (dayofmonth(Period) = 1)
);

-- Data provinsi: satu baris untuk setiap pasangan provinsi-bulan
create table province_monthly (
	Region_Source varchar(255) not null,
    Province_Name varchar(255) not null,
    Period date not null,
    Source_File varchar(255) not null,
    Source_Sheet varchar(50) not null,
    Source_Publication_Period char(7) not null,
    active_borrower_accounts bigint unsigned not null,
    outstanding decimal(20,9) not null,
    twp90 decimal(18,17) not null,
    
    primary key (Province_Name, Period),
    
    constraint chk_province_outstanding
		check (outstanding >= 0),
        
	constraint chk_province_twp90
		check (twp90 between 0 and 1),
        
	constraint chk_province_month_start
		check (dayofmonth(Period) = 1)
    );
    
    describe national_monthly;
    describe province_monthly;
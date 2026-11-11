use fintech_lending;

-- Tabel penampung CSV nasional
create table stg_national (
    Period VARCHAR(50),
    Source_File VARCHAR(255),
    Source_Sheet VARCHAR(50),
    Source_Publication_Period VARCHAR(50),
    active_borrower_accounts VARCHAR(100),
    outstanding VARCHAR(100),
    twp90 VARCHAR(100)
);

-- Tabel penampung CSV provinsi
create table stg_province (
    Region_Source VARCHAR(255),
    Province_Name VARCHAR(255),
    Period VARCHAR(50),
    Source_File VARCHAR(255),
    Source_Sheet VARCHAR(50),
    Source_Publication_Period VARCHAR(50),
    active_borrower_accounts VARCHAR(100),
    outstanding VARCHAR(100),
    twp90 VARCHAR(100)
);

-- Memeriksa struktur kedua tabel
describe stg_national;
describe stg_province;
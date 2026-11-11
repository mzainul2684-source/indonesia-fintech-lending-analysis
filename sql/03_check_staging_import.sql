USE fintech_lending;

SELECT
    COUNT(*) AS jumlah_baris,
    MIN(Period) AS periode_awal,
    MAX(Period) AS periode_akhir
FROM stg_national;

SELECT
    Period,
    active_borrower_accounts,
    outstanding,
    twp90
FROM stg_national
WHERE Period IN ('2022-12', '2025-12')
ORDER BY Period;


-- Pemeriksaan awal hasil impor provinsi
SELECT
    COUNT(*) AS jumlah_baris,
    COUNT(DISTINCT Province_Name) AS jumlah_provinsi,
    COUNT(DISTINCT Period) AS jumlah_bulan,
    MIN(Period) AS periode_awal,
    MAX(Period) AS periode_akhir
FROM fintech_lending.stg_province;

-- Sampel untuk dibandingkan dengan CSV
SELECT
    Region_Source,
    Province_Name,
    Period,
    Source_File,
    active_borrower_accounts,
    outstanding,
    twp90
FROM fintech_lending.stg_province
WHERE Province_Name = 'Banten'
  AND Period = '2025-01';
  
use fintech_lending;
-- 1.Nasional: Setiap bulan harusnya 1 baris
select 
	Period,
    count(*) as jumlah_baris
from stg_national
group by Period
having count(*) > 1;

-- 2. Provinsi: setiap pasangan provinsi-bulan hanya satu baris
SELECT
    Province_Name,
    Period,
    COUNT(*) AS jumlah_baris
FROM stg_province
GROUP BY Province_Name, Period
HAVING COUNT(*) > 1;

-- 3. Setiap bulan harus memiliki 38 baris dan 38 provinsi
SELECT
    Period,
    COUNT(*) AS jumlah_baris,
    COUNT(DISTINCT Province_Name) AS jumlah_provinsi
FROM stg_province
GROUP BY Period
HAVING COUNT(*) <> 38
    OR COUNT(DISTINCT Province_Name) <> 38;
    
    
-- 4. Setiap provinsi harus memiliki 18 baris dan 18 bulan
SELECT
    Province_Name,
    COUNT(*) AS jumlah_baris,
    COUNT(DISTINCT Period) AS jumlah_bulan
FROM stg_province
GROUP BY Province_Name
HAVING COUNT(*) <> 18
    OR COUNT(DISTINCT Period) <> 18;
    
USE fintech_lending;

-- Baris nasional yang memiliki kolom kosong
SELECT *
FROM stg_national
WHERE NULLIF(TRIM(Period), '') IS NULL
   OR NULLIF(TRIM(Source_File), '') IS NULL
   OR NULLIF(TRIM(Source_Sheet), '') IS NULL
   OR NULLIF(TRIM(Source_Publication_Period), '') IS NULL
   OR NULLIF(TRIM(active_borrower_accounts), '') IS NULL
   OR NULLIF(TRIM(outstanding), '') IS NULL
   OR NULLIF(TRIM(twp90), '') IS NULL;

-- Baris provinsi yang memiliki kolom kosong
SELECT *
FROM stg_province
WHERE NULLIF(TRIM(Region_Source), '') IS NULL
   OR NULLIF(TRIM(Province_Name), '') IS NULL
   OR NULLIF(TRIM(Period), '') IS NULL
   OR NULLIF(TRIM(Source_File), '') IS NULL
   OR NULLIF(TRIM(Source_Sheet), '') IS NULL
   OR NULLIF(TRIM(Source_Publication_Period), '') IS NULL
   OR NULLIF(TRIM(active_borrower_accounts), '') IS NULL
   OR NULLIF(TRIM(outstanding), '') IS NULL
   OR NULLIF(TRIM(twp90), '') IS NULL;



USE fintech_lending;

-- Memeriksa format periode dan angka pada kedua tabel
WITH data_gabungan AS (
    SELECT
        'Nasional' AS dataset,
        'Indonesia' AS wilayah,
        Period,
        Source_Publication_Period,
        active_borrower_accounts,
        outstanding,
        twp90
    FROM stg_national

    UNION ALL

    SELECT
        'Provinsi' AS dataset,
        Province_Name AS wilayah,
        Period,
        Source_Publication_Period,
        active_borrower_accounts,
        outstanding,
        twp90
    FROM stg_province
),
hasil_pemeriksaan AS (
    SELECT
        *,
        CASE
            WHEN REGEXP_LIKE(
                Period,
                '^[0-9]{4}-(0[1-9]|1[0-2])$'
            ) THEN 'Sesuai'
            ELSE 'Periksa'
        END AS cek_periode,

        CASE
            WHEN REGEXP_LIKE(
                Source_Publication_Period,
                '^[0-9]{4}-(0[1-9]|1[0-2])$'
            ) THEN 'Sesuai'
            ELSE 'Periksa'
        END AS cek_periode_publikasi,

        CASE
            WHEN REGEXP_LIKE(
                active_borrower_accounts,
                '^[0-9]+$'
            ) THEN 'Sesuai'
            ELSE 'Periksa'
        END AS cek_rekening,

        CASE
            WHEN REGEXP_LIKE(
                outstanding,
                '^[0-9]+(,[0-9]+)?$'
            ) THEN 'Sesuai'
            ELSE 'Periksa'
        END AS cek_outstanding,

        CASE
            WHEN REGEXP_LIKE(
                twp90,
                '^[0-9]+(,[0-9]+)?$'
            ) THEN 'Sesuai'
            ELSE 'Periksa'
        END AS cek_twp90
    FROM data_gabungan
)
SELECT *
FROM hasil_pemeriksaan
WHERE cek_periode = 'Periksa'
   OR cek_periode_publikasi = 'Periksa'
   OR cek_rekening = 'Periksa'
   OR cek_outstanding = 'Periksa'
   OR cek_twp90 = 'Periksa';
   
   
   
USE fintech_lending;

-- Mengukur kebutuhan digit untuk menentukan tipe numerik
WITH data_gabungan AS (
    SELECT
        'Nasional' AS dataset,
        active_borrower_accounts,
        outstanding,
        twp90
    FROM stg_national

    UNION ALL

    SELECT
        'Provinsi' AS dataset,
        active_borrower_accounts,
        outstanding,
        twp90
    FROM stg_province
)
SELECT
    dataset,
    MAX(CHAR_LENGTH(active_borrower_accounts))
        AS digit_rekening,

    MAX(CHAR_LENGTH(SUBSTRING_INDEX(outstanding, ',', 1)))
        AS digit_bulat_outstanding,

    MAX(
        CASE WHEN LOCATE(',', outstanding) > 0
             THEN CHAR_LENGTH(SUBSTRING_INDEX(outstanding, ',', -1))
             ELSE 0
        END
    ) AS digit_desimal_outstanding,

    MAX(CHAR_LENGTH(SUBSTRING_INDEX(twp90, ',', 1)))
        AS digit_bulat_twp90,

    MAX(
        CASE WHEN LOCATE(',', twp90) > 0
             THEN CHAR_LENGTH(SUBSTRING_INDEX(twp90, ',', -1))
             ELSE 0
        END
    ) AS digit_desimal_twp90
FROM data_gabungan
GROUP BY dataset;

-- Memeriksa TWP90 di luar rentang rasio 0 sampai 1
WITH data_gabungan AS (
    SELECT
        'Nasional' AS dataset,
        'Indonesia' AS wilayah,
        Period,
        twp90
    FROM stg_national

    UNION ALL

    SELECT
        'Provinsi' AS dataset,
        Province_Name AS wilayah,
        Period,
        twp90
    FROM stg_province
)
SELECT *
FROM data_gabungan
WHERE NOT REGEXP_LIKE(twp90, '^(0(,[0-9]+)?|1(,0+)?)$');
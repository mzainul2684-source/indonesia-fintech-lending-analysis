USE fintech_lending;

-- Nasional: tampilkan baris yang hilang atau berbeda
SELECT
    s.Period AS periode_staging,
    a.Period AS periode_analisis,
    s.active_borrower_accounts AS rekening_staging,
    a.active_borrower_accounts AS rekening_analisis,
    s.outstanding AS outstanding_staging,
    a.outstanding AS outstanding_analisis,
    s.twp90 AS twp90_staging,
    a.twp90 AS twp90_analisis
FROM stg_national AS s
LEFT JOIN national_monthly AS a
    ON a.Period = STR_TO_DATE(
        CONCAT(s.Period, '-01'), '%Y-%m-%d'
    )
WHERE a.Period IS NULL
   OR a.active_borrower_accounts <>
      CAST(s.active_borrower_accounts AS UNSIGNED)
   OR a.outstanding <>
      CAST(REPLACE(s.outstanding, ',', '.') AS DECIMAL(20,9))
   OR a.twp90 <>
      CAST(REPLACE(s.twp90, ',', '.') AS DECIMAL(18,17))
   OR BINARY a.Source_File <> BINARY s.Source_File
   OR BINARY a.Source_Sheet <> BINARY s.Source_Sheet
   OR BINARY a.Source_Publication_Period <>
      BINARY s.Source_Publication_Period;

-- Provinsi: tampilkan baris yang hilang atau berbeda
SELECT
    s.Province_Name,
    s.Period AS periode_staging,
    a.Period AS periode_analisis,
    s.active_borrower_accounts AS rekening_staging,
    a.active_borrower_accounts AS rekening_analisis,
    s.outstanding AS outstanding_staging,
    a.outstanding AS outstanding_analisis,
    s.twp90 AS twp90_staging,
    a.twp90 AS twp90_analisis
FROM stg_province AS s
LEFT JOIN province_monthly AS a
    ON BINARY a.Province_Name = BINARY s.Province_Name
   AND a.Period = STR_TO_DATE(
       CONCAT(s.Period, '-01'), '%Y-%m-%d'
   )
WHERE a.Period IS NULL
   OR a.active_borrower_accounts <>
      CAST(s.active_borrower_accounts AS UNSIGNED)
   OR a.outstanding <>
      CAST(REPLACE(s.outstanding, ',', '.') AS DECIMAL(20,9))
   OR a.twp90 <>
      CAST(REPLACE(s.twp90, ',', '.') AS DECIMAL(18,17))
   OR BINARY a.Region_Source <> BINARY s.Region_Source
   OR BINARY a.Source_File <> BINARY s.Source_File
   OR BINARY a.Source_Sheet <> BINARY s.Source_Sheet
   OR BINARY a.Source_Publication_Period <>
      BINARY s.Source_Publication_Period;
      

-- Rekonsiliasi outstanding provinsi terhadap nasional
WITH total_provinsi AS (
    SELECT
        Period,
        COUNT(*) AS jumlah_provinsi,
        SUM(outstanding) AS outstanding_provinsi
    FROM province_monthly
    GROUP BY Period
),
rekonsiliasi AS (
    SELECT
        p.Period,
        p.jumlah_provinsi,
        p.outstanding_provinsi,
        n.outstanding AS outstanding_nasional,
        p.outstanding_provinsi - n.outstanding AS selisih
    FROM total_provinsi AS p
    LEFT JOIN national_monthly AS n
        ON p.Period = n.Period
)
SELECT
    *,
    CASE
        WHEN outstanding_nasional IS NULL
            THEN 'Nasional tidak ditemukan'
        WHEN jumlah_provinsi <> 38
            THEN 'Jumlah provinsi tidak sesuai'
        WHEN ABS(selisih) <= 0.000001
            THEN 'Sesuai dalam toleransi'
        ELSE 'Periksa selisih'
    END AS status_rekonsiliasi
FROM rekonsiliasi
WHERE outstanding_nasional IS NULL
   OR jumlah_provinsi <> 38
   OR ABS(selisih) > 0.000001
ORDER BY Period;


-- Nilai staging untuk verifikasi sumber DKI Jakarta
SELECT
    Province_Name,
    Period,
    outstanding,
    twp90,
    Source_File,
    Source_Sheet,
    Source_Publication_Period
FROM stg_province
WHERE Province_Name = 'DKI Jakarta'
  AND Period IN ('2025-10', '2025-11', '2025-12')
ORDER BY Period;
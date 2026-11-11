USE fintech_lending;

CREATE OR REPLACE VIEW v_national_monthly AS
WITH pembanding AS (
    SELECT
        Period,
        outstanding,
        twp90,
        active_borrower_accounts,
        Source_File,
        Source_Sheet,
        Source_Publication_Period,

        LAG(outstanding) OVER (
            ORDER BY Period
        ) AS outstanding_previous_month,

        LAG(outstanding, 12) OVER (
            ORDER BY Period
        ) AS outstanding_previous_year,

        LAG(twp90) OVER (
            ORDER BY Period
        ) AS twp90_previous_month

    FROM national_monthly
)
SELECT
    Period,
    outstanding,
    twp90,
    active_borrower_accounts,

    outstanding_previous_month,
    outstanding_previous_year,

    outstanding - outstanding_previous_month
        AS outstanding_change_mom,

    outstanding / NULLIF(outstanding_previous_month, 0) - 1
        AS outstanding_growth_mom,

    outstanding / NULLIF(outstanding_previous_year, 0) - 1
        AS outstanding_growth_yoy,

    (twp90 - twp90_previous_month) * 100
        AS twp90_change_mom_pp,

    outstanding * 1000000000
        / NULLIF(active_borrower_accounts, 0)
        AS outstanding_per_account_idr,

    Source_File,
    Source_Sheet,
    Source_Publication_Period

FROM pembanding;


-- Memeriksa cakupan dan ketersediaan pembanding
SELECT
    COUNT(*) AS jumlah_baris,
    MIN(Period) AS periode_awal,
    MAX(Period) AS periode_akhir,
    COUNT(outstanding_growth_mom) AS bulan_dengan_mom,
    COUNT(outstanding_growth_yoy) AS bulan_dengan_yoy
FROM v_national_monthly;

-- Memeriksa angka Desember 2025
SELECT
    Period,
    ROUND(outstanding, 3) AS outstanding_miliar,
    ROUND(outstanding_growth_mom * 100, 2) AS mom_persen,
    ROUND(outstanding_growth_yoy * 100, 2) AS yoy_persen,
    ROUND(twp90 * 100, 4) AS twp90_persen,
    active_borrower_accounts
FROM v_national_monthly
WHERE Period = '2025-12-01';


SELECT
    COUNT(*) AS jumlah_baris,
    MIN(Period) AS periode_awal,
    MAX(Period) AS periode_akhir,
    COUNT(outstanding_growth_mom) AS bulan_dengan_mom,
    COUNT(outstanding_growth_yoy) AS bulan_dengan_yoy
FROM fintech_lending.v_national_monthly;



USE fintech_lending;

CREATE OR REPLACE VIEW v_province_monthly AS
WITH pembanding AS (
    SELECT
        p.*,

        LAG(outstanding) OVER (
            PARTITION BY Province_Name
            ORDER BY Period
        ) AS outstanding_previous_month,

        LAG(outstanding, 12) OVER (
            PARTITION BY Province_Name
            ORDER BY Period
        ) AS outstanding_previous_year,

        LAG(twp90) OVER (
            PARTITION BY Province_Name
            ORDER BY Period
        ) AS twp90_previous_month

    FROM province_monthly AS p
)
SELECT
    p.Period,
    p.Region_Source,
    p.Province_Name,
    p.outstanding,
    p.twp90,
    p.active_borrower_accounts,

    p.outstanding_previous_month,
    p.outstanding_previous_year,

    p.outstanding - p.outstanding_previous_month
        AS outstanding_change_mom,

    p.outstanding / NULLIF(p.outstanding_previous_month, 0) - 1
        AS outstanding_growth_mom,

    p.outstanding / NULLIF(p.outstanding_previous_year, 0) - 1
        AS outstanding_growth_yoy,

    (p.twp90 - p.twp90_previous_month) * 100
        AS twp90_change_mom_pp,

    p.outstanding / NULLIF(n.outstanding, 0)
        AS outstanding_share_national,

    n.twp90 AS national_twp90,

    (p.twp90 - n.twp90) * 100
        AS twp90_gap_national_pp,

    p.Source_File,
    p.Source_Sheet,
    p.Source_Publication_Period

FROM pembanding AS p
INNER JOIN national_monthly AS n
    ON p.Period = n.Period;
    
    

-- Memeriksa cakupan view provinsi
SELECT
    COUNT(*) AS jumlah_baris,
    COUNT(DISTINCT Province_Name) AS jumlah_provinsi,
    MIN(Period) AS periode_awal,
    MAX(Period) AS periode_akhir,
    COUNT(outstanding_growth_mom) AS baris_dengan_mom,
    COUNT(outstanding_growth_yoy) AS baris_dengan_yoy
FROM v_province_monthly;

-- Memeriksa sampel DKI Jakarta Desember 2025
SELECT
    Province_Name,
    Period,
    ROUND(outstanding, 3) AS outstanding_miliar,
    ROUND(outstanding_growth_yoy * 100, 2) AS yoy_persen,
    ROUND(outstanding_share_national * 100, 2)
        AS kontribusi_persen,
    ROUND(twp90 * 100, 4) AS twp90_persen,
    ROUND(twp90_gap_national_pp, 4)
        AS selisih_twp90_poin_persentase
FROM v_province_monthly
WHERE Province_Name = 'DKI Jakarta'
  AND Period = '2025-12-01';
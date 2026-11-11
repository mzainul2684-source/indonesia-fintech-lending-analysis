USE fintech_lending;

-- Pertumbuhan outstanding nasional bulanan
WITH pembanding_bulanan AS (
    SELECT
        Period,
        outstanding,
        LAG(outstanding) OVER (
            ORDER BY Period
        ) AS outstanding_bulan_sebelumnya
    FROM national_monthly
),
pertumbuhan AS (
    SELECT
        Period,
        outstanding,
        outstanding_bulan_sebelumnya,

        outstanding - outstanding_bulan_sebelumnya
            AS perubahan_outstanding,

        (
            (outstanding - outstanding_bulan_sebelumnya)
            / NULLIF(outstanding_bulan_sebelumnya, 0)
        ) * 100 AS pertumbuhan_mom_persen

    FROM pembanding_bulanan
)
SELECT
    Period,
    outstanding,
    outstanding_bulan_sebelumnya,
    ROUND(perubahan_outstanding, 3)
        AS perubahan_outstanding_miliar,
    ROUND(pertumbuhan_mom_persen, 2)
        AS pertumbuhan_mom_persen,
    CASE
        WHEN outstanding_bulan_sebelumnya IS NULL
            THEN 'Pembanding tidak tersedia'
        WHEN outstanding_bulan_sebelumnya = 0
            THEN 'Persentase tidak dapat dihitung'
        WHEN perubahan_outstanding > 0 THEN 'Naik'
        WHEN perubahan_outstanding < 0 THEN 'Turun'
        ELSE 'Tetap'
    END AS arah_perubahan
FROM pertumbuhan
WHERE Period BETWEEN '2023-01-01' AND '2025-12-01'
ORDER BY Period;


-- Lima pertumbuhan MoM tertinggi dan terendah
WITH pembanding_bulanan AS (
    SELECT
        Period,
        outstanding,
        LAG(outstanding) OVER (
            ORDER BY Period
        ) AS outstanding_bulan_sebelumnya
    FROM national_monthly
),
pertumbuhan AS (
    SELECT
        Period,
        outstanding,
        outstanding - outstanding_bulan_sebelumnya
            AS perubahan_outstanding,

        (
            (outstanding - outstanding_bulan_sebelumnya)
            / NULLIF(outstanding_bulan_sebelumnya, 0)
        ) * 100 AS pertumbuhan_mom_persen

    FROM pembanding_bulanan
    WHERE Period BETWEEN '2023-01-01' AND '2025-12-01'
),
peringkat AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            ORDER BY pertumbuhan_mom_persen DESC, Period
        ) AS peringkat_tertinggi,

        ROW_NUMBER() OVER (
            ORDER BY pertumbuhan_mom_persen ASC, Period
        ) AS peringkat_terendah

    FROM pertumbuhan
    WHERE pertumbuhan_mom_persen IS NOT NULL
),
pilihan AS (
    SELECT
        'Pertumbuhan tertinggi' AS kategori,
        peringkat_tertinggi AS peringkat,
        Period,
        outstanding,
        perubahan_outstanding,
        pertumbuhan_mom_persen
    FROM peringkat
    WHERE peringkat_tertinggi <= 5

    UNION ALL

    SELECT
        'Pertumbuhan terendah' AS kategori,
        peringkat_terendah AS peringkat,
        Period,
        outstanding,
        perubahan_outstanding,
        pertumbuhan_mom_persen
    FROM peringkat
    WHERE peringkat_terendah <= 5
)
SELECT
    kategori,
    peringkat,
    Period,
    ROUND(outstanding, 3) AS outstanding_miliar,
    ROUND(perubahan_outstanding, 3)
        AS perubahan_outstanding_miliar,
    ROUND(pertumbuhan_mom_persen, 2)
        AS pertumbuhan_mom_persen
FROM pilihan
ORDER BY
    CASE WHEN kategori = 'Pertumbuhan tertinggi'
         THEN 1 ELSE 2 END,
    peringkat;
    
    
    
    
-- Pertumbuhan outstanding akhir tahun dibandingkan akhir tahun sebelumnya
WITH pembanding_tahunan AS (
    SELECT
        Period,
        outstanding,

        LAG(outstanding, 12) OVER (
            ORDER BY Period
        ) AS outstanding_tahun_sebelumnya

    FROM national_monthly
)
SELECT
    YEAR(Period) AS tahun,

    ROUND(outstanding_tahun_sebelumnya, 3)
        AS outstanding_desember_sebelumnya_miliar,

    ROUND(outstanding, 3)
        AS outstanding_desember_miliar,

    ROUND(
        outstanding - outstanding_tahun_sebelumnya,
        3
    ) AS perubahan_outstanding_miliar,

    ROUND(
        (
            (outstanding - outstanding_tahun_sebelumnya)
            / NULLIF(outstanding_tahun_sebelumnya, 0)
        ) * 100,
        2
    ) AS pertumbuhan_yoy_persen

FROM pembanding_tahunan
WHERE MONTH(Period) = 12
  AND YEAR(Period) BETWEEN 2023 AND 2025
ORDER BY Period;



-- Perkembangan rekening aktif dan rata-rata outstanding per rekening
WITH indikator AS (
    SELECT
        Period,
        outstanding,
        active_borrower_accounts,

        outstanding * 1000000000
            / NULLIF(active_borrower_accounts, 0)
            AS outstanding_per_rekening_rupiah

    FROM national_monthly
),
pembanding AS (
    SELECT
        *,

        LAG(active_borrower_accounts, 12) OVER (
            ORDER BY Period
        ) AS rekening_tahun_sebelumnya,

        LAG(outstanding_per_rekening_rupiah, 12) OVER (
            ORDER BY Period
        ) AS saldo_per_rekening_tahun_sebelumnya

    FROM indikator
)
SELECT
    YEAR(Period) AS tahun,

    active_borrower_accounts,

    ROUND(
        (
            (
                CAST(active_borrower_accounts AS DECIMAL(20,0))
                - CAST(rekening_tahun_sebelumnya AS DECIMAL(20,0))
            )
            / NULLIF(rekening_tahun_sebelumnya, 0)
        ) * 100,
        2
    ) AS pertumbuhan_rekening_yoy_persen,

    ROUND(outstanding_per_rekening_rupiah, 0)
        AS outstanding_per_rekening_rupiah,

    ROUND(
        (
            (
                outstanding_per_rekening_rupiah
                - saldo_per_rekening_tahun_sebelumnya
            )
            / NULLIF(saldo_per_rekening_tahun_sebelumnya, 0)
        ) * 100,
        2
    ) AS pertumbuhan_saldo_per_rekening_yoy_persen

FROM pembanding
WHERE MONTH(Period) = 12
  AND YEAR(Period) BETWEEN 2023 AND 2025
ORDER BY Period;
USE fintech_lending;

-- Membandingkan outstanding dan TWP90 pada akhir tahun
WITH pembanding_tahunan AS (
    SELECT
        Period,
        outstanding,
        twp90,

        LAG(outstanding, 12) OVER (
            ORDER BY Period
        ) AS outstanding_tahun_sebelumnya,

        LAG(twp90, 12) OVER (
            ORDER BY Period
        ) AS twp90_tahun_sebelumnya

    FROM national_monthly
)
SELECT
    YEAR(Period) AS tahun,

    ROUND(outstanding, 3)
        AS outstanding_miliar,

    ROUND(
        (
            (outstanding - outstanding_tahun_sebelumnya)
            / NULLIF(outstanding_tahun_sebelumnya, 0)
        ) * 100,
        2
    ) AS pertumbuhan_outstanding_yoy_persen,

    ROUND(twp90_tahun_sebelumnya * 100, 4)
        AS twp90_desember_sebelumnya_persen,

    ROUND(twp90 * 100, 4)
        AS twp90_desember_persen,

    ROUND(
        (twp90 - twp90_tahun_sebelumnya) * 100,
        4
    ) AS perubahan_twp90_poin_persentase

FROM pembanding_tahunan
WHERE MONTH(Period) = 12
  AND YEAR(Period) BETWEEN 2023 AND 2025
ORDER BY Period;



-- Pergerakan TWP90 nasional setiap bulan
WITH pembanding_bulanan AS (
    SELECT
        Period,
        outstanding,
        twp90,

        LAG(twp90) OVER (
            ORDER BY Period
        ) AS twp90_bulan_sebelumnya

    FROM national_monthly
)
SELECT
    Period,

    ROUND(outstanding, 3)
        AS outstanding_miliar,

    ROUND(twp90 * 100, 4)
        AS twp90_persen,

    ROUND(twp90_bulan_sebelumnya * 100, 4)
        AS twp90_bulan_sebelumnya_persen,

    ROUND(
        (twp90 - twp90_bulan_sebelumnya) * 100,
        4
    ) AS perubahan_twp90_poin_persentase

FROM pembanding_bulanan
WHERE Period BETWEEN '2023-01-01' AND '2025-12-01'
ORDER BY
    (twp90 - twp90_bulan_sebelumnya) DESC,
    Period
LIMIT 5;
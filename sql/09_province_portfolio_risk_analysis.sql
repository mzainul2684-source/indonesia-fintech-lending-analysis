USE fintech_lending;

-- Kontribusi outstanding dan TWP90 provinsi, Desember 2025
SELECT
    ROW_NUMBER() OVER (
        ORDER BY p.outstanding DESC, p.Province_Name
    ) AS peringkat_outstanding,

    p.Province_Name,

    ROUND(p.outstanding, 3)
        AS outstanding_miliar,

    ROUND(
        p.outstanding / NULLIF(n.outstanding, 0) * 100,
        2
    ) AS kontribusi_outstanding_persen,

    p.active_borrower_accounts,

    ROUND(p.twp90 * 100, 4)
        AS twp90_provinsi_persen,

    ROUND(n.twp90 * 100, 4)
        AS twp90_nasional_persen,

    ROUND(
        (p.twp90 - n.twp90) * 100,
        4
    ) AS selisih_twp90_poin_persentase,

    CASE
        WHEN p.twp90 > n.twp90 THEN 'Di atas nasional'
        WHEN p.twp90 < n.twp90 THEN 'Di bawah nasional'
        ELSE 'Sama dengan nasional'
    END AS posisi_twp90

FROM province_monthly AS p
INNER JOIN national_monthly AS n
    ON p.Period = n.Period
WHERE p.Period = '2025-12-01'
ORDER BY p.outstanding DESC, p.Province_Name;




-- Perubahan TWP90 provinsi sekitar lonjakan nasional November 2025
WITH perbandingan AS (
    SELECT
        Province_Name,

        MAX(
            CASE WHEN Period = '2025-10-01'
                 THEN twp90 END
        ) AS twp90_oktober,

        MAX(
            CASE WHEN Period = '2025-11-01'
                 THEN twp90 END
        ) AS twp90_november,

        MAX(
            CASE WHEN Period = '2025-12-01'
                 THEN twp90 END
        ) AS twp90_desember,

        MAX(
            CASE WHEN Period = '2025-11-01'
                 THEN outstanding END
        ) AS outstanding_november

    FROM province_monthly
    WHERE Period BETWEEN '2025-10-01' AND '2025-12-01'
    GROUP BY Province_Name
)
SELECT
    Province_Name,

    ROUND(twp90_oktober * 100, 4)
        AS twp90_oktober_persen,

    ROUND(twp90_november * 100, 4)
        AS twp90_november_persen,

    ROUND(
        (twp90_november - twp90_oktober) * 100,
        4
    ) AS kenaikan_november_poin_persentase,

    ROUND(twp90_desember * 100, 4)
        AS twp90_desember_persen,

    ROUND(outstanding_november, 3)
        AS outstanding_november_miliar

FROM perbandingan
ORDER BY
    (twp90_november - twp90_oktober) DESC,
    Province_Name;
    
    
    
    
-- Pertumbuhan outstanding dan perubahan TWP90 provinsi secara tahunan
SELECT
    sekarang.Province_Name,

    ROUND(sebelumnya.outstanding, 3)
        AS outstanding_des2024_miliar,

    ROUND(sekarang.outstanding, 3)
        AS outstanding_des2025_miliar,

    ROUND(
        sekarang.outstanding - sebelumnya.outstanding,
        3
    ) AS perubahan_outstanding_miliar,

    ROUND(
        (
            (sekarang.outstanding - sebelumnya.outstanding)
            / NULLIF(sebelumnya.outstanding, 0)
        ) * 100,
        2
    ) AS pertumbuhan_outstanding_yoy_persen,

    ROUND(sebelumnya.twp90 * 100, 4)
        AS twp90_des2024_persen,

    ROUND(sekarang.twp90 * 100, 4)
        AS twp90_des2025_persen,

    ROUND(
        (sekarang.twp90 - sebelumnya.twp90) * 100,
        4
    ) AS perubahan_twp90_poin_persentase

FROM province_monthly AS sekarang
LEFT JOIN province_monthly AS sebelumnya
    ON sekarang.Province_Name = sebelumnya.Province_Name
   AND sebelumnya.Period = '2024-12-01'

WHERE sekarang.Period = '2025-12-01'

ORDER BY
    (sekarang.outstanding - sebelumnya.outstanding) DESC,
    sekarang.Province_Name;
    
    
    
-- Konsentrasi outstanding pada lima provinsi terbesar
WITH peringkat_provinsi AS (
    SELECT
        Period,
        Province_Name,
        outstanding,

        ROW_NUMBER() OVER (
            PARTITION BY Period
            ORDER BY outstanding DESC, Province_Name
        ) AS peringkat

    FROM province_monthly
),
total_lima_terbesar AS (
    SELECT
        Period,
        SUM(outstanding) AS outstanding_top5
    FROM peringkat_provinsi
    WHERE peringkat <= 5
    GROUP BY Period
)
SELECT
    t.Period,

    ROUND(t.outstanding_top5, 3)
        AS outstanding_top5_miliar,

    ROUND(n.outstanding, 3)
        AS outstanding_nasional_miliar,

    ROUND(
        t.outstanding_top5
        / NULLIF(n.outstanding, 0) * 100,
        2
    ) AS kontribusi_top5_persen

FROM total_lima_terbesar AS t
INNER JOIN national_monthly AS n
    ON t.Period = n.Period

WHERE t.Period IN (
    '2024-07-01',
    '2024-12-01',
    '2025-12-01'
)
ORDER BY t.Period;
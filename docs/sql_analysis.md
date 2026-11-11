# Dokumentasi Analisis SQL

## Indonesia Fintech Lending Analysis

### 1. Gambaran Umum

Dokumen ini menjelaskan proses pengolahan lanjutan, validasi, dan analisis data fintech lending Indonesia menggunakan MySQL.

Data yang digunakan merupakan hasil proses ETL menggunakan Microsoft Excel Power Query. Dataset tersebut bersumber dari Statistik Layanan Pendanaan Bersama Berbasis Teknologi Informasi (LPBBTI) yang dipublikasikan oleh Otoritas Jasa Keuangan (OJK).

Analisis SQL bertujuan untuk:

1. Menyimpan data nasional dan provinsi dalam database relasional.
2. Memeriksa kelengkapan dan konsistensi data.
3. Menyesuaikan tipe data untuk kebutuhan analisis.
4. Menghitung pertumbuhan outstanding pinjaman.
5. Menganalisis perkembangan risiko kredit melalui TWP90.
6. Membandingkan kondisi fintech lending antarprovinsi.
7. Menyediakan reporting views untuk kebutuhan visualisasi.

### 2. Teknologi yang Digunakan

- Database Management System: MySQL
- SQL Editor: MySQL Workbench
- Sumber data: CSV hasil pengolahan Excel Power Query
- Visualisasi lanjutan: Microsoft Power BI

Database yang digunakan bernama:

`fintech_lending`

### 3. Dataset yang Digunakan

Dua file CSV menjadi sumber utama analisis SQL.

| Dataset | Nama File | Jumlah Baris | Cakupan |
|---|---|---:|---|
| Nasional | `fintech_lending_national.csv` | 37 | Desember 2022 sampai Desember 2025 |
| Provinsi | `fintech_lending_province.csv` | 684 | Juli 2024 sampai Desember 2025 |

Kedua file tersimpan dalam folder `data/processed/`.

Dataset nasional memiliki satu observasi untuk setiap bulan.

Dataset provinsi memiliki satu observasi untuk setiap kombinasi provinsi dan bulan.

### 4. Struktur File SQL

Proyek menggunakan 10 script SQL yang disimpan dalam folder `sql/`.

| No. | Nama File | Fungsi |
|---|---|---|
| 01 | `01_setup_database.sql` | Membuat database dan memeriksa versi MySQL |
| 02 | `02_create_staging_tables.sql` | Membuat tabel penampung untuk impor CSV |
| 03 | `03_check_staging_import.sql` | Memeriksa hasil impor dan konsistensi data staging |
| 04 | `04_create_analysis_tables.sql` | Membuat tabel analisis dengan tipe data dan batasan yang sesuai |
| 05 | `05_load_analysis_tables.sql` | Memindahkan dan mengonversi data dari staging ke tabel analisis |
| 06 | `06_validate_analysis_tables.sql` | Memvalidasi hasil pengolahan pada tabel analisis |
| 07 | `07_national_growth_analysis.sql` | Menganalisis pertumbuhan outstanding nasional |
| 08 | `08_national_credit_risk_analysis.sql` | Menganalisis perkembangan TWP90 nasional |
| 09 | `09_province_portfolio_risk_analysis.sql` | Menganalisis outstanding dan risiko kredit antarprovinsi |
| 10 | `10_create_reporting_views.sql` | Membuat views untuk kebutuhan pelaporan dan dashboard |

### 5. Pembuatan Database

Script `01_setup_database.sql` digunakan untuk membuat database bernama `fintech_lending`.

Database dibuat menggunakan character set `utf8mb4` agar dapat menyimpan data teks dengan baik.

Script ini juga melakukan pemeriksaan versi MySQL dan database yang sedang aktif.

### 6. Pembuatan Staging Tables

Script `02_create_staging_tables.sql` membuat dua tabel penampung:

- `stg_national`
- `stg_province`

Staging tables digunakan sebagai tempat penyimpanan sementara data hasil impor CSV.

Pada tahap ini, sebagian besar kolom disimpan sebagai `VARCHAR`.

Pendekatan ini digunakan karena file CSV memiliki format tertentu, termasuk penggunaan koma sebagai pemisah desimal.

Konversi tipe data dilakukan setelah data berhasil diimpor dan diperiksa.

### 7. Proses Impor CSV

Impor dilakukan secara manual menggunakan fitur **Table Data Import Wizard** pada MySQL Workbench.

File yang diimpor:

1. `fintech_lending_national.csv` ke tabel `stg_national`.
2. `fintech_lending_province.csv` ke tabel `stg_province`.

File CSV menggunakan titik koma sebagai pemisah kolom dan koma sebagai pemisah desimal.

Oleh karena itu, pengaturan pemisah saat impor perlu disesuaikan dengan format file sumber.

Proses impor melalui wizard merupakan langkah manual dan belum diotomatisasi melalui script SQL.

### 8. Pemeriksaan Data Staging

Script `03_check_staging_import.sql` digunakan untuk memeriksa data setelah proses impor.

Pemeriksaan mencakup:

- Jumlah baris yang berhasil diimpor.
- Kelengkapan periode pengamatan.
- Jumlah provinsi.
- Duplikasi kombinasi provinsi dan periode.
- Kelengkapan kolom.
- Kesesuaian contoh nilai dengan file CSV.

Pemeriksaan staging penting untuk memastikan bahwa data telah masuk ke database tanpa mengalami perubahan yang tidak diinginkan.

### 9. Pembuatan Tabel Analisis

Script `04_create_analysis_tables.sql` membuat dua tabel utama:

- `national_monthly`
- `province_monthly`

Tabel analisis menggunakan tipe data yang sesuai dengan karakteristik setiap kolom.

Contohnya:

- `DATE` untuk periode pengamatan.
- `BIGINT UNSIGNED` untuk jumlah rekening aktif.
- `DECIMAL` untuk outstanding dan TWP90.

Primary key yang digunakan:

| Tabel | Primary Key |
|---|---|
| `national_monthly` | `Period` |
| `province_monthly` | `Province_Name`, `Period` |

Tabel juga menerapkan batasan data, antara lain:

- Outstanding tidak boleh bernilai negatif.
- TWP90 harus berada dalam rentang 0 sampai 1.
- Tanggal periode harus menunjukkan hari pertama dalam bulan.

### 10. Pemindahan dan Konversi Data

Script `05_load_analysis_tables.sql` digunakan untuk memindahkan data dari staging tables ke tabel analisis.

Proses ini mencakup beberapa konversi.

#### 10.1 Konversi Periode

Periode yang awalnya berbentuk teks `YYYY-MM` dikonversi menjadi tipe `DATE`.

Sebagai contoh:

`2025-12` menjadi `2025-12-01`.

#### 10.2 Konversi Nilai Numerik

Nilai outstanding dan TWP90 pada CSV menggunakan koma sebagai pemisah desimal.

Sebelum dikonversi ke tipe `DECIMAL`, koma diganti menjadi titik menggunakan fungsi `REPLACE()`.

#### 10.3 Konversi Jumlah Rekening Aktif

Kolom `active_borrower_accounts` dikonversi menjadi bilangan bulat menggunakan `CAST()`.

Setelah proses pemindahan, jumlah baris dan cakupan periode diperiksa kembali.

### 11. Validasi Tabel Analisis

Script `06_validate_analysis_tables.sql` digunakan untuk memeriksa kesesuaian antara staging tables dan tabel analisis.

Pemeriksaan mencakup:

1. Perbandingan data nasional sebelum dan sesudah konversi.
2. Perbandingan data provinsi sebelum dan sesudah konversi.
3. Pemeriksaan nilai yang hilang atau berbeda.
4. Rekonsiliasi outstanding provinsi terhadap nilai nasional.
5. Pemeriksaan contoh data tertentu terhadap sumber.

Rekonsiliasi digunakan sebagai alat pemeriksaan. Perbedaan antara agregat provinsi dan nasional perlu dianalisis sebelum dianggap sebagai kesalahan data.

### 12. Analisis Pertumbuhan Nasional

Script `07_national_growth_analysis.sql` digunakan untuk menganalisis perkembangan outstanding pinjaman nasional.

Analisis yang dilakukan meliputi:

- Pertumbuhan outstanding bulanan atau Month-over-Month (MoM).
- Identifikasi periode dengan pertumbuhan MoM tertinggi dan terendah.
- Pertumbuhan outstanding pada akhir tahun dibandingkan akhir tahun sebelumnya.
- Perkembangan jumlah rekening aktif.
- Perhitungan rata-rata outstanding per rekening aktif.

Pertumbuhan MoM dihitung menggunakan rumus:

`(Outstanding bulan berjalan / Outstanding bulan sebelumnya) - 1`

Pertumbuhan tahunan dihitung dengan membandingkan outstanding pada periode yang setara.

### 13. Analisis Risiko Kredit Nasional

Script `08_national_credit_risk_analysis.sql` digunakan untuk menganalisis perkembangan TWP90 nasional.

Analisis ini mencakup:

1. Perbandingan outstanding dan TWP90 pada akhir tahun.
2. Perubahan TWP90 dari satu bulan ke bulan berikutnya.
3. Identifikasi perkembangan risiko kredit dalam periode pengamatan.

TWP90 digunakan sebagai indikator risiko keterlambatan pembayaran pinjaman lebih dari 90 hari.

Kenaikan TWP90 menunjukkan peningkatan tingkat wanprestasi yang tercermin dalam indikator tersebut.

Namun, pergerakan TWP90 tidak boleh langsung dianggap sebagai bukti hubungan sebab-akibat dengan pertumbuhan outstanding.

### 14. Analisis Portofolio dan Risiko Provinsi

Script `09_province_portfolio_risk_analysis.sql` digunakan untuk membandingkan kondisi fintech lending antarprovinsi.

Analisis meliputi:

- Kontribusi outstanding provinsi terhadap total nasional.
- Perbandingan TWP90 antarprovinsi.
- Perubahan TWP90 provinsi pada periode tertentu.
- Pertumbuhan outstanding provinsi secara tahunan.
- Identifikasi konsentrasi outstanding pada lima provinsi terbesar.

Analisis tersebut membantu menjelaskan distribusi aktivitas fintech lending serta variasi indikator risiko kredit antarwilayah.

### 15. Pembuatan Reporting Views

Script `10_create_reporting_views.sql` digunakan untuk membuat dua view utama:

- `v_national_monthly`
- `v_province_monthly`

View merupakan hasil query yang dapat digunakan kembali tanpa harus menyimpan seluruh hasil perhitungan sebagai tabel fisik terpisah.

#### 15.1 View Nasional

`v_national_monthly` menyediakan data nasional dan indikator turunannya, termasuk:

- Outstanding.
- TWP90.
- Jumlah rekening aktif.
- Outstanding bulan sebelumnya.
- Outstanding pada bulan yang sama tahun sebelumnya.
- Perubahan outstanding MoM.
- Pertumbuhan outstanding MoM.
- Pertumbuhan outstanding YoY.
- Perubahan TWP90 dalam poin persentase.
- Rata-rata outstanding per rekening aktif.

Perhitungan periode pembanding menggunakan fungsi jendela SQL seperti `LAG()`.

#### 15.2 View Provinsi

`v_province_monthly` menyediakan data provinsi beserta indikator yang diperlukan untuk analisis perkembangan dan perbandingan wilayah.

View ini digunakan sebagai salah satu sumber data yang mempermudah proses pembuatan laporan dan visualisasi.

### 16. Hasil Pemeriksaan Utama

Hasil pemeriksaan terhadap view nasional menunjukkan:

| Pemeriksaan | Hasil |
|---|---:|
| Jumlah observasi nasional | 37 |
| Periode awal | 2022-12-01 |
| Periode akhir | 2025-12-01 |
| Observasi dengan pembanding MoM | 36 |
| Observasi dengan pembanding YoY | 25 |

Contoh indikator nasional pada Desember 2025:

| Indikator | Nilai |
|---|---:|
| Outstanding | Rp96.617,431 miliar |
| Pertumbuhan outstanding MoM | 1,90% |
| Pertumbuhan outstanding YoY | 25,44% |
| TWP90 | 4,3202% |
| Rekening penerima pinjaman aktif | 26.104.165 |

Nilai tersebut digunakan sebagai salah satu acuan pemeriksaan hasil analisis dan dashboard.

### 17. Urutan Menjalankan Script

Untuk membangun database dari awal, script disusun dengan urutan:

1. `01_setup_database.sql`
2. `02_create_staging_tables.sql`
3. Impor kedua file CSV menggunakan Table Data Import Wizard.
4. `03_check_staging_import.sql`
5. `04_create_analysis_tables.sql`
6. `05_load_analysis_tables.sql`
7. `06_validate_analysis_tables.sql`
8. `07_national_growth_analysis.sql`
9. `08_national_credit_risk_analysis.sql`
10. `09_province_portfolio_risk_analysis.sql`
11. `10_create_reporting_views.sql`

Urutan tersebut menunjukkan alur kerja yang digunakan dalam proyek.

Script pembuatan tabel dan pemindahan data belum seluruhnya dirancang untuk dijalankan berulang kali pada database yang sudah berisi data.

Oleh karena itu, pengulangan proses perlu memperhatikan keberadaan tabel dan data sebelumnya agar tidak menimbulkan kesalahan atau duplikasi.

### 18. Keterbatasan

Beberapa keterbatasan teknis proyek ini meliputi:

1. Impor CSV ke staging tables masih dilakukan secara manual melalui MySQL Workbench.
2. Sebagian script SQL tidak dirancang untuk dijalankan berulang kali tanpa penyesuaian.
3. Hasil analisis bergantung pada cakupan data OJK yang digunakan.
4. Data nasional dan provinsi memiliki periode pengamatan yang berbeda.
5. Tidak semua perubahan antarindikator dapat ditafsirkan sebagai hubungan sebab-akibat.

### 19. Kesimpulan Proses SQL

Tahap SQL menghasilkan struktur database yang lebih terorganisasi, pemeriksaan kualitas data, perhitungan indikator pertumbuhan dan risiko kredit, serta reporting views yang siap digunakan untuk visualisasi.

Hasil analisis selanjutnya digunakan dalam pembuatan dashboard interaktif menggunakan Microsoft Power BI.
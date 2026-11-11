# Dokumentasi Validasi Data

## Indonesia Fintech Lending Analysis

### 1. Tujuan Validasi

Validasi data dilakukan untuk memastikan bahwa dataset hasil pengolahan memiliki struktur yang konsisten, cakupan periode yang sesuai, dan nilai yang dapat digunakan untuk analisis.

Pemeriksaan dilakukan pada beberapa tahap, yaitu:

1. Validasi dalam Excel Power Query.
2. Pemeriksaan hasil ekspor CSV.
3. Validasi data setelah diimpor ke MySQL.
4. Pemeriksaan hasil perhitungan dan reporting views.

Dokumen ini membedakan hasil pemeriksaan yang telah terkonfirmasi dengan pemeriksaan yang masih memiliki keterbatasan.

### 2. Dataset yang Divalidasi

| Dataset | Jumlah Baris | Periode | Cakupan |
|---|---:|---|---|
| Nasional | 37 | Desember 2022 sampai Desember 2025 | Indonesia |
| Provinsi | 684 | Juli 2024 sampai Desember 2025 | 38 provinsi |

Dataset nasional terdiri atas satu observasi setiap bulan.

Dataset provinsi terdiri atas satu observasi untuk setiap kombinasi provinsi dan bulan.

### 3. Pemeriksaan Struktur Dataset

#### 3.1 Jumlah Observasi

Hasil pemeriksaan menunjukkan:

- Dataset nasional memiliki 37 observasi.
- Dataset provinsi memiliki 684 observasi.
- Dataset provinsi mencakup 38 provinsi.
- Setiap provinsi memiliki 18 observasi bulanan.
- Setiap bulan pada dataset provinsi memiliki 38 observasi.

Jumlah 684 observasi sesuai dengan 38 provinsi dikalikan 18 bulan.

**Status: Sesuai.**

#### 3.2 Pemeriksaan Duplikasi

Duplikasi diperiksa berdasarkan kombinasi pengenal data.

Pada dataset nasional, pemeriksaan menggunakan kolom `Period`.

Pada dataset provinsi, pemeriksaan menggunakan kombinasi `Province_Name` dan `Period`.

Hasil pemeriksaan CSV final:

| Dataset | Jumlah Duplikasi |
|---|---:|
| Nasional | 0 |
| Provinsi | 0 |

**Status: Tidak ditemukan duplikasi.**

#### 3.3 Pemeriksaan Nilai Kosong

Pemeriksaan dilakukan terhadap seluruh kolom dalam dua file CSV final.

Hasil pemeriksaan tidak menemukan sel kosong pada dataset nasional maupun provinsi.

**Status: Tidak ditemukan nilai kosong.**

### 4. Pemeriksaan Format dan Nilai

#### 4.1 Format Periode

Kolom `Period` menggunakan format `YYYY-MM`.

Periode pada dataset nasional membentuk rangkaian bulanan dari Desember 2022 sampai Desember 2025.

Periode pada dataset provinsi membentuk rangkaian bulanan dari Juli 2024 sampai Desember 2025.

**Status: Sesuai dengan cakupan yang ditetapkan.**

#### 4.2 Outstanding Pinjaman

Outstanding disimpan sebagai nilai numerik dalam satuan miliar rupiah.

Pemeriksaan terhadap kedua CSV final tidak menemukan nilai outstanding negatif.

**Status: Tidak ditemukan nilai negatif.**

#### 4.3 TWP90

TWP90 disimpan sebagai proporsi dengan rentang nilai 0 sampai 1.

Pemeriksaan terhadap kedua CSV final tidak menemukan TWP90 di luar rentang tersebut.

**Status: Sesuai dengan rentang yang ditetapkan.**

#### 4.4 Jumlah Rekening Aktif

Kolom `active_borrower_accounts` menyimpan jumlah rekening penerima pinjaman aktif dalam bentuk bilangan bulat.

Dalam analisis, indikator ini tidak ditafsirkan secara otomatis sebagai jumlah individu unik.

### 5. Rekonsiliasi Outstanding Provinsi dan Nasional

Rekonsiliasi dilakukan dengan menjumlahkan outstanding seluruh provinsi pada setiap bulan, kemudian membandingkannya dengan outstanding nasional pada periode yang sama.

Rumus pemeriksaan:

`Selisih = Total Outstanding Provinsi - Outstanding Nasional`

Pemeriksaan dilakukan terhadap 18 periode yang sama, yaitu Juli 2024 sampai Desember 2025.

Hasil pemeriksaan ulang terhadap CSV final menunjukkan:

- Jumlah periode yang dibandingkan: 18.
- Jumlah provinsi setiap periode: 38.
- Jumlah periode dengan selisih melebihi toleransi 0,000001 miliar rupiah: 0.

**Status: Sesuai untuk seluruh 18 periode pada dataset final.**

Hasil ini berlaku untuk rekonsiliasi dua CSV final. Hasil tersebut tidak otomatis menjelaskan seluruh perbedaan atau temuan yang pernah muncul pada tabel sumber OJK selama proses ETL.

### 6. Pemeriksaan terhadap Sumber OJK

Selain pemeriksaan struktur dataset, proses pengolahan juga melibatkan perbandingan nilai hasil transformasi dengan publikasi OJK.

Beberapa pemeriksaan yang dilakukan meliputi:

- Perbandingan nilai nasional pada periode tertentu.
- Pemeriksaan outstanding, rekening aktif, dan TWP90.
- Pemeriksaan contoh provinsi pada beberapa periode.
- Pemeriksaan data menggunakan workbook pembanding.

Pada proses ETL sebelumnya, sampel nilai yang telah diperiksa menunjukkan kecocokan dengan data sumber yang digunakan.

Namun, pemeriksaan tersebut bersifat selektif. Dokumentasi ini tidak mengklaim bahwa setiap sel pada seluruh publikasi OJK telah diperiksa secara manual.

### 7. Validasi Menggunakan SQL

Pemeriksaan lanjutan dilakukan menggunakan MySQL.

#### 7.1 Validasi Staging Tables

Script `03_check_staging_import.sql` digunakan untuk memeriksa:

- Jumlah observasi hasil impor.
- Periode awal dan akhir.
- Duplikasi nasional.
- Duplikasi provinsi.
- Jumlah provinsi setiap bulan.
- Jumlah observasi setiap provinsi.
- Kolom kosong.
- Format periode.
- Format nilai numerik.
- Rentang nilai TWP90.

#### 7.2 Validasi Analysis Tables

Script `06_validate_analysis_tables.sql` digunakan untuk membandingkan data pada staging tables dengan tabel analisis.

Pemeriksaan mencakup:

1. Kesesuaian nilai nasional setelah konversi.
2. Kesesuaian nilai provinsi setelah konversi.
3. Kelengkapan data setelah proses pemindahan.
4. Kesesuaian metadata sumber.
5. Rekonsiliasi outstanding provinsi dengan nasional.

Tabel analisis menggunakan primary key dan batasan nilai untuk membantu menjaga integritas data.

### 8. Pemeriksaan Reporting Views

Script `10_create_reporting_views.sql` menghasilkan:

- `v_national_monthly`
- `v_province_monthly`

Hasil pemeriksaan view nasional yang telah dilakukan sebelumnya:

| Indikator Pemeriksaan | Hasil |
|---|---:|
| Jumlah baris | 37 |
| Periode awal | 2022-12-01 |
| Periode akhir | 2025-12-01 |
| Jumlah periode dengan pembanding MoM | 36 |
| Jumlah periode dengan pembanding YoY | 25 |

Periode yang belum memiliki data pembanding tidak dipaksakan memiliki angka pertumbuhan.

Sebagai contoh, pertumbuhan YoY Januari 2023 tidak tersedia karena data Januari 2022 tidak termasuk dalam dataset.

### 9. Pemeriksaan Sampel Desember 2025

Sebagai pemeriksaan akhir, indikator nasional Desember 2025 dibandingkan dengan hasil analisis dan visualisasi.

| Indikator | Nilai |
|---|---:|
| Outstanding | Rp96.617,431 miliar |
| Pertumbuhan Outstanding MoM | 1,90% |
| Pertumbuhan Outstanding YoY | 25,44% |
| TWP90 | 4,3202% |
| Rekening Penerima Pinjaman Aktif | 26.104.165 |

Nilai ini digunakan sebagai salah satu acuan untuk memastikan konsistensi hasil SQL dan dashboard Power BI.

### 10. Keterbatasan Validasi

Beberapa keterbatasan yang perlu diperhatikan:

1. Pemeriksaan terhadap publikasi OJK dilakukan pada sampel dan titik pemeriksaan tertentu, bukan seluruh sel sumber.
2. Rekonsiliasi outstanding yang dinyatakan sesuai menggunakan dua CSV final dengan periode yang sama.
3. Perbedaan pada tahap ekstraksi atau rekonsiliasi awal harus dibedakan dari hasil pemeriksaan dataset final.
4. Kesesuaian struktur dan perhitungan tidak membuktikan bahwa seluruh data sumber bebas dari kesalahan.
5. Pemeriksaan ulang seluruh Power Query pada komputer lain memerlukan penyesuaian koneksi sumber.

### 11. Kesimpulan Validasi

Berdasarkan pemeriksaan ulang terhadap dua CSV final, dataset memenuhi pemeriksaan jumlah observasi, cakupan periode, duplikasi, kelengkapan kolom, rentang TWP90, dan nilai outstanding nonnegatif.

Rekonsiliasi outstanding provinsi terhadap nasional juga menunjukkan kecocokan untuk seluruh 18 periode yang dibandingkan.

Validasi pada Excel Power Query dan MySQL memberikan pemeriksaan tambahan terhadap struktur, transformasi, serta konsistensi hasil pengolahan.

Dengan memperhatikan keterbatasan validasi sumber, kedua dataset digunakan sebagai dasar analisis SQL dan pembuatan dashboard Power BI.
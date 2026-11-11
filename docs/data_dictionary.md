# Kamus Data (Data Dictionary)

## Indonesia Fintech Lending Analysis

Dokumen ini menjelaskan struktur, jenis, satuan, dan definisi setiap kolom dalam dataset hasil pengolahan Statistik Layanan Pendanaan Bersama Berbasis Teknologi Informasi (LPBBTI) yang dipublikasikan oleh Otoritas Jasa Keuangan (OJK).

Proyek ini menggunakan dua dataset utama, yaitu data nasional dan data provinsi.

## 1. Dataset Nasional

**Nama file:** `fintech_lending_national.csv`

**Lokasi:** `data/processed/`

**Periode:** Desember 2022 sampai Desember 2025

**Jumlah observasi:** 37 baris

Setiap baris merepresentasikan satu periode bulanan pada tingkat nasional.

| Nama Kolom | Tipe Data | Keterangan | Satuan atau Format |
|---|---|---|---|
| Period | Teks | Periode pengamatan data | YYYY-MM |
| Source_File | Teks | Nama file Excel OJK yang digunakan sebagai sumber | Nama file |
| Source_Sheet | Teks | Nomor sheet dalam file sumber OJK | Nomor sheet |
| Source_Publication_Period | Teks | Periode publikasi statistik OJK yang menjadi sumber | YYYY-MM |
| active_borrower_accounts | Bilangan bulat | Jumlah rekening penerima pinjaman aktif | Rekening/entitas sesuai sumber OJK |
| outstanding | Desimal | Nilai pinjaman yang masih belum dilunasi | Miliar rupiah |
| twp90 | Desimal | Tingkat wanprestasi pinjaman lebih dari 90 hari | Proporsi |

## 2. Dataset Provinsi

**Nama file:** `fintech_lending_province.csv`

**Lokasi:** `data/processed/`

**Periode:** Juli 2024 sampai Desember 2025

**Jumlah observasi:** 684 baris

**Jumlah provinsi:** 38

Setiap baris merepresentasikan satu provinsi pada satu periode bulanan.

| Nama Kolom | Tipe Data | Keterangan | Satuan atau Format |
|---|---|---|---|
| Region_Source | Teks | Label wilayah sebagaimana tercantum dalam sumber OJK | Teks |
| Province_Name | Teks | Nama provinsi yang telah distandardisasi | Teks |
| Period | Teks | Periode pengamatan data | YYYY-MM |
| Source_File | Teks | Nama file Excel OJK yang digunakan sebagai sumber | Nama file |
| Source_Sheet | Teks | Nomor sheet dalam file sumber OJK | Nomor sheet |
| Source_Publication_Period | Teks | Periode publikasi statistik OJK yang menjadi sumber | YYYY-MM |
| active_borrower_accounts | Bilangan bulat | Jumlah rekening penerima pinjaman aktif pada suatu provinsi | Rekening/entitas sesuai sumber OJK |
| outstanding | Desimal | Nilai pinjaman yang masih belum dilunasi pada suatu provinsi | Miliar rupiah |
| twp90 | Desimal | Tingkat wanprestasi pinjaman lebih dari 90 hari pada suatu provinsi | Proporsi |

## 3. Definisi Indikator

### 3.1 Outstanding Pinjaman

Outstanding merupakan nilai pinjaman yang masih belum dilunasi oleh penerima pinjaman pada periode pelaporan.

Dalam dataset ini, outstanding disajikan menggunakan satuan miliar rupiah.

Sebagai contoh, nilai `96617,431` menunjukkan outstanding sebesar Rp96.617,431 miliar.

### 3.2 Rekening Penerima Pinjaman Aktif

Indikator `active_borrower_accounts` menunjukkan jumlah rekening penerima pinjaman aktif sebagaimana dilaporkan dalam statistik OJK.

Indikator ini tidak otomatis menunjukkan jumlah individu unik karena satu orang dapat memiliki lebih dari satu rekening.

### 3.3 Tingkat Wanprestasi 90 Hari (TWP90)

TWP90 merupakan indikator yang digunakan untuk menggambarkan tingkat wanprestasi pinjaman dengan keterlambatan pembayaran lebih dari 90 hari.

Nilai TWP90 dalam dataset disimpan sebagai proporsi.

Contoh:

- Nilai dalam CSV: `0,043201848445`
- Nilai dalam persentase: sekitar `4,3202%`

Oleh karena itu, nilai TWP90 perlu ditampilkan menggunakan format persentase saat disajikan dalam laporan atau dashboard.

## 4. Format Dataset

Kedua dataset menggunakan ketentuan berikut:

| Komponen | Format |
|---|---|
| Format file | CSV |
| Pemisah kolom | Titik koma (;) |
| Pemisah desimal | Koma (,) |
| Format periode | YYYY-MM |
| Format TWP90 | Proporsi |
| Satuan outstanding | Miliar rupiah |

Nilai yang kosong tidak boleh langsung dianggap sama dengan nol karena keduanya memiliki makna yang berbeda.

## 5. Sumber dan Pengolahan Data

**Sumber utama:** Otoritas Jasa Keuangan (OJK), Statistik LPBBTI.

Data mentah disimpan dalam folder `data/raw/`.

Pengolahan dilakukan menggunakan Microsoft Excel Power Query melalui proses ekstraksi, transformasi, penggabungan, serta validasi data.

Hasil akhirnya disimpan dalam folder `data/processed/` untuk digunakan pada tahap analisis MySQL dan visualisasi Power BI.

## 6. Catatan Penggunaan

1. Data nasional mencakup Desember 2022 hingga Desember 2025.
2. Data provinsi mencakup Juli 2024 hingga Desember 2025.
3. Periode Desember 2022 pada data nasional digunakan sebagai periode awal dan pembanding untuk perhitungan pertumbuhan.
4. Jumlah rekening aktif tidak boleh langsung ditafsirkan sebagai jumlah peminjam unik.
5. TWP90 merupakan indikator berbentuk proporsi yang perlu dikonversi ke tampilan persentase.
6. Setiap analisis harus memperhatikan perbedaan cakupan waktu antara dataset nasional dan provinsi.
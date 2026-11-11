# Dokumentasi Proses ETL

## Indonesia Fintech Lending Analysis

### 1. Gambaran Umum

Dokumen ini menjelaskan proses Extract, Transform, Load (ETL) dalam pengolahan data fintech lending Indonesia yang bersumber dari Otoritas Jasa Keuangan (OJK).

Pengolahan dilakukan menggunakan Microsoft Excel Power Query untuk menghasilkan dataset yang terstruktur, konsisten, dan siap digunakan dalam analisis.

Workbook pengolahan memiliki 52 query yang mencakup ekstraksi, transformasi, penggabungan, validasi, dan persiapan ekspor data.

Hasil pengolahan kemudian digunakan pada tahap analisis SQL dan pembuatan dashboard Power BI.

### 2. Sumber Data

Data bersumber dari Statistik Layanan Pendanaan Bersama Berbasis Teknologi Informasi (LPBBTI) yang dipublikasikan OJK.

Tiga file utama yang digunakan dalam proses ekstraksi adalah:

1. `OJK_LPBBTI_2023_12.xlsx`
2. `OJK_LPBBTI_2024_12.xlsx`
3. `OJK_LPBBTI_2025_12.xlsx`

Selain ketiga file tersebut, terdapat file OJK tambahan yang digunakan sebagai pembanding dalam proses validasi.

Indikator utama yang diolah meliputi:

- Jumlah rekening penerima pinjaman aktif.
- Outstanding pinjaman.
- Tingkat wanprestasi 90 hari (TWP90).

### 3. Tahap Extract

Tahap ekstraksi dilakukan dengan mengimpor data dari file Excel OJK ke Microsoft Excel Power Query.

Data utama diambil dari Tabel 9 pada publikasi statistik LPBBTI.

Query utama pada proses ekstraksi adalah:

- `Raw_Table9_2023`
- `Raw_Table9_2024`
- `Raw_Table9_2025`

File sumber dipertahankan agar proses pengolahan tetap memiliki referensi terhadap data asli.

### 4. Tahap Transform

#### 4.1 Penataan Struktur Data

Data hasil ekstraksi memiliki struktur tabel yang perlu disesuaikan agar dapat digunakan dalam analisis.

Proses transformasi mencakup:

1. Mengidentifikasi baris dan kolom yang relevan.
2. Menentukan header data.
3. Mengubah struktur tabel menjadi format panjang melalui proses unpivot.
4. Memisahkan informasi periode, wilayah, indikator, dan nilai.
5. Menyesuaikan tipe data.
6. Menstandardisasi nama indikator.
7. Menambahkan informasi file sumber untuk mempermudah penelusuran.

Beberapa query yang digunakan antara lain:

- `Stg_Table_2023`
- `Header_Table9_2023`
- `Long_Table9_2023`
- `Stg_Table9_2024`
- `Header_Table9_2024`
- `Long_Table9_2024`
- `Stg_Table9_2025`
- `Header_Table9_2025`
- `Long_Table9_2025`

#### 4.2 Standardisasi Wilayah

Wilayah dalam data OJK diklasifikasikan berdasarkan tingkat geografisnya.

Klasifikasi tersebut membedakan:

- Nasional
- Subtotal wilayah
- Provinsi

Kolom `Region_Level` digunakan dalam tahap pengolahan untuk membedakan kategori tersebut.

Untuk analisis provinsi, hanya observasi dengan tingkat wilayah provinsi yang dipilih.

Nama provinsi juga distandardisasi untuk memastikan konsistensi penamaan.

Query yang berkaitan dengan proses ini antara lain:

- `Map_Province_Names`
- `Check_Province_RegionLabels`
- `Check_Province_NameMapping`

#### 4.3 Penggabungan Data Nasional

Data nasional dari masing-masing tahun publikasi digabungkan menjadi satu rangkaian data bulanan.

Query yang digunakan:

- `National_Selected_2023`
- `National_Selected_2024`
- `National_Selected_2025`
- `National_Combined`

Dalam proses ini, periode yang muncul pada lebih dari satu publikasi diperiksa agar tidak menghasilkan observasi ganda.

Hasil penggabungan memiliki cakupan Desember 2022 sampai Desember 2025.

Query `National_Combined` menghasilkan 111 baris dalam format panjang karena setiap periode memiliki tiga indikator.

Setelah disusun dalam format lebar, dataset nasional menghasilkan 37 observasi bulanan.

#### 4.4 Penggabungan Data Provinsi

Data provinsi digabungkan menggunakan query:

- `Province_Selected_2024`
- `Province_Selected_2025`
- `Province_Combined`

Pemilihan data dilakukan berdasarkan periode dan tingkat wilayah.

Data tahun 2024 mencakup Juli sampai Desember, sedangkan data tahun 2025 mencakup Januari sampai Desember.

Hasil akhirnya terdiri atas 38 provinsi dengan 18 periode bulanan.

Dataset provinsi yang telah disusun dalam format lebar memiliki 684 observasi.

### 5. Validasi Kualitas Data

Validasi dilakukan untuk memeriksa kelengkapan, konsistensi, serta kecocokan hasil pengolahan dengan sumber.

#### 5.1 Pemeriksaan Duplikasi

Pemeriksaan duplikasi dilakukan untuk memastikan bahwa kombinasi periode dan wilayah tidak menghasilkan pengamatan ganda.

Query yang digunakan:

- `Check_National_Duplicates`
- `Check_Province_Duplicates`

#### 5.2 Pemeriksaan Cakupan Periode

Pemeriksaan ini bertujuan memastikan bahwa data mencakup periode yang diharapkan.

Query yang digunakan:

- `Check_National_Coverage`
- `Check_Province_Coverage`

#### 5.3 Pemeriksaan Nilai Sumber

Nilai hasil transformasi dibandingkan dengan nilai yang tercantum pada file OJK.

Query yang digunakan antara lain:

- `Check_SourceValues_2023`
- `Check_SourceValues_2024`
- `Check_SourceValues_2025`
- `Check_Province_SourceSamples`

Pemeriksaan juga dilakukan pada beberapa contoh provinsi dan periode untuk memastikan kesesuaian nilai.

#### 5.4 Rekonsiliasi Outstanding

Rekonsiliasi dilakukan untuk memeriksa hubungan antara nilai outstanding hasil pengolahan dan agregat pada tabel sumber.

Query yang digunakan:

- `Check_Outstanding_Recon_2023`
- `Check_Outstanding_Recon_2024`
- `Check_Outstanding_Recon_2025`

Hasil rekonsiliasi menjadi dasar untuk mengidentifikasi dan mencatat perbedaan yang ditemukan.

#### 5.5 Pemeriksaan Periode yang Tumpang Tindih

Beberapa periode tersedia pada lebih dari satu file publikasi OJK.

Pemeriksaan dilakukan sebelum data digabungkan untuk mencegah duplikasi.

Query terkait:

- `Check_Overlap_National_Dec2023`
- `Check_Overlap_National_Dec2024`

### 6. Tahap Load dan Ekspor

Setelah data selesai ditransformasi dan diperiksa, hasilnya disusun untuk kebutuhan analisis lanjutan.

Query ekspor yang digunakan:

- `National_Export`
- `Province_Export`

Kedua query mengubah data menjadi format lebar sehingga setiap indikator memiliki kolom tersendiri.

Hasil ekspor disimpan dalam folder `data/processed/`.

| Dataset | Nama File | Jumlah Baris | Periode |
|---|---|---:|---|
| Nasional | `fintech_lending_national.csv` | 37 | Des 2022 sampai Des 2025 |
| Provinsi | `fintech_lending_province.csv` | 684 | Jul 2024 sampai Des 2025 |

Kedua file tersebut menjadi sumber data untuk proses analisis menggunakan MySQL.

### 7. Catatan Teknis dan Keterbatasan

Workbook Excel Power Query menggunakan koneksi ke file sumber melalui alamat direktori lokal.

Apabila folder proyek dipindahkan ke komputer atau lokasi penyimpanan lain, alamat sumber pada Power Query perlu diperbarui sebelum dilakukan refresh.

Folder `data/raw/` menyimpan file sumber OJK terpilih dan file pembanding. Keberadaan file tersebut tidak berarti keseluruhan proses ETL sudah dapat dijalankan ulang secara otomatis pada komputer lain.

Untuk mereproduksi tahap analisis SQL, diperlukan dua dataset hasil pengolahan dalam format CSV, yaitu fintech_lending_national.csv dan fintech_lending_province.csv. Kedua dataset tersebut tidak disertakan dalam repositori publik ini. Struktur dan formatnya dijelaskan dalam dokumentasi kamus data.

### 8. Hasil Akhir

Proses ETL menghasilkan dua dataset utama:

1. Dataset nasional untuk menganalisis perkembangan outstanding pinjaman, rekening penerima pinjaman aktif, dan TWP90 dari waktu ke waktu.
2. Dataset provinsi untuk membandingkan kondisi fintech lending antarprovinsi.

Kedua dataset telah digunakan sebagai dasar analisis SQL dan visualisasi interaktif menggunakan Power BI.
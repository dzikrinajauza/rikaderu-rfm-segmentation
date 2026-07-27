# 🛍️ RIKADERU E-Commerce — Customer Segmentation & RFM Tiered Strategy

### Analisis Segmentasi Pelanggan menggunakan RFM Analysis & K-Means Clustering untuk Optimasi Alokasi Anggaran Marketing

![alt text](https://github.com/dzikrinajauza/rikaderu-rfm-segmentation/blob/main/assets/1.png?raw=true)
![alt text](https://github.com/dzikrinajauza/rikaderu-rfm-segmentation/blob/main/assets/4.png?raw=true)
![alt text](https://github.com/dzikrinajauza/rikaderu-rfm-segmentation/blob/main/assets/5.png?raw=true)

## 📌 Ringkasan Proyek

Proyek ini merupakan studi kasus end-to-end data analytics pada sebuah retailer ritel kado & dekorasi rumah (All-Occasion Gifts & Home Decor Retailer) berbasis e-commerce. Tujuannya adalah mengubah data transaksi mentah menjadi strategi bisnis yang actionable, dengan mengelompokkan ribuan pelanggan ke dalam segmen yang jelas dan sistem tiering loyalitas, sehingga tim marketing dapat mengalokasikan anggaran promosi secara lebih efisien dan tepat sasaran.

Hasil akhir proyek dikemas dalam sebuah dashboard interaktif yang memungkinkan tim bisnis melakukan simulasi alokasi budget secara real-time.

## 🎯 Business Understanding

### Permasalahan Bisnis:

Tim Marketing memiliki anggaran promosi yang terbatas dan selama ini menjalankan kampanye diskon secara broad/merata ke seluruh pelanggan tanpa mempertimbangkan nilai kontribusi masing-masing. Pendekatan ini tidak efisien karena:

- Pelanggan bernilai tinggi (high-value) menerima insentif yang sama dengan pelanggan yang jarang bertransaksi, sehingga berpotensi terjadi budget wastage.
- Pelanggan yang berisiko berhenti berbelanja (churn) tidak mendapat perhatian khusus untuk diaktivasi kembali.

### Objective

Membangun sistem segmentasi berbasis data historis transaksi untuk menjawab pertanyaan strategis:

"Siapa pelanggan paling menguntungkan yang harus dijaga (retensi), dan siapa pelanggan hampir 'mati' yang perlu didorong untuk kembali belanja — dengan alokasi budget promosi yang proporsional terhadap kontribusi mereka?"

### Business Impact yang Ditargetkan:

- Meningkatkan efisiensi marketing spend dengan alokasi budget berbasis kontribusi revenue per tier.
- Menurunkan customer churn melalui identifikasi dini segmen At Risk dan Hibernating.
- Meningkatkan Customer Lifetime Value (CLV) melalui strategi retensi yang dipersonalisasi per segmen.

## 🔄 Alur Pemrosesan Data (Data Pipeline)

### 1. Data Collection

Dataset transaksi e-commerce diperoleh dari Kaggle, dengan atribut wajib:

| Kategori            | Kolom               |
| :------------------ | :------------------ |
| Identitas Pelanggan | CustomerID          |
| Identitas Transaksi | InvoiceNo           |
| Tanggal Transaksi   | InvoiceDate         |
| Nilai Transaksi     | Quantity, UnitPrice |

### 2. Data Preparation & Cleaning

| Tahapan                        | Deskripsi                                 |
| :----------------------------- | :---------------------------------| 
| Feature Creation               | Membuat kolom `TotalAmount` = `Quantity` × `UnitPrice`, karena dataset mentah tidak memiliki kolom nilai transaksi total. |
| Handling Missing Values        | Menghapus (drop) baris dengan `CustomerID` kosong, karena transaksi anonim tidak dapat dianalisis dengan metode RFM.|
| Handling Returns/Cancellations | Mengidentifikasi dan memisahkan transaksi retur/batal, yaitu baris dengan `InvoiceNo` berawalan huruf "C" (contoh: `C536379`) dan nilai `Quantity` negatif, agar metrik Monetary pelanggan tetap akurat. |

### 3. Feature Engineering — Metode RFM

Dari data transaksi yang sudah bersih, dilakukan agregasi per CustomerID menjadi 3 metrik inti:

| Metrik        | Definisi                                             |
| :------------ | :--------------------------------------------------- |
| Recency (R)   | Jumlah hari sejak transaksi terakhir pelanggan       |
| Frequency (F) | Jumlah total transaksi/invoice unik pelanggan        |
| Monetary (M)  | Total nilai belanja pelanggan sepanjang periode data |

Setiap metrik kemudian diberi skor (1–3) menggunakan pendekatan quantile-based scoring, menghasilkan kombinasi RFM Score (contoh: 333, 113, 223) yang menjadi dasar klasifikasi segmen.

## 🧠 Metodologi

### 1. Normalisasi Data

Nilai RFM dinormalisasi agar skala antar fitur setara sebelum proses clustering.

### 2. Clustering — K-Means

Model K-Means Clustering dilatih menggunakan data RFM yang sudah ternormalisasi untuk mengelompokkan pelanggan berdasarkan pola perilaku belanja yang serupa.

### 3. Rule-Based Segmentation

Kombinasi skor R-F-M dipetakan ke dalam 8 segmen pelanggan standar industri untuk interpretasi bisnis yang lebih intuitif:

| Segmen                         | Karakteristik                                                 |
| :----------------------------- | :------------------------------------------------------------ |
| 🏆 Champions                   | Baru belanja, sering, dan bernilai tinggi — pelanggan terbaik |
| 💛 Loyal Champions             | Sering belanja secara konsisten dalam jangka panjang          |
| 🆕 Recent Customers            | Baru saja melakukan transaksi pertama/terkini                 |
| 🌱 Promising                   | Pelanggan baru dengan potensi berkembang                      |
| ⚠️ Customers Needing Attention | Nilai transaksi menurun dari rata-rata                        |
| 😴 At Risk / About to Sleep    | Dulu aktif, kini mulai jarang bertransaksi                    |
| 💤 Hibernating                 | Sudah lama tidak bertransaksi                                 |
| ❌ Lost                        | Pelanggan yang kemungkinan besar sudah churn                  |

### 4. Business Tiering

Kedelapan segmen tersebut disederhanakan menjadi 4 tier strategis (Platinum, Gold, Silver, Bronze) berdasarkan kombinasi skor RFM, untuk memudahkan pengambilan keputusan alokasi budget oleh tim marketing.

## 📊 Hasil Segmentasi & Strategi Bisnis

### Distribusi Populasi & Kontribusi Revenue per Tier

| Tier        | Jumlah Pelanggan | % Populasi | Kontribusi Revenue | Alokasi Budget Promosi |
| :---------- | :--------------- | :--------- | :----------------- | :--------------------- |
| 🖤 Platinum | 857              | 19.8%      | $5.3 Juta          | 50%                    |
| 💛 Gold     | 1.000            | 23.0%      | $1.9 Juta          | 35%                    |
| 🤍 Silver   | 1.105            | 25.5%      | $0.8 Juta          | 15%                    |
| 🟤 Bronze   | 1.377            | 31.7%      | $0.8 Juta          | 0%                     |

Meski hanya mewakili 19.8% dari total populasi pelanggan, tier Platinum menyumbang mayoritas total revenue perusahaan. Sebaliknya, tier Bronze — meski jumlahnya paling besar (31.7%) — memberikan kontribusi revenue paling rendah, mengindikasikan bahwa strategi diskon merata selama ini tidak efisien secara ROI.

### Strategi Alokasi Budget (Simulasi: Total $150,000)

Dashboard dilengkapi slider simulasi anggaran (rentang $100,000–$500,000) yang secara dinamis mendistribusikan budget berdasarkan proporsi kontribusi tier:

1. Platinum → $75,000 (50%) — Fokus retensi & reward (VIP program, akses eksklusif) untuk mempertahankan pelanggan paling menguntungkan.
2. Gold → $52,500 (35%) — Fokus upselling & loyalty nurturing agar naik kelas menjadi Platinum.
3. Silver → $22,500 (15%) — Fokus re-engagement campaign untuk mencegah penurunan lebih lanjut menuju tier Bronze.
4. Bronze → $0 (0%) — Tidak diberikan diskon; direkomendasikan strategi biaya rendah seperti email reactivation atau dikeluarkan dari kampanye promosi berbayar, karena secara historis tidak memberikan return yang sepadan.

💡 Dengan pendekatan ini, tim marketing dapat mengalihkan anggaran dari kampanye "diskon merata" menjadi investasi berbasis nilai pelanggan, sekaligus mengidentifikasi 884 pelanggan At Risk dan 749 pelanggan Hibernating sebagai target prioritas kampanye reaktivasi.

## 🖥️ Dashboard

Dashboard interaktif dibangun untuk memvisualisasikan hasil analisis dan memungkinkan simulasi strategi budget secara real-time, terdiri dari 3 halaman utama:

### 1. Overview Tiered

Ringkasan distribusi tier, kontribusi revenue, dan simulator alokasi budget promosi.

### 2. RFM Segment Details

Breakdown distribusi 8 segmentasi pelanggan berdasarkan RFM score.

### 3. Customer Data Table

Tabel database pelanggan lengkap (Recency, Frequency, Monetary, RFM Score, Segmentasi, dan Tier) yang dapat dicari dan disortir.

## Cara Menjalankan Dashboard

Proyek ini dibangun sepenuhnya menggunakan R dan dijalankan melalui RStudio.

### 1. Clone repository

```git clone https://github.com/dzikrinajauza/rikaderu-rfm-segmentation.git
cd rikaderu-rfm-segmentation
```

### 2. Buka project di RStudio

Buka file `dataAnalist_segmentasiPelanggan.Rproj` agar working directory otomatis mengikuti struktur proyek.

### 3. Install package yang dibutuhkan (jalankan sekali di R Console)

`install.packages(c("shiny", "bslib", "dplyr", "scales", "ggplot2", "DT", "plotly", "bsicons", "tidyverse", "lubridate", "readr", "stringr"))`

### 4. Jalankan pipeline data (opsional — hasil cleaning sudah tersedia di `hasil_dataCleaning.csv`)

```source("dataCleaning.R") # Cleaning & feature engineering RFM
source("metodeRFM_KMeansMachineLearning.R")  # Clustering K-Means & scoring RFM
```

### 5. Jalankan dashboard Shiny

`shiny::runApp("dashboard_segmentasiPelanggan/app.R")`

Atau cukup buka file dashboard_segmentasiPelanggan/app.R di RStudio lalu klik tombol Run App.
Dashboard akan terbuka secara lokal (contoh: http://127.0.0.1:6709, port dapat berbeda sesuai konfigurasi Shiny di perangkat masing-masing).

## 👤 Author

[Dzikrina Jauza Hasna] Data Analyst | E-Commerce & Customer Analytics 📧 [dzikrinajauza@example.com] · 🔗 https://www.linkedin.com/in/dzikrinajauza/ ·

Proyek ini merupakan bagian dari latihan mandiri portofolio Data Analyst dengan studi kasus digital business (e-commerce), dibuat untuk mendemonstrasikan kemampuan end-to-end analytics: dari data cleaning, feature engineering, machine learning (clustering), hingga penerjemahan hasil analisis menjadi rekomendasi strategi bisnis yang berdampak nyata.

> > > > > > > 94f1ae57ee6b40fcfd0fa40bf5e3be13a1f8e802

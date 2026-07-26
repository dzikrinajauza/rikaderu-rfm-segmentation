# 🛍️ RIKADERU E-Commerce — Customer Segmentation & RFM Tiered Strategy

### Analisis Segmentasi Pelanggan menggunakan RFM Analysis & K-Means Clustering untuk Optimasi Alokasi Anggaran Marketing

![alt text](?raw=true)

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

"Siapa pelanggan paling menguntungkan yang harus dijaga (retensi), dan siapa pelanggan hampir   'mati' yang perlu didorong untuk kembali belanja — dengan alokasi budget promosi yang   proporsional terhadap kontribusi mereka?"

### Business Impact yang Ditargetkan:

- Meningkatkan efisiensi marketing spend dengan alokasi budget berbasis kontribusi revenue per tier.
- Menurunkan customer churn melalui identifikasi dini segmen At Risk dan Hibernating.
- Meningkatkan Customer Lifetime Value (CLV) melalui strategi retensi yang dipersonalisasi per segmen.

## 🔄 Alur Pemrosesan Data (Data Pipeline)

### 1. Data Collection

Dataset transaksi e-commerce diperoleh dari Kaggle, dengan atribut wajib:

| Kategori |	Kolom |
|:---------|:-------|
| Identitas Pelanggan	| CustomerID |
| Identitas Transaksi	| InvoiceNo |
| Tanggal Transaksi	| InvoiceDate |
| Nilai Transaksi |	Quantity, UnitPrice |

### 2. Data Preparation & Cleaning

| Tahapan |	Deskripsi |
|:--------|:----------|
| Feature Creation |	Membuat kolom TotalAmount = Quantity × UnitPrice, karena dataset mentah tidak |memiliki kolom nilai transaksi total. |
| Handling Missing Values	| Menghapus (drop) baris dengan CustomerID kosong, karena transaksi anonim tidak dapat dianalisis dengan metode RFM. |
| Handling Returns/Cancellations	| Mengidentifikasi dan memisahkan transaksi retur/batal, yaitu baris dengan InvoiceNo berawalan huruf "C" (contoh: C536379) dan nilai Quantity negatif, agar metrik Monetary pelanggan tetap akurat. |

### 3. Feature Engineering — Metode RFM

Dari data transaksi yang sudah bersih, dilakukan agregasi per CustomerID menjadi 3 metrik inti:

| Metrik | Definisi |
|:-------|:---------|
| Recency (R) |	Jumlah hari sejak transaksi terakhir pelanggan |
| Frequency (F)	| Jumlah total transaksi/invoice unik pelanggan |
| Monetary (M)	| Total nilai belanja pelanggan sepanjang periode data |

Setiap metrik kemudian diberi skor (1–3) menggunakan pendekatan quantile-based scoring, menghasilkan kombinasi RFM Score (contoh: 333, 113, 223) yang menjadi dasar klasifikasi segmen.

## 🧠 Metodologi

### 1. Normalisasi Data
Nilai RFM dinormalisasi agar skala antar fitur setara sebelum proses clustering.
### 2. Clustering — K-Means
Model K-Means Clustering dilatih menggunakan data RFM yang sudah ternormalisasi untuk mengelompokkan pelanggan berdasarkan pola perilaku belanja yang serupa.
### 3. Rule-Based Segmentation
Kombinasi skor R-F-M dipetakan ke dalam 8 segmen pelanggan standar industri untuk interpretasi bisnis yang lebih intuitif:

| Segmen |	Karakteristik |
|:-------|:---------------|
| 🏆 Champions	| Baru belanja, sering, dan bernilai tinggi — pelanggan terbaik |
| 💛 Loyal Champions	| Sering belanja secara konsisten dalam jangka panjang |
| 🆕 Recent Customers	| Baru saja melakukan transaksi pertama/terkini |
| 🌱 Promising	| Pelanggan baru dengan potensi berkembang |
| ⚠️ Customers Needing Attention	| Nilai transaksi menurun dari rata-rata |
| 😴 At Risk / About to Sleep	 | Dulu aktif, kini mulai jarang bertransaksi |
| 💤 Hibernating	| Sudah lama tidak bertransaksi |
| ❌ Lost	| Pelanggan yang kemungkinan besar sudah churn |

### 4. Business Tiering 
Kedelapan segmen tersebut disederhanakan menjadi 4 tier strategis (Platinum, Gold, Silver, Bronze) berdasarkan kombinasi skor RFM, untuk memudahkan pengambilan keputusan alokasi budget oleh tim marketing.

## 📊 Hasil Segmentasi & Strategi Bisnis

### Distribusi Populasi & Kontribusi Revenue per Tier

| Tier	| Jumlah Pelanggan |	% Populasi |	Kontribusi Revenue	| Alokasi Budget Promosi |
|:------|:-----------------|:------------|:---------------------|:-----------------------|
| 🖤 Platinum	 | 857	| 19.8% |	$5.3 Juta	| 50% |
| 💛 Gold	 | 1.000	| 23.0% |	$1.9 Juta	| 35% |
| 🤍 Silver |	1.105	| 25.5%	| $0.8 Juta	| 15% |
| 🟤 Bronze |	1.377 |	31.7% |	$0.8 Juta |	0% |

Meski hanya mewakili 19.8% dari total populasi pelanggan, tier Platinum menyumbang mayoritas total revenue perusahaan. Sebaliknya, tier Bronze — meski jumlahnya paling besar (31.7%) — memberikan kontribusi revenue paling rendah, mengindikasikan bahwa strategi diskon merata selama ini tidak efisien secara ROI.

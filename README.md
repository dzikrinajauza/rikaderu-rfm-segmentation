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
|:---------|-------:|
| Identitas Pelanggan	| CustomerID |
| Identitas Transaksi	| InvoiceNo |
| Tanggal Transaksi	| InvoiceDate |
| Nilai Transaksi |	Quantity, UnitPrice |

### 2. Data Preparation & Cleaning

| Tahapan |	Deskripsi |
|:--------|----------:|
| Feature Creation |	Membuat kolom TotalAmount = Quantity × UnitPrice, karena dataset mentah tidak |memiliki kolom nilai transaksi total. |
| Handling Missing Values	| Menghapus (drop) baris dengan CustomerID kosong, karena transaksi anonim tidak dapat dianalisis dengan metode RFM. |
| Handling Returns/Cancellations	| Mengidentifikasi dan memisahkan transaksi retur/batal, yaitu baris dengan InvoiceNo berawalan huruf "C" (contoh: C536379) dan nilai Quantity negatif, agar metrik Monetary pelanggan tetap akurat. |

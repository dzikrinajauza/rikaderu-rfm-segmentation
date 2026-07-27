# ==============================================================================
# APLIKASI SHINY: RIKADERU E-COMMERCE - RFM TIERED STRATEGY DASHBOARD
# ==============================================================================

# 1. LOAD LIBRARIES --------------------------------------------------------
library(shiny)      # Framework utama pembuat UI web
library(bslib)      # Tema CSS Bootstrap 5
library(plotly)     # Pembuat grafik interaktif (hoverable)
library(ggplot2)    # Pembuat grafik statis
library(dplyr)      # Alat bantu manipulasi/filter data (SQL-like)
library(scales)     # Format angka (misal: merapikan persentase)
library(bsicons)    # Mengambil icon bawaan Bootstrap (<i class="bi...">)
library(tidyverse)  # Kumpulan library data science
library(lubridate)  # Alat bantu hitung tanggal/waktu
library(readr)      # Alat baca file CSV
library(stringr)    # Alat bantu manipulasi teks/string
library(DT)         # Pembuat tabel data interaktif (BARU)

# 2. PERSIAPAN DATA (BACKEND LOGIC) ----------------------------------------
# Membaca data mentah
cleaned_dataPenjualan <- read_csv("../hasil_dataCleaning.csv")

# Menentukan tanggal acuan untuk menghitung Recency (hari ini)
tanggal_analisis <- max(cleaned_dataPenjualan$InvoiceDate) + days(1)

# Tahap 1: Membangun base RFM (Recency, Frequency, Monetary)
rfm_base <- cleaned_dataPenjualan %>%
  group_by(CustomerID) %>%
  summarise(
    Recency = as.numeric(difftime(tanggal_analisis, max(InvoiceDate), units = "days")),
    frequency = n_distinct(InvoiceNo),
    Monetary = sum(revenue)
  )

# Tahap 2: Mengubah angka asli menjadi skor 1-3 (Ranking)
rfm_score <- rfm_base %>%
  mutate(
    R_score = ntile(desc(Recency), 3),
    F_score = ntile(frequency, 3),
    M_score = ntile(Monetary, 3)
  ) %>%
  mutate(rfm_score = paste0(R_score, F_score, M_score))

# Tahap 3: Memilah pelanggan ke dalam 8 Segmen berdasarkan kombinasi Skor RFM
rfm_final <- rfm_score %>%
  mutate(Segmentasi = case_when(
    rfm_score == "333" ~ "Champions", 
    rfm_score == "332" ~ "Loyal Champions", 
    rfm_score %in% c("331", "323", "322", "321", "313", "312", "311") ~ "Recent Customers", 
    rfm_score %in% c("233", "133") ~ "Promising",
    rfm_score %in% c("232", "231", "223") ~ "Customers Needing Attention",
    rfm_score %in% c("222", "221", "213", "212", "211") ~ "At Risk / About to Sleep",
    rfm_score %in% c("132", "131", "123", "122", "121", "113", "112") ~ "Hibernating",
    rfm_score == "111" ~ "Lost",
    TRUE ~ "Other"
  ))


# Tahap 4: Menyederhanakan 8 Segmen menjadi 4 Tier (Platinum, Gold, Silver, Bronze)
rfm_tiered <- rfm_final %>%
  mutate(Tier = case_when(
    Segmentasi %in% c("Champions", "Loyal Champions") ~ "Platinum",
    Segmentasi %in% c("Recent Customers", "Promising") ~ "Gold",
    Segmentasi %in% c("Customers Needing Attention", "At Risk / About to Sleep") ~ "Silver",
    Segmentasi %in% c("Hibernating", "Lost", "Other") ~ "Bronze",
    TRUE ~ "Bronze" 
  )) %>%
  mutate(Tier = factor(Tier, levels = c("Platinum", "Gold", "Silver", "Bronze")))


# Tahap 5: Meringkas data menjadi tabel kecil (Agregat) khusus untuk Dashboard
dashboard_data <- rfm_tiered %>%
  group_by(Tier) %>%
  summarise(
    Jumlah_Pelanggan = n(), 
    Total_Revenue = sum(Monetary, na.rm = TRUE)
  ) %>%
  mutate(
    Persentase_Pelanggan = round((Jumlah_Pelanggan / sum(Jumlah_Pelanggan)) * 100, 1)
  )

view(rfm_tiered)

# Tahap 6: Menyimpan jumlah pelanggan per tier ke dalam variabel tunggal
jml_plat <- dashboard_data$Jumlah_Pelanggan[dashboard_data$Tier == "Platinum"]
jml_gold <- dashboard_data$Jumlah_Pelanggan[dashboard_data$Tier == "Gold"]
jml_silv <- dashboard_data$Jumlah_Pelanggan[dashboard_data$Tier == "Silver"]
jml_brnz <- dashboard_data$Jumlah_Pelanggan[dashboard_data$Tier == "Bronze"]

# Tahap 7: Menyiapkan variabel CSS/Warna Global agar grafik seragam
tier_colors <- c("Platinum" = "#4c443d", "Gold" = "#F3CB51", "Silver" = "#EEEEEE", "Bronze" = "#A0522D")


# 3. USER INTERFACE / TAMPILAN DEPAN (FRONTEND/HTML) -----------------------

ui <- page_sidebar(
  title = "RIKADERU E-COMMERCE - RFM TIERED STRATEGY DASHBOARD",
  theme = bs_theme(version = 5, bootswatch = "flatly",
                   base_font = font_google("Inter"),
                   primary = "#215e61"),
  
  fillable = FALSE,
  
  tags$head(
    tags$style(HTML("
      .navbar {
        background-color:#14383a  !important; 
      }
      .navbar .navbar-brand {
        color:#e9efef  !important;
        font-weight: bold;
      }
    "))
  ),
  
  # === PANEL KIRI (SIDEBAR / <aside>) ===
  sidebar = sidebar(bg = "#bccfd0",
                    width = 300, 
                    h5("Strategic Control", style = "font-weight: bold; font-size: 18px; margin-top:0;"),
                    
                    # Elemen Form <select> (SUDAH DITAMBAHKAN OPSI KE-3)
                    selectInput("tampilan", "Select Visual Display", 
                                choices = c("Overview Tiered", "RFM Segment Details", "Customer Data Table")),
                    
                    # Elemen Form <input type="range">
                    sliderInput("budget", "Promotional Budget Target (USD)", 
                                min = 100000, max = 500000, value = 150000, step = 10000),
                    
                    hr(), # garis horizontal
                    h6("Population Summary:", style = "font-weight: bold;"),
                    
                    # Membangun Grid Layout untuk Icon Summary
                    layout_columns(
                      col_widths = c(3,3,3,3), 
                      
                      div(
                        div(bs_icon("star-fill", color="#E1DCC9", size="1.2em"), 
                            style="background-color:#1F150C; border-radius:50%; width:35px; height:35px; display:flex; align-items:center; justify-content:center; margin-bottom:5px;"),
                        p("PLATINUM", style="font-size:10px; margin:0;"), p(jml_plat, style="font-weight:bold;")
                      ),
                      
                      div(
                        div(bs_icon("star-fill", color="#333333", size="1.2em"), 
                            style="background-color:#F3CB51; border-radius:50%; width:35px; height:35px; display:flex; align-items:center; justify-content:center; margin-bottom:5px;"),
                        p("GOLD", style="font-size:10px; margin:0;"), p(jml_gold, style="font-weight:bold;")
                      ),
                      
                      div(
                        div(bs_icon("star-fill", color="#333333", size="1.2em"), 
                            style="background-color:#EEEEEE; border-radius:50%; width:35px; height:35px; display:flex; align-items:center; justify-content:center; margin-bottom:5px;"),
                        p("SILVER", style="font-size:10px; margin:0;"), p(jml_silv, style="font-weight:bold;")
                      ),
                      
                      div(
                        div(bs_icon("star-fill", color="#333333", size="1.2em"), 
                            style="background-color:#A0522D; border-radius:50%; width:35px; height:35px; display:flex; align-items:center; justify-content:center; margin-bottom:5px;"),
                        p("BRONZE", style="font-size:10px; margin:0;"), p(jml_brnz, style="font-weight:bold;")
                      )
                    )
  ),
  
  # === PANEL KANAN UTAMA (MAIN CONTENT) ===
  
  # --- KONDISI 1: TAMPILAN OVERVIEW TIERED ---
  conditionalPanel(
    condition = "input.tampilan == 'Overview Tiered'",
    
    # Baris ke 1
    layout_columns( # membagi halaman secara horizontal menjadi beberapa bagian atau card2
      card(style="background-color: white;",
           card_header("% Number of Customers per Tier", style="background-color:#215e61; color:#FFFFFF; font-size: 16px;"),
           plotlyOutput("donut_chart", height = "300px") # server logic, Render Grafik Donat
      ),
      card(style="background-color: white;",
           card_header("Total Revenue Contribution per Tier (Millions)", style="background-color:#215e61; color:#FFFFFF;"),
           plotlyOutput("bar_chart", height = "300px") # server logic, Render Grafik bar_chart
      )
    ),
    
    # Baris ke 2
    card(style="background-color: white; margin-top: 18px;",
         card_header(textOutput("budget_title"), style="background-color:#215e61; color:#FFFFFF;"),
         plotOutput("combo_chart", height = "300px") # Server logic, Rnder grafik combo_cart
    ),
    
    # Baris ke 3
    layout_columns(
      style="margin-top:18px;",
      card(style = "background-color: #4c443d;", 
           h5(bs_icon("star-fill", color="#E1DCC9", size="1.2em"), " PLATINUM TIER", style = "font-weight: bold; color: #FFFFFF;"),
           p(strong("Alokasi Budget: 50%"), style ="color: white;")
      ),
      card(style = "background-color: #F3CB51;", 
           h5(bs_icon("star-fill", color="#333333", size="1.2em"), " GOLD TIER", style = "font-weight: bold; color: black;"),
           p(strong("Alokasi Budget: 35%"), style ="color: black;")
      ),
      card(style = "background-color: #EEEEEE;",
           h5(bs_icon("star-fill", color="#333333", size="1.2em"), " SILVER TIER", style = "font-weight: bold; color: black;"),
          p(strong("Alokasi Budget: 15%"), style ="color: black;")
      ),
      card(style = "background-color: #A0522D;",
          h5(bs_icon("star-fill", color="#E1DCC9", size="1.2em"), " BRONZE TIER", style = "font-weight: bold; color: #FFFFFF;"),
           p(strong("Alokasi Budget: 0"), style ="color: #FFFFFF;")
      )
    )
  ),
  
  # --- KONDISI 2: TAMPILAN RFM SEGMENT DETAILS ---
  conditionalPanel(
    condition = "input.tampilan == 'RFM Segment Details'",
    
    card(style="background-color: white;",
         card_header("Distribusi Detail 8 Segmen Pelanggan", style="background-color:#215e61; color:#FFFFFF;"),
         plotOutput("segment_chart", height = "450px") # server logic, render grafik RFM 
    )
  ),
  
  # --- KONDISI 3: TAMPILAN TABEL DATA PELANGGAN ---
  conditionalPanel(
    condition = "input.tampilan == 'Customer Data Table'",
    
    card(style="background-color: white;",
         card_header("Database Pelanggan Lengkap (RFM & Tier)", style="background-color:#215e61; color:#FFFFFF;"),
         DTOutput("tabel_pelanggan") # server logic, render tabel_pelanggan
    )
  )
)


# 4. SERVER LOGIC (PENGOLAH GRAFIK DINAMIS) --------------------------------

server <- function(input, output, session) {
  
  # Render Grafik Donat
  output$donut_chart <- renderPlotly({
    # plot_ly(...): Memanggil library pembuat grafik.
    # type = 'pie', hole = 0.5: Mengubah grafik pie biasa menjadi donat dengan
    plot_ly(dashboard_data, labels = ~Tier, values = ~Persentase_Pelanggan, type = 'pie',
            textfont = list(size = 16, family = "Inter"),
            hole = 0.5, textinfo = 'label+percent',
            # marker: Mengatur visual fisik dari potongan donat.
            marker = list(colors = unname(tier_colors[dashboard_data$Tier]),
                          line = list(color = 'white', width = 2))) %>%
      # layout(...): Ini adalah pengaturan "Box Model" pada CSS.
      layout(
        # showlegend = FALSE: Pendekatan CSS: display: none; untuk kotak legenda (keterangan warna).
        showlegend = FALSE, 
        margin = list(t = 20, b = 20, l = 20, r = 20),
        paper_bgcolor = 'rgba(0,0,0,0)', 
        plot_bgcolor = 'rgba(0,0,0,0)'   
      )
  })
  
  # Render Grafik Batang (Bar)
  output$bar_chart <- renderPlotly({
    plot_data <- dashboard_data %>%
      # mutate(...): Sebelum digambar, datanya diubah dulu. Nilai Total_Revenue dibagi 1 juta (1e6) agar angkanya lebih pendek dan enak dibaca.
      mutate(Rev_Juta = Total_Revenue / 1e6)
    
    plot_ly(plot_data, x = ~Tier, y = ~Rev_Juta, type = 'bar',
            text = ~paste0(round(Rev_Juta, 1), ""), textposition = 'auto',
            marker = list(color = unname(tier_colors[plot_data$Tier]))) %>%
      layout(
        yaxis = list(title = list(text = "Revenue (Million USD)", font = list(color = "black"), size = 14), tickfont = list(color = "black", size = 12)),
        xaxis = list(title = "", tickfont = list(color = "black", size = 12)),
        showlegend = FALSE, 
        margin = list(t = 20, b = 20, l = 20, r = 20),
        paper_bgcolor = 'rgba(0,0,0,0)',
        plot_bgcolor = 'rgba(0,0,0,0)'
      )
  })
  
  # Render Text Judul Dinamis berdasarkan tarikan Slider Budget
  output$budget_title <- renderText({
    paste0("Promotion Budget Allocation Simulation (Total: ", input$budget, " USD)")
  })
  
  # Render Grafik Kombinasi (Bawah)
  output$combo_chart <- renderPlot({
    budget_data <- data.frame(
      Tier = factor(c("Platinum", "Gold", "Silver", "Bronze"), levels = c("Platinum", "Gold", "Silver", "Bronze")),
      Alokasi = c(input$budget * 0.50, input$budget * 0.35, input$budget * 0.15, 0),
      Target_Konversi = c(80, 50, 20, 5)
    )
    
    ggplot(budget_data, aes(x = Tier)) +
      geom_col(aes(y = Alokasi, fill = Tier), width = 0.5) +
      geom_text(aes(y = Alokasi, label = paste0(Alokasi, " USD")), 
                vjust = -0.5, fontface = "bold", color = "black", size = 4.5) +
      geom_line(aes(y = Target_Konversi * (max(Alokasi)/100), group = 1), color = "black", size = 1) +
      geom_point(aes(y = Target_Konversi * (max(Alokasi)/100)), color = "black", size = 3) +
      scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
      scale_fill_manual(values = tier_colors) +
      theme_minimal() +
      labs(y = "Alokasi Budget", x = "") +
      theme(
        legend.position = "none",
        axis.text.y = element_blank(),
        axis.title.y = element_blank(),
        axis.line.x = element_line(color = "black"),
        axis.text.x = element_text(size = 14, color = "black"),
        plot.background = element_rect(fill = "transparent", color = NA),
        panel.background = element_rect(fill = "transparent", color = NA)
      )
  }, bg = "transparent")
  
  # Render Grafik Segmentasi 8 Tier 
  output$segment_chart <- renderPlot({
    segmentasi_sum <- rfm_tiered %>%
      count(Tier, Segmentasi, name = "Jumlah_Pelanggan")
    
    ggplot(segmentasi_sum, aes(x = Jumlah_Pelanggan, y = reorder(Segmentasi, Jumlah_Pelanggan), fill = Tier)) + 
      geom_col() +
      scale_fill_manual(values = tier_colors) +
      labs(
        title = "Distribusi Segmentasi Pelanggan (8 Klasifikasi)",
        x = "Jumlah Pelanggan",
        y = "" 
      ) +
      theme_minimal() +
      geom_text(aes(label = Jumlah_Pelanggan), hjust = -0.2, size = 4, fontface="bold") +
      theme(
        axis.text.y = element_text(size = 12, face = "bold"),
        axis.text.x = element_text(size = 11),
        plot.title = element_text(size = 14, face = "bold"),
        panel.grid.major.y = element_blank(),
        plot.margin = margin(10, 20, 10, 10),
        legend.position = "right", 
        legend.title = element_text(face = "bold")
      )
  })
  
  # Render Tabel Data Pelanggan Interaktif (BARU)
  output$tabel_pelanggan <- renderDT({
    datatable(rfm_tiered, 
              options = list(
                pageLength = 5,       
                scrollX = TRUE,
                searchHighlight = TRUE 
              ),
              rownames = FALSE,        
              class = 'cell-border stripe' 
    )
  })
}

# 5. JALANKAN APLIKASI -----------------------------------------------------
shinyApp(ui = ui, server = server)
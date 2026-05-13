# 🏨 Elite Hotels International — Booking Data Analysis

> **119,390 Records | 32 Features | 2015–2017 | End-to-End Data Analysis**

[![Python](https://img.shields.io/badge/Python-3.8%2B-blue?logo=python&logoColor=white)](https://www.python.org/)
[![MySQL](https://img.shields.io/badge/MySQL-Database-orange?logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Jupyter](https://img.shields.io/badge/Jupyter-Notebook-orange?logo=jupyter&logoColor=white)](https://jupyter.org/)
[![pandas](https://img.shields.io/badge/pandas-EDA-green?logo=pandas&logoColor=white)](https://pandas.pydata.org/)
[![seaborn](https://img.shields.io/badge/seaborn-Visualization-blue)](https://seaborn.pydata.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-lightgrey)](LICENSE)

---

## 🌟 Situation

Elite Hotels International operates two hotel types — **City Hotel** and **Resort Hotel** — and was sitting on three years of raw booking data (2015–2017) covering 119,390 records across 32 features with no structured analytical framework to extract business value from it.

The data itself presented serious quality challenges before any analysis could begin: missing values across key columns (`children`, `country`, `agent`, `company`), zero-guest records caused by data entry errors, negative and extreme ADR outliers, zero-night stay records, and inconsistent categorical formats. Beyond data quality, the business had no clear visibility into its most critical operational problems:

- A high and growing **cancellation rate** with no understanding of which segments, channels, or deposit policies were driving it
- No tracking of **seasonal revenue patterns** or peak vs. trough period performance
- No guest segmentation by **repeat vs. new, family vs. solo, or source country**
- No systematic analysis of **what booking behaviours predict a confirmed stay vs. a cancellation**

The need was a full-stack analytics pipeline — from raw CSV through SQL database to Python EDA — that could surface the operational intelligence required to reduce cancellations, optimise pricing, and grow revenue.

---

## 🎯 Task

The project was built to answer ten core business questions across five analytical domains:

| Domain | Business Questions |
|---|---|
| **Cancellation Intelligence** | What is the overall and hotel-wise cancellation rate? Which segments, deposit types, and lead times cancel most? |
| **Revenue & Pricing** | What is total realised revenue? How does ADR vary by month, hotel type, and stay duration? |
| **Booking Channels** | Which market segments and distribution channels drive the most volume, best ADR, and lowest cancellation? |
| **Guest Behaviour** | Do special requests predict lower cancellations? Do repeat guests outperform new guests? How do families differ? |
| **Geographic & Seasonal** | Which countries send the highest-value guests? Which months are peak vs. trough? What is the optimal booking window? |

Deliverables: a cleaned MySQL database with 20+ SQL analytical queries and 3 reusable views, plus a 10-section Python EDA notebook with 10 publication-quality figures and an executive KPI dashboard.

---

## ⚙️ Action

### 1. Database Setup & Data Loading (MySQL)

A production-style MySQL database was built from scratch:

```sql
-- Database and table creation
CREATE DATABASE hotel_booking_analysis;

CREATE TABLE hotel_bookings (
    booking_id     INT AUTO_INCREMENT PRIMARY KEY,
    hotel          VARCHAR(50),
    is_canceled    TINYINT,
    lead_time      INT,
    adr            DECIMAL(10,2),
    market_segment VARCHAR(50),
    deposit_type   VARCHAR(50),
    country        VARCHAR(10),
    -- ... 32 columns total
);

-- Bulk load from CSV with NULL handling
LOAD DATA INFILE '...hotel_bookings.csv'
INTO TABLE hotel_bookings
SET children = NULLIF(@children, '');
```

Performance indexes were created on the most-queried columns:

```sql
CREATE INDEX idx_hotel             ON hotel_bookings(hotel);
CREATE INDEX idx_country           ON hotel_bookings(country);
CREATE INDEX idx_market_segment    ON hotel_bookings(market_segment);
CREATE INDEX idx_arrival_year      ON hotel_bookings(arrival_date_year);
CREATE INDEX idx_reservation_status ON hotel_bookings(reservation_status);
```

---

### 2. SQL Data Cleaning

Three targeted cleaning operations were applied directly in MySQL:

```sql
-- Fix missing children values
UPDATE hotel_bookings SET children = 0 WHERE children IS NULL;

-- Fix missing country values
UPDATE hotel_bookings SET country = 'Unknown' WHERE country IS NULL;

-- Remove zero-guest records (data entry errors)
DELETE FROM hotel_bookings
WHERE adults = 0 AND children = 0 AND babies = 0;
```

---

### 3. SQL Analysis (20+ Queries across 12 Sections)

**Exploratory Queries (Sections A–T)**

| Query | Purpose |
|---|---|
| A | Total bookings count |
| B | Hotel-wise booking distribution |
| C & D | Overall and hotel-wise cancellation rate |
| E & F | Monthly and yearly booking trends |
| G | Average Daily Rate (ADR) by hotel type |
| H | Top 10 guest source countries |
| I | Market segment: volume, ADR, cancellation rate |
| J | Customer type breakdown and average ADR |
| K | Repeat vs. new guest count |
| L | Lead time category bucketing (0–7, 8–30, 31–90, 90+ days) |
| M | Special request frequency distribution |
| N | Meal preference analysis |
| O | Deposit type vs. cancellation rate |
| P | Room type mismatch analysis (reserved ≠ assigned) |
| Q & R | Average stay duration; weeknight vs. weekend breakdown |
| S | Guest composition: Solo / Couples / Families / Groups |
| T | Parking space requirement distribution |

**Revenue Queries (Section 7)**
- Total realised revenue (confirmed bookings only: `adr × total_nights`)
- Hotel-wise and month-wise revenue breakdown
- Most profitable customer types by average booking value

**Advanced Business Queries (Section 8)**
- High-cancellation market segments ranked by rate
- Long lead time cancellation analysis (Short / Medium / Long buckets)
- Special requests vs. cancellation rate cross-tab
- Repeat guest revenue contribution

**KPI Dashboard Queries (Section 9)**
- Total bookings · Confirmed bookings · Cancelled bookings · Average ADR · Average stay duration

**Reusable Views (Section 10)**

```sql
CREATE VIEW vw_hotel_revenue AS ...        -- Hotel revenue summary
CREATE VIEW vw_cancellation_summary AS ... -- Hotel cancellation KPIs
CREATE VIEW vw_monthly_revenue AS ...      -- Month × year revenue grid
```

---

### 4. Python Data Cleaning & Feature Engineering

A rigorous multi-step pipeline was applied before EDA:

| Step | Action |
|---|---|
| **Null imputation** | `children`, `agent`, `company` filled with `0`; `country` filled with `'Unknown'` |
| **Zero-guest removal** | Deleted records where `adults + children + babies = 0` |
| **ADR outlier removal** | Removed records where `adr < 0` or `adr > 5000` |
| **Zero-night removal** | Removed records where `weekend_nights + week_nights = 0` |
| **Month ordering** | Set `arrival_date_month` as an ordered categorical (Jan → Dec) |
| **Feature: `total_nights`** | `stays_in_weekend_nights + stays_in_week_nights` |
| **Feature: `total_guests`** | `adults + children + babies` |
| **Feature: `total_revenue`** | `adr × total_nights` |
| **Feature: `arrival_date`** | Parsed to `datetime` from year + month + day columns |
| **Feature: `quarter`** | Derived Q1–Q4 from arrival date |
| **Feature: `room_type_match`** | Binary flag: `1` if reserved room = assigned room |
| **Feature: `has_children`** | Binary flag for family bookings |

**Result:** 118,902 clean records from 119,390 raw rows.

---

### 5. Python EDA — 10 Sections, 10 Figures

| Section | Key Analysis | Figure |
|---|---|---|
| 1. Environment Setup | Library config, brand colour palette | — |
| 2. Data Quality | Missing value audit, hotel type distribution | `fig_01` |
| 3. EDA | Key metric distributions, correlation heatmap | `fig_02`, `fig_03` |
| 4. Cancellation | Monthly trend, segment rates, lead time buckets, deposit type | `fig_04` |
| 5. Revenue & ADR | Monthly ADR trend, monthly revenue, ADR by stay length, revenue by customer type | `fig_05` |
| 6. Booking Channels | Volume by segment, lead time vs ADR bubble chart, distribution channel ADR vs volume | `fig_06` |
| 7. Guest Behaviour | Special requests vs cancellation, meal plan analysis, room match impact, customer type ADR | `fig_07` |
| 8. Seasonal Trends | Booking heatmap (hotel × month), quarterly ADR + cancellation, optimal lead time, weeknight vs weekend | `fig_08` |
| 9. Geographic Intelligence | Top 15 source countries, country positioning bubble chart (nights × ADR × cancellation) | `fig_09` |
| 10. KPI Dashboard | Full executive dashboard — 4 KPI cards + 6 charts on dark branded canvas | `fig_10` |

---

### 6. Tools & Stack

```
Python     pandas · numpy · matplotlib · seaborn · matplotlib.gridspec
MySQL      20+ analytical queries · 3 views · 5 performance indexes
Jupyter    Reproducible 11-section EDA notebook
```

---

## 📊 Result

### Key Findings & Strategic Recommendations

| # | Finding | Recommendation |
|---|---|---|
| 1 | **37% overall cancellation rate** — City Hotel at 41.7%, Resort Hotel at 27.8% | Implement dynamic deposit policies; non-refundable discount tiers for early bookers |
| 2 | **Non-Refund deposit type paradoxically cancels at ~99%** | Revise deposit policy structuring — non-refund offers are attracting speculative bookings |
| 3 | **Bookings with >180-day lead time cancel at 50%+** | Apply tiered confirmation workflows for long lead-time online bookings |
| 4 | **Lowest ADR window: 31–90 days in advance** | Promote smart booking windows to consumers; protect peak inventory with yield management |
| 5 | **Guests making 3+ special requests cancel at <20%** vs. 40%+ for zero requests | Make special request capture mandatory at checkout to filter intent and flag high-risk bookings |
| 6 | **August is peak revenue month** — Resort Hotel ADR spikes 130%+ above annual average | Surge pricing in Jul–Aug; restrict discount channels during peak season |
| 7 | **Portugal (PRT) accounts for 40%+ of all bookings** — high concentration risk | Target GBR, DEU, BRA markets with tailored international packages |
| 8 | **Repeat guests cancel at only 15% vs. 37% for new guests** — but only 3.2% of bookings are repeats | Launch a structured loyalty programme; incentivise direct booking with member rates |

### Strongest Predictors of Cancellation (Correlation Analysis)

```
1. Lead time          2. Deposit type (Non-Refund)
3. Market segment     4. Previous cancellations history
5. Special requests (inverse — more requests = lower cancellation risk)
```

### Figures Produced

10 high-resolution figures (130–150 DPI) covering:
KPI card panels · distribution histograms · correlation heatmaps · monthly trend lines ·
cancellation deep-dive composites · revenue bar/line charts · channel bubble charts ·
guest behaviour dual-axis charts · seasonal heatmaps · geographic bubble plots ·
executive dark-themed KPI dashboard

### Predictive Modelling Roadmap (Next Steps)

```
1. Cancellation Prediction Model  →  XGBoost / LightGBM
   Features: lead_time, deposit_type, market_segment, special_requests

2. Revenue Forecasting            →  SARIMA / Prophet (demand planning)

3. Guest Lifetime Value (CLV)     →  RFM-based segmentation

4. Real-time Dashboard            →  Power BI / Tableau integration
```

---

## 📁 Repository Structure

```
├── elite_hotels_analysis.ipynb                  # Full 10-section EDA notebook
├── Hotel_Booking_Data_Analysis_Project.sql      # MySQL DDL + 20+ queries + 3 views + 5 indexes
├── figures/                                     # Exported chart PNGs
│   ├── fig_01_data_quality.png
│   ├── fig_02_distributions.png
│   ├── fig_03_correlation.png
│   ├── fig_04_cancellation.png
│   ├── fig_05_revenue.png
│   ├── fig_06_channels.png
│   ├── fig_07_guest_behavior.png
│   ├── fig_08_seasonal.png
│   ├── fig_09_geography.png
│   └── fig_10_kpi_dashboard.png
└── README.md                                    # This file
```

---

## 🚀 Getting Started

### Prerequisites

```bash
pip install pandas numpy matplotlib seaborn jupyter
```

### Run the Python Notebook

```bash
git clone https://github.com/your-username/elite-hotels-analysis.git
cd elite-hotels-analysis
jupyter notebook elite_hotels_analysis.ipynb
```

> **Note:** Update the CSV path in Section 1 Cell 2 to point to your local copy of `hotel_bookings.csv`. The dataset is available on [Kaggle](https://www.kaggle.com/datasets/jessemostipak/hotel-booking-demand).

### Run the SQL Analysis

1. Open MySQL Workbench (or any MySQL-compatible client).
2. Place `hotel_bookings.csv` in your MySQL uploads directory (see path in the SQL file comments).
3. Run `Hotel_Booking_Data_Analysis_Project.sql` in full — it creates the database, table, loads data, cleans it, runs all queries, and creates views and indexes.

---

## 🤝 Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you'd like to change.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

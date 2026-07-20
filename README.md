# automotive-industry-sql-analysis

An end-to-end SQL data analysis project on automotive industry data — covering sales, dealers, car models, and recall history. Focus on schema design, data cleaning, exploratory analysis, and business-focused insight generation using PostgreSQL.

---

## 📌 Project Overview

This project analyzes automotive industry data spanning car sales (167,934 transactions), dealer performance, car models, and recall history.

**Business problem:** A car dealer needs to decide which car models to prioritize in inventory and sales push, but doesn't currently have visibility into which models are most profitable, best-selling, or carry the most recall risk, because sales, dealer, and recall data live in separate systems.

The workflow includes:

- Multi-table schema design (4 related tables with primary/foreign keys)
- Data Cleaning & Exploratory Data Analysis (EDA)
- SQL Analysis (business-question driven, easy → advanced)
- Honest documentation of data limitations where questions weren't answerable

**Dataset source:** IBM Coursera course dataset (automotive industry sales, dealers, car models, and recall data).

---

## 🛠️ Tools Used

- PostgreSQL

---

## 📁 Project Structure

```
automotive-industry-data-analysis/
│── README.md
│── SQL/
│   └── automotive_analysis.sql
└── Dataset/
    ├── car_sales.csv
    ├── dealers.csv
    ├── car_model.csv
    └── recalls.csv
```
    
---

## 🗄️ Schema

Four related tables, linked by primary/foreign keys:

- **car_model** — car_id (PK), model
- **dealers** — dealer_id (PK), location and contact details
- **car_sales** — sales_id (PK), car_id (FK), dealer_id (FK), sale details + weather conditions at time of sale
- **recalls** — recall_id (PK), car_id (FK), recall_date, system_affected, units affected

`car_sales` is the transactional table; `car_model` and `dealers` are reference/master tables. Verified all foreign keys resolve cleanly with zero unmatched rows before running any analysis.

---

## 🔑 Key Insights

- **Beaufort** is the most recalled model by total units, with **Airbag** issues being its most common recall cause
- **Salish** is the best-selling car model overall, with **106,133** total units sold
- **Northern Auto Sales** leads all dealers in total sales volume
- Dealers selling recalled models mirror the overall top-selling dealer — expected, since **all 5 car models in this dataset have recall history**, so there's no "recall-free" dealer segment to compare against
- Weather has a significant effect on daily sales: average sales drop from **~146–151/day in clear conditions** to just **21–45/day during rain, snow, or fog** — a decline of roughly **70–86%** depending on condition. Fog shows the steepest drop (**86%**, 151.43 → 20.71/day), followed by rain (**84%**, 145.83 → 23.30/day) and snow (**70%**, 147.56 → 44.52/day)
- **March 2019** was the single month with the highest number of recalls; **2018** was the year with the highest recall volume overall

---

## ⚠️ Data Limitations

This project intentionally documents where the data did **not** support a planned business question, rather than forcing a misleading conclusion:

- **Recall-impact-on-sales was not answerable.** Recall records span 2016–2020, while sales records span 2023–2025 — the two time periods don't overlap, so no valid "before vs. after recall" sales comparison could be made.
- **No recall-free comparison group exists.** All 5 car models in this dataset have recall history, so "recall history vs. no recall history" sales comparisons have no baseline to compare against.
- **No variation in recall count across models.** Every model has an identical recall count (26), so recall frequency couldn't be correlated against sales performance.



---

## 📈 SQL Analysis

The SQL project includes:

### Schema & Data Cleaning
- 4-table relational schema with enforced primary/foreign keys
- Row counts, duplicate checks, NULL checks, and distinct-value checks per table
- Join integrity testing to confirm all foreign keys resolve before analysis

### Business Questions Answered
1. Which car model gets the most recalls, and what's the most common issue?
2. Which car model sells the most units overall?
3. Which dealers have the highest total sales?
4. Which dealers sell the highest volume of recalled models?
5. Does weather (rain/snow/fog/temperature) affect daily sales volume?
6. Which month/year had the highest number of recalls?

Full query set: [`SQL/Automotive_industry_sql.sql`](SQL/Automotive_industry_sql.sql)

---

## 🔄 What I'd Improve Next

- Build an interactive Power BI dashboard to visualize sales, dealer, and recall trends
- Bring in a dataset with overlapping recall and sales date ranges to properly test recall impact on sales
- Add a data source with recall-free models to enable a true comparison baseline
- Automate data refresh instead of static import

---

## 📚 Skills Demonstrated

- Relational schema design (primary keys, foreign keys, multi-table joins)
- SQL (aggregation, GROUP BY, window-style comparisons, subqueries, date functions)
- Data Cleaning & EDA across multiple related tables
- Recognizing and documenting real data limitations instead of forcing false conclusions
- Business problem framing and insight communication

---

## 👤 Author

**Ved Chavan**

GitHub: https://github.com/vedchavan

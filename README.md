# UK Online Retail Sales Analysis using SQL

## Project Overview
This project analyzes retail transaction data from a UK-based online retailer to identify sales trends, top-performing products, customer purchasing patterns, and country-wise revenue.

The analysis uses SQL in Microsoft SQL Server Management Studio (SSMS).

## Dataset
- **Source:** [UCI Machine Learning Repository – Online Retail](https://archive.ics.uci.edu/dataset/352/online+retail)
- **Records:** 541,909 transactions
- **Period:** December 2010 – December 2011

The dataset is not included in this repository due to its large file size. Please download it from the original source to reproduce the analysis.

## Tools Used
- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- SQL

## Project Files
- `01_data_validation.sql` – Checks data quality and validates the dataset.
- `02_sales_analysis.sql` – Contains SQL queries for sales and customer analysis.

## Business Questions
1. What is the total revenue generated?
2. How does revenue change month by month?
3. How do monthly sales quantities change?
4. Which products generate the highest revenue?
5. Which countries generate the most revenue?
6. Which products sell the most across meteorological seasons?
7. Which products generate the highest revenue during November and December?
8. Which customers contribute the most revenue?

## Data Cleaning and Limitations
- Converted invoice dates into a usable date format for analysis.
- Excluded cancellation invoices and transactions with non-positive quantities from the main sales analysis.
- Excluded two confirmed fully cancelled transactions from the main analysis to avoid overstating revenue.
- Other potential cancellation-related data quality issues were not fully investigated.
- December 2011 contains data only through December 9, so its figures are incomplete.
- The dataset covers just over one annual cycle; seasonal findings are exploratory and do not establish recurring yearly patterns.

## Key Findings
- **Total revenue analyzed:** £10,398,907.22
- **Highest-revenue month:** November 2011, with £1,509,496.33
- **Top revenue-generating country:** United Kingdom, with £8,757,444.76
- **Top product by revenue:** REGENCY CAKESTAND 3 TIER, with £174,484.74

## Objective
The goal of this project is to practice SQL data validation, date conversion, aggregation, filtering, grouping, and ranking while answering practical retail business questions.

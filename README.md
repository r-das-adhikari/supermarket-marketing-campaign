Supermarket Marketing Campaign Analysis

A end-to-end data analytics capstone project covering Python ETL, SQL Server analysis, and Tableau dashboard design — built as part of the Career 247 Data Analytics Certification Program.


Project Overview

This project analyzes a supermarket's customer marketing campaign data across 2,215 customers with 22 variables including demographics, spending behavior, and campaign responses. The goal is to uncover actionable insights around customer segmentation, channel performance, and marketing effectiveness.


Tech Stack

LayerToolData CleaningPython (pandas)DatabaseSQL Server (SSMS)VisualizationTableau DesktopVersion ControlGitHub


Project Structure

```
supermarket-marketing-campaign/
│
├── data/
│   ├── raw/
│   │   └── marketing_campaign.csv        # Original dataset
│   └── cleaned/
│       └── supermarket_customers.csv     # Cleaned dataset
│
├── python/
│   └── cleaning_pipeline.py             # ETL cleaning pipeline
│
├── sql/
│   └── analysis_queries.sql             # Full SQL analysis script
│
├── tableau/
│   └── supermarket_campaign.twbx        # Packaged Tableau workbook
│
├── assets/
│   ├── dashboard_1_executive.png        # Dashboard screenshots
│   ├── dashboard_2_segmentation.png
│   └── dashboard_3_marketing.png
│
└── README.md
```


Dataset


Source: UCI Machine Learning Repository — Customer Personality Analysis
Rows: 2,215 customers (after cleaning)
Columns: 22 variables
Key fields: Income, Age, Education, Marital Status, Product Spend, Channel Purchases, Campaign Response, Recency



Phase 1 — Python Data Cleaning

Key cleaning steps:


Filled 24 missing Income values with median (mean skewed by $666K outlier)
Removed 8 income outliers via IQR method
Dropped age outliers (Year_Birth=1893 implying 130+ years old)
Consolidated Education into 3 tiers: Graduate, Postgraduate, Undergraduate
Consolidated Marital_Status into 2 groups: Married, Single
Converted Dt_Customer to datetime
Engineered new columns: Age, Tenure_Days, Tenure_Years, Total_Spending, Total_Purchases, Total_Children, Recency_Segment, Response_Number
Dropped ~15 rows with logically inconsistent multi-column behavior


Pipeline architecture:

ingest() → validate() → clean_demographics() → clean_spending()
→ clean_purchases() → engineer_features() → export()

How to run:

bashpip install pandas sqlalchemy pyodbc
python python/cleaning_pipeline.py


Phase 2 — SQL Server Analysis

Database setup:

sqlCREATE DATABASE Supermarket_Campaign_DB;
USE Supermarket_Campaign_DB;

Analysis covers:


Data validation and quality checks
KPI framework (Revenue, Acceptance Rate, AOV, CLV)
Demographic segmentation (Education, Income, Age, Family)
Behavioral drivers (Channel usage, Product preferences)
High-value and at-risk customer identification
Campaign response analysis
BI-ready views for Tableau connection


Views created:

sqlvw_channel_usage
vw_customer_info
vw_spending_profile

How to run:


Open SSMS
Connect to your SQL Server instance
Open sql/analysis_queries.sql
Execute all queries



Phase 3 — Tableau Dashboards

Three interactive dashboards built on a dark navy theme (#0D1B2A) with consistent gold accent (#E0A458).

Dashboard 1 — Executive Overview

<img width="1600" height="900" alt="Dashboard 1" src="https://github.com/user-attachments/assets/8bbe7154-7373-4d0b-ad44-acc9ec82385a" />


Charts:


5 KPI cards with sparklines (Revenue, Acceptance Rate, Customers, Avg Value, AOV)
Revenue by Channel (bar chart)
Recency Segment Distribution (donut chart)
Product Category Spend (lollipop chart)


Key insight: Store channel drives 39% of total revenue. Wines and Meat account for 75% of all product spending.


Dashboard 2 — Customer Segmentation

<img width="1600" height="900" alt="Dashboard 2" src="https://github.com/user-attachments/assets/0519a7ba-180e-4b5e-b0d0-fe095e1290ba" />


Charts:


4 KPI cards with sparklines (Customers, Avg Income, High Value %, Avg Family Size)
Butterfly chart: Education vs Marital Status spend
Income vs Spending scatter plot
Spend by Age Group lollipop
Education × Recency heatmap
Income bracket distribution


Key insight: Graduate customers with higher income ($70K+) contribute disproportionately to total spending. 60+ age group has highest average spend.


Dashboard 3 — Marketing Insights

<img width="1600" height="900" alt="Dashboard 3" src="https://github.com/user-attachments/assets/732a7912-46ce-4d0d-8632-e26e2d69e413" />


Charts:


4 KPI cards with sparklines (Response Rate, Total Purchases, Avg Web Visits, Avg Recency)
Campaign response by Recency Segment
Avg Purchases by Education lollipop
Complain Rate donut
Recency vs Spending scatter plot
Web Visits vs Purchases bar chart
Product Spending by Segment treemap


Key insight: Active customers are 3x more likely to respond to campaigns than Inactive customers (24.26% vs 8.44%). Marketing budget should prioritize Active segment.


Key Findings

InsightDetailTop channelStore ($2.65M — 39% of revenue)Top productWines ($3.40M — 51% of spending)Best campaign targetActive segment (24.26% response rate)High value customers26.95% of customer baseComplaint rate4.51% (low — good customer satisfaction)Avg customer value$3,037 per customer


How to View Dashboards:

Option  — Tableau Desktop


Download tableau/supermarket_campaign.twbx
Open in Tableau Desktop (2022.1 or later)
If prompted for data source, point to data/cleaned/supermarket_customers.csv



Setup Instructions

Prerequisites

Python 3.8+
SQL Server Express (or higher)
Tableau Desktop 2022.1+

Installation

bash# Clone the repository
git clone https://github.com/r-das-adhikari/supermarket-marketing-campaign.git
cd supermarket-marketing-campaign

# Install Python dependencies
pip install -r requirements.txt

# Run cleaning pipeline
python python/cleaning_pipeline.py

# Open SQL script in SSMS and execute
# Then connect Tableau to SQL Server


Author

Ramkrishna
Data Analytics Student — Career 247 Certification Program


License

This project is for educational and portfolio purposes.
Dataset source: UCI Machine Learning Repository

CREATE DATABASE Supermarket_Campaign_DB;
GO
USE Supermarket_Campaign_DB;
GO

SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';
GO

SELECT TOP 10 * FROM dbo.supermarket_customers;
GO
 
 
-- ================================================================================================
-- SECTION 1 : DATA INTEGRITY & VALIDATION
-- ================================================================================================
 
-- 1.1 Total row count
SELECT COUNT(*) AS total_rows
FROM supermarket_customers;
 
-- 1.2 Check unique IDs (should match total rows)
SELECT COUNT(DISTINCT Id) AS unique_ids
FROM supermarket_customers;
 
-- 1.3 Confirm no duplicate IDs
SELECT   Id,
         COUNT(*) AS cnt
FROM     supermarket_customers
GROUP BY Id
HAVING   COUNT(*) > 1;
 
-- 1.4 Check NULLs in required fields
SELECT
    SUM(CASE WHEN Id            IS NULL THEN 1 ELSE 0 END) AS null_id,
    SUM(CASE WHEN Income        IS NULL THEN 1 ELSE 0 END) AS null_income,
    SUM(CASE WHEN Year_Birth    IS NULL THEN 1 ELSE 0 END) AS null_year_birth,
    SUM(CASE WHEN Dt_Customer   IS NULL THEN 1 ELSE 0 END) AS null_dt_customer,
    SUM(CASE WHEN Response      IS NULL THEN 1 ELSE 0 END) AS null_response,
    SUM(CASE WHEN Education     IS NULL THEN 1 ELSE 0 END) AS null_education,
    SUM(CASE WHEN Marital_Status IS NULL THEN 1 ELSE 0 END) AS null_marital_status
FROM supermarket_customers;
 
-- 1.5 Min / Max sanity check on all numeric columns
SELECT
    MIN(Income)           AS min_income,         MAX(Income)           AS max_income,
    MIN(Age)              AS min_age,             MAX(Age)              AS max_age,
    MIN(Recency)          AS min_recency,         MAX(Recency)          AS max_recency,
    MIN(MntWines)         AS min_wines,           MAX(MntWines)         AS max_wines,
    MIN(MntFruits)        AS min_fruits,          MAX(MntFruits)        AS max_fruits,
    MIN(MntMeatProducts)  AS min_meat,            MAX(MntMeatProducts)  AS max_meat,
    MIN(MntFishProducts)  AS min_fish,            MAX(MntFishProducts)  AS max_fish,
    MIN(MntSweetProducts) AS min_sweets,          MAX(MntSweetProducts) AS max_sweets,
    MIN(MntGoldProds)     AS min_gold,            MAX(MntGoldProds)     AS max_gold,
    MIN(Total_Spending)   AS min_total_spend,     MAX(Total_Spending)   AS max_total_spend
FROM supermarket_customers;
 
-- 1.6 Check for negative or zero values in monetary columns

SELECT COUNT(*) AS negative_or_zero_spend_rows
FROM supermarket_customers
WHERE MntWines < 0 OR MntFruits < 0 OR MntMeatProducts < 0
   OR MntFishProducts < 0 OR MntSweetProducts < 0 OR MntGoldProds < 0;
 
-- 1.7 Distinct values in categorical columns

SELECT Education,      COUNT(*) AS cnt FROM supermarket_customers GROUP BY Education;
SELECT Marital_Status, COUNT(*) AS cnt FROM supermarket_customers GROUP BY Marital_Status;
 
-- 1.8 Verify Kidhome / Teenhome range

SELECT
    MIN(Kidhome)  AS min_kids,  MAX(Kidhome)  AS max_kids,
    MIN(Teenhome) AS min_teens, MAX(Teenhome) AS max_teens
FROM supermarket_customers;
 
 
-- ============================================================================================
-- SECTION 2 : KPI FRAMEWORK
-- ============================================================================================
 
-- 2.1 Overall campaign KPIs
--   KPIs : response rate, avg spend, recency, avg income,
--                avg web/store/catalog purchases, complaint rate

SELECT
    COUNT(*)                                                    AS total_customers,
    ROUND(AVG(CAST(Response AS FLOAT)) * 100, 2)               AS response_rate_pct,
    ROUND(AVG(Income), 2)                                       AS avg_income,
    ROUND(AVG(Total_Spending), 2)                               AS avg_total_spend,
    ROUND(SUM(Total_Spending), 2)                               AS total_revenue,
    ROUND(AVG(Recency), 2)                                      AS avg_recency_days,
    ROUND(AVG(CAST(Complain AS FLOAT)) * 100, 2)               AS complaint_rate_pct,
    ROUND(AVG(CAST(NumWebPurchases     AS FLOAT)), 2)           AS avg_web_purchases,
    ROUND(AVG(CAST(NumStorePurchases   AS FLOAT)), 2)           AS avg_store_purchases,
    ROUND(AVG(CAST(NumCatalogPurchases AS FLOAT)), 2)           AS avg_catalog_purchases
FROM supermarket_customers;
 
-- 2.2 Total spend by product category
--    Total and average customer spend (sum of MntWines, MntMeatProducts ...)
SELECT
    ROUND(SUM(MntWines),         2) AS total_wines,
    ROUND(SUM(MntFruits),        2) AS total_fruits,
    ROUND(SUM(MntMeatProducts),  2) AS total_meat,
    ROUND(SUM(MntFishProducts),  2) AS total_fish,
    ROUND(SUM(MntSweetProducts), 2) AS total_sweets,
    ROUND(SUM(MntGoldProds),     2) AS total_gold
FROM supermarket_customers;
 
-- 2.3 Average spend by product category
SELECT
    ROUND(AVG(MntWines),         2) AS avg_wines,
    ROUND(AVG(MntFruits),        2) AS avg_fruits,
    ROUND(AVG(MntMeatProducts),  2) AS avg_meat,
    ROUND(AVG(MntFishProducts),  2) AS avg_fish,
    ROUND(AVG(MntSweetProducts), 2) AS avg_sweets,
    ROUND(AVG(MntGoldProds),     2) AS avg_gold
FROM supermarket_customers;
 
-- 2.4 Category penetration rate
SELECT
    ROUND(AVG(CASE WHEN MntWines         > 0 THEN 1.0 ELSE 0 END) * 100, 2) AS wine_penetration_pct,
    ROUND(AVG(CASE WHEN MntFruits        > 0 THEN 1.0 ELSE 0 END) * 100, 2) AS fruit_penetration_pct,
    ROUND(AVG(CASE WHEN MntMeatProducts  > 0 THEN 1.0 ELSE 0 END) * 100, 2) AS meat_penetration_pct,
    ROUND(AVG(CASE WHEN MntFishProducts  > 0 THEN 1.0 ELSE 0 END) * 100, 2) AS fish_penetration_pct,
    ROUND(AVG(CASE WHEN MntSweetProducts > 0 THEN 1.0 ELSE 0 END) * 100, 2) AS sweet_penetration_pct,
    ROUND(AVG(CASE WHEN MntGoldProds     > 0 THEN 1.0 ELSE 0 END) * 100, 2) AS gold_penetration_pct
FROM supermarket_customers;
 
-- 2.5 Purchase channel usage averages
--    average number of web/store/catalog purchases
SELECT
    ROUND(AVG(NumDealsPurchases),   2) AS avg_deals,
    ROUND(AVG(NumWebPurchases),     2) AS avg_web,
    ROUND(AVG(NumCatalogPurchases), 2) AS avg_catalog,
    ROUND(AVG(NumStorePurchases),   2) AS avg_store,
    ROUND(AVG(NumWebVisitsMonth),   2) AS avg_web_visits
FROM supermarket_customers;
 
 
-- ================================================================================================
-- SECTION 3 : DEMOGRAPHIC SEGMENTATION
-- Segment customers based on age, education, income, marital status, household composition
-- ================================================================================================
 
-- 3.1 Response rate and spend by Education
--      compare Response by education level
SELECT
    Education,
    COUNT(*)                                                AS total_customers,
    SUM(CAST(Response AS INT))                              AS accepted,
    ROUND(AVG(CAST(Response AS FLOAT)) * 100, 2)           AS response_rate_pct,
    ROUND(AVG(Income), 2)                                   AS avg_income,
    ROUND(AVG(Total_Spending), 2)                           AS avg_spend
FROM     supermarket_customers
GROUP BY Education
ORDER BY response_rate_pct DESC;
 
-- 3.2 Response rate and spend by Marital Status
SELECT
    Marital_Status,
    COUNT(*)                                                AS total_customers,
    SUM(CAST(Response AS FLOAT))                            AS accepted,
    ROUND(AVG(CAST(Response AS FLOAT)) * 100, 2)           AS response_rate_pct,
    ROUND(AVG(Income), 2)                                   AS avg_income,
    ROUND(AVG(Total_Spending), 2)                           AS avg_spend
FROM     supermarket_customers
GROUP BY Marital_Status
ORDER BY response_rate_pct DESC;
 
-- 3.3 Response rate and spend by Age Group
--     Segment customers based on age (derived from Year_Birth)
SELECT
    CASE
        WHEN Age BETWEEN 18 AND 35 THEN '18-35 Young'
        WHEN Age BETWEEN 36 AND 50 THEN '36-50 Middle'
        WHEN Age BETWEEN 51 AND 65 THEN '51-65 Senior'
        ELSE '65+ Elder'
    END                                                     AS age_group,
    COUNT(*)                                                AS total_customers,
    SUM(CAST(Response AS FLOAT))                            AS accepted,
    ROUND(AVG(CAST(Response AS FLOAT)) * 100, 2)           AS response_rate_pct,
    ROUND(AVG(Income), 2)                                   AS avg_income,
    ROUND(AVG(Total_Spending), 2)                           AS avg_spend
FROM supermarket_customers
GROUP BY
    CASE
        WHEN Age BETWEEN 18 AND 35 THEN '18-35 Young'
        WHEN Age BETWEEN 36 AND 50 THEN '36-50 Middle'
        WHEN Age BETWEEN 51 AND 65 THEN '51-65 Senior'
        ELSE '65+ Elder'
    END
ORDER BY response_rate_pct DESC;
 
-- 3.4 Response rate and spend by Income Bracket
--     income brackets (Income) as a segment cut
SELECT
    CASE
        WHEN Income <  30000 THEN 'Low (<30k)'
        WHEN Income <  60000 THEN 'Mid (30k-60k)'
        WHEN Income <  90000 THEN 'High (60k-90k)'
        ELSE                      'Very High (90k+)'
    END                                                     AS income_bracket,
    COUNT(*)                                                AS total_customers,
    SUM(CAST(Response AS FLOAT))                            AS accepted,
    ROUND(AVG(CAST(Response AS FLOAT)) * 100, 2)           AS response_rate_pct,
    ROUND(AVG(Total_Spending), 2)                           AS avg_spend
FROM supermarket_customers
GROUP BY
    CASE
        WHEN Income <  30000 THEN 'Low (<30k)'
        WHEN Income <  60000 THEN 'Mid (30k-60k)'
        WHEN Income <  90000 THEN 'High (60k-90k)'
        ELSE                      'Very High (90k+)'
    END
ORDER BY response_rate_pct DESC;
 
-- 3.5 Household composition — Kidhome and Teenhome separately
--      Household composition (Kidhome, Teenhome) as segment cuts
--      Households with teenagers are significantly underrepresented among respondents
SELECT
    Kidhome,
    Teenhome,
    COUNT(*)                                                AS total_customers,
    ROUND(AVG(CAST(Response AS FLOAT)) * 100, 2)           AS response_rate_pct,
    ROUND(AVG(Total_Spending), 2)                           AS avg_spend,
    ROUND(AVG(Income), 2)                                   AS avg_income
FROM     supermarket_customers
GROUP BY Kidhome, Teenhome
ORDER BY response_rate_pct DESC;
 
-- 3.6 Households with teenagers vs without
--      Households with teenagers are significantly underrepresented among respondents
SELECT
    CASE WHEN Teenhome > 0 THEN 'Has Teenagers' ELSE 'No Teenagers' END AS teen_status,
    COUNT(*)                                                AS total_customers,
    SUM(CAST(Response AS FLOAT))                                           AS accepted,
    ROUND(AVG(CAST(Response AS FLOAT)) * 100, 2)           AS response_rate_pct,
    ROUND(AVG(Total_Spending), 2)                           AS avg_spend
FROM supermarket_customers
GROUP BY CASE WHEN Teenhome > 0 THEN 'Has Teenagers' ELSE 'No Teenagers' END;
 
-- 3.7 Customer tenure segments
--      customer tenure (Dt_Customer) as a segment cut
SELECT
    CASE
        WHEN Tenure_Years <= 1 THEN 'New (0-1 yr)'
        WHEN Tenure_Years <= 3 THEN 'Growing (1-3 yrs)'
        WHEN Tenure_Years <= 5 THEN 'Established (3-5 yrs)'
        ELSE                        'Loyal (5+ yrs)'
    END                                                     AS tenure_group,
    COUNT(*)                                                AS total_customers,
    SUM(CAST(Response AS FLOAT))                                           AS accepted,
    ROUND(AVG(CAST(Response AS FLOAT)) * 100, 2)           AS response_rate_pct,
    ROUND(AVG(Total_Spending), 2)                           AS avg_spend,
    ROUND(AVG(Income), 2)                                   AS avg_income
FROM supermarket_customers
GROUP BY
    CASE
        WHEN Tenure_Years <= 1 THEN 'New (0-1 yr)'
        WHEN Tenure_Years <= 3 THEN 'Growing (1-3 yrs)'
        WHEN Tenure_Years <= 5 THEN 'Established (3-5 yrs)'
        ELSE                        'Loyal (5+ yrs)'
    END
ORDER BY response_rate_pct DESC;
 
 
-- ============================================================
-- SECTION 4 : BEHAVIOURAL DRIVERS & SPENDING ANALYSIS
--     Explore behavioural drivers such as recency, product category spend, and channel usage
-- ============================================================
 
-- 4.1 Spending and response by Recency Segment
--       recency of purchase (Recency) as a KPI and segment cut
SELECT
    Recency_Segment,
    COUNT(*)                                                AS total_customers,
    ROUND(AVG(Total_Spending), 2)                           AS avg_spend,
    ROUND(AVG(Income), 2)                                   AS avg_income,
    ROUND(AVG(CAST(Response AS FLOAT)) * 100, 2)           AS response_rate_pct
FROM     supermarket_customers
GROUP BY Recency_Segment
ORDER BY avg_spend DESC;
 
-- 4.2 Repeat purchase proxy — high web visits with low recency
SELECT
    Recency_Segment,
    CASE
        WHEN NumWebVisitsMonth >= 7 THEN 'High Visits (7+)'
        WHEN NumWebVisitsMonth >= 4 THEN 'Mid Visits (4-6)'
        ELSE                             'Low Visits (0-3)'
    END                                                     AS visit_group,
    COUNT(*)                                                AS total_customers,
    ROUND(AVG(CAST(Response AS FLOAT)) * 100, 2)           AS response_rate_pct,
    ROUND(AVG(Total_Spending), 2)                           AS avg_spend
FROM supermarket_customers
GROUP BY
    Recency_Segment,
    CASE
        WHEN NumWebVisitsMonth >= 7 THEN 'High Visits (7+)'
        WHEN NumWebVisitsMonth >= 4 THEN 'Mid Visits (4-6)'
        ELSE                             'Low Visits (0-3)'
    END
ORDER BY response_rate_pct DESC;
 
-- 4.3 Channel usage by responders vs non-responders
--     compare Response by number of web purchases
--     channel usage (web, store, catalogue, discounted purchases)
SELECT
    Response,
    ROUND(AVG(NumWebPurchases),     2) AS avg_web_purchases,
    ROUND(AVG(NumStorePurchases),   2) AS avg_store_purchases,
    ROUND(AVG(NumCatalogPurchases), 2) AS avg_catalog_purchases,
    ROUND(AVG(NumDealsPurchases),   2) AS avg_deal_purchases,
    ROUND(AVG(NumWebVisitsMonth),   2) AS avg_web_visits,
    ROUND(AVG(Total_Spending),      2) AS avg_spend
FROM     supermarket_customers
GROUP BY Response;
 
-- 4.4 Category penetration by responders vs non-responders
--      Summarise category-level contribution to total spend"
SELECT
    Response,
    ROUND(AVG(CASE WHEN MntWines         > 0 THEN 1.0 ELSE 0 END) * 100, 2) AS wine_pct,
    ROUND(AVG(CASE WHEN MntFruits        > 0 THEN 1.0 ELSE 0 END) * 100, 2) AS fruit_pct,
    ROUND(AVG(CASE WHEN MntMeatProducts  > 0 THEN 1.0 ELSE 0 END) * 100, 2) AS meat_pct,
    ROUND(AVG(CASE WHEN MntFishProducts  > 0 THEN 1.0 ELSE 0 END) * 100, 2) AS fish_pct,
    ROUND(AVG(CASE WHEN MntSweetProducts > 0 THEN 1.0 ELSE 0 END) * 100, 2) AS sweet_pct,
    ROUND(AVG(CASE WHEN MntGoldProds     > 0 THEN 1.0 ELSE 0 END) * 100, 2) AS gold_pct,
    ROUND(AVG(MntWines),         2)                                           AS avg_wine_spend,
    ROUND(AVG(MntMeatProducts),  2)                                           AS avg_meat_spend,
    ROUND(AVG(MntFishProducts),  2)                                           AS avg_fish_spend,
    ROUND(AVG(MntFruits),        2)                                           AS avg_fruit_spend,
    ROUND(AVG(MntSweetProducts), 2)                                           AS avg_sweet_spend,
    ROUND(AVG(MntGoldProds),     2)                                           AS avg_gold_spend
FROM     supermarket_customers
GROUP BY Response;
 
-- 4.5 Category breadth — how many categories each customer buys from
SELECT
    category_breadth,
    COUNT(*)                                                AS total_customers,
    ROUND(AVG(Total_Spending), 2)                           AS avg_spend,
    ROUND(AVG(CAST(Response AS FLOAT)) * 100, 2)           AS response_rate_pct
FROM (
    SELECT *,
        (CASE WHEN MntWines         > 0 THEN 1 ELSE 0 END +
         CASE WHEN MntFruits        > 0 THEN 1 ELSE 0 END +
         CASE WHEN MntMeatProducts  > 0 THEN 1 ELSE 0 END +
         CASE WHEN MntFishProducts  > 0 THEN 1 ELSE 0 END +
         CASE WHEN MntSweetProducts > 0 THEN 1 ELSE 0 END +
         CASE WHEN MntGoldProds     > 0 THEN 1 ELSE 0 END) AS category_breadth
    FROM supermarket_customers
) t
GROUP BY category_breadth
ORDER BY category_breadth;
 
-- 4.6 Cross-sell segments by category breadth
--      customers who spend across multiple product categories
SELECT
    CASE
        WHEN category_breadth >= 5 THEN 'Multi Category (5-6)'
        WHEN category_breadth >= 3 THEN 'Mid Category (3-4)'
        ELSE                             'Single Category (1-2)'
    END                                                     AS cross_sell_segment,
    COUNT(*)                                                AS total_customers,
    ROUND(AVG(Total_Spending), 2)                           AS avg_spend,
    ROUND(AVG(CAST(Response AS FLOAT)) * 100, 2)           AS response_rate_pct,
    ROUND(AVG(Income), 2)                                   AS avg_income
FROM (
    SELECT *,
        (CASE WHEN MntWines         > 0 THEN 1 ELSE 0 END +
         CASE WHEN MntFruits        > 0 THEN 1 ELSE 0 END +
         CASE WHEN MntMeatProducts  > 0 THEN 1 ELSE 0 END +
         CASE WHEN MntFishProducts  > 0 THEN 1 ELSE 0 END +
         CASE WHEN MntSweetProducts > 0 THEN 1 ELSE 0 END +
         CASE WHEN MntGoldProds     > 0 THEN 1 ELSE 0 END) AS category_breadth
    FROM supermarket_customers
) t
GROUP BY
    CASE
        WHEN category_breadth >= 5 THEN 'Multi Category (5-6)'
        WHEN category_breadth >= 3 THEN 'Mid Category (3-4)'
        ELSE                             'Single Category (1-2)'
    END
ORDER BY response_rate_pct DESC;
 
-- 4.7 Complaint impact on response and spending
--      complaint rate (Complain) listed as a KPI
SELECT
    Complain,
    COUNT(*)                                                AS total_customers,
    ROUND(AVG(CAST(Response AS FLOAT)) * 100, 2)           AS response_rate_pct,
    ROUND(AVG(Total_Spending), 2)                           AS avg_spend,
    ROUND(AVG(Income), 2)                                   AS avg_income
FROM     supermarket_customers
GROUP BY Complain;
 
-- 4.8 Complaint rate by Education segment
--      complaint rate as KPI + Education as segment cut
SELECT
    Education,
    COUNT(*)                                                AS total_customers,
    SUM(CAST(Complain AS FLOAT))                            AS total_complaints,
    ROUND(AVG(CAST(Complain  AS FLOAT)) * 100, 2)          AS complaint_rate_pct,
    ROUND(AVG(CAST(Response  AS FLOAT)) * 100, 2)          AS response_rate_pct
FROM     supermarket_customers
GROUP BY Education
ORDER BY complaint_rate_pct DESC;
 
 
-- ================================================================================================
-- SECTION 5 : HIGH-VALUE & AT-RISK SEGMENT IDENTIFICATION
-- ================================================================================================
 
-- 5.1 High-value customers — top 10% spenders

SELECT TOP 10 PERCENT
    Id, Age, Education, Marital_Status,
    Income, Total_Spending, Response, Recency_Segment
FROM     supermarket_customers
ORDER BY Total_Spending DESC;
 
-- 5.2 At-risk customers — high recency and low spend
SELECT
    COUNT(*)                                                AS at_risk_customers,
    ROUND(AVG(Total_Spending), 2)                           AS avg_spend,
    ROUND(AVG(Income), 2)                                   AS avg_income,
    SUM(CAST(Response AS FLOAT))                             AS accepted_membership
FROM supermarket_customers
WHERE Recency > 60
  AND Total_Spending < 100;
 
-- 5.3 Underpenetrated segment — older high spenders with low online engagement

SELECT
    COUNT(*)                                                AS underpenetrated_count,
    ROUND(AVG(Age), 1)                                      AS avg_age,
    ROUND(AVG(Total_Spending), 2)                           AS avg_spend,
    ROUND(AVG(Income), 2)                                   AS avg_income,
    ROUND(AVG(CAST(Response AS FLOAT)) * 100, 2)           AS response_rate_pct
FROM supermarket_customers
WHERE Age             > 55
  AND Total_Spending  > 500
  AND NumWebPurchases <= 2;
 
-- 5.4 High income + web active segment
--     Customers with income above $60k and at least three web purchases
--            have a 30% higher likelihood of accepting the membership
SELECT
    CASE
        WHEN Income > 60000 AND NumWebPurchases >= 3 THEN 'High Income + Web Active'
        WHEN Income > 60000 AND NumWebPurchases <  3 THEN 'High Income + Web Inactive'
        WHEN Income <=60000 AND NumWebPurchases >= 3 THEN 'Low Income + Web Active'
        ELSE                                              'Low Income + Web Inactive'
    END                                                     AS customer_segment,
    COUNT(*)                                                AS total_customers,
    ROUND(AVG(CAST(Response AS FLOAT)) * 100, 2)           AS response_rate_pct,
    ROUND(AVG(Total_Spending), 2)                           AS avg_spend
FROM supermarket_customers
GROUP BY
    CASE
        WHEN Income > 60000 AND NumWebPurchases >= 3 THEN 'High Income + Web Active'
        WHEN Income > 60000 AND NumWebPurchases <  3 THEN 'High Income + Web Inactive'
        WHEN Income <=60000 AND NumWebPurchases >= 3 THEN 'Low Income + Web Active'
        ELSE                                              'Low Income + Web Inactive'
    END
ORDER BY response_rate_pct DESC;
 
 
-- ================================================================================================
-- SECTION 6 : CUSTOMER PROFILE SUMMARY
--  Develop customer profiles: loyal high spenders, bargain hunters,
--        digital shoppers, and dormant or at-risk customers
-- ================================================================================================
 
-- 6.1 Individual profile counts
--     loyal high spenders
SELECT COUNT(*) AS loyal_high_spenders
FROM supermarket_customers
WHERE Total_Spending > 1000
  AND (NumStorePurchases + NumWebPurchases) > 10;
 
--     bargain hunters (many deals purchases)
SELECT COUNT(*) AS bargain_hunters
FROM supermarket_customers
WHERE NumDealsPurchases >= 5;
 
--    digital shoppers (frequent web visits)
SELECT COUNT(*) AS digital_shoppers
FROM supermarket_customers
WHERE NumWebPurchases   >= 6
  AND NumWebVisitsMonth >= 5;
 
--     dormant or at-risk customers (high recency and low spend)
SELECT COUNT(*) AS dormant_customers
FROM supermarket_customers
WHERE Recency_Segment = 'Inactive'
  AND Total_Spending  < 200;
 
-- 6.2 Full profile comparison — response rate and spend per profile
SELECT
    CASE
        WHEN Total_Spending > 1000
             AND (NumStorePurchases + NumWebPurchases) > 10 THEN 'Loyal High Spender'
        WHEN NumDealsPurchases >= 5                         THEN 'Bargain Hunter'
        WHEN NumWebPurchases   >= 6
             AND NumWebVisitsMonth >= 5                     THEN 'Digital Shopper'
        WHEN Recency_Segment = 'Inactive'
             AND Total_Spending < 200                       THEN 'Dormant'
        ELSE                                                     'Regular'
    END                                                     AS customer_profile,
    COUNT(*)                                                AS total_customers,
    ROUND(AVG(Income), 2)                                   AS avg_income,
    ROUND(AVG(Total_Spending), 2)                           AS avg_spend,
    ROUND(AVG(CAST(Response AS FLOAT)) * 100, 2)           AS response_rate_pct
FROM supermarket_customers
GROUP BY
    CASE
        WHEN Total_Spending > 1000
             AND (NumStorePurchases + NumWebPurchases) > 10 THEN 'Loyal High Spender'
        WHEN NumDealsPurchases >= 5                         THEN 'Bargain Hunter'
        WHEN NumWebPurchases   >= 6
             AND NumWebVisitsMonth >= 5                     THEN 'Digital Shopper'
        WHEN Recency_Segment = 'Inactive'
             AND Total_Spending < 200                       THEN 'Dormant'
        ELSE                                                     'Regular'
    END
ORDER BY response_rate_pct DESC;
 
 
-- ================================================================================================
-- SECTION 7 : OPTIONAL VIEWS FOR POWER BI / TABLEAU
--  Create dimension-like views such as customer_info,
--        spending_profile, and channel_usage
-- ================================================================================================
 
-- 7.1 Customer info view — demographics and tenure
CREATE VIEW vw_customer_info AS
SELECT
    Id, Age, Education, Marital_Status,
    Income, Kidhome, Teenhome, Total_Children,
    Tenure_Days, Tenure_Years,
    Recency, Recency_Segment
FROM supermarket_customers;
 
-- 7.2 Spending profile view — all spend columns plus total
CREATE VIEW vw_spending_profile AS
SELECT
    Id,
    MntWines, MntFruits, MntMeatProducts,
    MntFishProducts, MntSweetProducts, MntGoldProds,
    Total_Spending, Response
FROM supermarket_customers;
 
-- 7.3 Channel usage view — all purchase count columns
CREATE VIEW vw_channel_usage AS
SELECT
    Id,
    NumDealsPurchases, NumWebPurchases,
    NumCatalogPurchases, NumStorePurchases,
    NumWebVisitsMonth, Total_Purchases
FROM supermarket_customers;

-- ================================================================================================
--                   END OF ANALYSIS
-- ================================================================================================
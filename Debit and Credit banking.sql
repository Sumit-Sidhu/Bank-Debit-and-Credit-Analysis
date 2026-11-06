SELECT * FROM credit_debit_analysis.`debit and credit banking`;
SELECT COUNT(*) as Total_Rows 
FROM `credit_debit_analysis`.`debit and credit banking`;

#--5 KPI QUERIES--

#1. TOTAL CREDIT AMOUNT
SELECT CONCAT(ROUND(SUM(Amount)/1000,1),'K') as Total_Credit_Amount_K
FROM `credit_debit_analysis`.`debit and credit banking`
WHERE `Transaction Type` = 'Credit';

#2. TOTAL DEBIT AMOUNT
SELECT CONCAT(ROUND(SUM(Amount)/1000,1),'K') as Total_Debit_Amount_K
FROM `credit_debit_analysis`.`debit and credit banking`
WHERE `Transaction Type` = 'Debit';

#3. CREDIT TO DEBIT RATIO
SELECT CONCAT(ROUND(
SUM(CASE WHEN `Transaction Type`='Credit' THEN Amount ELSE 0 END) / 
SUM(CASE WHEN `Transaction Type`='Debit' THEN Amount ELSE 0 END) * 100,0),'%') as Credit_To_Debit_Ratio
FROM `credit_debit_analysis`.`debit and credit banking`;

#4. NET TRANSACTION AMOUNT
SELECT CONCAT(ROUND((SUM(CASE WHEN `Transaction Type`='Credit' THEN Amount ELSE 0 END) - 
SUM(CASE WHEN `Transaction Type`='Debit' THEN Amount ELSE 0 END))/1000,1),'K') as Net_Amount
FROM `credit_debit_analysis`.`debit and credit banking`;

#5. ACCOUNT ACTIVITY RATIO
SELECT CONCAT(ROUND(COUNT(DISTINCT `Account Number`)*100.0 / COUNT(*),3),'%') as Account_Activity_Ratio
FROM `credit_debit_analysis`.`debit and credit banking`;


#--7 CHARTS QUERIES--

#Chart 1: TRANSACTIONS PER MONTH 
SELECT 
  MONTHNAME(STR_TO_DATE(`Transaction Date`, '%Y-%m-%d')) as Month, 
  MONTH(STR_TO_DATE(`Transaction Date`, '%Y-%m-%d')) as month_no, 
  COUNT(*) as total_transactions
FROM `credit_debit_analysis`.`debit and credit banking`
GROUP BY MONTH(STR_TO_DATE(`Transaction Date`, '%Y-%m-%d')), MONTHNAME(STR_TO_DATE(`Transaction Date`, '%Y-%m-%d'))
ORDER BY month_no;

#Chart 2: TOTAL TRANSACTION AMOUNT BY BRANCH 
SELECT Branch, SUM(Amount) as total_amount
FROM `credit_debit_analysis`.`debit and credit banking`
GROUP BY Branch ORDER BY total_amount DESC;

#Chart 3: TRANSACTION METHOD DISTRIBUTION
SELECT `Transaction Method`, SUM(Amount) as total_amount
FROM `credit_debit_analysis`.`debit and credit banking`
GROUP BY `Transaction Method`;

#Chart 4: TRANSACTION VOLUME BY BANK
SELECT `Bank Name`, SUM(Amount) as total_volume
FROM `credit_debit_analysis`.`debit and credit banking`
GROUP BY `Bank Name` ORDER BY total_volume DESC;

#Chart 5: HIGH RISK TRANSACTION FLAG 
SELECT `Transaction Type`, COUNT(*) as count
FROM `credit_debit_analysis`.`debit and credit banking`
GROUP BY `Transaction Type`;

#Chart 6: SUSPICIOUS TRANSACTION FREQUENCY
SELECT 
  MONTHNAME(STR_TO_DATE(`Transaction Date`, '%Y-%m-%d')) as Month, 
  MONTH(STR_TO_DATE(`Transaction Date`, '%Y-%m-%d')) as m_no, 
  COUNT(*) as suspicious_freq
FROM `credit_debit_analysis`.`debit and credit banking`
WHERE Amount > 8000
GROUP BY MONTH(STR_TO_DATE(`Transaction Date`, '%Y-%m-%d')), MONTHNAME(STR_TO_DATE(`Transaction Date`, '%Y-%m-%d'))
ORDER BY m_no;

#Chart 7: BRANCH TRANSACTION GROWTH
WITH monthly_data AS (
  SELECT Branch, DATE_FORMAT(`Transaction Date`, '%Y-%m') as ym, SUM(Amount) as total
  FROM `credit_debit_analysis`.`debit and credit banking`
  GROUP BY Branch, ym
)
SELECT Branch, ym, total,
LAG(total) OVER (PARTITION BY Branch ORDER BY ym) as prev_month_total,
ROUND((total - LAG(total) OVER (PARTITION BY Branch ORDER BY ym)) / LAG(total) OVER (PARTITION BY Branch ORDER BY ym) * 100,2) as growth_pct
FROM monthly_data;

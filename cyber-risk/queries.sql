SELECT Min(total_loss_usd)AS min_loss,
Max(total_loss_usd)AS max_loss,
Round(Avg(total_loss_usd), 2) AS avg_loss
FROM financial_impact; 

SELECT t2.attack_vector_primary AS attack_type,
Round(Avg(t1.total_loss_usd), 2) AS avg_total_loss
FROM   financial_impact AS t1
JOIN incidents_master_clean AS t2
ON t1.incident_id = t2.incident_id
GROUP BY 1
ORDER BY 2 DESC; 

SELECT CASE
WHEN t1.company_revenue_usd < 10000000 THEN 'Small under $10M'
WHEN t1.company_revenue_usd < 100000000 THEN 'Medium $10M - $100M'
WHEN t1.company_revenue_usd < 1000000000 THEN 'Large $100M - $1B'
ELSE 'Enterprise over $1B'
end AS revenue_bucket,
Count(*) AS incident_count,
Round(Avg(t2.total_loss_usd), 2) AS avg_total_loss
FROM financial_impact t2
JOIN incidents_master_clean t1
ON t2.incident_id = t1.incident_id
GROUP BY revenue_bucket
ORDER BY revenue_bucket;

SELECT t3.industry_name,
Round(Avg(t1.total_loss_usd), 2) AS avg_total_loss
FROM financial_impact AS t1
JOIN incidents_master_clean AS t2
ON t1.incident_id = t2.incident_id
JOIN naics_industry_lookup AS t3
ON t2.industry_primary = t3.code
GROUP BY t3.industry_name
ORDER BY avg_total_loss DESC; 

SELECT t1.industry_name,
Round(Avg(t2.insurance_payout_usd / Nullif(t2.total_loss_usd, 0) * 100), 2)
AS avg_coverage_pct
FROM financial_impact AS t2
JOIN incidents_master_clean AS t3
ON t2.incident_id = t2.incident_id
JOIN naics_industry_lookup AS t1
ON t2.industry_primary = t3.code
GROUP BY t1.industry_name
ORDER BY avg_coverage_pct DESC; 

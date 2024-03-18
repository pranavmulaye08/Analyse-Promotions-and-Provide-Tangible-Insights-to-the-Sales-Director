#Q4
SELECT 
    dp.category,
    (SUM(fe.quantity_sold_after_promo) - SUM(fe.quantity_sold_before_promo)) / SUM(fe.quantity_sold_before_promo) * 100 AS isu_percentage,
    RANK() OVER (ORDER BY (SUM(fe.quantity_sold_after_promo) - SUM(fe.quantity_sold_before_promo)) / SUM(fe.quantity_sold_before_promo) DESC) AS rank_order
FROM 
    fact_events fe
JOIN 
    dim_products dp ON fe.product_code = dp.product_code
JOIN 
    dim_campaigns dc ON fe.campaign_id = dc.campaign_id
WHERE 
    dc.campaign_name = 'Diwali'
GROUP BY 
    dp.category
ORDER BY 
    isu_percentage DESC;
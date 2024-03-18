#Q3
SELECT 
    dc.campaign_name,
    SUM(fe.base_price * fe.quantity_sold_before_promo) / 1000000 AS total_revenue_before_promotion_millions,
	Sum(
		CASE
			WHEN fe.promo_type = '25% OFF' THEN (fe.base_price - (fe.base_price * 0.25)) * fe.quantity_sold_after_promo
            WHEN fe.promo_type = '33% OFF' THEN (fe.base_price - (fe.base_price * 0.33)) * fe.quantity_sold_after_promo
            WHEN fe.promo_type = '50% OFF' THEN (fe.base_price - (fe.base_price * 0.50)) * fe.quantity_sold_after_promo
            WHEN fe.promo_type = 'BOGOF' THEN (fe.base_price - (fe.base_price * 0.50)) * fe.quantity_sold_after_promo
            WHEN fe.promo_type = '500 Cashback' THEN (fe.base_price - 500) * fe.quantity_sold_after_promo
            -- ELSE fe.base_price * fe.quantity_sold_after_promo -- Default case if none of the above conditions are met
        END
    ) / 1000000 AS total_revenue_after_promotion_millions
FROM 
    fact_events fe
JOIN 
    dim_campaigns dc ON fe.campaign_id = dc.campaign_id
GROUP BY 
    dc.campaign_name;
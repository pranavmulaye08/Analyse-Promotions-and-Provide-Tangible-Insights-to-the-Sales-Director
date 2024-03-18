# Q1
Select fe.product_code,fe.base_price From fact_events fe
JOIN dim_products dp ON fe.product_code=dp.product_code
WHERE fe.base_price>500 and fe.promo_type="BOGOF";
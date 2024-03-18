WITH RevenueCalculations AS (
    SELECT
        fe.event_id,
        dp.product_name,
        fe.promo_type,
        fe.base_price,
        fe.quantity_sold_after_promo,
        fe.quantity_sold_before_promo,
        -- Calculate adjusted quantity sold considering BOGOF promotion
        CASE WHEN fe.promo_type = 'BOGOF' THEN fe.quantity_sold_after_promo * 2 ELSE fe.quantity_sold_after_promo END AS adjusted_quantity_sold,
        -- Calculate Before Revenue
        fe.base_price * fe.quantity_sold_before_promo AS Before_Revenue
    FROM
        fact_events fe
    JOIN dim_products dp ON fe.product_code = dp.product_code
), DiscountsAndRevenue AS (
    SELECT
        event_id,
        product_name,
        promo_type,
        base_price,
        quantity_sold_after_promo,
        quantity_sold_before_promo,
        adjusted_quantity_sold,
        Before_Revenue,
        -- Calculate Total Discount based on promo_type and adjusted quantity
        CASE
            WHEN promo_type = '25% OFF' THEN base_price * 0.25 * adjusted_quantity_sold
            WHEN promo_type = '50% OFF' THEN base_price * 0.50 * adjusted_quantity_sold
            WHEN promo_type = '33% OFF' THEN base_price * 0.33 * adjusted_quantity_sold
            WHEN promo_type = 'BOGOF' THEN quantity_sold_after_promo * base_price -- Since adjusted quantity already accounts for BOGOF
            WHEN promo_type = '500 Cashback' THEN 500 * quantity_sold_after_promo
            ELSE 0
        END AS Total_Discount
    FROM RevenueCalculations
), FinalCalculations AS (
    SELECT
        event_id,
        product_name,
        Before_Revenue,
        -- Calculate Revenue After Discount
        (base_price * adjusted_quantity_sold) - Total_Discount AS Revenue_After,
        -- Calculate Incremental Revenue
        ((base_price * adjusted_quantity_sold) - Total_Discount) - Before_Revenue AS Incremental_Revenue,
        -- Calculate IR% as numeric for ranking
        CASE
            WHEN Before_Revenue > 0 THEN (((base_price * adjusted_quantity_sold) - Total_Discount - Before_Revenue) / Before_Revenue * 100)
            ELSE NULL
        END AS IR_Percentage
    FROM DiscountsAndRevenue
), RankedCalculations AS (
    SELECT
        event_id,
        product_name,
        Before_Revenue,
        Revenue_After,
        Incremental_Revenue,
        IR_Percentage,
        RANK() OVER (ORDER BY IR_Percentage DESC) AS IR_Rank
    FROM FinalCalculations
)
SELECT
    event_id,
    product_name,
    Before_Revenue,
    Revenue_After AS After_Revenue,
    Incremental_Revenue,
    CONCAT(ROUND(IR_Percentage, 2), '%') AS IR_Percentage,
    IR_Rank
FROM
    RankedCalculations
WHERE
    IR_Rank <= 5;

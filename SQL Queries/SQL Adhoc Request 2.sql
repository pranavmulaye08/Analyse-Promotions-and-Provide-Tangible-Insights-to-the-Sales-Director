#Q2

SELECT city,count(store_id) as store_count FROM dim_stores
GROUP BY city
ORDER BY store_count DESC;
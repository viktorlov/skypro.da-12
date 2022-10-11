SELECT a.id as order_id
    , a.created_date as order_created_date
    , a.transaction_value
    , a.commission
    , a.processing_cost
    , a.promocode_cost
    , a.intergtation_cost as integration_cost
    , a.user_id
    , b.created_date as user_created_date
    , b.language as user_region_code
FROM exam.orders a
    LEFT JOIN exam.users b
        ON a.user_id = b.id
WHERE EXTRACT(MONTH FROM a.created_date) = '04'
      AND EXTRACT(YEAR FROM a.created_date) = '2021'
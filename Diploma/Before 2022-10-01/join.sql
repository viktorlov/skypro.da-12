SELECT * 
FROM public.orders AS a
    LEFT JOIN public.region AS b
        ON a.destination_id = b.id
            LEFT JOIN public.users AS c
                ON a.user_id = c.id
ORDER BY a.transaction_value DESC
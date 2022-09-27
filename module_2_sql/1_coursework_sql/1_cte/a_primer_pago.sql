-- Первая оплата урока: 
-- стоблец 1: usuario (пользователь)
-- столбец 2: primera_fecha (первая дата)

-- a_primer_pago as
-- (

select user_id as usuario
    , min(date_trunc('day', transaction_datetime)) as primera_fecha
from skyeng_db.payments
where status_name = 'success'
    and classes != 0
group by usuario

-- )

order by 1,2
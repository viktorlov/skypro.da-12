-- Изменение баланса по успешным транзакциям:
-- Стоблец 1: usuario (пользователь)
-- Стоблец 2: fecha_de_pago (дата транзакции)
-- Стоблец 3: cambio_de_saldo_de_transaccion (изменение баланса транзакций)

with

a_primer_pago as -- первая оплата
    (
    select user_id as usuario
        , min(date_trunc('day', transaction_datetime)) as primera_fecha
    from skyeng_db.payments
    where status_name = 'success'
        and classes != 0
    group by usuario
    ),

b_calendario as -- календарь
    (
    select distinct date_trunc('day', class_start_datetime) as fecha
    from skyeng_db.classes
    union 
    select distinct date_trunc('day', transaction_datetime)
    from skyeng_db.payments
    ),

c_calendario_de_usuario as -- календарь дат пользователя
    (
    select a.usuario
        , b.fecha
    from a_primer_pago as a  
        inner join b_calendario as b on b.fecha >= a.primera_fecha
    )--,

-- d_pagos_por_fechas as -- успешные транзакции
--(

select user_id as usuario
    , date_trunc('day', transaction_datetime) as fecha_de_pago
    , sum(classes) as cambio_de_saldo_de_transaccion
from skyeng_db.payments
where status_name = 'success'
    and classes != 0
group by 1,2 

--)

order by 1,2
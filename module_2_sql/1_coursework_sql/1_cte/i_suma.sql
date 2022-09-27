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

b_calendario as -- календарь дат
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
    ),

d_pagos_por_fechas as -- успешные транзакции
    (
    select user_id as usuario
        , date_trunc('day', transaction_datetime) as fecha_de_pago
        , sum(classes) as cambio_de_saldo_de_transaccion
    from skyeng_db.payments
    where status_name = 'success'
        and classes != 0
    group by 1,2 
    ),

e_pagos_por_fechas_acumuladas as -- баланс успешных транзакций
    (
    select c.usuario
        , c.fecha
        , coalesce(cambio_de_saldo_de_transaccion, 0) as cambio_de_saldo_de_transaccion
        , sum(coalesce(cambio_de_saldo_de_transaccion, 0)) over (partition by c.usuario order by fecha) as cambio_de_saldo_de_transaccion_acumulatio
    from c_calendario_de_usuario as c 
        left join d_pagos_por_fechas as d on c.usuario = d.usuario and date_trunc('day', c.fecha) = d.fecha_de_pago
    ),

f_clases_por_fechas as -- количество уроков по дням
    (
    select user_id as usuario
        , date_trunc('day', class_start_datetime) as fecha
        , count(id_class)*(-1) as clases 
    from skyeng_db.classes
    where class_type != 'trial'
        and class_status in ('success', 'failed_by_student')
    group by 1,2
    ),

g_clases_por_fechas_acumuladas as -- баланс количества уроков по дням
    (
    select c.usuario
        , c.fecha
        , coalesce(clases, 0) clases
        , sum(coalesce(clases, 0)) over (partition by c.usuario order by c.fecha) as clases_acumulativas
    from c_calendario_de_usuario as c 
        left join f_clases_por_fechas as f on c.usuario = f.usuario and c.fecha = f.fecha
    ),

h_saldos as -- баланс по паре "студент/дата"
    (
    select e.usuario
        , e.fecha
        , e.cambio_de_saldo_de_transaccion
        , e.cambio_de_saldo_de_transaccion_acumulatio
        , g.clases
        , g.clases_acumulativas
        , (g.clases_acumulativas + e.cambio_de_saldo_de_transaccion_acumulatio) as saldo 
    from e_pagos_por_fechas_acumuladas as e 
        inner join g_clases_por_fechas_acumuladas as g on e.fecha = g.fecha and e.usuario = g.usuario
    )

select fecha
    , sum(cambio_de_saldo_de_transaccion) as suma_de_cambio_de_saldo_de_transaccion
    , sum(cambio_de_saldo_de_transaccion_acumulatio) as suma_de_cambio_de_saldo_de_transaccion_acumulatio
    , sum(clases) as suma_de_clases
    , sum(clases_acumulativas) as suma_de_clases_acumulativas
    , sum(saldo) as suma_de_saldos 
from h_saldos
group by fecha
-- начало: ограничение по дате
having fecha <= '2017-12-07'
-- конец: ограничение по дате
order by fecha
-- Календарь уникальных дат:
-- Столбец 1: fecha (дата)

-- b_calendario as
-- (

select distinct date_trunc('day', class_start_datetime) as fecha
from skyeng_db.classes
union 
select distinct date_trunc('day', transaction_datetime)
from skyeng_db.payments

-- )

order by 1
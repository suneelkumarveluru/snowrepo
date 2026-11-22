-- Example only: locate changed customer attributes in staging.
-- Customize schemas and add a transactional merge/update strategy for production.
with stage as (
    select 1 as customer_id, 'Ada' as customer_name, 'Dallas' as city
    union all
    select 2, 'Grace', 'Austin'
),
current_dimension as (
    select 1 as customer_id, 'Ada' as customer_name, 'Houston' as city
)
select
    s.customer_id,
    s.customer_name,
    s.city,
    case
        when d.customer_id is null then 'NEW'
        when hash(s.customer_name, s.city) <> hash(d.customer_name, d.city)
            then 'CHANGED'
        else 'UNCHANGED'
    end as change_type
from stage s
left join current_dimension d using (customer_id);

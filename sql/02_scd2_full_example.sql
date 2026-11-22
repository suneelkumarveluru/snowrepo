-- Snowflake SCD Type 2 demonstration (synthetic data only).
-- Run in a disposable schema with CREATE TABLE privileges.
-- Demonstrates: deterministic deduplication, expire changed rows, insert new versions.
create or replace temporary table demo_dim_customer (
    customer_id number,
    customer_name varchar,
    city varchar,
    valid_from timestamp_ntz,
    valid_to timestamp_ntz,
    is_current boolean
);
insert into demo_dim_customer values
(1, 'Ada', 'Dallas', '2025-01-01'::timestamp_ntz, null, true),
(2, 'Grace', 'Austin', '2025-01-01'::timestamp_ntz, null, true);

create or replace temporary table demo_customer_stage (
    customer_id number,
    customer_name varchar,
    city varchar,
    source_updated_at timestamp_ntz
);
insert into demo_customer_stage values
(1, 'Ada', 'Houston', '2026-11-01'::timestamp_ntz),
(2, 'Grace', 'Austin', '2026-11-01'::timestamp_ntz),
(3, 'Linus', 'Seattle', '2026-11-01'::timestamp_ntz);

begin transaction;

-- Capture rows to insert BEFORE expiring current rows.
create or replace temporary table demo_scd2_delta as
select s.*
from (
    select * from demo_customer_stage
    qualify row_number() over (
        partition by customer_id
        order by source_updated_at desc, customer_name desc, city desc
    ) = 1
) s
left join demo_dim_customer d
    on d.customer_id = s.customer_id and d.is_current
where d.customer_id is null
   or d.customer_name is distinct from s.customer_name
   or d.city is distinct from s.city;

update demo_dim_customer d
set valid_to = delta.source_updated_at, is_current = false
from demo_scd2_delta delta
where d.customer_id = delta.customer_id
  and d.is_current = true
  and delta.source_updated_at > d.valid_from;

insert into demo_dim_customer
    (customer_id, customer_name, city, valid_from, valid_to, is_current)
select delta.customer_id, delta.customer_name, delta.city,
       delta.source_updated_at, null, true
from demo_scd2_delta delta
where not exists (
    select 1 from demo_dim_customer d
    where d.customer_id = delta.customer_id
      and d.is_current
      and d.valid_from >= delta.source_updated_at
);

commit;

-- Check exactly one current record per customer.
select customer_id, count(*) as active_versions
from demo_dim_customer
where is_current
group by customer_id
having count(*) <> 1;

select * from demo_dim_customer order by customer_id, valid_from;

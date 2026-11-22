-- Self-contained Snowflake example showing duplicate business-key detection.
with source_rows as (
    select column1::integer as customer_id, column2::varchar as name
    from values (1, 'Ada'), (2, 'Grace'), (2, 'Grace Updated')
)
select customer_id, count(*) as row_count
from source_rows
group by customer_id
having count(*) > 1
order by customer_id;

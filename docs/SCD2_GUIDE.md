# Snowflake Type 2 Dimension Demo

Use `sql/02_scd2_full_example.sql` in a **disposable Snowflake schema**. It creates temporary tables containing synthetic customer records, detects changes, and demonstrates closing an old version and opening a new version.

The final duplicate-active-version query should return no rows. Re-run the entire script to recreate synthetic demo tables.

## Important limitations

- This is **not** a deployable production procedure. DDL statements may implicitly commit transactions in Snowflake; production implementations should create work tables ahead of the DML transaction.
- Ensure change timestamps are monotonically increasing, reject stale events, and define deterministic ordering for identical timestamps.
- Validate unique current customer keys, non-overlapping time ranges, and idempotent reprocessing.
- Use a controlled transaction with staging tables and a concurrency strategy for production.
- The example intentionally uses timestamp-based SCD2 validity rather than surrogate version keys.

Start with `sql/scd2_change_detection.sql` to understand change classification, then use this full synthetic demonstration.

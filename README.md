# Snowflake Slowly Changing Dimension Examples

Practical SQL examples for detecting Type 2 dimension changes.

## Run

Execute `sql/scd2_change_detection.sql` in a Snowflake SQL worksheet.

The sample is self-contained using inline `VALUES` and reports NEW, CHANGED, or UNCHANGED customer rows.

**Important:** Change detection does not itself update dimension history. Production SCD2 pipelines must close old records, insert new versions, ensure stable keys, and handle concurrent runs and duplicate input records.

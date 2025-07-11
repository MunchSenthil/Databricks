
-- https://docs.databricks.com/aws/en/dlt/expectations?language=SQL

create streaming table manju_silver.sales_cleaned_pl
(CONSTRAINT valid_order_id EXPECT (order_id IS NOT NULL) ON VIOLATION DROP ROW)
as
select distinct * from stream sales_pl;

-- https://docs.databricks.com/aws/en/dlt-ref/dlt-sql-ref-apply-changes-into

-- Create a streaming table, then use AUTO CDC to populate it:
CREATE OR REFRESH STREAMING TABLE manju_silver.products_cleaned;

CREATE FLOW product_flow
AS AUTO CDC INTO
  manju_silver.products_cleaned
FROM stream(products_pl)
  KEYS (product_id)
  APPLY AS DELETE WHEN operation = "DELETE"
  SEQUENCE BY seqNum
  COLUMNS * EXCEPT (operation, seqNum,_rescued_data)
  STORED AS SCD TYPE 1;


CREATE OR REFRESH STREAMING TABLE manju_silver.customers_cleaned;

CREATE FLOW customer_flow
AS AUTO CDC INTO
  manju_silver.customers_cleaned
FROM stream(customers_pl)
  KEYS (customer_id)
  APPLY AS DELETE WHEN operation = "DELETE"
  SEQUENCE BY sequenceNum
  COLUMNS * EXCEPT (operation, sequenceNum,_rescued_data)
  STORED AS SCD TYPE 2;

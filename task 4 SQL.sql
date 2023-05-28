-- 1) jumlah penggunaan tiap tipe pembayaran secara all time

WITH payment_counts AS (
  SELECT payment_type, COUNT(*) AS count
  FROM order_payments_dataset
  GROUP BY payment_type
)
SELECT payment_type, count
FROM payment_counts
ORDER BY count DESC;

-- 2)detail informasi jumlah penggunaan tiap tipe pembayaran untuk setiap tahun

WITH payment_usage AS (
  SELECT
    date_part('year', od.order_purchase_timestamp) AS year,
    opd.payment_type,
    COUNT(opd.payment_type) AS total
  FROM orders_dataset AS od
  JOIN order_payments_dataset AS opd ON od.order_id = opd.order_id
  GROUP BY year, opd.payment_type
)
SELECT
  payment_type,
  SUM(CASE WHEN year = 2016 THEN total ELSE 0 END) AS "2016",
  SUM(CASE WHEN year = 2017 THEN total ELSE 0 END) AS "2017",
  SUM(CASE WHEN year = 2018 THEN total ELSE 0 END) AS "2018",
  SUM(total) AS sum_payment_type_usage
FROM payment_usage
GROUP BY payment_type
ORDER BY sum_payment_type_usage DESC;


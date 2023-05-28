--1) rata-rata jumlah customer aktif bulanan (monthly active user) per tahun

SELECT EXTRACT(year FROM order_month) AS year,
       ROUND(AVG(customer_total)) AS avg_mau
FROM (
    SELECT DATE_TRUNC('month', od.order_purchase_timestamp) AS order_month,
           COUNT(DISTINCT cd.customer_unique_id) AS customer_total
    FROM orders_dataset AS od
    JOIN customers_dataset AS cd ON cd.customer_id = od.customer_id
    GROUP BY order_month
) AS sub
GROUP BY year
ORDER BY year;

--2 jumlah customer baru pada tiap tahun

SELECT year, COUNT(customer_unique_id) AS total_new_customer
FROM (
  SELECT
  	MIN(EXTRACT(YEAR FROM od.order_purchase_timestamp)) AS year,
  	cd.customer_unique_id
  FROM orders_dataset AS od
  JOIN customers_dataset AS cd
  	ON cd.customer_id = od.customer_id
  GROUP BY cd.customer_unique_id
) AS sub
GROUP BY year
ORDER BY year;

--3 jumlah customer repeat order pada tiap tahun

SELECT sub.year, COUNT(sub.customer_unique_id) AS total_customer_repeat
FROM (
  SELECT
    EXTRACT(YEAR FROM od.order_purchase_timestamp) AS year,
    cd.customer_unique_id
  FROM orders_dataset AS od
  JOIN customers_dataset AS cd
    ON cd.customer_id = od.customer_id
  GROUP BY EXTRACT(YEAR FROM od.order_purchase_timestamp), cd.customer_unique_id
  HAVING COUNT(od.order_id) > 1
) AS sub
GROUP BY sub.year
ORDER BY sub.year;

--4 rata-rata jumlah order yang dilakukan customer untuk tiap tahun

SELECT sub.year, ROUND(AVG(sub.freq), 3) AS avg_frequency
FROM (
  SELECT
    date_part('year', od.order_purchase_timestamp) AS year,
    cd.customer_unique_id,
    COUNT(od.order_id) AS freq
  FROM orders_dataset AS od
  JOIN customers_dataset AS cd
    ON cd.customer_id = od.customer_id
  GROUP BY date_part('year', od.order_purchase_timestamp), cd.customer_unique_id
) AS sub
GROUP BY sub.year
ORDER BY sub.year;

--5 Gabung keempat query yang telah dibuat menjadi satu tampilan tabel

SELECT mau.year,
       mau.avg_mau,
       new_cust.total_new_customer,
       repeat_order.total_customer_repeat,
       frequency.avg_frequency
FROM (
  SELECT EXTRACT(YEAR FROM order_month) AS year,
         ROUND(AVG(customer_total)) AS avg_mau
  FROM (
    SELECT DATE_TRUNC('month', od.order_purchase_timestamp) AS order_month,
           COUNT(DISTINCT cd.customer_unique_id) AS customer_total
    FROM orders_dataset AS od
    JOIN customers_dataset AS cd ON cd.customer_id = od.customer_id
    GROUP BY order_month
  ) AS sub
  GROUP BY year
) AS mau
JOIN (
  SELECT year,
         COUNT(customer_unique_id) AS total_new_customer
  FROM (
    SELECT MIN(EXTRACT(YEAR FROM od.order_purchase_timestamp)) AS year,
           cd.customer_unique_id
    FROM orders_dataset AS od
    JOIN customers_dataset AS cd ON cd.customer_id = od.customer_id
    GROUP BY cd.customer_unique_id
  ) AS sub
  GROUP BY year
) AS new_cust ON mau.year = new_cust.year
JOIN (
  SELECT sub.year,
         COUNT(sub.customer_unique_id) AS total_customer_repeat
  FROM (
    SELECT EXTRACT(YEAR FROM od.order_purchase_timestamp) AS year,
           cd.customer_unique_id
    FROM orders_dataset AS od
    JOIN customers_dataset AS cd ON cd.customer_id = od.customer_id
    GROUP BY EXTRACT(YEAR FROM od.order_purchase_timestamp), cd.customer_unique_id
    HAVING COUNT(od.order_id) > 1
  ) AS sub
  GROUP BY sub.year
) AS repeat_order ON mau.year = repeat_order.year
JOIN (
  SELECT sub.year,
         ROUND(AVG(sub.freq), 3) AS avg_frequency
  FROM (
    SELECT date_part('year', od.order_purchase_timestamp) AS year,
           cd.customer_unique_id,
           COUNT(od.order_id) AS freq
    FROM orders_dataset AS od
    JOIN customers_dataset AS cd ON cd.customer_id = od.customer_id
    GROUP BY date_part('year', od.order_purchase_timestamp), cd.customer_unique_id
  ) AS sub
  GROUP BY sub.year
) AS frequency ON mau.year = frequency.year
ORDER BY mau.year;








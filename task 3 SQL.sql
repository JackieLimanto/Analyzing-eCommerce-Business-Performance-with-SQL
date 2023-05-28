--1) Tabel yang berisi informasi pendapatan/revenue perusahaan total untuk tiap tahun

CREATE TABLE total_revenue AS
  SELECT
  	date_part('year', o.order_purchase_timestamp) AS year,
  	SUM(oi.price + oi.freight_value) AS revenue
  FROM order_items_dataset AS oi
  JOIN orders_dataset AS o ON oi.order_id = o.order_id AND o.order_status = 'delivered'
  GROUP BY year
  ORDER BY year;

--2) tabel yang berisi informasi jumlah cancel order total untuk tiap tahun

CREATE TABLE canceled_order AS
  SELECT
  	date_part('year', order_purchase_timestamp) AS year,
  	COUNT(order_status) AS canceled_count
  FROM orders_dataset
  WHERE order_status = 'canceled'
  GROUP BY year
  ORDER BY year;

--3) tabel yang berisi nama kategori produk yang memberikan pendapatan total tertinggi tiap tahun

CREATE TABLE top_product_category AS
  SELECT 
  	year,
  	top_category,
  	product_revenue
  FROM (
  	SELECT
  		date_part('year', shipping_limit_date) AS year,
  		pd.product_category_name AS top_category,
  		SUM(oid.price + oid.freight_value) AS product_revenue,
  		RANK() OVER (PARTITION BY date_part('year', shipping_limit_date)
  				 ORDER BY SUM(oid.price + oid.freight_value) DESC) AS ranking
  	FROM orders_dataset AS od 
  	JOIN order_items_dataset AS oid
  		ON od.order_id = oid.order_id
  	JOIN product_dataset AS pd
  		ON oid.product_id = pd.product_id
  	WHERE od.order_status = 'delivered'
  	GROUP BY 1, 2
  	ORDER BY 1
  	) AS sub
  WHERE ranking = 1;

--4) tabel yang berisi nama kategori produk yang memiliki jumlah cancel order terbanyak untuk tiap tahun

CREATE TABLE most_canceled_category AS
  SELECT 
  	year,
  	most_canceled,
  	total_canceled
  FROM (
  	SELECT
  		date_part('year', shipping_limit_date) AS year,
  		pd.product_category_name AS most_canceled,
  		COUNT(od.order_id) AS total_canceled,
  		RANK() OVER (PARTITION BY date_part('year', shipping_limit_date)
  				 ORDER BY COUNT(od.order_id) DESC) AS ranking
  	FROM orders_dataset AS od 
  	JOIN order_items_dataset AS oid
  		ON od.order_id = oid.order_id
  	JOIN product_dataset AS pd
  		ON oid.product_id = pd.product_id
  	WHERE od.order_status = 'canceled'
  	GROUP BY 1, 2
  	ORDER BY 1
  	) AS sub
  WHERE ranking = 1;

-- 5) Menghapus data tahun 2020

DELETE FROM top_product_category WHERE year = 2020;
DELETE FROM most_canceled_category WHERE year = 2020;

-- 6) Menggabungkan tabel yang dibutuhkan

SELECT 
  tr.year,
  tr.revenue AS total_revenue,
  tpc.top_category AS top_product,
  tpc.product_revenue AS total_revenue_top_product,
  co.canceled_count,
  mcc.most_canceled AS top_canceled_product,
  mcc.total_canceled
FROM total_revenue AS tr
JOIN top_product_category AS tpc
  ON tr.year = tpc.year
JOIN canceled_order AS co
  ON tr.year = co.year
JOIN most_canceled_category AS mcc
  ON tr.year = mcc.year;
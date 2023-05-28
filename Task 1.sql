-- 1) Membuat database dengan cara klik kanan pada Databases > Create > Database.. dengan nama ecommerce_minpro_1


-- 2) Membuat tabel menggunakan statement/query CREATE TABLE dengan mengikuti penamaan kolom di csv, kemudian memastikan tipe datanya sudah sesuai.

CREATE TABLE customers_dataset (
	customer_id VARCHAR,
	customer_unique_id VARCHAR,
	customer_zip_code_prefix VARCHAR,
	customer_city VARCHAR,
	customer_state VARCHAR
);

CREATE TABLE sellers_dataset (
	seller_id VARCHAR,
	seller_zip_code_prefix VARCHAR,
	seller_city VARCHAR,
	seller_state VARCHAR
);

CREATE TABLE geolocation_dataset (
	geolocation_zip_code_prefix VARCHAR,
	geolocation_lat NUMERIC,
	geolocation_lng NUMERIC,
	geolocation_city VARCHAR,
	geolocation_state VARCHAR
);

CREATE TABLE product_dataset (
	product_id VARCHAR,
	product_category_name VARCHAR,
	product_name_lenght NUMERIC,
	product_description_lenght NUMERIC,
	product_photos_qty NUMERIC,
	product_weight_g NUMERIC,
	product_length_cm NUMERIC,
	product_height_cm NUMERIC,
	product_width_cm NUMERIC
);

CREATE TABLE orders_dataset (
	order_id VARCHAR,
	customer_id VARCHAR,
	order_status VARCHAR,
	order_purchase_timestamp TIMESTAMP,
	order_approved_at TIMESTAMP,
	order_delivered_carrier_date TIMESTAMP,
	order_delivered_customer_date TIMESTAMP,
	order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE order_items_dataset (
	order_id VARCHAR,
	order_item_id INTEGER,
	product_id VARCHAR,
	seller_id VARCHAR,
	shipping_limit_date TIMESTAMP,
	price NUMERIC,
	freight_value NUMERIC
);

CREATE TABLE order_payments_dataset (
	order_id VARCHAR,
	payment_sequential INTEGER,
	payment_type VARCHAR,
	payment_installments INTEGER,
	payment_value NUMERIC
);

CREATE TABLE order_reviews_dataset (
	review_id VARCHAR,
	order_id VARCHAR,
	review_score INTEGER,
	review_comment_title VARCHAR,
	review_comment_message VARCHAR,
	review_creation_date TIMESTAMP,
	review_answer_timestamp TIMESTAMP
);

-- 3) Mengimpor file csv ke dalam masing-masing table yang telah dibuat dengan statement/query COPY

COPY customers_dataset FROM 'C:\Users\Jacky\Documents\Data Science\Mini Project 1\customers_dataset.csv' DELIMITER ',' CSV HEADER;
COPY geolocation_dataset FROM 'C:\Users\Jacky\Documents\Data Science\Mini Project 1\geolocation_dataset.csv' DELIMITER ',' CSV HEADER;
COPY order_items_dataset FROM 'C:\Users\Jacky\Documents\Data Science\Mini Project 1\order_items_dataset.csv' DELIMITER ',' CSV HEADER;
COPY order_payments_dataset FROM 'C:\Users\Jacky\Documents\Data Science\Mini Project 1\order_payments_dataset.csv' DELIMITER ',' CSV HEADER;
COPY order_reviews_dataset FROM 'C:\Users\Jacky\Documents\Data Science\Mini Project 1\order_reviews_dataset.csv' DELIMITER ',' CSV HEADER;
COPY orders_dataset FROM 'C:\Users\Jacky\Documents\Data Science\Mini Project 1\orders_dataset.csv' DELIMITER ',' CSV HEADER;
COPY product_dataset FROM 'C:\Users\Jacky\Documents\Data Science\Mini Project 1\product_dataset.csv' DELIMITER ',' CSV HEADER;
COPY sellers_dataset FROM 'C:\Users\Jacky\Documents\Data Science\Mini Project 1\sellers_dataset.csv' DELIMITER ',' CSV HEADER;


-- 4) Menentukan Primary Key dan Foreign Key untuk membuat relasi antar tabel,
-- Note : Pastikan Primary Key memiliki nilai unik dan tipe data sesuai antara Primary Key dan Foreign Key pada dataset.

-- PRIMARY KEY
ALTER TABLE customers_dataset ADD CONSTRAINT customers_dataset_pkey PRIMARY KEY (customer_id);
ALTER TABLE orders_dataset ADD CONSTRAINT orders_dataset_pkey PRIMARY KEY (order_id);
ALTER TABLE product_dataset ADD CONSTRAINT product_dataset_pkey PRIMARY KEY (product_id);
ALTER TABLE sellers_dataset ADD CONSTRAINT sellers_dataset_pkey PRIMARY KEY (seller_id);

-- FOREIGN KEY
ALTER TABLE order_payments_dataset ADD FOREIGN KEY (order_id) REFERENCES orders_dataset;
ALTER TABLE order_items_dataset ADD FOREIGN KEY (product_id) REFERENCES product_dataset;
ALTER TABLE order_items_dataset ADD FOREIGN KEY (seller_id) REFERENCES sellers_dataset;
ALTER TABLE order_items_dataset ADD FOREIGN KEY (order_id) REFERENCES orders_dataset;
ALTER TABLE orders_dataset ADD FOREIGN KEY (customer_id) REFERENCES customers_dataset;
ALTER TABLE order_reviews_dataset ADD FOREIGN KEY (order_id) REFERENCES orders_dataset;
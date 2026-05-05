-- Student demo — Cassandra replication (KEEP IT SIMPLE ON ONE LAPTOP)
--
-- SimpleStrategy:
--   - One logical "cluster" / one datacenter in class examples.
--   - No per-datacenter counts (unlike NetworkTopologyStrategy in production).
-- replication_factor: 1 here:
--   - One copy only — OK for coursework; mirrors our single Docker node.
--
-- Replace with Multi-DC setups only after you study NetworkTopologyStrategy.

DROP KEYSPACE IF EXISTS shop_demo;

CREATE KEYSPACE shop_demo WITH replication = {
  'class': 'SimpleStrategy',
  'replication_factor': 1
};

USE shop_demo;

-- One table: partition key = customer_id (all orders for one user stay in one partition).
CREATE TABLE orders_by_customer (
    customer_id text,
    order_id uuid,
    sku text,
    qty int,
    PRIMARY KEY ((customer_id), order_id)
) WITH CLUSTERING ORDER BY (order_id DESC);

INSERT INTO orders_by_customer (customer_id, order_id, sku, qty) VALUES
  ('c1', 11111111-1111-1111-1111-111111111101, 'P100', 1);
INSERT INTO orders_by_customer (customer_id, order_id, sku, qty) VALUES
  ('c1', 11111111-1111-1111-1111-111111111102, 'P101', 1);
INSERT INTO orders_by_customer (customer_id, order_id, sku, qty) VALUES
  ('c1', 11111111-1111-1111-1111-111111111103, 'P103', 1);
INSERT INTO orders_by_customer (customer_id, order_id, sku, qty) VALUES
  ('c2', 11111111-2222-2222-2222-222222222201, 'P101', 1);
INSERT INTO orders_by_customer (customer_id, order_id, sku, qty) VALUES
  ('c2', 11111111-2222-2222-2222-222222222202, 'P102', 1);
INSERT INTO orders_by_customer (customer_id, order_id, sku, qty) VALUES
  ('c3', 11111111-3333-3333-3333-333333333301, 'P102', 1);
INSERT INTO orders_by_customer (customer_id, order_id, sku, qty) VALUES
  ('c3', 11111111-3333-3333-3333-333333333302, 'P104', 1);
INSERT INTO orders_by_customer (customer_id, order_id, sku, qty) VALUES
  ('c4', 11111111-4444-4444-4444-444444444401, 'P100', 1);
INSERT INTO orders_by_customer (customer_id, order_id, sku, qty) VALUES
  ('c4', 11111111-4444-4444-4444-444444444402, 'P103', 1);
INSERT INTO orders_by_customer (customer_id, order_id, sku, qty) VALUES
  ('c5', 11111111-5555-5555-5555-555555555501, 'P104', 1);

-- Show keyspace replication (nice slide: "we really use SimpleStrategy + RF 1").
SELECT keyspace_name, replication
FROM system_schema.keyspaces
WHERE keyspace_name = 'shop_demo';

-- Query that matches how data is laid out: filter by partition key first.
SELECT * FROM orders_by_customer WHERE customer_id = 'c1';

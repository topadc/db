"""
Neo4j vs Cassandra - student demo (no Docker, no database servers).

Run in your IDE terminal or VS Code Run:
    python demo.py

Uses the same toy shop story as neo4j/demo.cypher and cassandra/demo.cql.
"""

from __future__ import annotations

from collections import defaultdict
from pprint import pprint

# ----- Shared toy data -----
CUSTOMERS = {
    "c1": {"name": "An"},
    "c2": {"name": "Binh"},
    "c3": {"name": "Chi"},
    "c4": {"name": "Dung"},
    "c5": {"name": "Em"},
}
PRODUCTS = {
    "P100": "Graph DB Basics",
    "P101": "Distributed Systems",
    "P102": "Streaming 101",
    "P103": "NoSQL Distilled",
    "P104": "Kafka in Action",
}

# friendship is undirected for queries
FRIENDS: dict[str, set[str]] = {
    "c1": {"c3", "c4"},
    "c2": {"c5"},
    "c3": {"c1", "c5"},
    "c4": {"c1"},
    "c5": {"c3", "c2"},
}

# who bought which SKU
BOUGHT: dict[str, set[str]] = {
    "c1": {"P100", "P101", "P103"},
    "c2": {"P101", "P102"},  # shares P101 with An; exposes P102 as a reco signal
    "c3": {"P102", "P104"},
    "c4": {"P100", "P103"},
    "c5": {"P104"},
}

# similarity edges between products (undirected)
SIMILAR_TO: dict[str, set[str]] = {
    "P100": {"P103"},
    "P101": {"P102", "P103"},
    "P102": {"P101", "P104"},
    "P103": {"P100", "P101"},
    "P104": {"P102"},
}

# Cassandra partition: orders per customer - cluster by order_id desc (simulate with sort)
ORDERS_BY_CUSTOMER: dict[str, list[tuple[str, str, int]]] = {
    "c1": [
        ("11111111-1111-1111-1111-111111111101", "P100", 1),
        ("11111111-1111-1111-1111-111111111102", "P101", 1),
        ("11111111-1111-1111-1111-111111111103", "P103", 1),
    ],
    "c2": [
        ("11111111-2222-2222-2222-222222222201", "P101", 1),
        ("11111111-2222-2222-2222-222222222202", "P102", 1),
    ],
    "c3": [
        ("11111111-3333-3333-3333-333333333301", "P102", 1),
        ("11111111-3333-3333-3333-333333333302", "P104", 1),
    ],
    "c4": [
        ("11111111-4444-4444-4444-444444444401", "P100", 1),
        ("11111111-4444-4444-4444-444444444402", "P103", 1),
    ],
    "c5": [
        ("11111111-5555-5555-5555-555555555501", "P104", 1),
    ],
}


def header(title: str) -> None:
    print()
    print("=" * 60)
    print(title)
    print("=" * 60)


def neo4j_demo() -> None:
    header("Neo4j-style: graph traversal (in memory)")

    me = "c1"
    print("\nQ1 - What did An buy?")
    for sku in sorted(BOUGHT[me]):
        print(f"  {CUSTOMERS[me]['name']}: {sku} - {PRODUCTS[sku]}")

    print("\nQ2 - Friends bought SKUs that I didn't")
    mine = BOUGHT[me]
    seen: set[tuple[str, str]] = set()
    for friend in FRIENDS.get(me, []):
        for sku in BOUGHT.get(friend, set()) - mine:
            key = (friend, sku)
            if key not in seen:
                seen.add(key)
                print(f"  friend {CUSTOMERS[friend]['name']}: {PRODUCTS[sku]}")

    print("\nQ3 - Lightweight collaborative (affinity count)")
    affinity: defaultdict[str, int] = defaultdict(int)
    shared_with_me = BOUGHT[me]
    for other, skus in BOUGHT.items():
        if other == me:
            continue
        shared = shared_with_me & skus
        if not shared:
            continue
        for reco in skus:
            if reco not in mine:
                affinity[reco] += 1
    for sku, n in sorted(affinity.items(), key=lambda x: -x[1])[:5]:
        print(f"  recommend {sku} ({PRODUCTS[sku]}): affinity={n}")

    seed = "P101"
    print(f"\nQ4 - SIMILAR_TO walk from {seed}")
    for adj in sorted(SIMILAR_TO.get(seed, [])):
        print(f"  {PRODUCTS[seed]} ~ {adj} ({PRODUCTS.get(adj, '?')})")


def cassandra_demo() -> None:
    header("Cassandra-style: partition key lookup (SimpleStrategy, RF 1)")

    replication = {"class": "SimpleStrategy", "replication_factor": "1"}
    print('\nEquivalent of: CREATE KEYSPACE shop_demo WITH replication = {...}')
    pprint(replication, width=60)

    print("\nEquivalent of:")
    print("  SELECT keyspace_name, replication")
    print("  FROM system_schema.keyspaces WHERE keyspace_name = 'shop_demo';")
    print({"keyspace_name": "shop_demo", "replication": replication})

    cid = "c1"
    print(f"\nEquivalent of: SELECT * FROM orders_by_customer WHERE customer_id = '{cid}'")
    rows = ORDERS_BY_CUSTOMER.get(cid, [])
    rows_sorted = sorted(rows, key=lambda r: r[0], reverse=True)
    print("customer_id | order_id | sku | qty")
    for oid, sku, qty in rows_sorted:
        print(f"{cid:^11} | {oid} | {sku} | {qty}")


def main() -> None:
    print(__doc__)
    neo4j_demo()
    cassandra_demo()
    print()


if __name__ == "__main__":
    main()

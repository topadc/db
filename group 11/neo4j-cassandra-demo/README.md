# Neo4j vs Cassandra — student demo



Same toy **shop / friends / buys** story in two modeling styles:



| Neo4j idea | Cassandra idea |

|------------|----------------|

| Traverse **relationships** (friends, SIMILAR_TO, co-buyers) | Rows grouped by **partition key** (`customer_id`) |

| Natural for paths and neighborhoods | Natural for keyed lookups (`WHERE customer_id = ?`) |



## Easiest — run one file (no Docker, no DB)



Requires **Python 3.9+** (stdlib only). In your IDE choose **Run** on `demo.py`, or:



```powershell

cd "d:\BK\252\DB\presentation\group 11\neo4j-cassandra-demo"

python demo.py

```



Outputs both “Neo4j-style” graph questions and “Cassandra-style” partition reads, plus **`SimpleStrategy` + replication_factor 1** in plain text.



## Optional — live Neo4j & Cassandra



- **Neo4j:** paste/run `neo4j/demo.cypher` in Neo4j Browser (**http://localhost:7474**).

- **Cassandra:** paste/run `cassandra/demo.cql` in **`cqlsh`** (Docker: `docker compose up -d`, then pipe the file into `cqlsh` as before). See also `docker-compose.yml`.



<details>

<summary>Prerequisites / Docker commands (collapse if you only use demo.py)</summary>



- Docker: install Docker Desktop, then `docker compose up -d`. Neo4j user `neo4j`, password `demo-password-change-me`.

- Without Docker: Neo4j Desktop native; Cassandra often via **WSL2** Ubuntu + `sudo apt install cassandra`, then `cat cassandra/demo.cql | cqlsh`.



```powershell

Get-Content ".\cassandra\demo.cql" -Raw | docker exec -i demo-cassandra cqlsh

```



</details>



## Talking points (slides)



- **Neo4j:** graph = **nodes + typed edges**; interesting queries often **hop** across relations.

- **Cassandra:** this demo uses **`SimpleStrategy`, RF 1** (one replica, one conceptual DC); **`customer_id`** is the partition key — match queries to partitions you designed.

- **Production:** Cassandra often **`NetworkTopologyStrategy`** and RF > 1; Neo4j is used where **graph traversal** dominates the workload.



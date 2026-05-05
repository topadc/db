// Neo4j demo: graph model for recommendations (who bought what, product similarity)
// Run statements in Neo4j Browser at http://localhost:7474 (user: neo4j, password from compose).

// ----- Reset (optional) -----
MATCH (n) DETACH DELETE n;

// ----- Constraints -----
CREATE CONSTRAINT customer_id IF NOT EXISTS FOR (c:Customer) REQUIRE c.id IS UNIQUE;
CREATE CONSTRAINT product_sku IF NOT EXISTS FOR (p:Product) REQUIRE p.sku IS UNIQUE;

// ----- Sample graph -----
MERGE (:Customer {id: 'c1', name: 'An'})
MERGE (:Customer {id: 'c2', name: 'Binh'})
MERGE (:Customer {id: 'c3', name: 'Chi'})
MERGE (:Customer {id: 'c4', name: 'Dung'})
MERGE (:Customer {id: 'c5', name: 'Em'});
MATCH (a:Customer {id: 'c1'}), (b:Customer {id: 'c2'}), (c:Customer {id: 'c3'}), (d:Customer {id: 'c4'}), (e:Customer {id: 'c5'})
MERGE (p100:Product {sku: 'P100', title: 'Graph DB Basics'})
MERGE (p101:Product {sku: 'P101', title: 'Distributed Systems'})
MERGE (p102:Product {sku: 'P102', title: 'Streaming 101'})
MERGE (p103:Product {sku: 'P103', title: 'NoSQL Distilled'})
MERGE (p104:Product {sku: 'P104', title: 'Kafka in Action'})
MERGE (a)-[:BOUGHT]->(p100)
MERGE (a)-[:BOUGHT]->(p101)
MERGE (a)-[:BOUGHT]->(p103)
MERGE (b)-[:BOUGHT]->(p101)
MERGE (b)-[:BOUGHT]->(p102)
MERGE (c)-[:BOUGHT]->(p102)
MERGE (c)-[:BOUGHT]->(p104)
MERGE (d)-[:BOUGHT]->(p100)
MERGE (d)-[:BOUGHT]->(p103)
MERGE (e)-[:BOUGHT]->(p104)
MERGE (p101)-[:SIMILAR_TO {score: 0.7}]-(p102)
MERGE (p102)-[:SIMILAR_TO {score: 0.8}]-(p104)
MERGE (p100)-[:SIMILAR_TO {score: 0.9}]-(p103)
MERGE (p101)-[:SIMILAR_TO {score: 0.6}]-(p103)
MERGE (a)-[:FRIENDS_WITH]->(c)
MERGE (a)-[:FRIENDS_WITH]->(d)
MERGE (c)-[:FRIENDS_WITH]->(e)
MERGE (b)-[:FRIENDS_WITH]->(e);

// ----- Demo queries -----
// Q1: products An bought
MATCH (c:Customer {id:'c1'})-[:BOUGHT]->(p)
RETURN c.name, p.sku AS sku, p.title AS title;

// Q2: Friends who bought something I didn't (graph traversal)
MATCH (me:Customer {id:'c1'})-[:FRIENDS_WITH]-(friend)-[:BOUGHT]->(p)
WHERE NOT EXISTS { (me)-[:BOUGHT]->(p) }
RETURN friend.name, p.title;

// Q3: Lightweight collaborative filter — items bought by peers who shared a basket with me
MATCH (me:Customer {id:'c1'})-[:BOUGHT]->(shared:Product)<-[:BOUGHT]-(other)-[:BOUGHT]->(reco:Product)
WHERE me <> other AND NOT EXISTS { (me)-[:BOUGHT]->(reco) }
RETURN reco.sku AS recommended_sku, reco.title AS recommended_title, count(*) AS affinity
ORDER BY affinity DESC LIMIT 5;

// Q4: Similar products via relationship walk
MATCH (seed:Product {sku:'P101'})-[:SIMILAR_TO]-(adj)
RETURN seed.title AS seed, adj.sku AS similar_sku, adj.title AS similar_title;

# Choom (Advanced Edition) 🚀

Choom is a social music application built with **Next.js 16**, leveraging a **Polyglot Persistence** architecture (Neo4j + Cassandra) to power deep social insights and large-scale activity tracking.

---

## 🏗️ Core Architecture & Database Strategy

This project demonstrates a "right-tool-for-the-job" approach by combining Graph and NoSQL databases:

### 1. Neo4j (Graph Database) — The Relationship Engine
Used for managing the **Social Graph** and complex musical connections.
*   **Music Soulmates:** Uses **Jaccard Similarity** algorithm in Cypher to find users with the most overlapping musical tastes.
*   **Social Circle:** Handles follower/following networks and shared artist discovery.
*   **Audit Logging:** Stores a "Transaction Log" of every data sync to ensure cross-database consistency.

### 2. Apache Cassandra (NoSQL) — The High-Velocity Engine
Used for high-throughput **Listening History** and time-series analytics.
*   **Listening Heatmap:** Analyzes activity timestamps to visualize peak listening hours for each user.
*   **Vault Analytics:** Calculates lifetime statistics (Total Plays, Unique Tracks) with high performance.
*   **Scalable History:** Stores every "listen" event from Spotify without performance degradation as data grows.

### 🛡️ Sync Auditor (Multi-DB Transaction Logic)
Because Neo4j and Cassandra do not share a single ACID transaction, we implemented a **Sync Coordinator** pattern. 
- It logs an `INITIATED_SYNC` event in Neo4j.
- It attempts the multi-DB write across both systems.
- It updates the log to `SUCCESS` or `FAILED` with detailed error traces.

---

## 🛠️ Getting Started

### 1. Requirements
- Node.js `20+`
- npm `10+`
- Docker Desktop (for Neo4j + Cassandra)
- **ngrok** (for Spotify HTTPS redirect during local development)

### 2. Install Project
```bash
npm install
```

### 3. Configure Environment Variables
Create a `.env.local` file in the root directory:
```env
NEO4J_URI=bolt://localhost:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=choom-password

CASSANDRA_CONTACT_POINTS=127.0.0.1
CASSANDRA_DATACENTER=datacenter1
CASSANDRA_KEYSPACE=choom

SPOTIFY_CLIENT_ID=your_client_id
SPOTIFY_CLIENT_SECRET=your_client_secret
SPOTIFY_REDIRECT_URI=https://<your-ngrok-domain>/api/auth/callback/spotify
```

### 4. Start Databases
```bash
docker compose up -d
```

### 5. Seed Initial Data
```bash
npm run seed
```
This script creates schemas, indexes, and initial demo users in both databases.

### 6. Run Application
```bash
npm run dev
```
Open [https://localhost:3000](https://localhost:3000). (Note: Next.js is configured for experimental HTTPS to support Spotify OAuth).

---

## 📊 Feature Verification Flow

1. **Sign in:** Use demo accounts (e.g., `an@choom.vn` / `choom123`).
2. **Connect Spotify:** Complete the OAuth flow.
3. **Sync Data:** Go to `/profile` and click **Sync now**.
4. **View Insights:** Visit the **Vault** page (`/vault`) to see:
    - **Music Soulmates:** People who share your vibe (Neo4j output).
    - **Listening Heatmap:** Your hourly activity chart (Cassandra output).
    - **Sync Audit Logs:** The status of your background transactions.

---

## 📂 Project Structure (Key Paths)
- `src/lib/neo4j.ts` & `src/lib/cassandra.ts`: Database drivers and analytical query functions.
- `src/lib/syncCoordinator.ts`: Logic handling multi-DB consistency.
- `src/app/api/insights/route.ts`: API endpoint for combined Graph and NoSQL analytics.
- `src/components/InsightsSection.tsx`: UI for displaying database insights.
- `db/`: Schema and seed scripts for Neo4j, Cassandra, and Postgres.

---

## 🎓 Academic Highlights (KPIs)
1. **Data Sovereignty:** Neo4j allows for relationship-based similarity calculations that are much faster than SQL JOINs.
2. **Horizontal Scaling:** Cassandra provides a distributed, high-availability store for append-only history logs.
3. **Consistency Management:** The `SyncLog` pattern demonstrates an understanding of distributed systems and the lack of global ACID transactions.
4. **HTTPS Dev Environment:** Configured `next.config.ts` to support secure `ngrok` tunnels for modern OAuth compliance.

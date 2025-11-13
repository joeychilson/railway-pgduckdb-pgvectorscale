# railway-pgduckdb-pgvectorscale

A Docker container combining pg_duckdb and pgvectorscale extensions for PostgreSQL 17 on Railway.

## Features

This container includes:
- **PostgreSQL 17** - Latest major version
- **pg_duckdb** (v1.0.0) - DuckDB integration for analytical queries
- **pgvector** (v0.8.1) - Vector similarity search
- **pgvectorscale** (v0.8.0) - Scalable vector search with DiskANN

## Quick Start

### Deploy on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new)

### Local Docker Build

```bash
docker build -t pgduckdb-pgvectorscale .
docker run -d \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD=yourpassword \
  pgduckdb-pgvectorscale
```

## Environment Variables

### PostgreSQL Variables
- `POSTGRES_PASSWORD` - Database password (required)
- `POSTGRES_USER` - Database user (default: postgres)
- `POSTGRES_DB` - Database name (default: postgres)

### S3 Configuration (Optional)
Configure S3 access for DuckDB:
- `S3_ACCESS_KEY_ID` - AWS access key ID
- `S3_SECRET_ACCESS_KEY` - AWS secret access key
- `S3_REGION` - AWS region
- `S3_SESSION_TOKEN` - AWS session token (optional)
- `S3_ENDPOINT` - Custom S3 endpoint (optional)
- `S3_URL_STYLE` - S3 URL style: 'path' or 'vhost' (default: path)

### DuckDB Extensions (Optional)
- `DUCKDB_EXTENSIONS` - Comma-separated list of DuckDB extensions to install

Example:
```bash
DUCKDB_EXTENSIONS=httpfs,parquet,json
```

## Usage Examples

### Using pg_duckdb

```sql
-- Create a table and query with DuckDB
CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    event_time TIMESTAMP,
    user_id INTEGER,
    event_type TEXT
);

-- DuckDB will automatically handle analytical queries
SELECT
    DATE_TRUNC('day', event_time) as day,
    COUNT(*) as event_count
FROM events
GROUP BY day
ORDER BY day;

-- Query S3 data directly (if S3 is configured)
SELECT * FROM read_parquet('s3://bucket/data.parquet');
```

### Using pgvectorscale

```sql
-- Create a table with vector column
CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    content TEXT,
    embedding VECTOR(1536)
);

-- Create a DiskANN index for scalable vector search
CREATE INDEX ON documents USING diskann (embedding);

-- Perform similarity search
SELECT id, content
FROM documents
ORDER BY embedding <-> '[0.1, 0.2, ...]'::vector
LIMIT 10;
```

## Documentation

- [pg_duckdb Docs](https://github.com/duckdb/pg_duckdb)
- [pgvector Docs](https://github.com/pgvector/pgvector)
- [pgvectorscale Docs](https://github.com/timescale/pgvectorscale)
- [Railway Docs](https://docs.railway.app/)

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

Contributions welcome! Please open an issue or submit a PR.

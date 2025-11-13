FROM pgduckdb/pgduckdb:17-v1.0.0 AS builder

USER root

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    libssl-dev \
    pkg-config \
    postgresql-server-dev-17 \
    && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

RUN cd /tmp && \
    git clone --branch v0.8.1 https://github.com/pgvector/pgvector.git && \
    cd pgvector && \
    make && \
    make install

RUN cd /tmp && \
    git clone --branch 0.8.0 https://github.com/timescale/pgvectorscale.git && \
    cd pgvectorscale/pgvectorscale && \
    cargo install --locked cargo-pgrx --version 0.12.9 && \
    cargo pgrx init --pg17 /usr/bin/pg_config && \
    cargo pgrx install --release

FROM pgduckdb/pgduckdb:17-v1.0.0

USER root

RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy pgvector files
COPY --from=builder /usr/share/postgresql/17/extension/vector--*.sql /usr/share/postgresql/17/extension/
COPY --from=builder /usr/share/postgresql/17/extension/vector.control /usr/share/postgresql/17/extension/
COPY --from=builder /usr/lib/postgresql/17/lib/vector.so /usr/lib/postgresql/17/lib/

# Copy pgvectorscale files
COPY --from=builder /usr/share/postgresql/17/extension/vectorscale--*.sql /usr/share/postgresql/17/extension/
COPY --from=builder /usr/share/postgresql/17/extension/vectorscale.control /usr/share/postgresql/17/extension/
COPY --from=builder /usr/lib/postgresql/17/lib/vectorscale*.so /usr/lib/postgresql/17/lib/

# Copy initialization scripts
COPY --chown=postgres:postgres init-extensions.sh /docker-entrypoint-initdb.d/0000-init-extensions.sh
RUN chmod +x /docker-entrypoint-initdb.d/0000-init-extensions.sh

EXPOSE 5432

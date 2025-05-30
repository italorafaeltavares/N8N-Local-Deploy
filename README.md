
# n8n with PostgreSQL, Redis & Nginx - Docker Setup

This repository contains a Docker Compose setup to run **n8n** workflow automation with **PostgreSQL** database, **Redis** queue, and an **Nginx** reverse proxy with SSL for local development.

---

## Project Structure

```
.
├── docker-compose.yml
└── nginx
    ├── conf
    │   └── default.conf
    └── certs
        ├── n8n.local.crt
        └── n8n.local.key
```

---

## Prerequisites

- Docker & Docker Compose installed on your machine
- `openssl` installed (for generating self-signed certificates)
- Permissions to modify your `/etc/hosts` file

---

## Setup Instructions

### 1. Clone this repository

```bash
git clone <your-repository-url>
cd <your-repository-folder>
```

### 2. Generate SSL certificates for `n8n.local`

Create the folder for certificates (if not existing):

```bash
mkdir -p nginx/certs
```

Generate a self-signed certificate valid for 365 days:

```bash
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout nginx/certs/n8n.local.key \
  -out nginx/certs/n8n.local.crt \
  -subj "/CN=n8n.local/O=n8n.local"
```

### 3. Add `n8n.local` to your `/etc/hosts`

Edit your `/etc/hosts` file with admin rights (e.g., `sudo nano /etc/hosts`) and add the line:

```
127.0.0.1 n8n.local
```

This allows your machine to resolve `https://n8n.local` to your local Docker setup.

### 4. Start the Docker containers

```bash
docker-compose up -d
```

This will start:

- PostgreSQL database (container: `n8n_postgres`)
- Redis (container: `n8n_redis`)
- n8n app (container: `n8n`)
- Nginx reverse proxy with SSL (container: `n8n_nginx`)

### 5. Access n8n

Open your browser and navigate to:

```
https://n8n.local
```

Login with the basic auth credentials set in `docker-compose.yml`:

- **Username:** `admin`
- **Password:** `admin123`

---

## Notes

- The PostgreSQL user, password, and database are configured in `docker-compose.yml`.
- The Redis service is used by n8n for queuing.
- Nginx handles SSL termination and proxies HTTPS requests to n8n.
- The Docker Compose configuration includes a network to connect all containers.
- For production, replace self-signed certificates with valid ones.

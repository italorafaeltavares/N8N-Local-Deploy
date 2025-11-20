#!/usr/bin/env bash
set -e

echo "🔧 Setting up local n8n environment..."

# Diretórios
mkdir -p nginx/conf nginx/certs

# Gerar certificado autoassinado se não existir
if [[ ! -f "nginx/certs/n8n.local.crt" || ! -f "nginx/certs/n8n.local.key" ]]; then
  echo "📜 Generating self-signed SSL certificate for n8n.local..."
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout nginx/certs/n8n.local.key \
    -out nginx/certs/n8n.local.crt \
    -subj "/CN=n8n.local/O=n8n.local"
else
  echo "✅ SSL certificate already exists, skipping generation."
fi

# Criar config do NGINX se não existir
if [[ ! -f "nginx/conf/default.conf" ]]; then
  echo "🧩 Creating default NGINX configuration..."
  cat > nginx/conf/default.conf <<'EOF'
server {
    listen 443 ssl;
    server_name n8n.local;

    ssl_certificate /etc/nginx/certs/n8n.local.crt;
    ssl_certificate_key /etc/nginx/certs/n8n.local.key;

    location / {
        proxy_pass http://n8n:5678;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket support (ESSENCIAL)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF
else
  echo "✅ NGINX configuration already exists, skipping creation."
fi

# Verificar /etc/hosts
if ! grep -q "n8n.local" /etc/hosts; then
  echo "⚠️  Please add the following line to your /etc/hosts file (requires sudo):"
  echo "127.0.0.1   n8n.local"
else
  echo "✅ /etc/hosts already contains n8n.local"
fi

# Subir o ambiente
echo "🚀 Starting Docker Compose..."
docker compose down -v
docker compose up -d

echo ""
echo "✅ n8n environment is up and running!"
echo "🌐 Access it at: https://n8n.local (accept the SSL warning)"
echo "🔐 Default login: admin / admin123"

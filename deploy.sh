#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

echo "===> [1/5] Pulling latest code from GitHub..."
git pull

echo "===> [2/5] Starting database, cache and storage (MySQL, Redis & MinIO)..."
docker compose up -d mysql redis minio

echo "===> [3/5] Checking RSA security keys..."
if [ ! -f "private.pem" ] || [ ! -f "public.pem" ]; then
    echo "Generating new RSA keys..."
    openssl genpkey -algorithm RSA -out private.pem -pkeyopt rsa_keygen_bits:2048
    openssl rsa -pubout -in private.pem -out public.pem
else
    echo "RSA keys already exist, skipping generation."
fi

echo "===> [4/5] Rebuilding and starting application containers..."
docker compose up -d --build --force-recreate

echo "===> [5/5] Cleaning up unused Docker images..."
docker image prune -f

echo "=========================================="
echo "🎉 Deployment completed successfully!"
echo "=========================================="

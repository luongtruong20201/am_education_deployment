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

echo "===> [4/5] Pulling latest application images and recreating containers..."
docker compose pull am_education_be am_education_fe nginx
docker compose up -d --force-recreate am_education_be am_education_fe nginx

echo "===> [5/5] Ensuring MinIO media bucket public download policy..."
docker exec -i am_education_minio mc alias set myminio http://localhost:9000 minioadmin minioadminpassword 2>/dev/null || true
docker exec -i am_education_minio mc anonymous set download myminio/ielts-audio 2>/dev/null || true

echo "===> [6/6] Cleaning up unused Docker images..."
docker image prune -f

echo "=========================================="
echo "🎉 Deployment completed successfully!"
echo "=========================================="

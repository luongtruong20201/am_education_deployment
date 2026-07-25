#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

docker compose up -d mysql redis minio

if [ ! -f private.pem ]; then
    openssl genpkey -algorithm RSA -out private.pem -pkeyopt rsa_keygen_bits:2048
    openssl rsa -pubout -in private.pem -out public.pem
fi

sleep 5

docker compose up -d

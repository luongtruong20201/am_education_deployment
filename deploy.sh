#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

docker compose up -d mysql redis

openssl genpkey -algorithm RSA -out private.pem -pkeyopt rsa_keygen_bits:2048
openssl rsa -pubout -in private.pem -out public.pem


sleep 5

docker compose up
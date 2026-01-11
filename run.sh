#!/bin/bash
echo "Starting n8n..."

if [ -f ".env_demo" ]; then
    echo "Loading configuration from .env"
    export $(grep -v '^#' .env_demo | xargs)
else
    echo "WARNING: .env file not found. Using default settings."
    echo "Tip: Copy .env.example to .env to configure options."
fi

# Start n8n
pnpm start

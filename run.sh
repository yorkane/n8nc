#!/bin/bash

# Define environment variables (Hardcoded from .env_demo)
export N8N_DEFAULT_LOCALE=en
export TZ=Asia/Shanghai
export GENERIC_TIMEZONE=Asia/Shanghai
export DB_TYPE=sqlite
export DB_SQLITE_DATABASE=n8nc.sqlite
export N8N_LOG_LEVEL=info
export N8N_LOG_OUTPUT=console
export N8N_SECURE_COOKIE=false
export NODE_FUNCTION_ALLOW_EXTERNAL=*
export NODE_FUNCTION_ALLOW_BUILTIN=*
export N8N_DIAGNOSTICS_ENABLED=false
export N8N_VERSION_NOTIFICATIONS_ENABLED=false
export N8N_ENTERPRISE_MOCK=true
export NODE_ENV=development
export N8N_LICENSE_SERVER_URL=
export N8N_LICENSE_AUTO_RENEW_ENABLED=false
export N8N_LICENSE_CERT=
export N8N_USER_MANAGEMENT_JWT_SECRET=mock-jwt-secret
export N8N_USER_MANAGEMENT_DISABLED=false
export N8N_SAML_ENABLED=true
export N8N_LDAP_ENABLED=true
export N8N_LOG_STREAMING_ENABLED=true
export N8N_VARIABLES_ENABLED=true
export N8N_SOURCE_CONTROL_ENABLED=true
export N8N_EXTERNAL_SECRETS_ENABLED=true
export N8N_WORKFLOW_HISTORY_ENABLED=true
export N8N_DEBUG=true
export N8N_AI_ASSISTANT_BASE_URL=https://api.n8n.io

echo "Starting n8n..."

# Get the absolute path of the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CUSTOM_NODE_DIR="$SCRIPT_DIR/custom_node"
CLI_NODE_MODULES_DIR="$SCRIPT_DIR/packages/cli/node_modules"

# Bundle custom nodes
if [ -d "$CUSTOM_NODE_DIR" ]; then
    echo "Bundling custom nodes from $CUSTOM_NODE_DIR to $CLI_NODE_MODULES_DIR..."
    mkdir -p "$CLI_NODE_MODULES_DIR"
    cp -r "$CUSTOM_NODE_DIR"/n8n-nodes-* "$CLI_NODE_MODULES_DIR/" 2>/dev/null || true
else
    echo "Warning: custom_node directory not found at $CUSTOM_NODE_DIR"
fi

# Start n8n
if command -v xvfb-run &> /dev/null; then
    xvfb-run pnpm start
else
    echo "xvfb-run not found, running without virtual display..."
    pnpm start
fi

# docker run -it -d -e N8N_ENTERPRISE_MOCK=true -e NODE_ENV=development -v /code/n8nc/docker/images/n8n/docker-entrypoint-slim.sh:/docker-entrypoint.sh -v ./n8ndata:/home/node/.n8n -v ./custom_node:/custom_node --name n8ns -p 5678:5678 n8n-slim

# docker run -it -d -e N8N_ENTERPRISE_MOCK=true -e NODE_ENV=development -v ./n8ndata:/data --name n8ns -p 5678:5678 n8n-slim

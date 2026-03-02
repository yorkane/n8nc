pnpm run clean
rm -rf packages/@n8n/eslint-plugin-community-nodes/dist packages/@n8n/eslint-plugin-community-nodes/*.tsbuildinfo
pnpm build
pnpm build:n8n
docker build -f docker/images/n8n/Dockerfile.slim -t n8nc .


# docker save n8nc | xz > n8nc.tar.xz -v -T32
# xz -d -k < n8nc.tar.xz | sudo docker load

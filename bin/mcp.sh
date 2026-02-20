#!/bin/bash
docker run --rm -i \
  -e "ES_API_KEY=Z1J4UXBaa0IwU2MtblJZaWxhYVA6R2NnZ18yVWlRYVNtTXAzZnpEZFdOQQ==" \
  -e "ES_URL=https://logs-c691f0.es.us-east-1.aws.found.io" \
  docker.elastic.co/mcp/elasticsearch \
  stdio

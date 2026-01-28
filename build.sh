#!/bin/bash
# Vercel build script
# Sets the correct baseURL for preview and production deployments

set -e

if [ -n "$VERCEL_URL" ]; then
  # Use the Vercel-provided URL (works for both preview and production)
  echo "Building with baseURL: https://$VERCEL_URL"
  hugo --minify --baseURL "https://$VERCEL_URL"
else
  # Local build - use production URL from config.toml
  echo "Building with default baseURL from config.toml"
  hugo --minify
fi

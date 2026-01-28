#!/bin/bash
# Vercel build script
# Sets the correct baseURL for preview and production deployments

set -e

if [ -n "$VERCEL_URL" ] && [ "$VERCEL_ENV" = "preview" ]; then
  # Use the Vercel-provided URL for preview deployments only
  echo "Building preview with baseURL: https://$VERCEL_URL"
  hugo --minify --baseURL "https://$VERCEL_URL"
else
  # Production or local build - use production URL from config.toml
  echo "Building with default baseURL from config.toml"
  hugo --minify
fi

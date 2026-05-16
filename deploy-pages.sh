#!/bin/bash
set -e

echo "🚀 Deploying Admin to Cloudflare Pages..."
cd cf-pages/admin
npx wrangler pages deploy . --project-name=ihandpump-admin

echo "🚀 Deploying Tracking to Cloudflare Pages..."
cd ../tracking
npx wrangler pages deploy . --project-name=ihandpump-tracking

echo "✅ Pages deployed!"

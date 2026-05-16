#!/bin/bash
set -e

echo "🚀 Deploying iHandPump API to Cloudflare Workers..."
cd cf-workers
npm run deploy
echo "✅ Workers deployed!"

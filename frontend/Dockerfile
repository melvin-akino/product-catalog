# ── Serve pre-built dist with Nginx ─────────────────────────────────────
# The frontend is built locally (npm run build) before deploy.
# This image just copies the already-built dist/ into nginx — no Node,
# no npm install, no Vite on the server. Keeps EC2 RAM free.
FROM nginx:1.25-alpine

COPY dist/ /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=15s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -fso /dev/null http://127.0.0.1/ || exit 1

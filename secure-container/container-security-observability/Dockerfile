# ── Stage 1: dependencias ────────────────────────────────────────────────────
FROM node:20-alpine AS deps
WORKDIR /app
COPY app/package*.json ./
RUN npm ci --omit=dev && npm cache clean --force

# ── Stage 2: builder (análisis estático ligero) ───────────────────────────────
FROM node:20-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY app/ ./
# Eliminar archivos de desarrollo
RUN find . -name "*.test.js" -delete \
 && find . -name "*.spec.js" -delete \
 && find . -name ".env*"     -delete

# ── Stage 3: runtime distroless ───────────────────────────────────────────────
# Imagen mínima: sin shell, sin package manager, sin herramientas de debug
FROM gcr.io/distroless/nodejs20-debian12:nonroot AS runtime

LABEL org.opencontainers.image.title="demo-api" \
      org.opencontainers.image.description="Demo API — Container Security & Observability portfolio" \
      org.opencontainers.image.source="https://github.com/LuchoN83/DevSecOps" \
      org.opencontainers.image.vendor="Lucho Navarrete" \
      org.opencontainers.image.licenses="MIT"

WORKDIR /app

# Copiar solo artefactos necesarios desde builder
COPY --from=builder --chown=nonroot:nonroot /app/node_modules ./node_modules
COPY --from=builder --chown=nonroot:nonroot /app/server.js    ./server.js

# Hardening:
#   - USER nonroot (UID 65532) provisto por imagen distroless
#   - Sin SUID/SGID en el filesystem destino
#   - Puerto no privilegiado
USER nonroot

ENV NODE_ENV=production \
    PORT=3000 \
    APP_VERSION=1.0.0

EXPOSE 3000

# Sin shell disponible → EXEC form obligatorio
CMD ["/nodejs/bin/node", "server.js"]

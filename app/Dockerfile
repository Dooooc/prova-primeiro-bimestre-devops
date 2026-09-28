# =============================================================================
# Stage 1 - deps: instala apenas dependencias de producao
# =============================================================================
FROM node:20-alpine AS deps

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev

# =============================================================================
# Stage 2 - runner: imagem final enxuta com usuario nao-root
# =============================================================================
FROM node:20-alpine AS runner

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules

COPY src ./src
COPY package.json ./

RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 3000

CMD ["node", "src/server.js"]

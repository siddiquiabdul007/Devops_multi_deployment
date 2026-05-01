# ---------- Stage 1: Build ----------
FROM node:25-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

# ---------- Stage 2: Runtime ----------
FROM gcr.io/distroless/nodejs20:nonroot

WORKDIR /app

COPY --from=builder /app .

ENV PORT=3002
ENV USER_SERVICE_URL=http://user-service:80

EXPOSE 3002

# Direct node execution (NO npm)
CMD ["index.js"]
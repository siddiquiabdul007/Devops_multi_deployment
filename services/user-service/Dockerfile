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

ENV PORT=3001
EXPOSE 3001

# Directly run node with your file
CMD ["index.js"]
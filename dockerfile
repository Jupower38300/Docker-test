# Étape 1 : Build de l'application
FROM node:20-alpine AS builder
ARG UID=10001
ARG GID=10001

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Étape 2 : Image finale distroless
FROM gcr.io/distroless/nodejs20-debian12:nonroot

ARG UID=10001
ARG GID=10001

WORKDIR /app

# Copie des fichiers avec permissions adaptées
COPY --chown=${UID}:${GID} --from=builder /app/package*.json ./
COPY --chown=${UID}:${GID} --from=builder /app/node_modules ./node_modules
COPY --chown=${UID}:${GID} --from=builder /app/dist ./dist

# Utilisateur distroless par défaut (nonroot)
USER ${UID}:${GID}

EXPOSE 3000
CMD ["dist/main"]
# Build stage
FROM node:24-alpine AS builder

# Habilitar Corepack para pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# Copiar archivos de dependencias
COPY package.json pnpm-lock.yaml ./

# Instalar dependencias
RUN pnpm install --frozen-lockfile

# Copiar código fuente
COPY . .

# Construir la aplicación
RUN pnpm run build

# Production stage
FROM node:24-alpine AS runtime

# Habilitar Corepack para pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# Copiar archivos de dependencias
COPY package.json pnpm-lock.yaml ./

# Instalar solo dependencias de producción
RUN pnpm install --prod --frozen-lockfile

# Copiar los archivos construidos desde el stage anterior
COPY --from=builder /app/dist ./dist

# Exponer el puerto
EXPOSE 4321

# Usar el comando preview de Astro para servir la build
CMD ["pnpm", "run", "preview", "--host", "0.0.0.0"]
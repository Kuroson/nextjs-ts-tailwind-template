FROM node:20.18.0-alpine AS dev

WORKDIR /app
COPY ./ ./

RUN corepack enable
RUN corepack prepare pnpm@9 --activate
RUN pnpm install --frozen-lockfile

FROM node:20.18.0-alpine AS builder

ENV NODE_ENV=production
WORKDIR /app

COPY --from=dev /app/node_modules node_modules
COPY ./ ./

RUN corepack enable
RUN corepack prepare pnpm@9 --activate
RUN pnpm run build

FROM node:20.18.0-alpine AS prod-deps

ENV NODE_ENV=production
WORKDIR /app

COPY ./ ./

RUN corepack enable
RUN corepack prepare pnpm@9 --activate
RUN pnpm install --frozen-lockfile --prod

FROM node:20.18.0-alpine AS prod

ENV NODE_ENV=production
WORKDIR /app

RUN corepack enable
RUN corepack prepare pnpm@9 --activate

COPY --from=builder /app/.next .next
COPY --from=builder /app/package.json package.json
COPY --from=builder /app/pnpm-lock.yaml pnpm-lock.yaml
COPY --from=prod-deps /app/node_modules node_modules

ENV PORT=3000
EXPOSE 3000

CMD ["pnpm", "run", "start"]

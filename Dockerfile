FROM node:20-alpine as dev

WORKDIR /app
COPY ./ ./

RUN yarn install --frozen-lockfile

FROM node:20-alpine as builder

ENV NODE_ENV production
WORKDIR /app

COPY --from=dev /app/node_modules node_modules
COPY ./ ./

RUN yarn run build

FROM node:20-alpine as prod-deps

ENV NODE_ENV production
WORKDIR /app

COPY ./ ./
RUN yarn install --frozen-lockfile --production

FROM node:20-alpine as prod

ENV NODE_ENV production
WORKDIR /app

COPY --from=builder /app/.next .next
COPY --from=builder /app/package.json package.json
COPY --from=builder /app/yarn.lock yarn.lock
COPY --from=prod-deps /app/node_modules node_modules

ENV PORT 3000
EXPOSE 3000

CMD ["yarn", "start"]

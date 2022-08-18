# syntax=docker/dockerfile:1

# ======================
# Base stage
# ======================

FROM node:16-alpine AS base

EXPOSE 3000
WORKDIR /usr/src/app

# ======================
# Dev stage
# ======================

FROM base AS dev

ARG USERID
ARG GROUPID

RUN apk --no-cache add \
    shadow \
    && usermod -u ${USERID} node \
    && groupmod -o -g ${GROUPID} node

#Run the application
CMD ["npm", "run", "dev"]

# ======================
# Build stage
# ======================

FROM base AS build

COPY ./package*.json ./
RUN npm ci

COPY ./ .
RUN npm run build

# ======================
# Prod stage
# ======================

FROM base AS prod

COPY ./package*.json ./
RUN npm install --only=production

COPY --from=build /usr/src/app/build /usr/src/app/build

USER node

CMD ["npm", "run", "start"]
# build
FROM node:20-alpine AS build
WORKDIR /app
COPY app/package.json ./
RUN npm ci --omit=dev
COPY app/ ./

# run (mínima y no-root)
FROM gcr.io/distroless/nodejs20-debian12
WORKDIR /app
COPY --from=build /app /app
ENV PORT=3000
EXPOSE 3000
USER 65532:65532
CMD ["server.js"]

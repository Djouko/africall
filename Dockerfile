FROM node:22-bookworm-slim

WORKDIR /app

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=8001
ENV EXTRA_PORTS=80,3000

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates python3 make g++ \
    && rm -rf /var/lib/apt/lists/*

COPY upload_this/package*.json ./

RUN npm ci --omit=dev --no-audit --no-fund

COPY upload_this/ ./

RUN mkdir -p temp

EXPOSE 80 3000 8001

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 CMD node -e "const port=process.env.PORT||8001; fetch(`http://127.0.0.1:${port}/health`).then((res)=>process.exit(res.ok?0:1)).catch(()=>process.exit(1))"

CMD ["node", "server.js"]

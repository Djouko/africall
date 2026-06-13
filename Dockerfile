FROM node:22-bookworm-slim

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=8001

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates python3 make g++ \
    && rm -rf /var/lib/apt/lists/*

COPY upload_this/package*.json ./

RUN npm ci --omit=dev --no-audit --no-fund

COPY upload_this/ ./

RUN mkdir -p temp

EXPOSE 8001

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 CMD ["node", "-e", "const http=require('node:http');const port=process.env.PORT||8001;const req=http.get({host:'127.0.0.1',port,path:'/api/web/get_theme',timeout:3000},res=>process.exit(res.statusCode>=200&&res.statusCode<500?0:1));req.on('timeout',()=>req.destroy());req.on('error',()=>process.exit(1));"]

CMD ["node", "server.js"]

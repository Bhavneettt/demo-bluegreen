FROM node:20-alpine
WORKDIR /app
COPY app/ ./app/
WORKDIR /app
RUN npm init -y && npm install express
ENV PORT=3000
EXPOSE 3000
CMD ["node", "server.js"]

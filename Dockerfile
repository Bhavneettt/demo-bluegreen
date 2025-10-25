FROM node:20-alpine
WORKDIR /app

# Copy package files and install dependencies locally first
COPY package*.json ./
COPY node_modules/ ./node_modules/

# Copy application code
COPY app/ ./app/

# Set environment variables
ENV PORT=3000
EXPOSE 3000

# Start the application
CMD ["node", "app/server.js"]

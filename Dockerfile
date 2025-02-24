# Use a Node.js base image
FROM node:18

# Set the working directory
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the app's source code
COPY . .

# Download Whisper model (adjust model size as needed)
RUN npx whisper-node download --model base

# Expose the port
EXPOSE 3000

# Start the Node.js server
CMD ["node", "server.js"]

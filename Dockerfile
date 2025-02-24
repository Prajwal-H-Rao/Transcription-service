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

# Ensure models directory exists
RUN mkdir -p /app/models

# Download Whisper model directly from the source
RUN curl -L -o /app/models/ggml-base.bin https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.bin

# Expose the port
EXPOSE 3000

# Start the Node.js server
CMD ["node", "server.js"]

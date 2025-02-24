FROM node:18-alpine

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install
COPY . .

# Install build tools, compile whisper.cpp, and copy the whisper-cli binary
RUN apk add --no-cache build-base cmake git wget && \
    git clone https://github.com/ggerganov/whisper.cpp.git && \
    cd whisper.cpp && \
    make && \
    cp build/whisper-cli /usr/local/bin/whisper

# Download the model file and update its permissions
RUN mkdir models && \
    wget -O models/ggml-base.en.bin "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin" && \
    chmod 644 models/ggml-base.en.bin

EXPOSE 4000
CMD ["node", "server.js"]

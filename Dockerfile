FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install
COPY . .

# Install build dependencies, clone and compile whisper.cpp
RUN apk add --no-cache build-base cmake git wget && \
    git clone https://github.com/ggerganov/whisper.cpp.git && \
    cd whisper.cpp && \
    make && cp /app/bin/main /usr/local/bin/whisper

# Create models directory and download model
RUN mkdir models && \
    wget -O models/ggml-base.en.bin "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin"

EXPOSE 4000
CMD ["node", "server.js"]
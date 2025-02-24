FROM node:16-buster

WORKDIR /home/prajw/whisper-node-server

# Copy package files and install Node.js dependencies
COPY package*.json ./
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    cmake
RUN npm install

# Clone and build whisper.cpp dependency
RUN git clone https://github.com/ggerganov/whisper.cpp.git && \
    cd whisper.cpp && \
    mkdir build && cd build && \
    cmake .. && make

# Copy remaining project files
COPY . .

# Expose the port (adjust if needed)
EXPOSE 4000

# Start the server
CMD ["node", "server.js"]

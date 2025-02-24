FROM node:16-buster

WORKDIR /home/prajw/whisper-node-server

# Copy package files and install Node.js dependencies
COPY package*.json ./
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    cmake
RUN npm install

# Remove old cmake and install a newer version
RUN apt-get remove -y cmake && \
    wget https://github.com/Kitware/CMake/releases/download/v3.22.0/cmake-3.22.0-linux-x86_64.sh && \
    chmod +x cmake-3.22.0-linux-x86_64.sh && \
    ./cmake-3.22.0-linux-x86_64.sh --skip-license --prefix=/usr/local && \
    rm cmake-3.22.0-linux-x86_64.sh

# Clone and build whisper.cpp dependency with filesystem flag
RUN git clone https://github.com/ggerganov/whisper.cpp.git && \
    cd whisper.cpp && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_EXE_LINKER_FLAGS="-lstdc++fs" && make

# Copy remaining project files
COPY . .

# Expose the port (adjust if needed)
EXPOSE 4000

# Start the server
CMD ["node", "server.js"]

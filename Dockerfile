FROM node:16-alpine
WORKDIR /app

# Copy package files and install dependencies (whisper model installs here via postinstall)
COPY package*.json ./
RUN npm install

#Copy the rest of the application code
COPY . .

# Expose the port used by the application
EXPOSE 4000

# Start the server
CMD ["node", "server.js"]

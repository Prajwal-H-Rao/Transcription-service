FROM node:18

WORKDIR /app

COPY package*.json ./
RUN npm install
COPY . .

# Install the 'base.en' model during image build non-interactively
RUN echo "" | npx whisper-node download base

EXPOSE 4000
CMD ["node", "server.js"]
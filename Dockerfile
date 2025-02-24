FROM node:14-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install
COPY . .

# Install the 'base.en' model during image build
RUN npx whisper-node download base

EXPOSE 4000
CMD ["node", "start.js"]
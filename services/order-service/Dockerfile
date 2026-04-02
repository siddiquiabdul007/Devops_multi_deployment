FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

ENV PORT=3002
ENV USER_SERVICE_URL=http://user-service:80

EXPOSE 3002

CMD ["npm", "start"]

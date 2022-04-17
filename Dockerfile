FROM node:17.7.2-alpine

WORKDIR /usr/src/app

COPY package*.json ./

RUN yarn install

COPY src/ .

EXPOSE 8080

CMD [ "node", "index.js" ]
FROM node:17.7.2-alpine

WORKDIR /usr/src/app

# COPY package*.json ./

# RUN yarn install

COPY src/index.js ./
COPY ./node_modules ./node_modules

EXPOSE 8080

CMD [ "node", "index.js" ]
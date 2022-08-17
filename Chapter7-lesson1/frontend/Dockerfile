FROM node:14.17.3-alpine
ARG VERSION=${VERSION}
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
RUN npm install -g http-server
COPY . .
RUN npm run build
EXPOSE 80
ENTRYPOINT ["http-server", "dist/frontend/", "-p", "80", "--proxy", "http://backend:8080"]

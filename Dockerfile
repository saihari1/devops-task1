FROM node:16-alpine
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN addgroup -S devgroup && adduser -S dev -G devgroup
USER dev
EXPOSE 3000
CMD ["npm", "start"]


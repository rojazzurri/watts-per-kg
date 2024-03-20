# base image
FROM node:lts-alpine

# set working directory
WORKDIR /app

# install app dependencies
COPY package.json ./
RUN npm install

# add app
COPY . ./

# start app
CMD ["npm", "run", "serve"]

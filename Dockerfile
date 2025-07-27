FROM node:20-slim as builder
WORKDIR /app
COPY ./package.json .
COPY ./yarn.lock .
RUN yarn install
COPY . .
RUN yarn build
EXPOSE 3000
CMD ["npm", "start"]

# Builder Stage
# FROM node:20-slim AS builder
# WORKDIR /app
# # Install dependencies
# COPY package.json yarn.lock ./
# RUN yarn install --frozen-lockfile
# # Copy source code
# COPY . .
# # Build the application
# RUN yarn build
# # Clean up
# RUN yarn cache clean && rm -rf node_modules

# # Runtime Stage
# FROM nginx:stable-alpine
# WORKDIR /usr/share/nginx/html
# # Remove default Nginx files
# RUN rm -rf ./*
# # Copy built assets
# COPY --from=builder /app/build .
# # Expose port 80
# EXPOSE 80
# # Start Nginx
# ENTRYPOINT ["nginx", "-g", "daemon off;"]
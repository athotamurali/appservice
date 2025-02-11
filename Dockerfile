# Use official Node.js image from Docker Hub
FROM node:14

# Set working directory inside the container
WORKDIR /app

# Copy the package.json and package-lock.json files into the container
COPY package*.json ./

# Install the dependencies
RUN npm install

# Copy the application code into the container
COPY . .

# Expose the application port (for example, 8080)
EXPOSE 8080

# Run the application
CMD ["npm", "start"]

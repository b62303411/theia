FROM node:18-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set up Theia
WORKDIR /theia
RUN npm install -g @theia/cli@1.39.0 && \
    yarn global add @theia/cli && \
    yarn theia download:plugins \
    --plugin @theia/python@latest \
    --plugin @theia/file-search@latest \
    --plugin @theia/git@latest \
    && yarn cache clean

# Copy Theia configuration
COPY package.json /theia/package.json
RUN yarn theia build

# Expose Theia port
EXPOSE 3000

# Persistent workspace
VOLUME /home/project

# Start Theia
CMD ["yarn", "theia", "start", "--hostname=0.0.0.0", "--port=3000"]

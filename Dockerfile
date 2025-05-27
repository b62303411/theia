FROM node:22-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Yarn explicitly
RUN npm install -g yarn

# Set up Theia
WORKDIR /theia
COPY package.json .

# Install dependencies and download plugins
RUN yarn install && \
    yarn global add @theia/cli@latest && \
    $(yarn global bin)/theia download:plugins \
    --plugin ms-python.python@latest \
    --plugin theia.file-search@latest \
    --plugin theia.git@latest > plugins.log 2>&1 && \
    yarn cache clean || { cat plugins.log; echo "Plugin download failed"; exit 1; }

# Install Python dependencies for ms-python.python
RUN pip3 install --no-cache-dir python-language-server

# Build Theia
RUN yarn theia build > build.log 2>&1 || { cat build.log; echo "Theia build failed"; exit 1; }

# Expose Theia port
EXPOSE 3000

# Persistent workspace
VOLUME /home/project

# Start Theia with logging
CMD yarn theia start --hostname=0.0.0.0 --port=3000 > start.log 2>&1 || { cat start.log; echo "Theia start failed"; exit 1; }

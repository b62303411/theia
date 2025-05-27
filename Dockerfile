FROM node:22-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set up Theia
WORKDIR /theia
COPY package.json package.json

# Add Yarn global bin to PATH dynamically
RUN yarn global add @theia/cli@1.39.0 && \
    export PATH=$(yarn global bin):$PATH && \
    theia --version && \
    yarn theia download:plugins \
    --plugin ms-python.python@2024.20.1 \
    --plugin theia.file-search@1.39.0 \
    --plugin theia.git@1.39.0 && \
    yarn cache clean || { echo "Plugin download failed"; exit 1; }

# Copy Theia configuration (already copied above, this might be redundant)
COPY package.json /theia/package.json
RUN yarn theia build || { echo "Theia build failed"; exit 1; }

# Expose Theia port
EXPOSE 3000

# Persistent workspace
VOLUME /home/project

# Start Theia
CMD ["yarn", "theia", "start", "--hostname=0.0.0.0", "--port=3000"]

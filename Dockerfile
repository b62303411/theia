FROM node:18

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*
# Verify Yarn is available
RUN yarn --version > yarn_version.log 2>&1 || { echo "Yarn not found"; exit 1; }

# Set up Theia
WORKDIR /theia
COPY package.json .

# Install dependencies and plugins
RUN yarn install > install.log 2>&1 && \
    yarn global add @theia/cli@latest && \
    $(yarn global bin)/theia download:plugins \
    --plugin ms-python.python@latest \
    --plugin theia.file-search@latest \
    --plugin theia.git@latest > plugins.log 2>&1 && \
    yarn cache clean || { cat install.log plugins.log; echo "Dependency or plugin installation failed"; exit 1; }

# Install Python dependencies
RUN pip3 install --no-cache-dir python-language-server pylint

# Build Theia
RUN yarn theia build > build.log 2>&1 || { cat build.log; echo "Theia build failed"; exit 1; }

# Expose Theia port
EXPOSE 3000

# Persistent workspace
VOLUME /home/project

# Start Theia with logging
CMD ["yarn", "theia", "start", "--hostname=0.0.0.0", "--port=3000"]

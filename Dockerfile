# Use official Node.js image with Yarn preinstalled
FROM node:16-bullseye-slim

# ---- System Dependencies ----
# Combine all apt operations into a single layer
RUN apt-get update && \
    apt-get install -y \
    python3 \
    python3-pip \
    git \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# ---- Theia Setup ----
WORKDIR /theia

# Copy package.json first for better caching
COPY package.json .

# Install dependencies in one layer with cleanup
RUN yarn install --frozen-lockfile && \
    yarn global add @theia/cli@latest && \
    $(yarn global bin)/theia download:plugins \
      --plugin ms-python.python@latest \
      --plugin theia.file-search@latest \
      --plugin theia.git@latest && \
    yarn cache clean

# ---- Python Support ----
RUN pip3 install --no-cache-dir python-language-server pylint

# ---- Build Theia ----
RUN yarn theia build

# ---- Security ----
# Create non-root user
RUN useradd -m theia-user && chown -R theia-user:theia-user /theia
USER theia-user

# ---- Networking & Storage ----
EXPOSE 3000
VOLUME /home/project

# ---- Startup ----
CMD ["yarn", "theia", "start", "--hostname=0.0.0.0", "--port=3000"]

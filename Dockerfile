FROM node:18-bookworm-slim

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-pip \
        git \
        build-essential \
        libsecret-1-dev \
        unzip \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /theia

# Copy application files
COPY package.json ./
# COPY yarn.lock ./  # Uncomment if you have a yarn.lock file

# Install dependencies
RUN yarn config set ignore-engines true && \
    yarn install

# Copy and install VS Code extensions
COPY plugins/*.vsix /plugins/
RUN mkdir -p /home/theia/plugins && \
    for vsix in /plugins/*.vsix; do \
        unzip "$vsix" -d "/home/theia/plugins/$(basename "$vsix" .vsix)"; \
    done

# Install Python packages
RUN pip3 install --no-cache-dir pylint python-lsp-server

# Create and switch to a non-root user
RUN useradd -m theia-user && chown -R theia-user:theia-user /theia
USER theia-user

# Expose port and define volume
EXPOSE 3000
VOLUME /home/project

# Start Theia
CMD ["yarn", "theia", "start", "--hostname=0.0.0.0", "--port=3000"]

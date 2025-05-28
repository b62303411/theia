FROM node:18-bookworm-slim

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-pip \
        git \
        build-essential \
        libsecret-1-dev \
        curl \
        unzip && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /theia

# Copy application files
COPY package.json ./

# Install dependencies
RUN yarn config set ignore-engines true && \
    yarn install

# Create plugins directory
RUN mkdir -p /home/theia/plugins

RUN curl -L -o /tmp/ms-python.python.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-python/vsextensions/python/2025.7.2025052102/vspackage
RUN file /tmp/ms-python.python.vsix
RUN unzip /tmp/ms-python.python.vsix -d /home/theia/plugins/ms-python.python

# Download and install the Python extension
RUN curl -L -o /tmp/ms-python.python.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-python/vsextensions/python/2025.7.2025052601/vspackage && \
    unzip /tmp/ms-python.python.vsix -d /home/theia/plugins/ms-python.python && \
    rm /tmp/ms-python.python.vsix

# Download and install VS Code extensions
RUN curl -L -o /tmp/ms-python.python.vsix https://open-vsx.org/api/ms-python/python/2024.6.0/file/ms-python.python-2024.6.0.vsix && \
    unzip /tmp/ms-python.python.vsix -d /home/theia/plugins/ms-python.python && \
    curl -L -o /tmp/vscode.git.vsix https://open-vsx.org/api/vscode/git/1.81.0/file/vscode.git-1.81.0.vsix && \
    unzip /tmp/vscode.git.vsix -d /home/theia/plugins/vscode.git && \
    rm /tmp/*.vsix

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

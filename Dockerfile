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
        unzip \
        libarchive-tools \
        file && \
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
RUN mkdir -p /home/theia/plugins/ms-python.python 
RUN gunzip -c /tmp/ms-python.python.vsix > /home/theia/plugins/ms-python.python/ms-python.python

RUN apt-get update && apt-get install -y python3 python3-pip python3-venv
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install requests

# Install Python packages
RUN pip3 install --no-cache-dir pylint python-lsp-server

# Create and switch to a non-root user
RUN useradd -m theia-user && chown -R theia-user:theia-user /theia
USER theia-user
# *** CRUCIAL: BUILD THEIA ***
RUN yarn theia build
# Expose port and define volume
EXPOSE 3000
VOLUME /home/project

# Start Theia
CMD ["yarn", "theia", "start", "--hostname=0.0.0.0", "--port=3000"]

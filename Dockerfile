FROM node:18-bookworm-slim
WORKDIR /theia

# Install OS deps
RUN apt-get update && \
    apt-get install -y python3 python3-pip python3-venv git build-essential libsecret-1-dev curl unzip libarchive-tools file openjdk-17-jdk maven p7zip-full && \
    rm -rf /var/lib/apt/lists/*

# Clone your Theia app repo (or official Theia)
RUN git clone --depth=1 https://github.com/eclipse-theia/theia.git .   # Or use your custom app

# Optionally: checkout a specific stable version/tag
# RUN git checkout v1.47.0

# Install Node deps
RUN yarn config set ignore-engines true && yarn

# Build theia
RUN yarn theia build

# Install Python tools as before
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install requests pylint python-lsp-server

# Expose port and define volume
EXPOSE 3000
VOLUME /home/project

# Start Theia
CMD ["yarn", "theia", "start", "--hostname=0.0.0.0", "--port=3000"]

FROM node:18-bookworm-slim

RUN apt-get update && \
    apt-get install -y \
      python3 \
      python3-pip \
      git \
      build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /theia

COPY package.json .
#COPY yarn.lock .  # Generate lockfile locally for reproducibility

RUN yarn config set ignore-engines true && \
    yarn install --frozen-lockfile && \
    yarn theia download:plugins \
      --plugin ms-python.python@2024.6.0 \
      --plugin vscode.git@1.81.0

RUN pip3 install --no-cache-dir pylint python-lsp-server

RUN useradd -m theia-user && chown -R theia-user:theia-user /theia
USER theia-user

EXPOSE 3000
VOLUME /home/project

CMD ["yarn", "theia", "start", "--hostname=0.0.0.0", "--port=3000"]

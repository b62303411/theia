FROM codercom/code-server:latest

USER root

# Install OpenJDK (Java 17), Maven and Git (optional, but useful for Java projects)
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk maven git && \
    rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME (for VS Code Java tools)
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

USER coder

# Preinstall Java extensions (Java Extension Pack by Microsoft)
RUN code-server --install-extension vscjava.vscode-java-pack && \
    code-server --install-extension vscjava.vscode-java-debug && \
    code-server --install-extension vscjava.vscode-java-dependency && \
    code-server --install-extension vscjava.vscode-java-test

# (Optional) Expose VS Code’s default port
EXPOSE 8443

# Create project workspace
RUN mkdir -p /home/coder/project

WORKDIR /home/coder/project

# Entrypoint is already set to code-server in base image

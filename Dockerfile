FROM theiaide/theia:1.47.0

# Add tools you need, e.g.:
USER root
RUN apt-get update && apt-get install -y python3 python3-pip openjdk-17-jdk maven && rm -rf /var/lib/apt/lists/*
USER theia
EXPOSE 3000
CMD ["yarn", "theia", "start", "--hostname=0.0.0.0", "--port=3000"]

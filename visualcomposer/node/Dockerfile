FROM ubuntu:14.04

RUN \
  apt-get update && \
  apt-get install -y wget curl php5 git zip && \
  curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
  apt-get install -y nodejs && \
  rm -rf /var/lib/apt/lists/*

# Define default command.
CMD ["bash"]

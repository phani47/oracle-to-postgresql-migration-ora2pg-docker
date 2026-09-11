FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    ora2pg \
    perl \
    libdbd-pg-perl \
    postgresql-client \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

CMD ["bash"]

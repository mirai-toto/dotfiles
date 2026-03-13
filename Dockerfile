FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
# Required for Homebrew to install non-interactively
ENV NONINTERACTIVE=1

# Install Homebrew dependencies + locale tools
RUN apt-get update && apt-get install -y \
    sudo git curl file build-essential procps \
    locales ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user with passwordless sudo (mirrors WSL setup)
RUN useradd -m -s /bin/bash testuser \
    && echo 'testuser ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER testuser
ENV USER=testuser
WORKDIR /home/testuser

# Copy dotfiles and run install during build so the image is pre-configured
COPY --chown=testuser:testuser . /home/testuser/dotfiles
RUN cd /home/testuser/dotfiles && bash install.sh

# Drop into zsh on every docker run
CMD ["/home/linuxbrew/.linuxbrew/bin/zsh"]

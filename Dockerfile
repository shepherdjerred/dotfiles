FROM ubuntu:24.04

# Avoid prompts from apt during build
ENV DEBIAN_FRONTEND=noninteractive \
    NONINTERACTIVE=1 \
    APT_LISTCHANGES_FRONTEND=none

# Install basic dependencies that might be needed before running install.sh
RUN apt-get update && \
    apt-get install -y \
    ca-certificates \
    curl \
    git \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Copy the entire repository into the container
COPY . /opt/dotfiles

# Set working directory
WORKDIR /opt/dotfiles

# Make install.sh executable and run it with local dotfiles
RUN chmod +x /opt/dotfiles/install.sh && \
    DOTFILES_LOCAL_PATH=/opt/dotfiles bash /opt/dotfiles/install.sh

# Add linuxbrew to PATH for all users
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

# Set fish as the default shell (if you want)
# Uncomment the following line if you want fish to be the default shell
# SHELL ["/home/linuxbrew/.linuxbrew/bin/fish", "-c"]

# Set default command to fish shell
CMD ["/home/linuxbrew/.linuxbrew/bin/fish"]

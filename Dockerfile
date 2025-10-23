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

# Make install.sh executable and run it with local dotfiles, then clean up aggressively
RUN chmod +x /opt/dotfiles/install.sh && \
    DOTFILES_LOCAL_PATH=/opt/dotfiles bash /opt/dotfiles/install.sh && \
    # Clean up Homebrew cache and downloads
    /home/linuxbrew/.linuxbrew/bin/brew cleanup --prune=all -s && \
    rm -rf /home/linuxbrew/.cache/Homebrew/* && \
    rm -rf /root/.cache/Homebrew/* && \
    # Clean up apt cache
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apt/archives/* && \
    # Clean up mise cache
    rm -rf /root/.local/share/mise/installs/*/downloads/* && \
    rm -rf /root/.local/share/mise/downloads/* && \
    # Clean up installation logs (keep marker but remove logs)
    rm -rf /var/lib/dotfiles/*.log /var/lib/dotfiles/*.json /var/lib/dotfiles/*.txt && \
    # Remove .git directories from cloned repos to save space
    rm -rf /root/.tmux/plugins/*/.git && \
    rm -rf /root/.config/delta/themes/.git && \
    # Clean up chezmoi cache
    rm -rf /root/.cache/chezmoi/* && \
    # Remove temporary files
    rm -rf /tmp/* /var/tmp/* && \
    # Clean up npm/pip caches if they exist
    rm -rf /root/.npm/_cacache/* && \
    rm -rf /root/.cache/pip/* && \
    # Remove the copied dotfiles directory as it's no longer needed
    rm -rf /opt/dotfiles

# Add linuxbrew to PATH for all users
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"

# Set fish as the default shell (if you want)
# Uncomment the following line if you want fish to be the default shell
# SHELL ["/home/linuxbrew/.linuxbrew/bin/fish", "-c"]

# Set default command to fish shell
CMD ["/home/linuxbrew/.linuxbrew/bin/fish"]

FROM ubuntu:24.04

# Build arguments
ARG USER_UID=1000
ARG USER_GID=1000
ARG USERNAME=jerred

# Avoid prompts from apt during build
ENV DEBIAN_FRONTEND=noninteractive \
    NONINTERACTIVE=1 \
    APT_LISTCHANGES_FRONTEND=none

# Install basic dependencies
RUN apt-get update && \
    apt-get install -y \
    ca-certificates \
    curl \
    git \
    sudo \
    gosu \
    && rm -rf /var/lib/apt/lists/*

# Create user with sudo privileges (handle existing GID/UID)
RUN groupadd --gid ${USER_GID} ${USERNAME} 2>/dev/null || groupmod -n ${USERNAME} $(getent group ${USER_GID} | cut -d: -f1) \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} -s /bin/bash 2>/dev/null || usermod -l ${USERNAME} -d /home/${USERNAME} -m $(getent passwd ${USER_UID} | cut -d: -f1) \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# Create brew group for shared access
RUN groupadd -r brew \
    && usermod -aG brew ${USERNAME}

# Pre-create linuxbrew directory with correct ownership
RUN mkdir -p /home/linuxbrew/.linuxbrew \
    && chown -R ${USERNAME}:brew /home/linuxbrew \
    && chmod -R g+w /home/linuxbrew

# Copy the entire repository into the container
COPY . /opt/dotfiles

# Set working directory
WORKDIR /opt/dotfiles

# Initialize git repo for chezmoi (it expects a git repository)
RUN git init && \
    git config user.email "docker@localhost" && \
    git config user.name "Docker Build" && \
    git add . && \
    git commit -m "Initial commit"

# Make install.sh executable and run it, then clean up aggressively
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

# Create /etc/profile.d script for login shells
RUN printf '#!/bin/bash\nexport PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"\nif command -v mise &>/dev/null; then\n    eval "$(mise activate bash --shims)"\nfi\n' > /etc/profile.d/linuxbrew.sh \
    && chmod +x /etc/profile.d/linuxbrew.sh

# Fix ownership after root installation
RUN chown -R ${USERNAME}:${USERNAME} /home/${USERNAME} \
    && chown -R ${USERNAME}:brew /home/linuxbrew \
    && chmod -R g+w /home/linuxbrew \
    && chown -R ${USERNAME}:${USERNAME} /var/lib/dotfiles 2>/dev/null || true \
    && chown -R ${USERNAME}:${USERNAME} /root/.local/share/mise 2>/dev/null || true \
    && chown -R ${USERNAME}:${USERNAME} /root/.config 2>/dev/null || true \
    && chown -R ${USERNAME}:${USERNAME} /root/.tmux 2>/dev/null || true

# Move root's dotfiles to user's home
RUN cp -r /root/.local /home/${USERNAME}/ 2>/dev/null || true \
    && cp -r /root/.config /home/${USERNAME}/ 2>/dev/null || true \
    && cp -r /root/.tmux /home/${USERNAME}/ 2>/dev/null || true \
    && cp -r /root/.tmux.conf /home/${USERNAME}/ 2>/dev/null || true \
    && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

# Change default shell to fish
RUN chsh -s /home/linuxbrew/.linuxbrew/bin/fish ${USERNAME}

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh

# Environment variables
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}" \
    BASH_ENV="/etc/profile.d/linuxbrew.sh" \
    HOME="/home/${USERNAME}" \
    USER="${USERNAME}"

# Switch to user
USER ${USERNAME}
WORKDIR /home/${USERNAME}

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/home/linuxbrew/.linuxbrew/bin/fish"]

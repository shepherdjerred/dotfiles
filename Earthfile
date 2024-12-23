VERSION 0.8

test:
  FROM DOCKERFILE -f .devcontainer/Dockerfile .
  ENV CODESPACES=true
  COPY . /workspaces/.codespaces/.persistedshare/dotfiles
  WORKDIR /workspaces/.codespaces/.persistedshare/dotfiles
  # so that Homebrew believes we're responsible enough to run as root
  # https://github.com/Homebrew/install/blob/master/install.sh#L324
  RUN touch /.dockerenv
  RUN ./install.sh

FROM gitpod/workspace-full:latest

# USER gitpod

# # Install .NET Core 5.0 SDK binaries on Ubuntu 20.04
# # Source: https://dev.to/carlos487/installing-dotnet-core-in-ubuntu-20-04-6jh
# RUN mkdir -p /home/gitpod/dotnet && curl -fsSL https://download.visualstudio.microsoft.com/download/pr/a0487784-534a-4912-a4dd-017382083865/be16057043a8f7b6f08c902dc48dd677/dotnet-sdk-5.0.101-linux-x64.tar.gz | tar xz -C /home/gitpod/dotnet
# ENV DOTNET_ROOT=/home/gitpod/dotnet
# ENV PATH=$PATH:/home/gitpod/dotnet

# ==============

USER root

# This Dockerfile adds a non-root user with sudo access. Use the "remoteUser"
# property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# will be updated to match your local UID/GID (when using the dockerFile property).
# See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=gitpod
ARG USER_UID=33333
ARG USER_GID=$USER_UID

# User for nvm
ARG USER_NVM_NAME=gitpod
ARG USER_NVM_UID=33333
ARG USER_NVM_GID=$USER_NVM_UID

ARG NODE_VERSION="lts/*"

ARG DOTNET_INSTALL_DIR=/usr/share/dotnet

ENV \
    # Unset ASPNETCORE_URLS from aspnet base image
    ASPNETCORE_URLS= \
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1 \
    NVM_DIR=/home/$USER_NVM_NAME/.nvm \
    DOTNET_ROOT=$DOTNET_INSTALL_DIR

# Configure apt and install packages
RUN install-packages \
      apt-utils dialog rsync 2>&1 \
      # Verify git, process tools, lsb-release (common in install instructions for CLIs) installed
      bzip2 openssh-client less iproute2 procps apt-transport-https gnupg2 curl lsb-release psmisc \
    ## setup the locales
    && update-locale LANG=C.UTF-8 \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && curl -fsSL https://dot.net/v1/dotnet-install.sh | bash -s -- --install-dir $DOTNET_INSTALL_DIR\
    # Set dotnet paths
    && echo "export DOTNET_ROOT='$DOTNET_INSTALL_DIR'"> /etc/profile.d/dotnet.sh \
    && echo 'export PATH="~/.dotnet/tools:$DOTNET_ROOT:$PATH"'> /etc/profile.d/dotnet.sh \
    # Set owner to .vscode-serverXYZ folders
    && chown -R $USERNAME:$USERNAME \
        /home/$USERNAME \
    # root user node installs
    && /bin/bash -c "source $NVM_DIR/nvm.sh \
            && nvm install ${NODE_VERSION} \
            && nvm alias default ${NODE_VERSION} \
            && npm install -g npm typescript yarn 2>&1" \
    # Set nvm profile loading and path
    && chmod -R g+w "$NVM_DIR" \
    && chmod a+r "$NVM_DIR/nvm.sh" \
    && chmod a+r "$NVM_DIR/bash_completion" \
    && echo "export NVM_DIR='$NVM_DIR'" > /etc/profile.d/nvm.sh \
    && echo '[ -s "$NVM_DIR/nvm-lazy.sh" ] && source "$NVM_DIR/nvm-lazy.sh" || [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh" || true' >> /etc/profile.d/nvm.sh \
    && echo '[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion" || true' >> /etc/profile.d/nvm.sh \
    && chmod 644 /etc/profile.d/nvm.sh \
    && [ ! -f /home/$USERNAME/.bashrc.d/50-node ] || rm -f /home/$USERNAME/.bashrc.d/50-node \
    # Set node modules path
    && echo 'export PATH="./node_modules/.bin:$PATH"' > /etc/profile.d/node_modules.sh

# Debian containers have a bug supporting locales in containers, so we use C.UTF-8 because some apps need it.
ENV \
  LC_ALL=C.UTF-8 \
  LANG=C.UTF-8 \
  LANGUAGE=C.UTF-8

WORKDIR /root


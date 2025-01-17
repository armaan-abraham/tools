FROM --platform=linux/amd64 nvidia/cuda:11.8.0-base-ubuntu22.04


# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install basic utilities and dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    vim \
    && rm -rf /var/lib/apt/lists/*

RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg \
    && install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ \
    && echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list \
    && apt-get update \
    && apt-get install -y code

RUN curl -sSf https://rye.astral.sh/get | RYE_INSTALL_OPTION="--yes" bash
ENV PATH="/root/.rye/shims:${PATH}"

# Configure git (replace with your details)
RUN git config --global user.name "Armaan Abraham" \
    && git config --global user.email "armaan.abraham@hotmail.com"

# # Install VS Code extensions
# RUN code --install-extension ms-python.python \
#     --no-sandbox \
#     --user-data-dir /root/.vscode \
#     && code --install-extension ms-python.vscode-pylance \
#     --no-sandbox \
#     --user-data-dir /root/.vscode \
#     && code --install-extension ms-toolsai.jupyter \
#     --no-sandbox \
#     --user-data-dir /root/.vscode

WORKDIR /root

CMD ["bash"]

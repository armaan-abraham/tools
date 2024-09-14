#!/bin/bash

setup_git() {
    read -p "Enter GitHub username: " github_username
    read -sp "Enter GitHub auth token: " github_token
    echo
    read -p "Enter GitHub repository URL: " repo_url

    git config --global user.name "$github_username"
    git config --global user.password "$github_token"
    git clone "$repo_url"
    
    # Get the repository name from the URL
    repo_name=$(basename "$repo_url" .git)
    
    # Move the current script into the cloned repository
    mv "$0" "$repo_name/"
    
    echo "Moved setup script into $repo_name directory"
}

install_rye() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        curl -sSf https://rye-up.com/get | bash
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        curl -sSf https://rye-up.com/get | bash
    else
        echo "Unsupported OS for Rye installation"
        exit 1
    fi
    source "$HOME/.rye/env"
    rye sync
}

check_gpu() {
    if command -v nvidia-smi &> /dev/null; then
        echo "CUDA GPU available:"
        nvidia-smi
        python -c "import torch; print('PyTorch CUDA available:', torch.cuda.is_available())"
    else
        echo "CUDA GPU not found"
    fi
}

case "$1" in
    "git") setup_git ;;
    "rye") install_rye ;;
    "gpu") check_gpu ;;
    *) echo "Usage: $0 {git|rye|gpu}" ;;
esac
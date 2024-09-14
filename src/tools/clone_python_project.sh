#!/bin/bash

setup_git() {
    read -p "Enter GitHub email: " github_email
    read -sp "Enter GitHub auth token: " github_token

    git config --global user.email "$github_email"
    git config --global user.password "$github_token"

    # Test the token
    if curl -s -H "Authorization: token $github_token" https://api.github.com/user | grep -q "login"; then
        :
    else
        echo "GitHub authentication failed. Please check your token and try again."
        exit 1
    fi

    echo
    read -p "Enter GitHub repository URL: " repo_url

    git clone "$repo_url"
    
    # Get the repository name from the URL
    repo_name=$(basename "$repo_url" .git)
    
    # Move the current script into the cloned repository
    mv "$0" "$repo_name/"
    
    echo "Success"
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
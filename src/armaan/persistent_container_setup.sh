# Set custom Rye installation path
export PERSIST_DIR="$(pwd)"

# Create .local directory if it doesn't exist
mkdir -p "$PERSIST_DIR/.local"

setup_rye() {
    RYE_HOME="$PERSIST_DIR/.local/rye"

    if [ ! -f "$PERSIST_DIR/.rye-source-added" ]; then
        export RYE_HOME="$PERSIST_DIR/.local/rye"
        curl -sSf https://rye.astral.sh/get | bash

        # Update shell configuration files to use custom Rye path
        if ! echo "source \"$RYE_HOME/env\"" >> ~/.profile 2>/dev/null; then
            echo "Failed to update ~/.profile."
        fi
        if ! echo "source \"$RYE_HOME/env\"" >> ~/.bashrc 2>/dev/null; then
            echo "Failed to update ~/.bashrc."
        fi
        
        # Source the new Rye environment
        source "$RYE_HOME/env"

        # Create marker file to indicate rye is configured
        touch "$PERSIST_DIR/.rye-source-added"
        echo "Rye setup complete."
    else
        echo "Rye source already added."
    fi
}


setup_git() {
    # Only prompt for credentials if git config or credentials file doesn't exist
    if [ ! -f "$PERSIST_DIR/.gitconfig" ] || [ ! -f "$PERSIST_DIR/.git-credentials" ]; then
        # Get GitHub credentials
        read -p "Enter GitHub email: " github_email
        read -p "Enter GitHub name: " github_name
        read -sp "Enter GitHub auth token: " github_token
        echo  # New line after password input

        # Create git config in persistent directory
        cat > "$PERSIST_DIR/.gitconfig" << EOL
[user]
    email = $github_email
    name = $github_name
[credential]
    helper = store
EOL

        # Store credentials in persistent directory
        echo "https://oauth2:${github_token}@github.com" > "$PERSIST_DIR/.git-credentials"
    fi

    # Always test GitHub authentication
    if curl -s -H "Authorization: token $(grep -o 'oauth2:.*@' "$PERSIST_DIR/.git-credentials" | cut -d':' -f2 | cut -d'@' -f1)" https://api.github.com/user | grep -q "login"; then
        echo "GitHub authentication successful."
    else
        echo "GitHub authentication failed. Please check your token and try again."
        rm "$PERSIST_DIR/.gitconfig" "$PERSIST_DIR/.git-credentials"
        exit 1
    fi

    # Always configure git to use the persistent config and credentials
    git config --global include.path "$PERSIST_DIR/.gitconfig"
    git config --global credential.helper "store --file=$PERSIST_DIR/.git-credentials"
}

setup_rye
setup_git

exec bash

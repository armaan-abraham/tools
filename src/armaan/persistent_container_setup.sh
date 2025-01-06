# Set custom Rye installation path
export PERSIST_DIR="/home/ubuntu/v2025-01-06"

setup_rye() {
    RYE_HOME="$PERSIST_DIR/.local/rye"

    if [ ! -f "$PERSIST_DIR/.rye-source-added" ]; then
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
    # Check if git is already configured by looking for a marker file
    if [ ! -f "$PERSIST_DIR/.git-configured" ]; then
        # Get GitHub credentials
        read -p "Enter GitHub email: " github_email
        read -sp "Enter GitHub auth token: " github_token
        echo  # New line after password input

        # Create git config in persistent directory
        cat > "$PERSIST_DIR/.gitconfig" << EOL
[user]
    email = $github_email
[credential]
    helper = store
EOL

        # Store credentials in persistent directory
        echo "https://oauth2:${github_token}@github.com" > "$PERSIST_DIR/.git-credentials"
        
        # Test the token
        if curl -s -H "Authorization: token $github_token" https://api.github.com/user | grep -q "login"; then
            echo "GitHub authentication successful."
            # Create marker file to indicate git is configured
            touch "$PERSIST_DIR/.git-configured"
        else
            echo "GitHub authentication failed. Please check your token and try again."
            rm "$PERSIST_DIR/.gitconfig" "$PERSIST_DIR/.git-credentials"
            exit 1
        fi
    else
        echo "Git is already configured."
    fi

    # Always run these commands when setting up a new instance
    git config --global include.path "$PERSIST_DIR/.gitconfig"
    git config --global credential.helper "store --file=$PERSIST_DIR/.git-credentials"
}

setup_rye
setup_git

exec bash

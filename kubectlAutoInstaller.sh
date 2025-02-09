#!/bin/bash

# Function to set up the .kube directory
setup_kube_directory() {
    echo "Ensuring the .kube directory exists..."

    # Ensure the HOME directory is correctly expanded and accessible
    KUBE_DIR="$HOME/.kube"

    # Create the .kube directory if it doesn't exist
    if [ ! -d "$KUBE_DIR" ]; then
        mkdir -p "$KUBE_DIR"
        if [ $? -eq 0 ]; then
            echo ".kube directory created at $KUBE_DIR"
        else
            echo "Failed to create the .kube directory at $KUBE_DIR"
            exit 1
        fi
    else
        echo ".kube directory already exists at $KUBE_DIR"
    fi
}

# Function to check and install kubectl
install_kubectl() {
    echo "Installing kubectl..."

    # Fetch the latest stable version of kubectl dynamically
    VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)

    # Define the kubectl binary download URL
    DOWNLOAD_URL="https://dl.k8s.io/release/$VERSION/bin/linux/amd64/kubectl"

    # Download the kubectl binary with the correct URL
    curl -LO "$DOWNLOAD_URL"

    # Check if the download was successful
    if [ $? -ne 0 ]; then
        echo "Failed to download kubectl from $DOWNLOAD_URL"
        exit 1
    fi

    # Make kubectl executable
    chmod +x kubectl

    # Move kubectl to /usr/local/bin to make it accessible globally
    sudo mv kubectl /usr/local/bin/

    echo "kubectl installation complete!"
}

# Set up the .kube directory first
setup_kube_directory

# Check if kubectl is installed and get the current version
if command -v kubectl &> /dev/null; then
    INSTALLED_VERSION=$(kubectl version --client --output=json | jq -r '.clientVersion.gitVersion')
    echo "kubectl is already installed. Current version: $INSTALLED_VERSION"

    # Fetch the latest stable version of kubectl
    LATEST_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    echo "Latest available version: $LATEST_VERSION"

    # Compare installed version with the latest version
    if [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]; then
        echo "A new version of kubectl is available!"
        read -p "Do you want to install the latest version (Y/N)? " choice
        case "$choice" in
            [Yy]* )
                install_kubectl
                ;;
            [Nn]* )
                echo "Keeping the current version of kubectl."
                ;;
            * )
                echo "Invalid input. Exiting."
                exit 1
                ;;
        esac
    else
        echo "You already have the latest version of kubectl installed."
    fi
else
    echo "kubectl is not installed. Installing the latest version..."
    install_kubectl
fi

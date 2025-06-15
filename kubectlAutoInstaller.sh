#!/bin/bash

# Enable exit on error and undefined variables
set -euo pipefail

# Global variables for cleanup
TEMP_FILES=()

# Function to cleanup temporary files
cleanup() {
    echo "Cleaning up temporary files..."
    for file in "${TEMP_FILES[@]}"; do
        if [ -f "$file" ]; then
            rm -f "$file"
            echo "Removed: $file"
        fi
    done
}

# Set trap to cleanup on exit/interrupt
trap cleanup EXIT INT TERM

# Function to download with retry logic
download_with_retry() {
    local url=$1
    local output_file=$2
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo "Downloading $output_file (attempt $attempt/$max_attempts)..."
        if curl -fL --connect-timeout 10 --max-time 300 -o "$output_file" "$url"; then
            echo "✓ Download successful: $output_file"
            return 0
        else
            echo "✗ Download failed (attempt $attempt/$max_attempts)"
            if [ $attempt -eq $max_attempts ]; then
                echo "Error: Failed to download after $max_attempts attempts"
                echo "URL: $url"
                return 1
            fi
            echo "Retrying in 5 seconds..."
            sleep 5
            ((attempt++))
        fi
    done
}

# Function to validate downloaded file
validate_file() {
    local file=$1
    local min_size=${2:-100}  # Minimum file size in bytes
    
    if [ ! -f "$file" ]; then
        echo "Error: File does not exist: $file"
        return 1
    fi
    
    local file_size=$(stat -c%s "$file" 2>/dev/null || echo 0)
    if [ "$file_size" -lt "$min_size" ]; then
        echo "Error: File too small (${file_size} bytes): $file"
        echo "Expected at least ${min_size} bytes"
        return 1
    fi
    
    echo "✓ File validation passed: $file (${file_size} bytes)"
    return 0
}

# Function to check and install dependencies
check_dependencies() {
    echo "Checking dependencies..."
    
    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        echo "jq not found. Installing jq..."
        if command -v apt &> /dev/null; then
            sudo apt update && sudo apt install -y jq
        elif command -v yum &> /dev/null; then
            sudo yum install -y jq
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y jq
        elif command -v brew &> /dev/null; then
            brew install jq
        else
            echo "Error: Package manager not found. Please install jq manually."
            echo "Visit: https://stedolan.github.io/jq/download/"
            exit 1
        fi
        
        # Verify installation
        if ! command -v jq &> /dev/null; then
            echo "Error: jq installation failed"
            exit 1
        fi
        echo "✓ jq installed successfully"
    else
        echo "✓ jq is already installed"
    fi
}

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

# Function to detect system architecture and OS
detect_platform() {
    # Detect OS
    OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    
    # Detect architecture
    ARCH=$(uname -m)
    case $ARCH in
        x86_64)
            ARCH="amd64"
            ;;
        aarch64)
            ARCH="arm64"
            ;;
        armv7l)
            ARCH="arm"
            ;;
        i386|i686)
            ARCH="386"
            ;;
        *)
            echo "Error: Unsupported architecture: $ARCH"
            echo "Supported architectures: x86_64 (amd64), aarch64 (arm64), armv7l (arm), i386/i686 (386)"
            exit 1
            ;;
    esac
    
    # Validate OS support
    case $OS in
        linux|darwin|windows)
            ;;
        *)
            echo "Error: Unsupported operating system: $OS"
            echo "Supported operating systems: linux, darwin (macOS), windows"
            exit 1
            ;;
    esac
    
    echo "Detected platform: $OS/$ARCH"
}

# Function to check and install kubectl
install_kubectl() {
    echo "Installing kubectl..."

    # Detect platform first
    detect_platform

    # Fetch the latest stable version of kubectl dynamically
    echo "Fetching latest kubectl version..."
    if ! VERSION=$(curl -fL -s --connect-timeout 10 https://dl.k8s.io/release/stable.txt); then
        echo "Error: Failed to fetch latest kubectl version"
        echo "Please check your internet connection or try again later"
        exit 1
    fi
    echo "Latest kubectl version: $VERSION"

    # Define the kubectl binary download URL based on detected platform
    DOWNLOAD_URL="https://dl.k8s.io/release/$VERSION/bin/$OS/$ARCH/kubectl"
    CHECKSUM_URL="https://dl.k8s.io/release/$VERSION/bin/$OS/$ARCH/kubectl.sha256"

    # Add files to cleanup list
    TEMP_FILES+=("kubectl" "kubectl.sha256")

    # Download the kubectl binary with retry logic
    if ! download_with_retry "$DOWNLOAD_URL" "kubectl"; then
        echo "Error: Failed to download kubectl binary"
        exit 1
    fi

    # Validate kubectl binary
    if ! validate_file "kubectl" 1000000; then  # Expect at least 1MB
        echo "Error: Downloaded kubectl binary appears to be invalid"
        exit 1
    fi

    # Download checksum file for verification
    if ! download_with_retry "$CHECKSUM_URL" "kubectl.sha256"; then
        echo "Error: Failed to download kubectl checksum"
        exit 1
    fi

    # Validate checksum file
    if ! validate_file "kubectl.sha256" 50; then  # Expect at least 50 bytes
        echo "Error: Downloaded checksum file appears to be invalid"
        exit 1
    fi

    # Verify binary integrity
    echo "Verifying kubectl binary integrity..."
    if echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check --quiet; then
        echo "✓ kubectl binary verified successfully"
    else
        echo "✗ kubectl binary verification failed - potentially corrupted download"
        echo "This could indicate a network issue or security problem"
        exit 1
    fi

    # Make kubectl executable
    chmod +x kubectl

    # Backup existing kubectl if it exists
    if [ -f "/usr/local/bin/kubectl" ]; then
        BACKUP_NAME="kubectl.backup.$(date +%Y%m%d_%H%M%S)"
        echo "Backing up existing kubectl..."
        sudo cp /usr/local/bin/kubectl "/usr/local/bin/$BACKUP_NAME"
        if [ $? -eq 0 ]; then
            echo "✓ Existing kubectl backed up as: $BACKUP_NAME"
            echo "  To restore: sudo mv /usr/local/bin/$BACKUP_NAME /usr/local/bin/kubectl"
        else
            echo "⚠ Warning: Failed to backup existing kubectl"
        fi
    fi

    # Move kubectl to /usr/local/bin to make it accessible globally
    if sudo mv kubectl /usr/local/bin/; then
        echo "✓ kubectl installed to /usr/local/bin/"
        
        # Verify installation
        if kubectl version --client --short &>/dev/null; then
            echo "✓ kubectl installation verified successfully"
            INSTALLED_VERSION=$(kubectl version --client --output=json | jq -r '.clientVersion.gitVersion')
            echo "Installed version: $INSTALLED_VERSION"
        else
            echo "⚠ Warning: kubectl installed but verification failed"
        fi
    else
        echo "✗ Error: Failed to install kubectl to /usr/local/bin/"
        echo "Please check sudo permissions and try again"
        exit 1
    fi

    echo "kubectl installation complete!"
}

# Check dependencies first
check_dependencies

# Set up the .kube directory
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

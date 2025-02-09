# Kubectl Installation and Configuration Script

This is a simple Bash script to install `kubectl`, check for updates, and ensure that the `.kube` directory exists in the user's home directory. 

## Features:
- **Installs kubectl**: Downloads and installs the latest stable version of `kubectl`.
- **Checks for kubectl updates**: If `kubectl` is already installed, it checks for the latest version and asks if you'd like to update it.
- **Ensures .kube directory exists**: Regardless of whether kubectl is installed or updated, the script ensures that the `.kube` directory exists in your home directory.

## Requirements
- Linux-based system (tested on Ubuntu, but should work on other Linux distributions).
- `curl` must be installed for downloading `kubectl`.
- `sudo` privileges to move the `kubectl` binary to `/usr/local/bin/`.

## Setup Instructions

### 1. Clone the Repository
Clone this repository to your local machine:

```bash
git clone https://github.com/yourusername/kubectl-install-script.git

# Kubectl Installation and Configuration Script

This Bash script automates the installation, update, and configuration of `kubectl`, the Kubernetes command-line tool. It ensures that `kubectl` is installed and updated while also setting up the `.kube` directory for proper configuration.

## Features
- **Installs `kubectl`**: Downloads and installs the latest stable version of `kubectl`.
- **Checks for updates**: If `kubectl` is already installed, the script verifies if an update is available and prompts the user for an upgrade.
- **Ensures `.kube` directory exists**: Creates the necessary `.kube` directory for Kubernetes configurations.

## Requirements
Before running this script, ensure the following requirements are met:
- A **Linux-based system** (Tested on Ubuntu; should work on other distributions).
- `curl` must be installed for downloading `kubectl`.
- `jq` must be installed for parsing JSON output.
- `sudo` privileges are required to move the `kubectl` binary to `/usr/local/bin/`.

### Install Required Dependencies
Ensure you have `curl` and `jq` installed before running the script:
```bash
sudo apt update && sudo apt install -y curl jq  # For Debian/Ubuntu
sudo yum install -y curl jq  # For RHEL/CentOS
sudo dnf install -y curl jq  # For Fedora
```

## Installation Instructions

### 1. Clone the Repository
Clone this repository to your local machine:
```bash
git clone https://github.com/z3r0-c001/kubectl-install-script.git
cd kubectl-install-script
```

### 2. Set Execute Permissions
Ensure the script has execute permissions:
```bash
chmod +x install-kubectl.sh
```

### 3. Run the Script
Execute the script to install or update `kubectl`:
```bash
./install-kubectl.sh
```

### 4. Verify Installation
After installation, confirm that `kubectl` is installed and working correctly:
```bash
kubectl version --client
```

## Updating `kubectl`
If `kubectl` is already installed, the script will check for the latest version. If an update is available, it will prompt you to install it.

You can manually check for updates using:
```bash
curl -L -s https://dl.k8s.io/release/stable.txt
```

## Additional Resources
- **Kubernetes Official Documentation**: [https://kubernetes.io/docs/home/](https://kubernetes.io/docs/home/)
- **kubectl Documentation**: [https://kubernetes.io/docs/reference/kubectl/](https://kubernetes.io/docs/reference/kubectl/)
- **kubectl Releases**: [https://github.com/kubernetes/kubectl/releases](https://github.com/kubernetes/kubectl/releases)

## Troubleshooting
If you encounter issues, consider the following:
- Ensure you have `curl` and `jq` installed.
- Run the script with `sudo` if necessary.
- Check that `/usr/local/bin/` is in your `PATH`:
  ```bash
  echo $PATH
  ```
- Manually install `kubectl` if the script fails:
  ```bash
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
  ```

## License
This project is open-source and available under the [MIT License](license).

## Attribution
This script was developed and maintained by [z3r0-c001](https://github.com/z3r0-c001). Contributions and feedback are welcome!

---
For issues and contributions, please create a pull request or open an issue in the repository.


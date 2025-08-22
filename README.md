# kubectl Auto Installer

A robust Bash script to automatically download and install the latest stable version of `kubectl` with enterprise-grade security and reliability features.

## 🚀 Features

- **🔒 Security First**: SHA256 checksum verification for all downloads
- **🌐 Multi-Platform Support**: Works on Linux, macOS, and Windows (WSL)
- **🏗️ Multi-Architecture**: Supports x86_64, ARM64, ARM, and i386 architectures
- **🛡️ Robust Error Handling**: Automatic retries, network timeout handling, and comprehensive validation
- **💾 Backup & Restore**: Automatic backup of existing kubectl with restore instructions
- **🛠️ Dependency Management**: Auto-installs required dependencies (`jq`)
- **📊 Progress Feedback**: Clear status messages and validation throughout the process
- **🧹 Clean Exit**: Automatic cleanup of temporary files on exit or interruption

## 🔧 Prerequisites

The script automatically handles most dependencies, but you'll need:

- Linux, macOS, or Windows (WSL) operating system
- `curl` (usually pre-installed)
- `sudo` privileges (for system-wide installation)
- Internet connection

**Note**: The script will automatically install `jq` if it's missing using your system's package manager.

## 📦 Installation & Usage

### Quick Start

1. **Download and run**:
   ```bash
   wget https://raw.githubusercontent.com/your-repo/kubectlAutoInstaller/main/kubectlAutoInstaller.sh
   chmod +x kubectlAutoInstaller.sh
   ./kubectlAutoInstaller.sh
   ```

2. **Or clone and run**:
   ```bash
   git clone <repository-url>
   cd kubectlAutoInstaller
   chmod +x kubectlAutoInstaller.sh
   ./kubectlAutoInstaller.sh
   ```

3. **Verify installation**:
   ```bash
   kubectl version --client
   ```

## 🔍 How It Works

### Security & Validation Process
1. **Dependency Check**: Verifies and installs `jq` if needed
2. **Platform Detection**: Auto-detects OS and CPU architecture
3. **Version Fetching**: Securely retrieves latest kubectl version from Kubernetes API
4. **Secure Download**: Downloads kubectl binary with retry logic and timeout handling
5. **Integrity Verification**: Downloads and verifies SHA256 checksums
6. **File Validation**: Checks file sizes and permissions before installation
7. **Backup Creation**: Creates timestamped backup of existing kubectl
8. **Installation**: Installs verified binary to `/usr/local/bin`
9. **Verification**: Confirms successful installation and functionality

### Supported Platforms
| OS | Architecture | Status |
|---|---|---|
| Linux | x86_64 (amd64) | ✅ Fully Supported |
| Linux | ARM64 (aarch64) | ✅ Fully Supported |
| Linux | ARM (armv7l) | ✅ Fully Supported |
| Linux | i386/i686 | ✅ Fully Supported |
| macOS | x86_64/ARM64 | ✅ Fully Supported |
| Windows (WSL) | x86_64/ARM64 | ✅ Fully Supported |

## 📝 Example Output

```bash
$ ./kubectlAutoInstaller.sh

Checking dependencies...
✓ jq is already installed
Ensuring the .kube directory exists...
✓ .kube directory already exists at /home/user/.kube

kubectl is already installed. Current version: v1.28.2
Latest available version: v1.29.0
Detected platform: linux/amd64

A new version of kubectl is available!
Do you want to install the latest version (Y/N)? Y

Installing kubectl...
Downloading kubectl (attempt 1/3)...
✓ Download successful: kubectl
✓ File validation passed: kubectl (45123456 bytes)
Downloading kubectl.sha256 (attempt 1/3)...
✓ Download successful: kubectl.sha256
✓ File validation passed: kubectl.sha256 (65 bytes)
Verifying kubectl binary integrity...
✓ kubectl binary verified successfully

Backing up existing kubectl...
✓ Existing kubectl backed up as: kubectl.backup.20241215_143022
  To restore: sudo mv /usr/local/bin/kubectl.backup.20241215_143022 /usr/local/bin/kubectl

✓ kubectl installed to /usr/local/bin/
✓ kubectl installation verified successfully
Installed version: v1.29.0

kubectl installation complete!
Cleaning up temporary files...
Removed: kubectl
Removed: kubectl.sha256
```

## 🛠️ Advanced Features

### Backup & Restore
The script creates timestamped backups of existing kubectl installations:
```bash
# Automatic backup location
/usr/local/bin/kubectl.backup.YYYYMMDD_HHMMSS

# To restore a backup
sudo mv /usr/local/bin/kubectl.backup.20241215_143022 /usr/local/bin/kubectl
```

### Error Recovery
- **Network failures**: Automatic retry with exponential backoff
- **Download corruption**: SHA256 verification prevents corrupted installations
- **Permission issues**: Clear error messages with troubleshooting guidance
- **Interrupted installation**: Automatic cleanup of temporary files

### Security Features
- SHA256 checksum verification for all downloads
- File size validation to detect truncated downloads
- Secure HTTPS downloads with connection timeouts
- Temporary file cleanup on script exit or interruption

## 🔧 Troubleshooting

### Common Issues

**Permission Denied**
```bash
Error: Failed to install kubectl to /usr/local/bin/
```
**Solution**: Ensure you have sudo privileges and run with appropriate permissions.

**Network Timeout**
```bash
✗ Download failed (attempt 1/3)
```
**Solution**: Check internet connection. The script will automatically retry up to 3 times.

**Architecture Not Supported**
```bash
Error: Unsupported architecture: <arch>
```
**Solution**: Currently supports x86_64, aarch64, armv7l, i386. File an issue for additional architecture support.

### Manual Dependency Installation

If automatic dependency installation fails:

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y jq curl

# RHEL/CentOS/Fedora
sudo yum install -y jq curl
# or
sudo dnf install -y jq curl

# macOS
brew install jq curl
```

## 🔒 Security Considerations

- **Source Verification**: Downloads only from official Kubernetes repositories (`https://dl.k8s.io/`)
- **Integrity Checks**: All binaries are verified with SHA256 checksums
- **HTTPS Only**: All network communication uses encrypted connections
- **Minimal Privileges**: Requests sudo only when necessary for installation
- **Clean Environment**: Temporary files are automatically cleaned up

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues or pull requests for:
- Additional platform/architecture support
- Enhanced error handling
- Security improvements
- Documentation updates

## 📞 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Verify your platform is supported
3. Ensure you have the required permissions
4. File an issue with detailed error output
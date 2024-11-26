# CI/CD Training Repository with KVM and Packer

This repository serves as a hands-on training resource for learning Continuous Integration (CI) practices using KVM virtualization and HashiCorp Packer. The project demonstrates real-world DevOps practices including environment validation, secure SSH key management, and automated testing.

## Overview

This training repository showcases:
- Automated environment validation
- Secure SSH key management
- GitHub Actions CI pipeline
- Infrastructure as Code principles
- Best practices for DevOps workflows

## Repository Structure

```
.
├── .github/workflows     # CI pipeline definitions
├── scripts              # Utility scripts
│   ├── healthcheck_environment.sh
│   ├── healthcheck_ssh_key.sh
│   └── setup_ssh.sh
├── packer               # Packer configurations
├── cloud-init           # Cloud-init templates
├── environments         # Environment-specific configs
│   └── README.md        # Environment README
├── .gitignore           # Git ignore file
└── README.md            # Documentation
```

## Branch Strategy

- `main`: Production-ready code
- `develop`: Integration branch
- `feature/*`: Feature development branches

## Key Components

### 1. Environment Validation

The environment validation system ensures all necessary prerequisites are met:
- Virtualization support (KVM)
- System resources (RAM, CPU, Disk)
- Required packages
- Network configuration
- User permissions

### 2. SSH Key Management

The project implements secure SSH key management for VM provisioning:
- ED25519 key generation (more secure than RSA)
- Proper permission settings (600 for private, 644 for public)
- Integration with Packer and cloud-init
- Automated validation checks

### 3. CI Pipeline

The GitHub Actions pipeline ensures code quality and environment consistency:
```yaml
jobs:
  healthcheck:    # Validates environment
  setup-ssh:      # Manages SSH keys
```

## Understanding SSH Keys in CI/CD

SSH keys are fundamental to secure VM provisioning:

1. **Key Pairs**: 
   - Private key (stays secure)
   - Public key (distributed to VMs)

2. **Security Considerations**:
   - Key permissions are critical
   - Private keys must remain confidential
   - Proper key types (ED25519 recommended)

3. **CI/CD Integration**:
   - Keys generated during CI pipeline
   - Stored as artifacts for subsequent jobs
   - Used by Packer for VM provisioning

## Getting Started

1. Clone the repository:
```bash
git checkout -b feature/your-feature develop
```

2. Validate your environment:
```bash
sudo ./scripts/healthcheck_environment.sh
```

3. Set up SSH keys:
```bash
./scripts/setup_ssh.sh
```

4. Verify SSH setup:
```bash
./scripts/healthcheck_ssh_key.sh
```

## Best Practices Demonstrated

1. **Security**:
   - Secure key generation
   - Proper file permissions
   - Environment variable handling

2. **CI/CD**:
   - Step-by-step validation
   - Clear job dependencies
   - Environment consistency

3. **Code Quality**:
   - Modular script design
   - Comprehensive error handling
   - Clear logging and feedback

4. **Documentation**:
   - Clear structure
   - Step-by-step guides
   - Security considerations

## Learning Objectives

After working with this repository, students should understand:
1. CI/CD pipeline structure and workflow
2. Secure SSH key management
3. Environment validation importance
4. GitHub Actions configuration
5. Infrastructure as Code principles

## Additional Resources

1. **SSH Security**:
   - [OpenSSH Documentation](https://www.openssh.com/manual.html)
   - [SSH Key Best Practices](https://infosec.mozilla.org/guidelines/openssh)

2. **CI/CD**:
   - [GitHub Actions Documentation](https://docs.github.com/en/actions)
   - [DevOps Best Practices](https://docs.github.com/en/actions/learn-github-actions/best-practices-for-github-actions)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
#!/usr/bin/env bash

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Set IFS to newline and tab for better readability
IFS=$'\n\t'

# Values
SSH_DIR="${HOME}/.ssh"
PACKER_KEY="${SSH_DIR}/packer_key"
PACKER_VARS="packer/variables/ssh.pkrvars.hcl"
CLOUD_INIT_TPL="cloud-init/templates/ssh.yml.tpl"

echo "Starting SSH key health check..."
echo "----------------------------------------"

check_ssh_dir() {
    echo "Checking SSH directory..."

    # Check SSH directory permissions
    if [[ -d "$SSH_DIR" ]]; then
        if [[ "$(stat -c %a "$SSH_DIR")" == "700" ]]; then
            echo "SSH directory permissions are correct."
        else
            echo "SSH directory permissions are incorrect. Expected 700, got $(stat -c %a "$SSH_DIR")"
            exit 1
        fi
    else
        echo "SSH directory does not exist."
        exit 1
    fi
}

# Check private key
check_private_key() {
    echo "Checking private key..."

    # Check if the private key exists
    if [[ -f "$PACKER_KEY" ]]; then
        # Check permissions
        if [[ "$(stat -c %a "$PACKER_KEY")" == "600" ]]; then
            echo "Private key exists with correct permissions."
        else
            echo "Private key has incorrect permissions. Expected: 600, Got: $(stat -c %a "$PACKER_KEY")"
            exit 1
        fi
    else
        echo "Private key not found at $PACKER_KEY"
        exit 1
    fi
}

check_public_key() {
    echo "Checking public key..."

    # Check public key
    if [[ -f "${PACKER_KEY}.pub" ]]; then
        if [[ "$(stat -c %a "${PACKER_KEY}.pub")" == "644" ]]; then
            echo "Public key exists with correct permissions."
        else
            echo "Public key has incorrect permissions. Expected: 644, Got: $(stat -c %a "${PACKER_KEY}.pub")"
            exit 1
        fi
    else
        echo "Public key not found at ${PACKER_KEY}.pub"
        exit 1
    fi
}

validate_public_key_format() {
    echo "Validating public key format..."

    # Validate public key format
    if ! ssh-keygen -l -f "${PACKER_KEY}.pub" &>/dev/null; then
        echo "Invalid public key format"
        exit 1
    else
        echo "Public key format is valid"
    fi
}

check_packer_vars() {
    echo "Checking packer vars..."

    if [[ -f "$PACKER_VARS" ]]; then
        if grep -q "ssh_public_key" "$PACKER_VARS"; then
            echo "Packer variables file exists and contains SSH configuration"
        else
            echo "Packer variables file exists but is missing SSH configuration"
            exit 1
        fi
    else
        echo "Packer variables file not found at $PACKER_VARS"
        exit 1
    fi
}

check_cloud_init_tpl() {
    echo "Checking cloud init template..."

    if [[ -f "$CLOUD_INIT_TPL" ]]; then
        if grep -q "ssh_authorized_keys:" "$CLOUD_INIT_TPL"; then
            echo "Cloud-init template exists and contains SSH configuration"
        else
            echo "Cloud-init template exists but is missing SSH configuration"
            exit 1
        fi
    else
        echo "Cloud-init template not found at $CLOUD_INIT_TPL"
        exit 1
    fi
}

# Main function
main() {
    echo "Starting healthcheck..."
    echo "----------------------------------------"

    # Run checks
    check_ssh_dir
    check_private_key
    check_public_key
    validate_public_key_format
    check_packer_vars
    check_cloud_init_tpl

    echo "----------------------------------------"
    echo "All checks passed successfully"
}

main "$@"

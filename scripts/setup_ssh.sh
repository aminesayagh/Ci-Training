#!/usr/bin/env bash

# Exit on error, unset variables, and pipefail
set -euo pipefail

# Set IFS to newline and tab
IFS=$'\n\t'

# Default values
KEY_NAME="packer_key"
SSH_DIR="${HOME}/.ssh"
KEY_TYPE="ed25519" # More secure than RSA
KEY_COMMENT="packer@$(hostname)"

check_dependencies() {
    # Check if ssh-keygen is installed
    if ! command -v ssh-keygen &>/dev/null; then
        echo "ssh-keygen could not be found"
        exit 1
    fi
}

generate_ssh_key() {
    # Ensure the SSH directory exists with correct permissions
    if [[ ! -d "${SSH_DIR}" ]]; then
        mkdir -p "${SSH_DIR}"
        chmod 700 "${SSH_DIR}"
    fi

    # Generate the key
    local key_file
    key_file="${SSH_DIR}/${KEY_NAME}"

    # Check if the key already exists
    if [[ -f "$key_file" ]]; then
        echo "SSH key already exists: $key_file"
        return
    fi

    echo "Generating SSH key: $key_file"
    ssh-keygen -t "${KEY_TYPE}" -C "${KEY_COMMENT}" -f "${key_file}" -N ""
    chmod 600 "${key_file}"
    chmod 644 "${key_file}.pub"
    echo "SSH key generated: $key_file"
}

# Create Packer variables file with SSH key information
create_packer_vars() {
    local vars_file="packer/variables/ssh.pkrvars.hcl"
    local key_file="${SSH_DIR}/${KEY_NAME}"

    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$vars_file")"

    # Create variables file
    cat >"$vars_file" <<EOF
# SSH key configuration for Packer
ssh_username = "ubuntu"
ssh_private_key_file = "${key_file}"
ssh_public_key_file = "${key_file}.pub"
ssh_public_key = "$(cat "${key_file}.pub")"
EOF

    echo "Created Packer variables file: $vars_file"
}

# Create cloud-init template for SSH key
create_cloud_init_template() {
    local template_file="cloud-init/templates/ssh.yml.tpl"
    local key_file="${SSH_DIR}/${KEY_NAME}"

    # Create directory if it doesn't exist
    mkdir -p "$(dirname "$template_file")"

    # Create cloud-init template
    cat >"$template_file" <<EOF
#cloud-config
ssh_authorized_keys:
  - \${ssh_public_key}

users:
  - name: ubuntu
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - \${ssh_public_key}
EOF

    echo "Created cloud-init template: $template_file"
}

main() {
    echo "Setting up SSH..."

    check_dependencies
    generate_ssh_key
    create_packer_vars
    create_cloud_init_template

    echo "SSH setup complete."
}

main "$@"

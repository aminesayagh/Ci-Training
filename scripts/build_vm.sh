#!/usr/bin/env bash
# scripts/build_vm.sh

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Set IFS to newline and tab
IFS=$'\n\t'

# Default values
PACKER_TEMPLATE="packer/ubuntu-kvm.pkr.hcl"
VARS_FILE="packer/variables/ssh.pkrvars.hcl"
OUTPUT_DIR="output"

check_dependencies() {
    echo "Checking dependencies..."
    # Check if packer is installed
    if ! command -v packer &>/dev/null; then
        echo "packer could not be found"
        exit 1
    fi
}

validate_packer_template() {
    echo "Validating packer template..."
    if ! packer validate -var-file="${VARS_FILE}" "${PACKER_TEMPLATE}"; then
        echo "Packer template validation failed"
        exit 1
    fi
    echo "Packer template validated successfully"
}

build_vm() {
    echo "Building VM..."
    if ! packer build -force -var-file="${VARS_FILE}" "${PACKER_TEMPLATE}"; then
        echo "VM build failed"
        exit 1
    fi
    echo "VM built successfully"
}

verify_output() {
    echo "Verifying output..."

    local qcow2_file="output-ubuntu-22.04/ubuntu-22.04.qcow2"
    if [[ ! -f "${qcow2_file}" ]]; then
        echo "QCOW2 file not found"
        exit 1
    fi
    echo "QCOW2 file verified successfully"
}

main() {
    echo "Starting build process..."
    echo "----------------------------------------"

    check_dependencies
    validate_packer_template
    build_vm
    verify_output

    echo "----------------------------------------"
    echo "Build process completed successfully"
}

main "$@"

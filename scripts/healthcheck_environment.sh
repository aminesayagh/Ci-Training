#!/usr/bin/env bash
# healthcheck_environment.sh

# Exit on error, unset variable, or pipe failure
set -euo pipefail

# Set IFS to newline and tab
IFS=$'\n\t'

# Required packages
REQUIRED_PACKAGES=(
    "qemu-kvm"
    "libvirt-daemon-system"
    "libvirt-clients"
    "bridge-utils"
    "packer"
    "cloud-init"
    "curl"
    "wget"
    "jq"
)

# Required system resources
MIN_RAM_GB=4
MIN_DISK_GB=20
MIN_CPU_CORES=2

check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root or with sudo privileges"
        exit 1
    fi
}

check_virtualization() {
    echo "Checking virtualization support..."

    if grep -E --color 'vmx|svm' /proc/cpuinfo >/dev/null; then
        echo "Virtualization support detected"
    else
        echo "Virtualization support not detected"
        exit 1
    fi

    if lsmod | grep kvm >/dev/null; then
        echo "KVM module loaded"
    else
        echo "KVM module not loaded"
        exit 1
    fi
}

check_system_resources() {
    echo "Checking system resources..."

    # Check RAM
    local total_ram_gb
    total_ram_gb=$(free -g | awk '/^Mem:/{print $2}')
    if [[ $total_ram_gb -lt $MIN_RAM_GB ]]; then
        echo "Insufficient RAM: $total_ram_gb GB (required $MIN_RAM_GB GB)"
        exit 1
    fi

    # Check disk space
    local total_disk_gb
    total_disk_gb=$(df -BG / | awk 'NR==2 {print $4}' | tr -d 'G')
    if [[ $total_disk_gb -lt $MIN_DISK_GB ]]; then
        echo "Insufficient disk space: $total_disk_gb GB (required $MIN_DISK_GB GB)"
        exit 1
    fi

    # Check CPU cores
    local total_cpu_cores
    total_cpu_cores=$(nproc)
    if [[ $total_cpu_cores -lt $MIN_CPU_CORES ]]; then
        echo "Insufficient CPU cores: $total_cpu_cores (required $MIN_CPU_CORES cores)"
        exit 1
    fi
}

check_required_packages() {
    echo "Checking required packages..."
    local missing_packages=()

    # Check if packages are installed
    for package in "${REQUIRED_PACKAGES[@]}"; do
        if ! command -v "$package" &>/dev/null && ! dpkg -l | grep -q "^ii.*$package"; then
            missing_packages+=("$package")
        fi
    done

    # Install missing packages
    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        echo "Installing missing packages: ${missing_packages[*]}"
        sudo apt-get update
        sudo apt-get install -y "${missing_packages[@]}"
    fi
}

check_network() {
    echo "Checking network configuration..."

    # Check if default network exists
    if virsh net-list --all | grep -q "default"; then
        echo "Default network found"
    else
        echo "Default network not found, creating..."
        virsh net-define /usr/share/libvirt/networks/default.xml
        virsh net-start default
        virsh net-autostart default
    fi

    # Skip internet connection check in CI
    # print CI variable
    echo "CI environment: ${CI:-}"
    if [[ "${CI:-}" == "true" ]]; then
        echo "CI environment detected, skipping internet connection check"
        return
    fi

    # Check internet connection
    if ping -c 1 8.8.8.8 &>/dev/null; then
        echo "Internet connection detected"
    else
        echo "No internet connection detected"
        exit 1
    fi
}

check_permissions() {
    echo "Checking permissions..."

    local required_groups=("libvirtd" "kvm")
    local current_user
    current_user=$(whoami)

    # what if the group is not present?
    for group in "${required_groups[@]}"; do
        if ! getent group "$group" >/dev/null; then
            echo "Group $group not found, creating..."
            sudo groupadd "$group"
        fi
    done

    for group in "${required_groups[@]}"; do
        if ! groups "$current_user" | grep -q "\b$group\b"; then
            echo "Adding $current_user to $group"
            sudo usermod -aG "$group" "$current_user"
        fi
    done
}

main() {
    echo "Starting system environment validation..."
    echo "----------------------------------------"

    check_root
    check_virtualization
    check_system_resources
    check_required_packages
    check_permissions
    check_network

    echo "----------------------------------------"
    echo "All checks passed"
}

main "$@"

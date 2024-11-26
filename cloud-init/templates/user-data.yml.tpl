# cloud-init/templates/user-data.yml.tpl
#cloud-config
autoinstall:
  version: 1
  locale: en_US
  keyboard:
    layout: us
  network:
    network:
      version: 2
      ethernets:
        ens3:
          dhcp4: true
  storage:
    layout:
      name: direct
  identity:
    hostname: ubuntu-server
    username: ${ssh_username}
    password: "packer"  # This will be removed in cleanup
  ssh:
    install-server: true
    allow-pw: true  # Will be disabled in cleanup
    authorized-keys:
      - ${ssh_public_key}
  user-data:
    disable_root: true
    package_upgrade: true
    packages:
      - qemu-guest-agent
      - python3
      - python3-pip
      - curl
      - wget
    runcmd:
      - systemctl enable qemu-guest-agent
      - systemctl start qemu-guest-agent
  late-commands:
    - echo '${ssh_username} ALL=(ALL) NOPASSWD:ALL' > /target/etc/sudoers.d/${ssh_username}
    - chmod 440 /target/etc/sudoers.d/${ssh_username}
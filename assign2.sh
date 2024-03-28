#!/bin/bash

# Update netplan configuration
update_netplan() {
    echo "Updating netplan configuration..."
    cat <<EOF | sudo tee /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens3:
      dhcp4: true
    ens4:
      dhcp4: no
      addresses: [192.168.16.21/24]
EOF
    sudo netplan apply
    echo "Netplan configuration updated."
}

# Update /etc/hosts file
update_hosts_file() {
    echo "Updating /etc/hosts file..."
    sudo sed -i '/192.168.16.21/d' /etc/hosts
    sudo sed -i '$a\192.168.16.21 server1' /etc/hosts
    echo "/etc/hosts file updated."
}

# Install required software
install_software() {
    echo "Installing apache2..."
    sudo apt update
    sudo apt install -y apache2
    echo "Apache2 installed."

    echo "Installing squid..."
    sudo apt install -y squid
    echo "Squid installed."
}

# Configure firewall using ufw
configure_firewall() {
    echo "Configuring firewall using ufw..."
    sudo ufw enable
    sudo ufw allow ssh
    sudo ufw allow http
    sudo ufw allow 3128
    echo "Firewall configured."
}

# Create user accounts
create_user_accounts() {
    echo "Creating user accounts..."
    sudo adduser --disabled-password --gecos "" dennis
    sudo usermod -aG sudo dennis
    echo "dennis ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/dennis
    sudo mkdir -p /home/dennis/.ssh
    sudo cp /home/ubuntu/.ssh/authorized_keys /home/dennis/.ssh/
    sudo chown -R dennis:dennis /home/dennis/.ssh
    sudo chmod 700 /home/dennis/.ssh
    sudo chmod 600 /home/dennis/.ssh/authorized_keys
    echo "Users created."
}

# Main function
main() {
    update_netplan
    update_hosts_file
    install_software
    configure_firewall
    create_user_accounts
}

# Execute main function
main

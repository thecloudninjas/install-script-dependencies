#!/bin/bash

set -e

echo "🔧 Updating system packages..."
sudo apt update && sudo apt upgrade && sudo apt install -y python3 git

echo "📦 Installing base packages..."
sudo apt install -y \
  curl unzip gnupg ca-certificates lsb-release \
  apt-transport-https software-properties-common \
  jq zsh python3 python3-pip git snapd

echo "📦 Installing common dependencies..."
sudo apt install -y \
  curl \
  unzip \
  gnupg \
  ca-certificates \
  apt-transport-https \
  lsb-release \
  software-properties-common \
  jq \
  zsh \
  python3 \
  python3-pip \
  git \
  snapd

# Ensure snapd is active
sudo systemctl enable --now snapd.socket

# --------------------
# Install kubectl
# --------------------
echo "🔧 Installing kubectl..."
KUBECTL_VERSION=$(curl -Ls https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

# --------------------
# Install Helm
# --------------------
echo "📦 Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version

# --------------------
# Install Docker
# --------------------
echo "🐳 Installing Docker..."
sudo apt remove -y docker docker-engine docker.io containerd runc || true
sudo install -m 0755 -d /etc/apt/keyrings -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
newgrp docker
docker --version

# --------------------
# Install Azure CLI
# --------------------
echo "☁️ Installing Azure CLI..."
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt update && sudo apt install -y azure-cli
rm microsoft.gpg
az version

# --------------------
# Install Terraform
# --------------------
echo "📦 Installing Terraform..."
# Install via APT (official and stable)
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt-get update && sudo apt-get install -y terraform
# ✅ Verify
terraform -version

# --------------------
# Install AWS CLI v2
# --------------------
echo "☁️ Installing AWS CLI v2..."
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update
aws --version || echo "❌ AWS CLI install failed"

# --------------------
# Install eksctl
# --------------------
echo "☁️ Installing eksctl..."
curl -s "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
chmod +x /usr/local/bin/eksctl
eksctl version || echo "❌ eksctl install failed"

# --------------------
# Install Google Cloud SDK (gcloud) via APT
# --------------------
echo "☁️ Installing gcloud CLI via APT..."

# Install transport and GPG tools
sudo apt update && sudo apt install -y apt-transport-https ca-certificates gnupg curl

# Add Google Cloud's APT repository
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
  sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list

# Import the GPG key
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
  gpg --dearmor | sudo tee /usr/share/keyrings/cloud.google.gpg > /dev/null

# Install the gcloud CLI
sudo apt update && sudo apt install -y google-cloud-sdk

# Verify the installation
gcloud version


# --------------------
# Install yq
# --------------------
echo "🔍 Installing yq..."
sudo apt install yq -y
yq --version || echo "❌ yq install failed"

# --------------------
# Install Oh My Zsh
# --------------------
echo "💻 Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
chsh -s $(which zsh)
zsh --version

# --------------------
# Install Katoolin3 for Kali Linux Tools
# --------------------
echo "🐱 Installing Katoolin3 (Kali Linux Tools Installer)..."

# Step 1: Clone Katoolin3 repo
git clone https://github.com/s-h-3-l-l/katoolin3.git ~/katoolin3

# Step 2: Make the main script executable
chmod +x ~/katoolin3/katoolin3.py

# Step 3: Create a symbolic link for global use
sudo ln -sf ~/katoolin3/katoolin3.py /usr/local/bin/katoolin3

# Step 4: Install GnuPG if not already present
sudo apt install -y gnupg

# Step 5: Add Kali Linux signing key (choose one of the below)

## Option A: For older systems using apt-key
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ED65462EC8D5E4C5 || true

## Option B: Recommended for Ubuntu 22.04+ (modern approach)
gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys ED65462EC8D5E4C5
gpg --export ED65462EC8D5E4C5 | sudo tee /etc/apt/trusted.gpg.d/kali.gpg > /dev/null

# Step 6: Update apt repositories
sudo apt update

# Step 7: Print success message
echo "✅ Katoolin3 installed. Run it using: katoolin3"



echo "✅ All tools (including Kali Linux tools via Katoolin3) installed successfully!"

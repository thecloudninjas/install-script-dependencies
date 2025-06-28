#!/bin/bash

set -e

echo "🔧 Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "📦 Installing base dependencies..."
sudo apt install -y \
  curl unzip gnupg ca-certificates lsb-release \
  apt-transport-https software-properties-common \
  jq zsh python3 python3-pip git snapd

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
echo "📦 Installing Terraform via APT..."
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install -y terraform
terraform -version

# --------------------
# Install AWS CLI v2
# --------------------
echo "☁️ Installing AWS CLI v2..."
cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update
export PATH=$PATH:/usr/local/bin
aws --version || echo "❌ AWS CLI install failed"

# --------------------
# Install eksctl
# --------------------
echo "☁️ Installing eksctl..."
curl -sL "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
chmod +x /usr/local/bin/eksctl
eksctl version || echo "❌ eksctl install failed"

# --------------------
# Install Google Cloud SDK (gcloud) via APT
# --------------------
echo "☁️ Installing gcloud CLI via APT..."
sudo apt update && sudo apt install -y apt-transport-https ca-certificates gnupg curl

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
  sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
  
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
  gpg --dearmor | sudo tee /usr/share/keyrings/cloud.google.gpg > /dev/null
  
sudo apt update && sudo apt install -y google-cloud-sdk

gcloud version || echo "❌ gcloud install failed"

# --------------------
# Install yq
# --------------------
echo "🔍 Installing yq..."
sudo apt install -y yq
yq --version || echo "❌ yq install failed"

# --------------------
# Install Oh My Zsh
# --------------------
echo "💻 Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
chsh -s $(which zsh)
zsh --version

# --------------------
# Final Message
# --------------------
echo "🎉 All tools installed successfully!"

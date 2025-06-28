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
sudo install -m 0755 -d /etc/apt/keyrings
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
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform
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
# Install Google Cloud SDK (gcloud)
# --------------------
sudo snap install google-cloud-cli --classic
# Check if gcloud was installed successfully
if command -v gcloud &> /dev/null; then
    echo "✅ gcloud installed successfully"
    gcloud version
else
    echo "❌ gcloud installation failed. Please check snap logs or permissions."
fi

# --------------------
# Install yq
# --------------------
echo "🔍 Installing yq..."
sudo snap install yq
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
echo "🐱 Installing Katoolin3 (Kali tools)..."
git clone https://github.com/s-h-3-l-l/katoolin3.git
cd ~/katoolin3
chmod +x katoolin3.py
sudo ./katoolin3.py
sudo python3 installer.py || echo "⚠️ Katoolin3 installer finished with warnings. Manual review may be required."
katoolin3

echo "✅ All tools (including Kali Linux tools via Katoolin3) installed successfully!"

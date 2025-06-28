#!/bin/bash

set -e

echo "🔧 Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "📦 Installing base dependencies..."
sudo apt install -y \
  ca-certificates \
  curl \
  gnupg \
  git \
  nmap \
  tar \
  unzip \
  wget \
  lsb-release \
  apt-transport-https \
  software-properties-common \
  zsh \
  software-properties-common

echo "☁️ Installing Azure CLI..."
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/azure-cli.list'
sudo apt update && sudo apt install -y azure-cli
rm microsoft.gpg

echo "🔧 Installing kubectl..."
KUBECTL_VERSION=$(curl -s https://dl.k8s.io/release/stable.txt)
if [ -z "$KUBECTL_VERSION" ]; then
  echo "❌ Failed to fetch kubectl version. Exiting."
  exit 1
fi
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "📦 Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

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

echo "📦 Installing Terraform..."
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install -y terraform

echo "☁️ Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

echo "☁️ Installing eksctl..."
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

echo "☁️ Installing Google Cloud CLI (gcloud)..."
sudo apt install -y apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
  sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
sudo apt update && sudo apt install -y google-cloud-sdk

echo "🔍 Installing jq and yq..."
sudo apt install -y jq
sudo snap install yq

echo "💻 Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "✨ Setting Zsh as default shell..."
chsh -s $(which zsh)

echo "🐱 Installing Kali Linux tools via katoolin3..."
sudo apt install -y python3 python3-pip
git clone https://github.com/s-h-3-l-l/katoolin3.git
cd katoolin3
sudo python3 installer.py || echo "⚠️ Katoolin3 install script may require manual follow-up."

cd ..
rm -rf katoolin3

echo "✅ All tools installed successfully!"

echo "🔍 Verifying versions..."
kubectl version --client
helm version
docker --version
az version
terraform -version
aws --version
eksctl version
gcloud version
jq --version
yq --version
zsh --version

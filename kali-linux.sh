#!/bin/bash
set -e

echo "🔧 Updating system..."
sudo apt update && sudo apt full-upgrade -y

echo "📦 Installing core tools..."
sudo apt install -y \
  git curl wget unzip net-tools build-essential \
  python3 python3-pip python3-venv \
  zsh tmux vim nano htop neofetch \
  dnsutils whois lsof gnupg socat ncat \
  nmap sqlmap nikto \
  aircrack-ng reaver pixiewps \
  john hashcat hydra \
  gobuster dirb \
  metasploit-framework \
  burpsuite \
  wireshark tcpdump \
  gparted ghex \
  exploitdb \
  binwalk radare2 \
  gdb strace ltrace \
  enum4linux crackmapexec \
  smbclient seclists wordlists \
  openvpn network-manager-openvpn-gnome \
  maltego zaproxy

echo "🛠️ Enabling Wireshark for non-root users..."
sudo dpkg-reconfigure wireshark-common
sudo usermod -aG wireshark $USER

echo "📜 Updating Exploit Database..."
searchsploit -u

# --------------------------------------------
# 🐳 Install Docker
# --------------------------------------------
echo "🐳 Installing Docker..."
sudo apt remove -y docker docker-engine docker.io containerd runc || true
sudo apt install -y ca-certificates gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker $USER
docker --version || echo "⚠️ Docker setup may need logout/login"

# --------------------------------------------
# 📦 Install VirtualBox
# --------------------------------------------
echo "📦 Installing VirtualBox..."
sudo apt install -y virtualbox virtualbox-guest-additions-iso

# --------------------------------------------
# 🧰 Offensive Tools
# --------------------------------------------

# ⚔️ Evil-WinRM
echo "⚔️ Installing Evil-WinRM..."
sudo gem install evil-winrm

# ⚔️ Veil Framework
echo "⚔️ Installing Veil Framework..."
sudo apt install -y veil

# ⚔️ Empire (PowerShell post-exploitation)
echo "⚔️ Installing Empire..."
cd /opt
sudo git clone https://github.com/BC-SECURITY/Empire.git
cd Empire
sudo ./setup/install.sh --yes

# --------------------------------------------
# ✅ Finishing Up
# --------------------------------------------
echo "✅ All tools installed!"
echo "⚠️ Please reboot or re-login to apply group membership changes (e.g., Docker, Wireshark)."

#📌 After Running:
#Run newgrp docker to activate Docker without reboot.

#Run katoolin3 if you still want a GUI-based installer.

#Notes:
#This does not install every single Kali tool (like kali-linux-everything) to save space and time.
#You can run this safely on a clean Kali install.
#If you're okay with downloading 10GB+ tools:

#sudo apt update && sudo apt install -y kali-linux-large 📌

#sudo apt install -y kali-linux-everything



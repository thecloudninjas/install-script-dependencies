#!/bin/bash

set -e

echo "🔧 Updating system..."
sudo apt update && sudo apt full-upgrade -y

echo "🧰 Installing essential tools..."
sudo apt install -y \
  git curl wget unzip net-tools build-essential \
  python3 python3-pip python3-venv \
  zsh tmux vim nano \
  nmap sqlmap nikto \
  aircrack-ng reaver \
  john hashcat hydra \
  gobuster dirb \
  metasploit-framework \
  burpsuite \
  wireshark tcpdump \
  gparted ghex \
  exploitdb \
  binwalk radare2 \
  gdb strace ltrace \
  dnsutils whois \
  enum4linux \
  crackmapexec \
  smbclient \
  seclists wordlists \
  openvpn network-manager-openvpn \
  htop neofetch

echo "📦 Installing optional GUI-based tools (if needed)..."
sudo apt install -y \
  maltego \
  zaproxy

echo "📜 Setting permissions for Wireshark (non-root capture)..."
sudo dpkg-reconfigure wireshark-common
sudo usermod -aG wireshark $USER

echo "🔍 Updating Exploit Database..."
searchsploit -u

echo "✅ Basic security toolkit is ready on Kali Linux!"
echo "⚠️ Reboot or re-login may be needed for some tools (like Wireshark group change)."

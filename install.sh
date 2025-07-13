#!/bin/bash

echo "🚀 Installing Discord VPS Bot..."

# Ask for bot token
read -p "🔑 Enter your Discord Bot Token: " BOT_TOKEN

# Update system
echo "🔄 Updating system packages..."
sudo apt update -y && sudo apt upgrade -y

# Install required packages
echo "📦 Installing Python, pip, git, and other dependencies..."
sudo apt install -y python3 python3-pip git curl apt-transport-https ca-certificates gnupg lsb-release

# Install Node.js and PM2
echo "⚙️ Installing Node.js and PM2 for 24/7 uptime..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
sudo npm install -g pm2

# Optional: Clean up Docker if broken versions exist
echo "🧹 Cleaning old Docker installations..."
sudo apt remove -y docker docker-engine docker.io containerd runc docker-ce docker-ce-cli containerd.io
sudo rm -rf /var/lib/docker || true

# Install Docker (optional for VPS management, skip if not needed)
# echo "🐳 Installing Docker..."
# curl -fsSL https://get.docker.com -o get-docker.sh
# sudo sh get-docker.sh

# Clone repo if not already in it
if [ ! -f "main.py" ]; then
    echo "📥 Cloning bot repository..."
    git clone https://github.com/hishadow1/discord-vps-bot.git
    cd discord-vps-bot || exit
fi

# Setup Python packages
echo "📦 Installing Python requirements..."
pip3 install -r requirements.txt || pip3 install discord.py aiohttp

# Create .env with token
echo "🔐 Creating .env file..."
echo "BOT_TOKEN=$BOT_TOKEN" > .env

# Run bot using PM2
echo "🔁 Starting bot with PM2..."
pm2 start main.py --interpreter=python3 --name="discord-vps-bot"
pm2 save
pm2 startup systemd | tee /tmp/pm2-setup.sh
sudo bash /tmp/pm2-setup.sh

echo "✅ Installation complete! Your bot is running 24/7 using PM2."
echo "📌 To check bot logs: pm2 logs discord-vps-bot"

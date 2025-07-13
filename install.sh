#!/bin/bash

echo "🚀 Installing Discord VPS Bot..."

# 📦 Update system & install dependencies
sudo apt-get update -y
sudo apt-get install -y python3 python3-pip git curl docker.io

# 🐳 Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker

# 📁 Clone bot repo
git clone https://github.com/hishadow1/discord-vps-bot ~/discord-vps-bot

# 📂 Go to bot folder
cd ~/discord-vps-bot

# 🐍 Install Python requirements
pip3 install -r requirements.txt

# 🔐 Ask for token
echo ""
read -p "🔑 Enter your Discord Bot Token: " BOT_TOKEN

# 🧠 Inject token into main.py
sed -i "s|\${BOT_TOKEN}|$BOT_TOKEN|" main.py

# ✅ Launch the bot
echo ""
echo "✅ Bot is starting..."
python3 main.py

#!/bin/bash

echo "🔧 Installing required packages..."
sudo apt update -y
sudo apt install -y python3 python3-pip

echo "📦 Installing Python libraries..."
pip3 install -r requirements.txt || pip3 install discord.py

echo "🔑 Please enter your Discord Bot Token:"
read -r TOKEN

echo "👑 Enter your Discord Admin User ID:"
read -r ADMIN_ID

echo "📁 Setting up environment..."
cat > .env <<EOF
DISCORD_TOKEN=${TOKEN}
ADMIN_ID=${ADMIN_ID}
EOF

echo "🚀 Starting bot in background using nohup..."
nohup python3 main.py > bot.log 2>&1 &

echo "✅ Bot is now running in the background!"

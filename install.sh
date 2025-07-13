#!/bin/bash
set -e

echo "🚀 Installing Discord VPS Bot..."

# 🔧 Fix broken Docker if exists
echo "🔧 Cleaning up old Docker..."
sudo apt remove -y docker docker-engine docker.io containerd runc || true
sudo apt purge -y docker-ce docker-ce-cli containerd.io || true
sudo rm -rf /var/lib/docker /var/lib/containerd

# 📦 Install dependencies
echo "📦 Installing system packages..."
sudo apt update -y
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common python3 python3-pip git

# 🐳 Install Docker from official source
echo "🐳 Installing Docker..."
curl -fsSL https://get.docker.com | sudo bash

# ▶️ Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker

# 🐳 Pull SSH-enabled Ubuntu image
sudo docker pull rastasheep/ubuntu-sshd

# 🐍 Install Discord library
pip3 install -U discord.py

# 📂 Create bot directory
mkdir -p ~/discord-vps-bot && cd ~/discord-vps-bot

# 🔐 Ask for bot token
read -p "🔑 Enter your Discord Bot Token: " BOT_TOKEN
if [[ -z "$BOT_TOKEN" ]]; then
  echo "❌ Token missing. Exiting..."
  exit 1
fi

# 🧠 Create bot script
cat > main.py <<EOF
import discord
from discord import app_commands
from discord.ext import commands
import subprocess, random, string, socket

intents = discord.Intents.default()
bot = commands.Bot(command_prefix="!", intents=intents)
used_ports = set()
user_containers = {}

def generate_password(l=8):
    return ''.join(random.choices(string.ascii_letters + string.digits, k=l))

def get_port():
    for p in range(2222, 2300):
        if p not in used_ports:
            used_ports.add(p)
            return p
    return None

@bot.event
async def on_ready():
    await bot.tree.sync()
    print("✅ Bot is online as", bot.user)

@bot.tree.command(name="vps", description="Create your own VPS container with SSH access")
async def vps(interaction: discord.Interaction):
    uid = str(interaction.user.id)
    if uid in user_containers:
        await interaction.response.send_message("⚠️ You already have a VPS. Use /destroy to delete it first.", ephemeral=True)
        return
    pwd = generate_password()
    port = get_port() or 0
    if port == 0:
        await interaction.response.send_message("❌ No available ports. Try again later.", ephemeral=True)
        return
    cname = f"vps_{uid}"
    try:
        subprocess.run(["docker","run","-d","--name",cname,"-p",f"{port}:22","--restart","unless-stopped","rastasheep/ubuntu-sshd"], check=True)
        subprocess.run(["docker","exec",cname,"bash","-c",f"echo root:{pwd} | chpasswd"], check=True)
        user_containers[uid] = {"name":cname,"port":port}
        ip = socket.gethostbyname(socket.gethostname())
        await interaction.response.send_message(f"🖥️ **VPS Ready!**\\n```\\nssh root@{ip} -p {port}\\nPassword: {pwd}\\n```", ephemeral=True)
    except Exception as e:
        await interaction.response.send_message(f"❌ Error creating VPS: {e}", ephemeral=True)

@bot.tree.command(name="destroy", description="Destroy your VPS container")
async def destroy(interaction: discord.Interaction):
    uid = str(interaction.user.id)
    if uid not in user_containers:
        await interaction.response.send_message("⚠️ You have no active VPS.", ephemeral=True)
        return
    info = user_containers.pop(uid)
    try:
        subprocess.run(["docker","rm","-f",info["name"]], check=True)
        await interaction.response.send_message("✅ Your VPS has been destroyed.", ephemeral=True)
    except Exception as e:
        await interaction.response.send_message(f"❌ Error destroying VPS: {e}", ephemeral=True)

bot.run("${BOT_TOKEN}")
EOF

# 🧠 Insert token into main.py
sed -i "s|\${BOT_TOKEN}|$BOT_TOKEN|" main.py

# ✅ Done
echo -e "\n✅ Done! Bot is ready to run."
echo "▶️ Starting bot now..."
python3 main.py

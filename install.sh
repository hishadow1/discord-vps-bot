#!/bin/bash
echo "🚀 Installing Discord VPS Bot..."

sudo apt update && sudo apt install -y docker.io python3 python3-pip curl git
sudo systemctl enable docker && sudo systemctl start docker
sudo docker pull rastasheep/ubuntu-sshd
pip3 install -U discord.py

mkdir -p ~/discord-vps-bot && cd ~/discord-vps-bot
read -p "🔐 Enter Discord Bot Token: " BOT_TOKEN

cat > main.py <<EOF
import discord
from discord import app_commands
from discord.ext import commands
import subprocess, random, string

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
    print("Bot online as", bot.user)

@bot.tree.command(name="vps", description="Create your VPS container")
async def vps(interaction: discord.Interaction):
    uid = str(interaction.user.id)
    if uid in user_containers:
        await interaction.response.send_message("⚠️ You already have one. Use /destroy first.", ephemeral=True)
        return
    pwd = generate_password()
    port = get_port() or 0
    if port == 0:
        await interaction.response.send_message("❌ No ports left.", ephemeral=True); return
    cname = f"vps_{uid}"
    subprocess.run(["docker","run","-d","--name",cname,"-p",f"{port}:22","--restart","unless-stopped","rastasheep/ubuntu-sshd"], check=True)
    subprocess.run(["docker","exec",cname,"bash","-c",f"echo root:{pwd} | chpasswd"], check=True)
    user_containers[uid] = {"name":cname,"port":port}
    await interaction.response.send_message(f"🖥️ VPS ready!\\n```\\nssh root@<YOUR_VPS_IP> -p {port}\\n```\\nPassword: `{pwd}`")

@bot.tree.command(name="destroy", description="Destroy your VPS")
async def destroy(interaction: discord.Interaction):
    uid = str(interaction.user.id)
    if uid not in user_containers:
        await interaction.response.send_message("⚠️ None to destroy.", ephemeral=True); return
    info = user_containers.pop(uid)
    subprocess.run(["docker","rm","-f",info["name"]], check=True)
    await interaction.response.send_message("✅ VPS destroyed.")

bot.run(BOT_TOKEN)
EOF

echo "✅ Done. To run the bot: cd ~/discord-vps-bot && python3 main.py"

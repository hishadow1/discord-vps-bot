# main.py
import discord
from discord.ext import tasks
from discord import app_commands
import os
import sys
import time

# === CONFIG ===
TOKEN = os.getenv("DISCORD_BOT_TOKEN")

# Load admin usernames from file
ADMIN_USERNAMES = []
if os.path.exists("admin_users.txt"):
    with open("admin_users.txt") as f:
        ADMIN_USERNAMES = [line.strip() for line in f if line.strip()]
else:
    ADMIN_USERNAMES = ["YourUsername"]  # fallback if file missing

intents = discord.Intents.default()
client = discord.Client(intents=intents)
tree = app_commands.CommandTree(client)

# === Admin check ===
def is_admin(interaction: discord.Interaction):
    return interaction.user.name in ADMIN_USERNAMES

# === Health check loop ===
@tasks.loop(seconds=60)
async def health_check():
    print("✅ Health check: Bot is alive.")

# === Slash commands ===
@tree.command(name="ping", description="Test if the bot is alive.")
async def ping(interaction: discord.Interaction):
    await interaction.response.send_message("🏓 Pong!")

@tree.command(name="shutdown", description="Shutdown the bot (admin only).")
async def shutdown(interaction: discord.Interaction):
    if not is_admin(interaction):
        await interaction.response.send_message("⛔ Not authorized", ephemeral=True)
        return
    await interaction.response.send_message("🛑 Shutting down...", ephemeral=True)
    save_data()
    await client.close()

@tree.command(name="restart", description="Restart the bot (admin only).")
async def restart(interaction: discord.Interaction):
    if not is_admin(interaction):
        await interaction.response.send_message("⛔ Not authorized", ephemeral=True)
        return
    await interaction.response.send_message("🔁 Restarting...", ephemeral=True)
    save_data()
    os.system("bash restart.sh")
    await client.close()

@tree.command(name="backup", description="Trigger a data backup (admin only).")
async def backup(interaction: discord.Interaction):
    if not is_admin(interaction):
        await interaction.response.send_message("⛔ Not authorized", ephemeral=True)
        return
    save_data()
    await interaction.response.send_message("💾 Backup completed!", ephemeral=True)

# === Safe shutdown logic ===
def save_data():
    print("💾 Saving data... (you can add file/db logic here)")

# === Bot ready ===
@client.event
async def on_ready():
    await tree.sync()
    print(f"🤖 Logged in as {client.user}")
    health_check.start()

# === Start bot ===
if __name__ == "__main__":
    if not TOKEN:
        print("❌ DISCORD_BOT_TOKEN not set.")
        sys.exit(1)
    client.run(TOKEN)

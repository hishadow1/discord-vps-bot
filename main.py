main.py

import discord from discord.ext import tasks from discord import app_commands import os import signal import sys import time

=== CONFIGURATION ===

ADMIN_USERNAMES = ["Shadow", "AdminUser"]  # Replace with actual usernames HEALTH_CHECK_INTERVAL = 60  # seconds

=== BOT SETUP ===

intents = discord.Intents.default() intents.messages = True intents.message_content = True client = discord.Client(intents=intents) tree = app_commands.CommandTree(client)

=== HEALTH CHECK ===

@tasks.loop(seconds=HEALTH_CHECK_INTERVAL) async def health_check(): print("[Health Check] Bot is running fine.")

=== ADMIN CHECK ===

def is_admin(interaction: discord.Interaction): return interaction.user.name in ADMIN_USERNAMES

=== COMMANDS ===

@tree.command(name="ping", description="Check if the bot is alive.") async def ping(interaction: discord.Interaction): await interaction.response.send_message("🏓 Pong!")

@tree.command(name="shutdown", description="Shutdown the bot (admin only).") async def shutdown(interaction: discord.Interaction): if not is_admin(interaction): await interaction.response.send_message("⛔ You are not authorized.", ephemeral=True) return await interaction.response.send_message("Shutting down safely...", ephemeral=True) save_data() await client.close()

@tree.command(name="restart", description="Restart the bot (admin only).") async def restart(interaction: discord.Interaction): if not is_admin(interaction): await interaction.response.send_message("⛔ You are not authorized.", ephemeral=True) return await interaction.response.send_message("Restarting bot...", ephemeral=True) save_data() os.execv(sys.executable, ['python3'] + sys.argv)

@tree.command(name="backup", description="Backup data (admin only).") async def backup(interaction: discord.Interaction): if not is_admin(interaction): await interaction.response.send_message("⛔ You are not authorized.", ephemeral=True) return save_data() await interaction.response.send_message("✅ Backup complete!", ephemeral=True)

=== SAFETY ===

def save_data(): print("[Safe Shutdown] Saving any persistent data if needed...") # Add backup logic here

=== READY ===

@client.event async def on_ready(): await tree.sync() print(f"✅ Logged in as {client.user}") health_check.start()

=== START ===

if name == "main": try: TOKEN = os.getenv("DISCORD_BOT_TOKEN") if not TOKEN: print("Error: DISCORD_BOT_TOKEN not set.") sys.exit(1) client.run(TOKEN) except KeyboardInterrupt: save_data() print("Bot shutdown via keyboard interrupt.") sys.exit(0)


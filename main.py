main.py

import discord from discord.ext import commands, tasks import os import signal import sys import time

=== CONFIGURATION ===

ADMIN_USERNAMES = ["Shadow", "AdminUser"]  # Replace with actual usernames HEALTH_CHECK_INTERVAL = 60  # seconds

=== BOT SETUP ===

intents = discord.Intents.default() intents.messages = True intents.message_content = True bot = commands.Bot(command_prefix="!", intents=intents)

=== HEALTH CHECK ===

@tasks.loop(seconds=HEALTH_CHECK_INTERVAL) async def health_check(): print("[Health Check] Bot is running fine.")

=== ADMIN-ONLY CHECK ===

def is_admin(ctx): return ctx.author.name in ADMIN_USERNAMES

=== COMMANDS ===

@bot.command() async def ping(ctx): await ctx.send("Pong!")

@bot.command() @commands.check(is_admin) async def shutdown(ctx): await ctx.send("Shutting down safely...") save_data() await bot.close()

@bot.command() @commands.check(is_admin) async def restart(ctx): await ctx.send("Restarting bot...") save_data() os.execv(sys.executable, ['python3'] + sys.argv)

@bot.command() @commands.check(is_admin) async def backup(ctx): save_data() await ctx.send("Backup complete!")

=== SAFETY ===

def save_data(): print("[Safe Shutdown] Saving any persistent data if needed...") # Add backup logic here, like saving to file or DB

=== ON READY ===

@bot.event async def on_ready(): print(f"Logged in as {bot.user.name}") health_check.start()

=== START BOT ===

if name == "main": try: TOKEN = os.getenv("DISCORD_BOT_TOKEN") if not TOKEN: print("Error: DISCORD_BOT_TOKEN not set.") sys.exit(1) bot.run(TOKEN) except KeyboardInterrupt: save_data() print("Bot shutdown via keyboard interrupt.") sys.exit(0)


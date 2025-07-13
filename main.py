import discord
from discord.ext import commands
import os

TOKEN = os.getenv("DISCORD_TOKEN")
ADMIN_ID = int(os.getenv("ADMIN_ID"))

intents = discord.Intents.all()
bot = commands.Bot(command_prefix="!", intents=intents)

@bot.event
async def on_ready():
    print(f"Logged in as {bot.user.name}")

@bot.command()
async def hello(ctx):
    await ctx.send("Hello!")

@bot.command()
async def shutdown(ctx):
    if ctx.author.id == ADMIN_ID:
        await ctx.send("Bot is shutting down...")
        await bot.close()
    else:
        await ctx.send("You are not authorized to do that.")

bot.run(TOKEN)

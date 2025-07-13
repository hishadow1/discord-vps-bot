# Discord VPS Bot

🖥️ A powerful Discord bot that gives users their own SSH-accessible VPS container using Docker!

## Dont forget to give me creadit if you are using or editing and the files


# creadits - SHADOWGAMER
---

## 📦 Features

- `/vps` — Creates a temporary Docker container with SSH access
- `/destroy` — Deletes the user’s container
- Each user gets:
  - Unique port (2222+)
  - Root access with password
  - Auto-restart on container crash
- All built with **Python + Docker**

---

## 📥 One-Line Installer (Run on your VPS)

```bash
bash <(curl -s https://raw.githubusercontent.com/hishadow1/discord-vps-bot/main/install.sh)

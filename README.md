<div align="center">

<br>

<img src="https://img.shields.io/badge/Platform-Termux%20%7C%20Linux%20%7C%20macOS%20%7C%20WSL2-blue?style=for-the-badge" alt="Platform Badge">
<img src="https://img.shields.io/badge/Version-Ghost%20Engine%20v4-important?style=for-the-badge" alt="Version Badge">
<img src="https://img.shields.io/badge/Privacy-TOR%20Network%20%7C%20SOCKS5%20%2B%20HTTP%20Proxy-purple?style=for-the-badge" alt="Privacy Badge">
<img src="https://img.shields.io/github/stars/ns-gamming/Termux-Tor-IP-Rotator?style=for-the-badge" alt="Stars Badge">
<img src="https://img.shields.io/github/license/ns-gamming/Termux-Tor-IP-Rotator?style=for-the-badge" alt="License Badge">

<br><br>

pkg██████╗  ██████╗  ██████╗  ███████╗██╗  ██╗████████╗
  ██╔══██╗██╔═══██╗██╔══██╗ ██╔════╝██║ ██╔╝╚══██╔══╝
  ██████╔╝██║   ██║██████╔╝ █████╗  █████╔╝    ██║   
  ██╔══██╗██║   ██║██╔══██╗ ██╔══╝  ██╔═██╗    ██║   
  ██████╔╝╚██████╔╝██║  ██║ ███████╗██║  ██╗   ██║   
  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   

          G H O S T   E N G I N E   v4
    Advanced Hybrid TOR Identity & IP Rotation System

💙 NS GAMMING — Termux-Tor-IP-Rotator

👻 Ghost Engine v4 — Advanced Hybrid TOR Privacy Framework

</div>
---

🧠 What Is Ghost Engine v4?

Ghost Engine v4 is a professional-grade TOR identity rotation framework designed to:

Route your traffic through the TOR network

Rotate IPs (exit nodes) automatically or on demand

Provide system-wide SOCKS5 + HTTP proxy access

Give you tools to test, debug, and monitor your anonymity


It is optimized for:

Android (Termux) — primary target

Linux (Debian / Ubuntu / Kali / Parrot / others)

macOS (Intel + Apple Silicon)

Windows (WSL2 environment)


All while staying:

Lightweight

Beginner-friendly

Script-driven and fast



---

🧑‍🎓 Who Is This For?

Intended User	Suitable?

Cybersecurity Learner	🟢 YES
OSINT / Researcher	🟢 YES
Darknet / Network Analyst	🟢 YES
Ethical Hacker / Pentester	🟢 YES
Data Analyst / Tor Tester	🟢 YES
Criminal Activity / Abuse	🔴 NO


> ⚠ Disclaimer:
This tool is for education, research, privacy, and security.
You are fully responsible for how you use it.
Do NOT use it for illegal activities.




---

🔍 Why Ghost Engine Exists

The internet tracks you using:

IP addresses & metadata

DNS requests

Browser fingerprinting

Web cookies & tracking pixels

Location-based routing

ISP-level logging & surveillance


Ghost Engine v4 focuses on one major pillar:

> ✨ Your visible network identity (IP) becomes unpredictable and rotating.



Using TOR + ControlPort and a custom engine, it:

Builds TOR circuits

Rotates exit IPs periodically (as low as ~3 seconds)

Allows instant manual IP change

Routes apps, terminals, and browsers through TOR



---

⚙ Technical Capabilities

Capability	Status	Detail

TOR SOCKS5 Proxy	🟢	127.0.0.1:9050
HTTP Proxy via Privoxy	🟢	127.0.0.1:8118
Auto IP Rotation	🟢	User-selectable interval (min ~3 sec)
Manual NEWNYM Rotation	🟢	Instant TOR identity refresh
IP History (in-memory)	🟢	Stored only in RAM (no disk persistence)
System-wide Proxy Mode	🟢	Works via OS / browser proxy config
TOR Status & Logs Panel	🟢	Inline debug and status view
Shell History Cleaning	🟢	Optional history disable / cleanup
curl / CLI Tools via TOR	🟢	Fully supported with proxy



---

🧰 Requirements (All Platforms)

Common tools required:

git

tor

privoxy

curl

netcat-openbsd or netcat


> On Termux, everything is installed with pkg.
On Linux/WSL, everything is installed with apt.
On macOS, install via Homebrew.




---

🚀 Quick Start — Android (Termux) [Recommended]

> ✅ Termux must be installed from F-Droid (Play Store version is outdated and may break things).
📥 https://f-droid.org/en/packages/com.termux/



1️⃣ Update Termux
```
pkg update -y && pkg upgrade -y
```
2️⃣ Install Dependencies
```
pkg install git tor privoxy curl netcat-openbsd -y
```
If privoxy fails:
```
pkg install tur-repo -y && pkg install privoxy -y
```
3️⃣ Clone the Repository
```
git clone https://github.com/ns-gamming/Termux-Tor-IP-Rotator
cd Termux-Tor-IP-Rotator
```
4️⃣ Install Ghost Engine Globally
```
chmod +x install.sh
bash install.sh
```
This will:

Install needed configs

Set up shortcuts / aliases (like ns-ghost)

Prepare TOR + Privoxy configuration


5️⃣ Launch Ghost Engine

ns-ghost

Wait 10–20 seconds the first time — TOR needs a moment to build secure circuits.


---

💻 Installation — Linux (Debian / Ubuntu / Kali / Parrot)

Manual Setup
```
sudo apt update
sudo apt install git tor privoxy curl netcat -y
```
```
git clone https://github.com/ns-gamming/Termux-Tor-IP-Rotator
cd Termux-Tor-IP-Rotator
```
```
chmod +x ns-ghost.sh
./ns-ghost.sh
```

---

☕ macOS (Intel + Apple Silicon)

Requirements: Homebrew

Install Homebrew if you don’t have it:
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
Install Dependencies
```
brew install tor privoxy curl netcat
```
Clone & Run
```
git clone https://github.com/ns-gamming/Termux-Tor-IP-Rotator
cd Termux-Tor-IP-Rotator
chmod +x ns-ghost.sh
./ns-ghost.sh
```

---

🪟 Windows (WSL2 Only)

1. Enable WSL & Ubuntu from Microsoft Store


2. Open Ubuntu terminal (WSL2)



Then:
```
sudo apt update
sudo apt install git tor privoxy curl netcat -y
```
```
git clone https://github.com/ns-gamming/Termux-Tor-IP-Rotator
cd Termux-Tor-IP-Rotator
chmod +x ns-ghost.sh
./ns-ghost.sh
```

---

🤖 Auto Debian/Ubuntu Installer (Optional but Cool)

For Debian/Ubuntu/Kali/Parrot/WSL2 users, you can create an auto installer:

Create a file called install_debian.sh:

nano install_debian.sh

Paste this inside:

#!/usr/bin/env bash
set -e

echo "[*] Ghost Engine v4 — Auto Installer (Debian/Ubuntu)"
echo

# Check for sudo
if ! command -v sudo >/dev/null 2>&1; then
  echo "[!] sudo not found. Please install sudo or run as root."
  exit 1
fi

# Update system
echo "[*] Updating system..."
sudo apt update -y && sudo apt upgrade -y

# Install dependencies
echo "[*] Installing dependencies (git, tor, privoxy, curl, netcat)..."
sudo apt install -y git tor privoxy curl netcat || {
  echo "[!] Failed to install dependencies. Check your sources and try again."
  exit 1
}

# Clone repo if needed
if [ ! -d "$HOME/Termux-Tor-IP-Rotator" ]; then
  echo "[*] Cloning repository..."
  git clone https://github.com/ns-gamming/Termux-Tor-IP-Rotator "$HOME/Termux-Tor-IP-Rotator"
else
  echo "[*] Repo already exists. Pulling latest changes..."
  cd "$HOME/Termux-Tor-IP-Rotator"
  git pull || true
fi

cd "$HOME/Termux-Tor-IP-Rotator"

# Make main script executable
if [ -f "ns-ghost.sh" ]; then
  chmod +x ns-ghost.sh
  echo "[*] Running Ghost Engine..."
  ./ns-ghost.sh
else
  echo "[!] ns-ghost.sh not found. Please check repository structure."
  exit 1
fi

echo
echo "[✓] Ghost Engine setup finished. Enjoy staying anonymous 👻"

Save & exit, then:
```
chmod +x install_debian.sh
./install_debian.sh
```
This will:

Update your system

Install required packages

Clone/update the repo

Run ns-ghost.sh automatically



---

🎛 Sample Ghost Engine Start Screen (ASCII UI)

When you start with ns-ghost, you can use something like this (example):

====================================================
        GHOST ENGINE v4 — NS GAMMING Special
====================================================
[+] Platform   : Termux / Linux / macOS / WSL2
[+] TOR Status : BOOTSTRAPPING (building circuits…)
[+] Proxy      : SOCKS5 127.0.0.1:9050  |  HTTP 127.0.0.1:8118
[+] Rotation   : Auto (every 15 seconds)

Choose an option:

  [1] Start / Restart TOR + Privoxy
  [2] Rotate Identity (NEWNYM)
  [3] Set Auto-Rotation Interval
  [4] Show Current IP (via TOR)
  [5] View TOR Log / Debug Panel
  [6] Stop & Cleanup
  [0] Exit

====================================================
  Use this tool responsibly. You are being watched
        — but now they don’t know from where. 👻
====================================================

You can adapt your script to print a similar UI for professional vibes 🌙


---

🌐 Route Device / Apps Through TOR

Android Wi-Fi Proxy (System Level)

1. Open Settings → Wi-Fi


2. Long-press your network → Modify Network


3. Expand Advanced options → Proxy: Manual



Set:

Field	Value

Hostname	```127.0.0.1```
Port	```8118```


> ⚠ If Ghost Engine is OFF and proxy is still ON → internet may stop working.
Disable proxy if not using Ghost Engine.




---

CLI Tools via TOR (Linux/Termux/macOS)

Example with curl:
```
curl --proxy http://127.0.0.1:8118 https://api64.ipify.org
```
Or using SOCKS5 via tor directly:
```
curl --socks5 127.0.0.1:9050 https://api64.ipify.org
```

---

✅ Verify That TOR Is Working

Terminal Verification
```
curl --proxy http://127.0.0.1:8118 https://api64.ipify.org
```
If that IP is different from your mobile/ISP IP → routed via TOR.


Browser Verification

Visit:

🔗 https://check.torproject.org/


You should see a “You are using Tor” style message.


---

🐞 Troubleshooting & Error Handling

Problem	Reason / Root Cause	Fix

No internet after enabling proxy	Proxy on but Ghost Engine / TOR is off	Turn off proxy or restart ns-ghost
TOR stuck at 5–20% bootstrapping	Slow network / blocked relays	Restart, wait longer, or use VPN + TOR
Same IP repeating after rotation	TOR reused same exit node	Rotate again, increase interval, or restart TOR
privoxy: not found in Termux	Package not in default repo	pkg install tur-repo -y && pkg install privoxy -y
Chrome still showing real IP	WebRTC leaks / bypassing proxy	Use Firefox, disable WebRTC
ns-ghost: command not found	Install script not run / PATH not updated	Re-run install.sh from repo root
Permission denied running script	No execute bit on script	chmod +x scriptname.sh
curl: (7) Failed to connect to 127.0.0.1	TOR/Privoxy not running or wrong port	Ensure Ghost Engine is running on 8118/9050



---

🔐 Security Tips (Important)

✔ Use Firefox instead of Chrome-based browsers
✔ Disable WebRTC:

In Firefox: open about:config → set media.peerconnection.enabled to false


✔ Do not log into personal accounts via TOR
✔ Avoid mixing real identity and anonymous sessions
✔ Rotate IP frequently if doing sensitive research
✔ Remember: TOR ≠ 100% immunity
Privacy = Tools + Your Behavior


---

🔄 Updating & Uninstalling

Update Ghost Engine

cd ~/Termux-Tor-IP-Rotator && bash update.sh

Uninstall Ghost Engine

cd ~/Termux-Tor-IP-Rotator && bash uninstall.sh


---

❓ FAQ

Q: Does this make me completely anonymous?
A: No tool can promise 100% anonymity. Ghost Engine improves your network privacy, especially IP-based tracking, but your behavior, browser settings, and accounts still matter.

Q: Can I use VPN + Ghost Engine?
A: Yes. Typical safe stack is:
You → VPN → TOR (Ghost Engine) → Internet.
Just understand the trade-offs (latency, trust in VPN, etc).

Q: Will my ping be higher?
A: Yes. TOR adds hops and encryption. This is a privacy tool, not meant for low-latency gaming.

Q: Can I use this for hacking illegal stuff?
A: No. This is strictly for ethical, educational, and research purposes.


---

## 💖 Support the Project – Keep Ghost Engine Alive

Ghost Engine v4 took **time, passion, research, testing, and love** to build.

If this tool protects your privacy, helps your learning journey, or simply inspires you —  
**consider supporting its development.**

Your contribution:

- Helps maintain future updates 🛠  
- Funds new features, optimization & testing  
- Supports open-source cybersecurity tools  
- Motivates continued development 💙  

No pressure, no expectation —  
just appreciation if you choose to help.

---

### 🪙 Donation Addresses

| Cryptocurrency | Address |
|----------------|---------|
| **Bitcoin (BTC)** | `bc1q5zapes7euft2lrk7ylpwj90p8y4ctmadn285du` |
| **Solana (SOL)** | `HTgZhMCd5pf474macjkHhrrJmQhczGPfrGwNaRFL7Pqc` |
| **Ethereum (ETH)** | `0x51c356fb219117e388b85c5fa734e6ae1a3f8df6` |

---

✨ Even the smallest support means something —  
not because of the money…  
but because it tells me:

> **"Someone out there believes in this project."**

Thank you for being here —  
and thank you for keeping the Ghost alive 👻💙

---

👤 Author & Contact

Built by:
💙 Nishant Sarkar — aka NABORAJ SARKAR 

📧 Email (Business): nishant.ns.business@gmail.com

🌐 Website: https://nsgamming.xyz

🐙 GitHub: https://github.com/ns-gamming

▶️ YouTube: https://youtube.com/@Nishant_sarkar

✈️ Telegram: https://t.me/nsgamming69

📸 Instagram: https://instagram.com/nishant_sarkar__10k

𝕏 Twitter: https://x.com/NSGAMMING699



---

🏷 License

This project is licensed under the MIT License.
You are free to use, modify, and redistribute — as long as proper credit is given.


---

<div align="center">⭐ If this project helped you —

PLEASE STAR ⭐ THE REPOSITORY

<br>💙 Stay Anonymous
💙 Stay Secure
💙 Stay Ghost 👻

</div>

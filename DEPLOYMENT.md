# AuraMusic Deployment Guide 🚀

Here is the step-by-step guide to deploy **AuraMusic** live for the public on Web and Android.

---

## 🌐 Option 1: Free 1-Click Cloud Web Deployment (Render / Railway)

### Method A: Render (Free Cloud Hosting)
1. Create a free account at [render.com](https://render.com).
2. Push your project to GitHub.
3. Click **New +** -> **Web Service**.
4. Connect your GitHub repository.
5. Set:
   - **Environment**: `Docker` (Render will automatically detect the [`Dockerfile`](Dockerfile)).
   - **Plan**: Free.
6. Click **Deploy Web Service**.
7. In ~2 minutes, your music app is live at `https://your-app-name.onrender.com`!

### Method B: Railway (Free & Fast)
1. Sign up at [railway.app](https://railway.app).
2. Click **New Project** -> **Deploy from GitHub repo**.
3. Select your repository.
4. Railway will automatically build the `Dockerfile` and give you a public URL (e.g. `https://auramusic.up.railway.app`).

---

## 📱 Option 2: Android Phone Distribution

### Method A: Direct APK Installation (Immediate)
1. Copy the release APK file: [`build/app/outputs/flutter-apk/app-release.apk`](build/app/outputs/flutter-apk/app-release.apk) (25.3 MB).
2. Send it to your phone via WhatsApp, Telegram, Google Drive, or USB cable.
3. Tap the file on your Android phone to install and start listening!

### Method B: GitHub Releases (Public Download Link)
1. Go to your GitHub repository -> **Releases** -> **Draft a new release**.
2. Tag version (e.g. `v1.0.0`).
3. Drag and drop `app-release.apk` into the release assets.
4. Publish! Anyone can download the app from your GitHub page.

---

## 💻 Option 3: Local Network Hosting (For Wi-Fi Devices)

To stream music to any phone, laptop, or smart TV connected to your local Wi-Fi:
1. Open PowerShell / Command Prompt inside the project folder:
   ```bash
   python backend/server.py 8080
   ```
2. Find your local IP address (`ipconfig` on Windows, e.g. `192.168.1.15`).
3. Open `http://192.168.1.15:8080` in the browser on any phone or laptop connected to the same Wi-Fi!

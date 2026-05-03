# 🚀 LifeFlow Premium Setup Guide

This guide will help you get the **LifeFlow Premium Intelligence Platform** running on a new system after cloning from GitHub.

## 1. Prerequisites
- **Java JDK 8 or 11**: The project is optimized for Java 8.
- **Maven 3.x**: For dependency management and running the server.
- **Firebase Account**: You need a Firestore database.
- **Gmail Account**: For sending emergency notifications.

---

## 2. Security: Restoration of Private Files
Since this project follows security best practices, sensitive credentials were **not** pushed to GitHub. You must manually recreate/restore these files:

### A. Firebase Service Account (`.json`)
1. Go to [Firebase Console](https://console.firebase.google.com/).
2. Project Settings > Service Accounts > Generate New Private Key.
3. Rename the downloaded file to:  
   `lifeflow-30d1a-firebase-adminsdk-fbsvc-387a43696d.json`
4. Place this file in the `backend/` directory.

### B. Configuration (`config.properties`)
1. Create a file named `config.properties` in `backend/src/`.
2. Paste the following template and fill in your details:
```properties
# LifeFlow Email Configuration
gmail.username=your-email@gmail.com
gmail.password=your-app-password
gmail.from.name=LifeFlow Emergency Center

# Firebase Configuration
firebase.service.account.filename=lifeflow-30d1a-firebase-adminsdk-fbsvc-387a43696d.json
fcm.server.key=YOUR_FCM_KEY
```
> **Note**: For Gmail, you must use an **App Password**, not your regular login password.

---

## 3. Database Seeding (Optional)
If your Firestore is empty, you can initialize it by:
1. Running the server (see below).
2. Navigating to `http://localhost:9090/blood-bank/seed_subscribers.jsp` (or similar utility pages in the root) to populate initial metadata.

---

## 4. Running the Project
Open your terminal in the `backend/` folder and run:

```bash
# 1. Compile the project
mvn clean compile

# 2. Start the Premium Intelligence Platform
mvn jetty:run
```

---

## 5. Accessing the Platform
- **URL**: `http://localhost:9090/blood-bank`
- **Default Admin**: `admin@lifeflow.com` / `Admin@123` (Assuming DB is seeded).

---
**Security Reminder**: Never commit your `config.properties` or `.json` files to any public repository!

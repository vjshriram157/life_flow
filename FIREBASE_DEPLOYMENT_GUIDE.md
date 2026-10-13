# 🚀 Deploying LifeFlow to Firebase (Firebase Hosting + Cloud Run)

Because **LifeFlow** is a dynamic Java EE application (Java Servlets + `.jsp` templates running on Jetty), it requires a server runtime. 

The official, production-grade way to host dynamic Java/containerized apps on Firebase is:
> **Firebase Hosting** (Front-door CDN / Custom Domain `*.web.app`)  
> └── **Rewrites to Google Cloud Run** (Running your Docker container on Google's serverless infrastructure under the same Firebase project).

---

## 📋 What Has Already Been Configured in this Repository

1. **`Dockerfile`**: Enhanced with dynamic port binding (`$PORT`) required by Google Cloud Run.
2. **`firebase.json`**: Configured with a rewrite rule directing all web traffic (`**`) to the Cloud Run service named `lifeflow` in region `us-central1`.
3. **`.firebaserc`**: Set default project ID to `lifeflow-30d1a` (update this if your project ID is different).
4. **`public/`**: Created fallback directory required by Firebase CLI.

---

## 🛠️ Step-by-Step Deployment (Choose your preferred method)

### Method 1: Google Cloud Console (Fastest & Easiest — No Local Tools Needed)

Since Firebase and Google Cloud share the exact same projects:

1. **Log in to Google Cloud Console**:
   - Go to [Google Cloud Run Console](https://console.cloud.google.com/run).
   - Ensure your Firebase project (`lifeflow-30d1a` or your own project) is selected in the top dropdown.

2. **Create Service**:
   - Click **"Create Service"**.
   - Choose **"Continuously deploy from a repository"** (Set up with Cloud Build).
   - Connect your GitHub account and select your repository: `vjshriram157/life_flow`.
   - Branch: `^main$`.
   - Build Type: **Dockerfile** (path: `/Dockerfile`).
   - Service Name: `lifeflow`.
   - Region: `us-central1` (matching `firebase.json`).
   - Authentication: Check **"Allow unauthenticated invocations"**.

3. **Configure Environment Variables**:
   - Click **"Container, Volumes, Networking, Security"** > **Container**.
   - Under **Environment variables**, add:
     - `FIREBASE_CONFIG`: *(Paste the entire contents of your service account `.json` key)*
     - `GEMINI_API_KEY`: *(Your Gemini AI API key)*
     - `PORT`: `8080`

4. **Click "Create"**:
   - Google will build your Docker container in the cloud and deploy it!

5. **Deploy Firebase Hosting Rewrites**:
   Once Cloud Run is live, connect your Firebase domain (`*.web.app`):
   ```bash
   npx firebase-tools login
   npx firebase-tools deploy --only hosting
   ```
   Your app will now be live on `https://<your-project-id>.web.app`!

---

### Method 2: Command Line (Using `gcloud` CLI)

If you have `gcloud` installed:

1. **Build and deploy the container to Cloud Run**:
   ```bash
   gcloud run deploy lifeflow \
     --source . \
     --project lifeflow-30d1a \
     --region us-central1 \
     --allow-unauthenticated
   ```

2. **Deploy Firebase Hosting**:
   ```bash
   npx firebase-tools deploy --only hosting
   ```

---

## 💡 Checking Logs & Monitoring
- **Realtime Server Logs**: Go to [Cloud Run Logs](https://console.cloud.google.com/run) -> click `lifeflow` -> **Logs**.
- **Firebase Hosting Analytics**: Available in the [Firebase Console](https://console.firebase.google.com/) under **Hosting**.
